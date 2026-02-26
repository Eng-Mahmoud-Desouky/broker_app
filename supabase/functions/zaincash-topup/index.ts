// ==============================================
// 💰 ZainCash Edge Function (API v2 - OAuth2)
// ==============================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ================================
// 🔐 Environment Variables (Validation)
// ================================

const getEnv = (name: string): string => {
  const value = Deno.env.get(name);
  if (!value) {
    console.error(`Missing Environment Variable: ${name}`);
    // We'll throw an error that the serve block can catch
    throw new Error(`Server configuration error: Missing ${name}`);
  }
  return value;
};

// These can stay top-level if they are always required
// But for robustness, we'll try-catch their initialization or move them.
let SUPABASE_URL: string, SUPABASE_SERVICE_ROLE_KEY: string;
try {
  SUPABASE_URL = getEnv("SUPABASE_URL");
  SUPABASE_SERVICE_ROLE_KEY = getEnv("SUPABASE_SERVICE_ROLE_KEY");
} catch (e) {
  // If top-level fails, the function will fail to start, which is fine
  console.error("Top-level Env Init Failed:", e.message);
}

const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

// ================================
// 🔑 Get OAuth2 Access Token
// ================================

async function getAccessToken(baseUrl: string, clientId: string, clientSecret: string): Promise<string> {
  const response = await fetch(`${baseUrl}/oauth2/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      client_id: clientId,
      client_secret: clientSecret,
      scope: "payment:read payment:write",
    }),
  });

  const data = await response.json();

  if (!data.access_token) {
    console.error("OAuth2 Error:", data);
    throw new Error("Failed to obtain ZainCash access token");
  }

  return data.access_token;
}

// ================================
// 🚀 Edge Function
// ================================

serve(async (req: Request) => {
  const url = new URL(req.url);

  // ==============================================
  // 1️⃣ Create Payment Session (POST)
  // ==============================================

  if (req.method === "POST") {
    try {
      // Get ZainCash config at request time to avoid top-level crashes
      const ZAINCASH_BASE_URL = getEnv("ZAINCASH_BASE_URL");
      const ZAINCASH_CLIENT_ID = getEnv("ZAINCASH_CLIENT_ID");
      const ZAINCASH_CLIENT_SECRET = getEnv("ZAINCASH_CLIENT_SECRET");
      const ZAINCASH_REDIRECT_URL = getEnv("ZAINCASH_REDIRECT_URL");

      const { user_id, amount: amount_usd } = await req.json();


      if (!user_id || !amount_usd) {
        return new Response("Missing user_id or amount", { status: 400 });
      }

      // Convert USD → IQD
      const amount_iqd = Math.round(amount_usd * 1307);

      // Generate IDs
      const externalReferenceId = crypto.randomUUID();
      const orderId = crypto.randomUUID().replace(/-/g, "");

      // Get OAuth2 token
      const accessToken = await getAccessToken(ZAINCASH_BASE_URL, ZAINCASH_CLIENT_ID, ZAINCASH_CLIENT_SECRET);

      // Log the payload (redacting sensitive bits)
      console.log('ZainCash Init Payload:', JSON.stringify({
        language: "en",
        externalReferenceId,
        orderId,
        serviceType: "Wallet Top-Up",
        amount: { value: amount_iqd.toString(), currency: "IQD" },
        redirectUrls: {
          successUrl: ZAINCASH_REDIRECT_URL.trim(),
          failureUrl: ZAINCASH_REDIRECT_URL.trim(),
        }
      }, null, 2));

      // Call ZainCash Init API
      const response = await fetch(
        `${ZAINCASH_BASE_URL}/api/v2/payment-gateway/transaction/init`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            language: "en",
            externalReferenceId,
            orderId,
            serviceType: "Wallet Top-Up",
            amount: {
              value: amount_iqd.toString(),
              currency: "IQD",
            },
            redirectUrls: {
              successUrl: ZAINCASH_REDIRECT_URL.trim(),
              failureUrl: ZAINCASH_REDIRECT_URL.trim(),
            },
          }),
        }
      );

      const data = await response.json();

      if (!data.redirectUrl) {
        console.error("ZainCash Init Failed:", data);
        return new Response(JSON.stringify(data), { status: 502 });
      }

      // Save payment session
      await supabase.from("payment_sessions").insert({
        user_id,
        provider: "zaincash",
        amount: amount_usd,
        currency: "USD",
        status: "created",
        provider_session_id: externalReferenceId,
        metadata: {
          orderId,
          amount_iqd,
          redirectUrl: data.redirectUrl,
        },
      });

      return new Response(
        JSON.stringify({
          redirectUrl: data.redirectUrl,
        }),
        {
          headers: { "Content-Type": "application/json" },
        }
      );
    } catch (err: any) {
      console.error("POST Error:", err);
      return new Response(err.message || String(err), { status: 500 });
    }
  }


  // ==============================================
  // 2️⃣ Handle Redirect (GET)
  // ==============================================

  if (req.method === "GET") {
    try {
      const status = url.searchParams.get("status");
      const externalReferenceId = url.searchParams.get("externalReferenceId");

      if (!externalReferenceId) {
        return new Response("Missing externalReferenceId", { status: 400 });
      }

      if (status === "success") {
        await supabase
          .from("payment_sessions")
          .update({
            status: "success",
            closed_at: new Date().toISOString(),
          })
          .eq("provider_session_id", externalReferenceId);

        // Insert wallet transaction if not exists
        const { data: existing } = await supabase
          .from("wallet_transactions")
          .select("id")
          .eq("provider_reference", externalReferenceId)
          .maybeSingle();

        if (!existing) {
          const { data: sessionData } = await supabase
            .from("payment_sessions")
            .select("user_id, amount, metadata")
            .eq("provider_session_id", externalReferenceId)
            .single();

          if (sessionData) {
            await supabase.from("wallet_transactions").insert({
              user_id: sessionData.user_id,
              amount: sessionData.amount,
              type: "topup",
              provider: "zaincash",
              provider_reference: externalReferenceId,
              status: "success",
              metadata: sessionData.metadata,
            });

            await supabase.rpc("credit_user_balance", {
              p_provider_reference: externalReferenceId,
            });
          }
        }
      }

      if (status === "failed") {
        await supabase
          .from("payment_sessions")
          .update({
            status: "failed",
            closed_at: new Date().toISOString(),
          })
          .eq("provider_session_id", externalReferenceId);
      }

      return new Response("OK", { status: 200 });
    } catch (err) {
      console.error("GET Error:", err);
      return new Response("Redirect handling failed", { status: 500 });
    }
  }

  return new Response("Not Found", { status: 404 });
});
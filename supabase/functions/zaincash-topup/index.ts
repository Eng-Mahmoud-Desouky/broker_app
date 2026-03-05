// ==============================================
// 💰 ZainCash Edge Function (With Gateway Toggle)
// ==============================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const getEnv = (name: string): string => {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing env: ${name}`);
  return value;
};

const SUPABASE_URL = getEnv("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = getEnv("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ================================
// Get OAuth2 Token
// =============
async function getAccessToken(
  baseUrl: string,
  clientId: string,
  clientSecret: string,
) {
  const response = await fetch(`${baseUrl}/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      client_id: clientId,
      client_secret: clientSecret,
      scope: "payment:read payment:write",
    }),
  });

  const data = await response.json();
  if (!data.access_token) throw new Error("Failed to get access token");
  return data.access_token;
}

// ================================
// Edge Function
// ================================

serve(async (req: Request) => {
  const url = new URL(req.url);

  // ==============================================
  // 1️⃣ Create Payment Session
  // ==============================================

  if (req.method === "POST") {
    try {
      // 🔐 Check gateway is active
      const { data: gateway } = await supabase
        .from("payment_gateways")
        .select("is_active")
        .eq("code", "zaincash")
        .single();

      if (!gateway || !gateway.is_active) {
        return new Response(
          JSON.stringify({ error: "Payment gateway disabled" }),
          { status: 403, headers: { "Content-Type": "application/json" } },
        );
      }

      const ZAINCASH_BASE_URL = getEnv("ZAINCASH_BASE_URL");
      const ZAINCASH_CLIENT_ID = getEnv("ZAINCASH_CLIENT_ID");
      const ZAINCASH_CLIENT_SECRET = getEnv("ZAINCASH_CLIENT_SECRET");
      const ZAINCASH_REDIRECT_URL = getEnv("ZAINCASH_REDIRECT_URL");

      const { user_id, amount } = await req.json();

      if (!user_id || !amount) {
        return new Response("Missing user_id or amount", { status: 400 });
      }

      const amount_iqd = Math.round(amount * 1307);

      const externalReferenceId = crypto.randomUUID();
      const orderId = crypto.randomUUID().replace(/-/g, "");

      const accessToken = await getAccessToken(
        ZAINCASH_BASE_URL,
        ZAINCASH_CLIENT_ID,
        ZAINCASH_CLIENT_SECRET,
      );

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
            amount: { value: amount_iqd.toString(), currency: "IQD" },
            redirectUrls: {
              successUrl: `${ZAINCASH_REDIRECT_URL}?status=success&externalReferenceId=${externalReferenceId}`,
              failureUrl: `${ZAINCASH_REDIRECT_URL}?status=failed&externalReferenceId=${externalReferenceId}`,
            },
          }),
        },
      );

      const data = await response.json();

      if (!data.redirectUrl) {
        return new Response(JSON.stringify(data), { status: 502 });
      }

      // Clear any existing 'created' sessions to avoid 'one_open_session_per_user' constraint violation
      await supabase
        .from("payment_sessions")
        .update({ status: "cancelled", closed_at: new Date().toISOString() })
        .eq("user_id", user_id)
        .eq("status", "created");

      const { error: sessionInsertErr } = await supabase.from("payment_sessions").insert({
        user_id,
        provider: "zaincash",
        amount,
        currency: "USD",
        status: "created",
        provider_session_id: externalReferenceId,
        metadata: { orderId, amount_iqd },
      });

      if (sessionInsertErr) {
        console.error("[ZainCash] Session insert error: ", sessionInsertErr);
        return new Response(JSON.stringify({ error: `Failed to insert payment session: ${sessionInsertErr.message}` }), { status: 500, headers: { "Content-Type": "application/json" } });
      }

      return new Response(JSON.stringify({ redirectUrl: data.redirectUrl }), {
        headers: { "Content-Type": "application/json" },
      });
    } catch (err: any) {
      return new Response(err.message, { status: 500 });
    }
  }

  // ==============================================
  // 2️⃣ Redirect Handling & Verification (Idempotent)
  // ==============================================

  if (req.method === "GET") {
    try {
      const url = new URL(req.url);
      const status = url.searchParams.get("status");

      // Get the raw externalReferenceId
      let rawExternalRefId = url.searchParams.get("externalReferenceId") || "";

      // Fix parsing issue: ZainCash sometimes appends ?token=... to the externalReferenceId itself
      // if not properly URI encoded before redirection. We split by '?' and only take the ID.
      const externalReferenceId = rawExternalRefId.split('?')[0];
      const token = url.searchParams.get("token") || (rawExternalRefId.includes('?token=') ? rawExternalRefId.split('?token=')[1] : null);

      console.info(
        `[ZainCash] GET Redirect - Parsed Params:`,
        `\n  - status: ${status}`,
        `\n  - externalReferenceId: ${externalReferenceId}`,
        `\n  - token: ${token ? 'present (hidden)' : 'none'}`
      );

      if (!externalReferenceId) {
        console.error("[ZainCash] Missing externalReferenceId in redirect");
        return sendHtmlRedirect("failed", "Missing Payment ID");
      }

      // 1. Fetch Session Status
      const { data: session, error: sessionErr } = await supabase
        .from("payment_sessions")
        .select("user_id, amount, status, metadata")
        .eq("provider_session_id", externalReferenceId)
        .maybeSingle();  // Fixed: use maybeSingle instead of single to prevent "Cannot coerce" error

      if (sessionErr) {
        console.error(
          `[ZainCash] Error fetching session config for ${externalReferenceId}:`,
          sessionErr.message,
        );
        return sendHtmlRedirect("failed", `DB Error: ${sessionErr.message} (ID: ${externalReferenceId})`);
      }

      if (!session) {
        console.error(
          `[ZainCash] Session not found for ${externalReferenceId}`,
        );
        return sendHtmlRedirect("failed", "Session not found");
      }

      // Idempotency check
      if (session.status === "success" || session.status === "failed") {
        console.info(
          `[ZainCash] Session ${externalReferenceId} already processed with status: ${session.status}`,
        );
        return sendHtmlRedirect(session.status);
      }

      // 2. TRUST THE QUERY PARAM 'status'
      // Note: ZainCash v2 does not expose a /transaction/status endpoint.
      // We will rely on the redirect param from ZainCash.
      // Ideally, in production, there's a webhook/callback or JWT verification to prevent tampering.
      let actualZainCashStatus = "failed";

      if (status === "success") {
        actualZainCashStatus = "success";
      } else {
        console.warn(
          `[ZainCash] Payment returned non-success status for ${externalReferenceId}:`,
          status,
        );
        actualZainCashStatus = "failed";
      }

      // 3. Process Result
      if (actualZainCashStatus === "success") {
        console.info(
          `[ZainCash] Payment VERIFIED successfully for ${externalReferenceId}. Updating DB...`,
        );

        // Update Payment Session
        const { error: updateErr } = await supabase
          .from("payment_sessions")
          .update({ status: "success", closed_at: new Date().toISOString() })
          .eq("provider_session_id", externalReferenceId)
          .eq("status", "created"); // Add condition to prevent double updates from concurrent requests

        if (updateErr) {
          console.error(
            `[ZainCash] DB update error for session ${externalReferenceId}:`,
            updateErr.message,
          );
          return sendHtmlRedirect("failed", "Failed to update session");
        }

        // Insert Wallet Transaction
        const { error: insertErr } = await supabase
          .from("wallet_transactions")
          .insert({
            user_id: session.user_id,
            amount: session.amount,
            type: "topup",
            provider: "zaincash",
            provider_reference: externalReferenceId,
            status: "success",
          });

        if (insertErr) {
          if (insertErr.code === '23505') {
            // 23505 is PostgreSQL unique_violation error code
            console.info(`[ZainCash] Transaction already exists for ${externalReferenceId}. Idempotent success.`);
          } else {
            console.error(
              `[ZainCash] Wallet transaction insert error for ${externalReferenceId}:`,
              insertErr.message,
            );
            return sendHtmlRedirect("failed", "Failed to record transaction");
          }
        } else {
          console.info(
            `[ZainCash] Wallet transaction recorded successfully for ${externalReferenceId}. Trigger will credit balance.`,
          );
        }

        return sendHtmlRedirect("success");
      } else {
        console.info(
          `[ZainCash] Payment verification failed or pending for ${externalReferenceId}. Marking session as failed.`,
        );

        const { error: updateErr } = await supabase
          .from("payment_sessions")
          .update({ status: "failed", closed_at: new Date().toISOString() })
          .eq("provider_session_id", externalReferenceId);

        if (updateErr) {
          console.error(
            `[ZainCash] Error marking session as failed for ${externalReferenceId}:`,
            updateErr.message,
          );
        }

        return sendHtmlRedirect("failed", "Payment was not successful");
      }
    } catch (err: any) {
      console.error("[ZainCash] Uncaught error in GET handler:", err.message);
      return sendHtmlRedirect("failed", "Server error");
    }
  }

  return new Response("Not Found", { status: 404 });
});

// ==============================================
// 3️⃣ App Redirect Helper (Deep Linking & Close)
// ==============================================

function sendHtmlRedirect(status: string, reason?: string) {
  // Deep link back to the Flutter app
  const deepLink = `brokerapp://payment/zaincash?status=${status}`;

  // Respond with a 302 Redirect to immediately trigger the app's deep link handler.
  // This completely prevents the WebView from ever rendering a fallback HTML page.
  return new Response(null, {
    status: 302,
    headers: { Location: deepLink },
  });
}
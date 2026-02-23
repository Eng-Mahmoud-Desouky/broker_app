// ==============================================
// 💰 ZainCash Edge Function for Supabase Wallet
// ==============================================
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as jose from "https://deno.land/x/jose@v4.14.4/index.ts";
// Load environment variables
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const ZAINCASH_MERCHANT_ID = Deno.env.get("ZAINCASH_MERCHANT_ID");
const ZAINCASH_MSISDN = Deno.env.get("ZAINCASH_MSISDN");
const ZAINCASH_SECRET = Deno.env.get("ZAINCASH_SECRET");
const ZAINCASH_REDIRECT_URL = Deno.env.get("ZAINCASH_REDIRECT_URL");
const IS_PRODUCTION = false; // use true when going live
const ZAINCASH_API = IS_PRODUCTION ? "https://api.zaincash.iq/transaction/init" : "https://test.zaincash.iq/transaction/init";
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
serve(async (req) => {
    const url = new URL(req.url);
    const path = url.pathname;
    // ==============================================
    // 1️⃣ Create Payment Session
    // ==============================================
    if (req.method === "POST") {
        try {
            const { user_id, amount: amount_usd } = await req.json();
            if (!user_id || !amount_usd) {
                return new Response("Missing user_id or amount", {
                    status: 400
                });
            }

            // Convert USD to IQD for ZainCash (1 USD = 1307 IQD)
            const amount_iqd = Math.round(amount_usd * 1307);

            // Build payload for ZainCash
            const payload = {
                user_id,
                amount: amount_iqd,
                serviceType: "Wallet Top-Up (Broker App)",
                msisdn: ZAINCASH_MSISDN,
                orderId: crypto.randomUUID(),
                redirectUrl: ZAINCASH_REDIRECT_URL,
                iat: Math.floor(Date.now() / 1000),
                exp: Math.floor(Date.now() / 1000) + 60 * 60 * 4
            };
            // Encode token
            const token = await new jose.SignJWT(payload).setProtectedHeader({
                alg: "HS256"
            }).sign(new TextEncoder().encode(ZAINCASH_SECRET));
            // Send request to ZainCash
            const response = await fetch(ZAINCASH_API, {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: new URLSearchParams({
                    token,
                    merchantId: ZAINCASH_MERCHANT_ID,
                    lang: "en"
                })
            });
            const data = await response.json();

            // 1️⃣ REMOVE the insertion into wallet_transactions.
            // 2️⃣ Instead, insert a record into payment_sessions.
            const sessionId = data.id || payload.orderId;
            await supabase.from("payment_sessions").insert({
                user_id,
                provider: "zaincash",
                amount: amount_usd,
                currency: "USD",
                status: "created",
                provider_session_id: sessionId,
                metadata: {
                    ...data,
                    amount_iqd,
                    amount_usd
                }
            });

            return new Response(JSON.stringify(data), {
                headers: {
                    "Content-Type": "application/json"
                }
            });
        } catch (err) {
            console.error(err);
            return new Response(err.message, {
                status: 500
            });
        }
    }
    // ==============================================
    // 2️⃣ Handle Redirect (Decode token)
    // ==============================================
    if (req.method === "GET") {
        const token = url.searchParams.get("token");
        console.log('Received token:', token);
        if (!token) {
            return new Response("No token provided", {
                status: 400
            });
        }
        try {
            const { payload } = await jose.jwtVerify(token, new TextEncoder().encode(ZAINCASH_SECRET));
            const result = payload as any;
            const sessionId = result.id;

            if (result.status === "success") {
                console.log('Payment success. Updating session and creating transaction...');

                // 1️⃣ Update payment_sessions set status = "success", closed_at = now()
                await supabase.from("payment_sessions")
                    .update({ status: "success", closed_at: new Date().toISOString() })
                    .eq("provider_session_id", sessionId);

                // 2️⃣ Ensure idempotency: If wallet_transactions already exists for provider_reference, skip insertion.
                const { data: existingTx } = await supabase
                    .from("wallet_transactions")
                    .select("id")
                    .eq("provider_reference", sessionId)
                    .single();

                if (!existingTx) {
                    // Fetch user_id and amount from payment_sessions if not in JWT payload (usually not)
                    const { data: sessionData } = await supabase
                        .from("payment_sessions")
                        .select("user_id, amount, metadata")
                        .eq("provider_session_id", sessionId)
                        .single();

                    if (sessionData) {
                        // 3️⃣ Insert into wallet_transactions with status = "success"
                        await supabase.from("wallet_transactions").insert({
                            user_id: sessionData.user_id,
                            amount: sessionData.amount,
                            type: "topup",
                            provider: "zaincash",
                            provider_reference: sessionId,
                            status: "success",
                            metadata: sessionData.metadata
                        });

                        // 4️⃣ Call RPC credit_user_balance
                        console.log('Calling credit_user_balance...');
                        await supabase.rpc("credit_user_balance", {
                            p_provider_reference: sessionId
                        });
                        console.log('RPC called successfully');
                    }
                }
            } else if (result.status === "failed") {
                console.log('Payment failed. Updating session status...');
                // 1️⃣ Update payment_sessions set status = "failed", closed_at = now()
                await supabase.from("payment_sessions")
                    .update({ status: "failed", closed_at: new Date().toISOString() })
                    .eq("provider_session_id", sessionId);
            }

            return new Response(JSON.stringify(result), {
                headers: {
                    "Content-Type": "application/json"
                }
            });
        } catch (err) {
            console.error("JWT Decode Error:", err);
            return new Response("Invalid token", {
                status: 400
            });
        }
    }
    // ==============================================
    // 3️⃣ Fallback (if route not found)
    // ==============================================
    return new Response("Not Found", {
        status: 404
    });
});


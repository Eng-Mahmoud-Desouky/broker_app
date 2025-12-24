import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as jose from 'https://esm.sh/jose@4.14.4'

serve(async (req) => {
    console.log("--- Edge Function Triggered ---")

    try {
        const payload = await req.json()
        console.log("Payload received:", JSON.stringify(payload, null, 2))

        const { record, table } = payload

        // 1. Initialize Supabase
        const supabaseUrl = Deno.env.get('SUPABASE_URL')
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

        if (!supabaseUrl || !supabaseServiceKey) {
            console.error("Missing Supabase environment variables")
            return new Response("Missing configuration", { status: 500 })
        }

        const supabase = createClient(supabaseUrl, supabaseServiceKey)

        let userId = ''
        let title = ''
        let body = ''

        // 2. Determine Message Content
        if (table === 'orders') {
            userId = record.user_id
            title = 'تحديث حالة الطلب'
            body = `تم تغيير حالة طلبك رقم ${record.reference_number} إلى ${record.status}`
        } else if (table === 'support_messages' && record.sender_type === 'admin') {
            userId = record.receiver_id
            title = 'رسالة جديدة من الدعم الفني'
            body = record.message
        } else {
            console.log("Ignored event: table or condition not met")
            return new Response("Condition not met", { status: 200 })
        }

        if (!userId) {
            console.error("User ID is missing in record")
            return new Response("No user ID", { status: 200 })
        }

        // 3. Get FCM Tokens
        console.log("Fetching tokens for user:", userId)
        const { data: tokens, error: tokenError } = await supabase
            .from('user_fcm_tokens')
            .select('fcm_token')
            .eq('user_id', userId)

        if (tokenError) {
            console.error("Error fetching tokens:", tokenError)
            return new Response("Error fetching tokens", { status: 500 })
        }

        if (!tokens || tokens.length === 0) {
            console.log("No FCM tokens found for this user")
            return new Response("No tokens", { status: 200 })
        }

        // 4. Authenticate with Google (FCM v1) manually using JWT
        const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
        if (!serviceAccountRaw) {
            console.error("FIREBASE_SERVICE_ACCOUNT secret is missing")
            return new Response("Missing Firebase Service Account", { status: 500 })
        }

        const serviceAccount = JSON.parse(serviceAccountRaw)

        console.log("Generating Google Access Token using JWT...")
        const jwt = await new jose.SignJWT({
            scope: 'https://www.googleapis.com/auth/firebase.messaging',
        })
            .setProtectedHeader({ alg: 'RS256' })
            .setIssuer(serviceAccount.client_email)
            .setAudience('https://oauth2.googleapis.com/token')
            .setExpirationTime('1h')
            .setIssuedAt()
            .sign(await jose.importPKCS8(serviceAccount.private_key, 'RS256'))

        const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                assertion: jwt,
            }),
        })

        const tokenData = await tokenRes.json()
        const accessToken = tokenData.access_token

        if (!accessToken) {
            console.error("Failed to obtain access token:", tokenData)
            return new Response("Auth failed", { status: 500 })
        }

        console.log("Access Token obtained successfully")

        const PROJECT_ID = serviceAccount.project_id
        const FCM_URL = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`

        // 5. Send Notification via FCM
        const sendPromises = tokens.map(async (t) => {
            console.log("Sending to token starting with:", t.fcm_token.substring(0, 10))
            const res = await fetch(FCM_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${accessToken}`
                },
                body: JSON.stringify({
                    message: {
                        token: t.fcm_token,
                        notification: { title, body },
                        data: {
                            click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            type: table
                        }
                    }
                })
            })
            return res.json()
        })

        const results = await Promise.all(sendPromises)
        console.log("FCM Responses:", JSON.stringify(results))

        // 6. Save to History (app_notifications table)
        console.log("Saving notification to history...")
        const { error: historyError } = await supabase
            .from('app_notifications')
            .insert({
                user_id: userId,
                title: title,
                body: body,
                type: table,
                data: record
            })

        if (historyError) {
            console.error("Error saving to history:", historyError)
        } else {
            console.log("Saved to history successfully")
        }

        return new Response('Success', { status: 200 })
    } catch (error) {
        console.error('CRITICAL ERROR:', error.message)
        return new Response(JSON.stringify({ error: error.message }), { status: 500 })
    }
})

-- ==============================================================
-- Migration: Add trigger for safe wallet logic
-- Description: Increment/Decrement the wallet balance based on 
--              successful transaction records.
-- ==============================================================

-- 1. Create the Wallet Trigger Function
CREATE OR REPLACE FUNCTION process_wallet_transaction()
RETURNS TRIGGER AS $$
BEGIN
    -- Only act on successful transactions
    IF NEW.status = 'success' THEN
        -- Handle 'topup' or 'refund' by adding to the wallet
        IF NEW.type IN ('topup', 'refund') THEN
            UPDATE public.wallets
            SET 
                balance = balance + NEW.amount,
                updated_at = NOW()
            WHERE user_id = NEW.user_id;
            
            -- Optional: If the user wallet doesn't exist, create it (Upsert logic)
            IF NOT FOUND THEN
                INSERT INTO public.wallets (user_id, balance, updated_at)
                VALUES (NEW.user_id, NEW.amount, NOW());
            END IF;
            
        -- Handle 'purchase' by deducting from the wallet
        ELSIF NEW.type = 'purchase' THEN
            UPDATE public.wallets
            SET 
                balance = balance - NEW.amount,
                updated_at = NOW()
            WHERE user_id = NEW.user_id;

            -- We don't insert here typically because purchases require an existing balance.
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Drop the trigger if it already exists
DROP TRIGGER IF EXISTS trg_process_wallet_transaction ON public.wallet_transactions;

-- 3. Attach the trigger to the wallet transactions table
CREATE TRIGGER trg_process_wallet_transaction
AFTER INSERT ON public.wallet_transactions
FOR EACH ROW
EXECUTE FUNCTION process_wallet_transaction();

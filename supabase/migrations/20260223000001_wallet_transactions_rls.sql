-- ===================================================================
-- 💳 Supabase RLS Policies for wallet_transactions
-- ===================================================================
-- This script enables RLS on the wallet_transactions table and 
-- allows users to view their own transactions and delete 
-- pending attempts that were cancelled.
-- ===================================================================

-- 1. Enable RLS
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies if any (to avoid duplicates)
DROP POLICY IF EXISTS "Users can view own transactions" ON public.wallet_transactions;
DROP POLICY IF EXISTS "Users can insert own transactions" ON public.wallet_transactions;
DROP POLICY IF EXISTS "Users can delete own pending transactions" ON public.wallet_transactions;

-- 3. Policy: Select (Users view own history)
CREATE POLICY "Users can view own transactions"
ON public.wallet_transactions
FOR SELECT
USING (auth.uid() = user_id);

-- 4. Policy: Insert (Allow client to record if needed, though usually handled by Edge Functions)
CREATE POLICY "Users can insert own transactions"
ON public.wallet_transactions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 5. Policy: Delete (Users can cleanup PENDING attempts)
CREATE POLICY "Users can delete own pending transactions"
ON public.wallet_transactions
FOR DELETE
USING (auth.uid() = user_id AND status = 'pending');

-- 6. Grant permissions
GRANT SELECT, INSERT, DELETE ON public.wallet_transactions TO authenticated;

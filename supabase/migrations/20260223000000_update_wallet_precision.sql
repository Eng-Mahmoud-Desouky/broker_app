-- Migration: Update wallet balance and transaction amount to numeric for USD precision
-- Created at: 2026-02-23

BEGIN;

-- 1. Update wallets table
ALTER TABLE wallets 
  ALTER COLUMN balance TYPE numeric(20, 2);

-- 2. Update wallet_transactions table
ALTER TABLE wallet_transactions 
  ALTER COLUMN amount TYPE numeric(20, 2);

-- 3. Update any views or functions that might depend on these types
-- (The RPC credit_user_balance should handle numeric automatically if it just adds the amount)

COMMIT;
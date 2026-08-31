-- Remove the constraint that limits promo code usage to once per user
ALTER TABLE public.promo_code_usages 
DROP CONSTRAINT IF EXISTS promo_code_user_unique;

-- Add a new unique constraint to prevent duplicate usage entries for the same order only
-- This allows the user to use the same promo code on different orders
ALTER TABLE public.promo_code_usages
ADD CONSTRAINT promo_code_order_unique UNIQUE (promo_code_id, order_id);

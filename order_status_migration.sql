-- ===================================================================
-- Order Status Migration - Broker App (PRODUCTION SAFE)
-- ===================================================================
-- This migration:
-- 1. Safely migrates old order statuses to the new workflow
-- 2. Uses NOT VALID constraint to avoid migration failure
-- 3. Preserves existing data
-- 4. Adds status history tracking with trigger
-- ===================================================================

BEGIN;

-- =====================================================
-- Step 0: Disable status logging trigger (if exists)
-- =====================================================
DROP TRIGGER IF EXISTS trigger_log_order_status_change ON public.orders;

-- =====================================================
-- Step 1: Drop old CHECK constraint
-- =====================================================
ALTER TABLE public.orders 
DROP CONSTRAINT IF EXISTS orders_status_check;

-- =====================================================
-- Step 2: Add new CHECK constraint (NOT VALID)
-- =====================================================
ALTER TABLE public.orders
ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  'under_review',         -- قيد المراجعة
  'purchasing',           -- قيد الشراء
  'purchased',            -- تم الشراء
  'in_china_warehouse',   -- في المخزن الصيني
  'shipping_to_iraq',     -- شحن إلى العراق
  'in_iraq_warehouse',    -- في المخزن العراقي
  'ready_for_delivery',   -- جاهز للتسليم
  'delivered',            -- تم التسليم
  'cancelled'             -- ملغي
)) NOT VALID;

-- =====================================================
-- Step 3: Update default status
-- =====================================================
ALTER TABLE public.orders 
ALTER COLUMN status SET DEFAULT 'under_review';

-- =====================================================
-- Step 4: Migrate existing order statuses
-- =====================================================
UPDATE public.orders
SET status = CASE
  WHEN status = 'pending' THEN 'under_review'
  WHEN status = 'processing' THEN 'purchasing'
  WHEN status = 'shipped' THEN 'shipping_to_iraq'
  WHEN status = 'delivered' THEN 'delivered'
  WHEN status = 'cancelled' THEN 'cancelled'
  ELSE 'under_review'
END
WHERE status IN (
  'pending',
  'processing',
  'shipped',
  'delivered',
  'cancelled'
);

-- =====================================================
-- Step 5: Validate CHECK constraint
-- =====================================================
ALTER TABLE public.orders
VALIDATE CONSTRAINT orders_status_check;

-- =====================================================
-- Step 6: Create order_status_history table
-- =====================================================
CREATE TABLE IF NOT EXISTS public.order_status_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  status text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,

  CONSTRAINT order_status_history_pkey PRIMARY KEY (id),
  CONSTRAINT order_status_history_order_id_fkey
    FOREIGN KEY (order_id)
    REFERENCES public.orders(id)
    ON DELETE CASCADE
);

-- =====================================================
-- Step 7: Index for performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id
  ON public.order_status_history(order_id);

-- =====================================================
-- Step 8: Comments
-- =====================================================
COMMENT ON TABLE public.order_status_history
IS 'History of order status changes for tracking';

-- =====================================================
-- Step 9: Enable RLS and policies
-- =====================================================
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own order status history"
ON public.order_status_history;

CREATE POLICY "Users can view own order status history"
  ON public.order_status_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.orders
      WHERE orders.id = order_status_history.order_id
        AND orders.user_id = auth.uid()
    )
  );

GRANT SELECT ON public.order_status_history TO authenticated;

-- =====================================================
-- Step 10: Create status logging trigger
-- =====================================================
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT')
     OR (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
    INSERT INTO public.order_status_history (
      order_id,
      status,
      created_by
    )
    VALUES (
      NEW.id,
      NEW.status,
      auth.uid()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_log_order_status_change
AFTER INSERT OR UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION log_order_status_change();

COMMIT;

-- ===================================================================
-- Verification (Optional)
-- ===================================================================

-- Check constraint definition
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conname = 'orders_status_check';

-- Sample recent orders
SELECT id, reference_number, status, created_at
FROM public.orders
ORDER BY created_at DESC
LIMIT 10;

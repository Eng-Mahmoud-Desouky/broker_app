-- ===================================================================
-- Supabase Schema Updates for Order System
-- ===================================================================
-- This script adds tables and modifications needed for order creation
-- system with address management and product weights
-- 
-- Execute in Supabase SQL Editor after review
-- ===================================================================

-- ===================================================================
-- 1. Create user_addresses table
-- ===================================================================
CREATE TABLE IF NOT EXISTS public.user_addresses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,                    -- اسم العنوان (مثلاً: "المنزل", "العمل")
  full_name text NOT NULL,                -- الاسم الكامل للمستلم
  phone_number text NOT NULL,
  country text NOT NULL,
  city text NOT NULL,
  state_province text,
  street_address text NOT NULL,
  building_number text,
  apartment_number text,
  postal_code text,
  is_default boolean DEFAULT false,      -- العنوان الافتراضي
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_addresses_pkey PRIMARY KEY (id),
  CONSTRAINT user_addresses_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id 
  ON public.user_addresses(user_id);

-- Add comment to table
COMMENT ON TABLE public.user_addresses IS 'User shipping addresses';

-- ===================================================================
-- 2. Create orders table
-- ===================================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  reference_number text NOT NULL UNIQUE,  -- رقم مرجعي فريد مثل ORD-20251214-00001
  
  -- Address Information (snapshot at order time)
  shipping_address jsonb NOT NULL,        -- Store complete address as JSON
  
  -- Shipping Information
  shipping_method text NOT NULL CHECK (shipping_method IN ('بحري', 'جوي')),  -- بحري = Sea, جوي = Air
  total_weight_kg decimal(10, 2) NOT NULL CHECK (total_weight_kg > 0),
  
  -- Pricing
  total_price decimal(15, 2),
  currency text DEFAULT 'USD',
  
  -- Order Status
  status text NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  
  -- Timestamps
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users(id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id 
  ON public.orders(user_id);

CREATE INDEX IF NOT EXISTS idx_orders_reference_number 
  ON public.orders(reference_number);

CREATE INDEX IF NOT EXISTS idx_orders_status 
  ON public.orders(status);

CREATE INDEX IF NOT EXISTS idx_orders_created_at 
  ON public.orders(created_at DESC);

-- Add comment to table
COMMENT ON TABLE public.orders IS 'Customer orders with shipping and status tracking';

-- ===================================================================
-- 3. Create order_items table
-- ===================================================================
CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  
  -- Product Information (snapshot at order time)
  product_name text NOT NULL,
  product_url text NOT NULL,
  platform text NOT NULL,
  price text NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  weight_kg decimal(10, 2) NOT NULL CHECK (weight_kg > 0),
  image_url text,
  metadata jsonb,                        -- For any additional information
  
  created_at timestamp with time zone DEFAULT now(),
  
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) 
    REFERENCES public.orders(id) ON DELETE CASCADE
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_order_items_order_id 
  ON public.order_items(order_id);

-- Add comment to table
COMMENT ON TABLE public.order_items IS 'Items within each order';

-- ===================================================================
-- 4. Modify cart_items table (Weight Solution 1)
-- ===================================================================
-- Only execute this if you chose Solution 1 for weight handling
-- Comment out if choosing Solution 2 or 3

-- NOTE: weight_kg is NULLABLE to not affect WebView product scraping
-- Users can fill in weight later before creating order
DO $$ 
BEGIN
  -- Check if column doesn't exist before adding
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'cart_items' 
    AND column_name = 'weight_kg'
  ) THEN
    ALTER TABLE public.cart_items 
    ADD COLUMN weight_kg decimal(10, 2) CHECK (weight_kg IS NULL OR weight_kg > 0);
    
    COMMENT ON COLUMN public.cart_items.weight_kg IS 'Product weight in kilograms (nullable - can be filled before order)';
  END IF;
END $$;

-- ===================================================================
-- 5. Modify products table (Weight Solution 2)
-- ===================================================================
-- Only execute this if you chose Solution 2 for weight handling
-- Comment out if choosing Solution 1 or 3

-- DO $$ 
-- BEGIN
--   -- Check if column doesn't exist before adding
--   IF NOT EXISTS (
--     SELECT 1 FROM information_schema.columns 
--     WHERE table_schema = 'public' 
--     AND table_name = 'products' 
--     AND column_name = 'weight_kg'
--   ) THEN
--     ALTER TABLE public.products 
--     ADD COLUMN weight_kg decimal(10, 2) CHECK (weight_kg > 0);
--     
--     COMMENT ON COLUMN public.products.weight_kg IS 'Product weight in kilograms';
--   END IF;
-- END $$;

-- ===================================================================
-- 6. Create function to generate reference numbers
-- ===================================================================
CREATE OR REPLACE FUNCTION generate_order_reference()
RETURNS text AS $$
DECLARE
  today_date text;
  sequence_num integer;
  reference_num text;
BEGIN
  -- Get today's date in YYYYMMDD format
  today_date := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
  
  -- Get count of orders created today + 1
  SELECT COUNT(*) + 1 INTO sequence_num
  FROM public.orders
  WHERE DATE(created_at) = CURRENT_DATE;
  
  -- Format: ORD-YYYYMMDD-XXXXX
  reference_num := 'ORD-' || today_date || '-' || LPAD(sequence_num::text, 5, '0');
  
  RETURN reference_num;
END;
$$ LANGUAGE plpgsql;

-- Add comment to function
COMMENT ON FUNCTION generate_order_reference() IS 'Generate unique order reference number';

-- ===================================================================
-- 7. Create trigger to auto-generate reference numbers
-- ===================================================================
CREATE OR REPLACE FUNCTION set_order_reference()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reference_number IS NULL OR NEW.reference_number = '' THEN
    NEW.reference_number := generate_order_reference();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS trigger_set_order_reference ON public.orders;

CREATE TRIGGER trigger_set_order_reference
  BEFORE INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION set_order_reference();

-- ===================================================================
-- 8. Create trigger for updated_at timestamp on user_addresses
-- ===================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_addresses_updated_at ON public.user_addresses;

CREATE TRIGGER update_user_addresses_updated_at
  BEFORE UPDATE ON public.user_addresses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ===================================================================
-- 9. Create trigger for updated_at timestamp on orders
-- ===================================================================
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ===================================================================
-- 10. Row Level Security (RLS) Policies
-- ===================================================================

-- Enable RLS on user_addresses
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;

-- Users can view only their own addresses
CREATE POLICY "Users can view own addresses"
  ON public.user_addresses
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own addresses
CREATE POLICY "Users can insert own addresses"
  ON public.user_addresses
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own addresses
CREATE POLICY "Users can update own addresses"
  ON public.user_addresses
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own addresses
CREATE POLICY "Users can delete own addresses"
  ON public.user_addresses
  FOR DELETE
  USING (auth.uid() = user_id);

-- Enable RLS on orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Users can view only their own orders
CREATE POLICY "Users can view own orders"
  ON public.orders
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own orders
CREATE POLICY "Users can insert own orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own orders (limited fields)
CREATE POLICY "Users can update own orders"
  ON public.orders
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Enable RLS on order_items
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Users can view order_items for their own orders
CREATE POLICY "Users can view own order items"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Users can insert order_items for their own orders
CREATE POLICY "Users can insert own order items"
  ON public.order_items
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- ===================================================================
-- 11. Grant necessary permissions
-- ===================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on user_addresses
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_addresses TO authenticated;
GRANT SELECT ON public.user_addresses TO anon;

-- Grant permissions on orders
GRANT SELECT, INSERT, UPDATE ON public.orders TO authenticated;
GRANT SELECT ON public.orders TO anon;

-- Grant permissions on order_items
GRANT SELECT, INSERT ON public.order_items TO authenticated;
GRANT SELECT ON public.order_items TO anon;

-- ===================================================================
-- 12. Sample data (optional - for testing)
-- ===================================================================

-- Uncomment the following to insert sample data for testing
/*
-- Insert sample address
INSERT INTO public.user_addresses (
  user_id, 
  name, 
  full_name, 
  phone_number, 
  country, 
  city, 
  street_address,
  is_default
) VALUES (
  auth.uid(),
  'المنزل',
  'محمود الدسوقي',
  '+964 770 123 4567',
  'العراق',
  'بغداد',
  'شارع الرشيد، بناية 10، شقة 5',
  true
);
*/

-- ===================================================================
-- End of migration script
-- ===================================================================

-- Verify tables were created
SELECT 
  schemaname, 
  tablename, 
  tableowner
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('user_addresses', 'orders', 'order_items')
ORDER BY tablename;

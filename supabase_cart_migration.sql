-- =====================================================
-- Cart Items Table Migration for Supabase
-- =====================================================
-- This migration creates the cart_items table with all necessary
-- columns, indexes, and Row Level Security (RLS) policies.
-- 
-- Run this SQL in your Supabase SQL Editor
-- =====================================================

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  price TEXT NOT NULL,
  image_url TEXT,
  images JSONB,
  product_url TEXT NOT NULL,
  platform TEXT NOT NULL,
  quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
  rating TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_platform ON cart_items(platform);
CREATE INDEX IF NOT EXISTS idx_cart_items_created_at ON cart_items(created_at DESC);

-- Enable Row Level Security
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can insert to own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can update own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON cart_items;

-- Create RLS policies
-- Policy: Users can view their own cart items
CREATE POLICY "Users can view own cart items"
  ON cart_items
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert to their own cart
CREATE POLICY "Users can insert to own cart"
  ON cart_items
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own cart items
CREATE POLICY "Users can update own cart items"
  ON cart_items
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own cart items
CREATE POLICY "Users can delete own cart items"
  ON cart_items
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_cart_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
DROP TRIGGER IF EXISTS trigger_update_cart_items_updated_at ON cart_items;
CREATE TRIGGER trigger_update_cart_items_updated_at
  BEFORE UPDATE ON cart_items
  FOR EACH ROW
  EXECUTE FUNCTION update_cart_items_updated_at();

-- =====================================================
-- Optional: Sample data for testing (remove in production)
-- =====================================================
-- Uncomment the following lines to insert sample data
-- Note: Replace 'YOUR_USER_ID' with an actual user ID from auth.users

/*
INSERT INTO cart_items (user_id, product_name, price, image_url, product_url, platform, quantity, rating)
VALUES 
  (
    'YOUR_USER_ID',
    'Sample Product from Amazon',
    '$29.99',
    'https://example.com/image.jpg',
    'https://www.amazon.com/sample-product',
    'amazon',
    1,
    '4.5'
  ),
  (
    'YOUR_USER_ID',
    'Sample Product from SHEIN',
    '$15.99',
    'https://example.com/image2.jpg',
    'https://www.shein.com/sample-product',
    'shein',
    2,
    '4.0'
  );
*/

-- =====================================================
-- Verification Queries
-- =====================================================
-- Run these queries to verify the migration was successful

-- Check if table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'cart_items'
);

-- Check indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'cart_items';

-- Check RLS policies
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'cart_items';

-- =====================================================
-- Cleanup (if needed)
-- =====================================================
-- Uncomment the following lines to drop the table and all related objects
-- WARNING: This will delete all cart data!

/*
DROP TRIGGER IF EXISTS trigger_update_cart_items_updated_at ON cart_items;
DROP FUNCTION IF EXISTS update_cart_items_updated_at();
DROP TABLE IF EXISTS cart_items CASCADE;
*/


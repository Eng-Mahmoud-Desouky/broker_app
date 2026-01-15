-- Add dimensions and raw_specs columns to cart_items table
-- These are optional fields for storing product weight and dimension data

-- Add dimensions column (JSONB) to store structured dimension data
-- Expected structure: { "length": number, "width": number, "height": number, "unit": string }
ALTER TABLE public.cart_items 
ADD COLUMN IF NOT EXISTS dimensions jsonb;

-- Add raw_specs column (JSONB) to store raw text for debugging
-- Expected structure: { "weightText": string | null, "dimensionText": string | null }
ALTER TABLE public.cart_items 
ADD COLUMN IF NOT EXISTS raw_specs jsonb;

-- Add comments for documentation
COMMENT ON COLUMN public.cart_items.dimensions IS 'Product dimensions in structured format (nullable - optional metadata)';
COMMENT ON COLUMN public.cart_items.raw_specs IS 'Raw specification text for debugging (nullable - optional metadata)';

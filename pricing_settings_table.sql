-- Create a table to store system-wide pricing and commission settings
CREATE TABLE IF NOT EXISTS public.pricing_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    broker_commission_percent numeric NOT NULL DEFAULT 5.0, -- Percentage
    air_freight_price_per_kg numeric NOT NULL DEFAULT 10.0, -- USD
    sea_freight_price_per_kg numeric NOT NULL DEFAULT 5.0,  -- USD
    updated_at timestamp with time zone DEFAULT now(),
    updated_by uuid REFERENCES auth.users(id)
);

-- Insert default values if the table is empty
INSERT INTO public.pricing_settings (broker_commission_percent, air_freight_price_per_kg, sea_freight_price_per_kg)
SELECT 5.0, 10.0, 5.0
WHERE NOT EXISTS (SELECT 1 FROM public.pricing_settings);

-- Add RLS policies (adjust as needed for your project)
ALTER TABLE public.pricing_settings ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read settings
CREATE POLICY "Allow authenticated to read pricing settings"
ON public.pricing_settings FOR SELECT
TO authenticated
USING (true);

-- Allow admins (support agents) to insert settings
CREATE POLICY "Allow admins to insert pricing settings"
ON public.pricing_settings FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_support_agent = true
    )
);

-- Allow admins to update pricing settings
CREATE POLICY "Allow admins to update pricing settings"
ON public.pricing_settings FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_support_agent = true
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_support_agent = true
    )
);

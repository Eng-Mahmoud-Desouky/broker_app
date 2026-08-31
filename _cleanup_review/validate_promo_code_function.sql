-- RPC Function to validate promo code and calculate discount
-- This function checks if a promo code is valid and returns the discount details
-- without creating an order

CREATE OR REPLACE FUNCTION public.validate_promo_code(
  p_promo_code text,
  p_base_price numeric
)
RETURNS TABLE (
  is_valid boolean,
  percentage numeric,
  discount_amount numeric,
  final_price numeric,
  error_message text
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_promo_id uuid;
  v_percentage numeric;
  v_discount numeric := 0;
  v_final_price numeric;
BEGIN
  -- التحقق من كود الخصم
  SELECT id, percentage
  INTO v_promo_id, v_percentage
  FROM public.promo_codes
  WHERE code = p_promo_code
    AND is_active = true
    AND (expires_at IS NULL OR expires_at > now());

  -- إذا لم يتم العثور على الكود أو غير صالح
  IF v_promo_id IS NULL THEN
    is_valid := false;
    percentage := 0;
    discount_amount := 0;
    final_price := p_base_price;
    error_message := 'كود الخصم غير صالح أو منتهي الصلاحية';
    RETURN NEXT;
    RETURN;
  END IF;

  -- حساب الخصم
  v_discount := (p_base_price * v_percentage) / 100;
  v_final_price := p_base_price - v_discount;

  -- إرجاع النتيجة
  is_valid := true;
  percentage := v_percentage;
  discount_amount := v_discount;
  final_price := v_final_price;
  error_message := NULL;
  
  RETURN NEXT;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.validate_promo_code(text, numeric) TO authenticated;

COMMENT ON FUNCTION public.validate_promo_code IS 'Validate promo code and calculate discount without creating order';

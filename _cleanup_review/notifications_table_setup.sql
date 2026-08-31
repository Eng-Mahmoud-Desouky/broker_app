-- ===================================================================
-- Notifications Schema Setup
-- ===================================================================

-- 1. Create user_fcm_tokens table
CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  fcm_token text NOT NULL,
  device_id text, -- Optional: to distinguish between user's devices
  platform text,  -- Optional: 'android', 'ios', 'web'
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  
  CONSTRAINT user_fcm_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT user_fcm_tokens_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) ON DELETE CASCADE,
  -- Ensure unique token per user
  UNIQUE(user_id, fcm_token)
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Users can only see their own tokens
CREATE POLICY "Users can view own tokens"
  ON public.user_fcm_tokens
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own tokens
CREATE POLICY "Users can insert own tokens"
  ON public.user_fcm_tokens
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tokens (e.g., on logout)
CREATE POLICY "Users can delete own tokens"
  ON public.user_fcm_tokens
  FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Create trigger to update updated_at
-- This uses the same function created in orders migration
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_user_fcm_tokens_updated_at') THEN
    CREATE TRIGGER update_user_fcm_tokens_updated_at
      BEFORE UPDATE ON public.user_fcm_tokens
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 5. Grant permissions
GRANT SELECT, INSERT, DELETE ON public.user_fcm_tokens TO authenticated;

COMMENT ON TABLE public.user_fcm_tokens IS 'Stores Firebase Cloud Messaging tokens for users to enable push notifications.';

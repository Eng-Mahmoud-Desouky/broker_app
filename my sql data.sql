-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.cart_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  product_name text NOT NULL,
  price text NOT NULL,
  image_url text,
  images jsonb,
  product_url text NOT NULL,
  platform text NOT NULL,
  quantity integer DEFAULT 1 CHECK (quantity > 0),
  rating text,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  currency text DEFAULT 'USD'::text,
  description text,
  review_count text,
  CONSTRAINT cart_items_pkey PRIMARY KEY (id),
  CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.offers (
  id text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  image_url text NOT NULL,
  discount_percentage text,
  valid_until timestamp without time zone NOT NULL,
  action_url text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  start_at timestamp with time zone,
  end_at timestamp with time zone,
  priority integer NOT NULL DEFAULT 0,
  color_hex text,
  discount_percent numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT offers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.payment_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  wallet_user_id uuid NOT NULL,
  provider character varying NOT NULL CHECK (provider::text = ANY (ARRAY['zaincash'::character varying, 'kicard'::character varying]::text[])),
  amount bigint NOT NULL CHECK (amount > 0),
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying]::text[])),
  reference_id text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT payment_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT payment_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT payment_sessions_wallet_user_id_fkey FOREIGN KEY (wallet_user_id) REFERENCES public.wallets(user_id)
);
CREATE TABLE public.product_categories (
  product_id uuid NOT NULL,
  category_id uuid NOT NULL,
  CONSTRAINT product_categories_pkey PRIMARY KEY (product_id, category_id),
  CONSTRAINT product_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.product_colors (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  color_hex text NOT NULL,
  label text,
  CONSTRAINT product_colors_pkey PRIMARY KEY (id),
  CONSTRAINT product_colors_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.product_images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  image_url text NOT NULL,
  position integer DEFAULT 0,
  CONSTRAINT product_images_pkey PRIMARY KEY (id),
  CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  main_image_url text NOT NULL,
  price numeric NOT NULL,
  original_price numeric,
  currency text NOT NULL DEFAULT 'USD'::text,
  rating numeric,
  review_count integer,
  platform_id text NOT NULL,
  platform_name text NOT NULL,
  is_in_stock boolean NOT NULL DEFAULT true,
  min_order integer NOT NULL DEFAULT 1,
  specifications jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  display_name text,
  is_support_agent boolean DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.support_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  sender USER-DEFINED NOT NULL,
  body text NOT NULL,
  attachments jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  read_at timestamp with time zone,
  CONSTRAINT support_messages_pkey PRIMARY KEY (id),
  CONSTRAINT support_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.support_threads(id),
  CONSTRAINT support_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id)
);
CREATE TABLE public.support_threads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  assigned_agent_id uuid,
  subject text,
  status USER-DEFINED NOT NULL DEFAULT 'open'::support_status,
  last_message_at timestamp with time zone NOT NULL DEFAULT now(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT support_threads_pkey PRIMARY KEY (id),
  CONSTRAINT support_threads_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT support_threads_assigned_agent_id_fkey FOREIGN KEY (assigned_agent_id) REFERENCES auth.users(id)
);
CREATE TABLE public.wallet_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  amount bigint NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['topup'::text, 'purchase'::text, 'refund'::text])),
  provider text,
  provider_reference text UNIQUE,
  status text NOT NULL CHECK (status = ANY (ARRAY['pending'::text, 'success'::text, 'failed'::text])),
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT wallet_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.wallets (
  user_id uuid NOT NULL,
  balance bigint NOT NULL DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wallets_pkey PRIMARY KEY (user_id),
  CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
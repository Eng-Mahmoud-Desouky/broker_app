-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

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
  CONSTRAINT offers_pkey PRIMARY KEY (id)
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
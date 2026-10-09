-- K Mart: prevent duplicate cart rows and make add-to-cart quantity increments atomic.
-- Review this migration against your production schema and run it in Supabase SQL Editor.
-- Expected types: cart_items.id, cart_id and product_id are UUID; quantity is an integer.

BEGIN;

-- Consolidate any existing duplicate (cart_id, product_id) rows before adding uniqueness.
WITH ranked AS (
  SELECT
    id,
    cart_id,
    product_id,
    SUM(quantity) OVER (PARTITION BY cart_id, product_id) AS combined_quantity,
    ROW_NUMBER() OVER (PARTITION BY cart_id, product_id ORDER BY id::text) AS row_number
  FROM public.cart_items
)
UPDATE public.cart_items AS item
SET quantity = ranked.combined_quantity
FROM ranked
WHERE item.id = ranked.id
  AND ranked.row_number = 1;

WITH ranked AS (
  SELECT
    id,
    ROW_NUMBER() OVER (PARTITION BY cart_id, product_id ORDER BY id::text) AS row_number
  FROM public.cart_items
)
DELETE FROM public.cart_items AS item
USING ranked
WHERE item.id = ranked.id
  AND ranked.row_number > 1;

CREATE UNIQUE INDEX IF NOT EXISTS cart_items_cart_id_product_id_uidx
  ON public.cart_items (cart_id, product_id);

CREATE OR REPLACE FUNCTION public.add_to_cart_item(
  p_cart_id uuid,
  p_product_id uuid,
  p_quantity integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF p_quantity IS NULL OR p_quantity <= 0 THEN
    RAISE EXCEPTION 'Quantity must be greater than zero';
  END IF;

  INSERT INTO public.cart_items (cart_id, product_id, quantity)
  VALUES (p_cart_id, p_product_id, p_quantity)
  ON CONFLICT (cart_id, product_id)
  DO UPDATE SET quantity = public.cart_items.quantity + EXCLUDED.quantity;
END;
$$;

GRANT EXECUTE ON FUNCTION public.add_to_cart_item(uuid, uuid, integer) TO authenticated;

COMMIT;

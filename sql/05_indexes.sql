-- =========================================================
-- CP3 - PHASE 1: QUERY OPTIMIZATION INDEXES
-- =========================================================

SET search_path TO amazon;

-- R19: Helps filter products by category
CREATE INDEX IF NOT EXISTS idx_products_category_id
ON products(category_id);

-- R09/R20: Helps date range filtering on orders
CREATE INDEX IF NOT EXISTS idx_orders_ordered_at
ON orders(ordered_at);

-- R15/R17: Helps seller-related order item queries
CREATE INDEX IF NOT EXISTS idx_order_items_seller_id
ON order_items(seller_id);

-- R16: Helps review filtering by product and rating
CREATE INDEX IF NOT EXISTS idx_reviews_product_rating
ON product_reviews(product_id, rating);

-- R22: Helps ordered pagination by order date
CREATE INDEX IF NOT EXISTS idx_orders_ordered_at_desc
ON orders(ordered_at DESC);

-- Refresh statistics after creating indexes
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE product_reviews;
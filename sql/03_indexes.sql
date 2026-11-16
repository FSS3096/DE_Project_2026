
-- =========================================================
-- CP2 - PHASE 1: PERFORMANCE INDEXES
-- =========================================================

SET search_path TO amazon;

-- Covering index for product-level order history
CREATE INDEX IF NOT EXISTS idx_order_items_product_id_cover
ON order_items (product_id)
INCLUDE (order_id, quantity);

-- Refresh table statistics
ANALYZE order_items;

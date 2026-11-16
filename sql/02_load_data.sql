
-- =========================================================
-- AMAZON ONLINE SHOPPING DATABASE
-- CP1 - PHASE 2: DATA LOADING
-- PostgreSQL 15+
-- =========================================================

\set ON_ERROR_STOP on

-- Load parent tables first

\copy amazon.cities (city_id, city_name, state) FROM 'seed_data/seed_data/cities.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.categories (category_id, category_name, parent_category_id, is_digital) FROM 'seed_data/seed_data/categories.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.sellers (seller_id, business_name, gstin, city_id, joined_on, seller_rating, status) FROM 'seed_data/seed_data/sellers.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.products (product_id, asin, seller_id, category_id, title, brand, mrp, price, stock_qty, is_prime_eligible, avg_rating, review_count, listed_on, status) FROM 'seed_data/seed_data/products.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.customers (customer_id, full_name, email, phone, city_id, signup_date, is_prime, prime_since) FROM 'seed_data/seed_data/customers.csv' WITH (FORMAT CSV, HEADER TRUE);

-- Load dependent tables

\copy amazon.addresses (address_id, customer_id, label, line1, city_id, pincode, is_default) FROM 'seed_data/seed_data/addresses.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.orders (order_id, customer_id, address_id, ordered_at, payment_method, total_amount, status, shipped_at, delivered_at) FROM 'seed_data/seed_data/orders.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.order_items (order_id, line_no, product_id, seller_id, quantity, unit_price) FROM 'seed_data/seed_data/order_items.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.returns (return_id, order_id, line_no, reason, requested_at, status, refund_amount) FROM 'seed_data/seed_data/returns.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.product_reviews (review_id, product_id, customer_id, rating, title, body, verified_purchase, helpful_votes, created_at) FROM 'seed_data/seed_data/product_reviews.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy amazon.cart_items (customer_id, product_id, quantity, added_at) FROM 'seed_data/seed_data/cart_items.csv' WITH (FORMAT CSV, HEADER TRUE);

-- Update table statistics

ANALYZE amazon.cities;
ANALYZE amazon.categories;
ANALYZE amazon.sellers;
ANALYZE amazon.products;
ANALYZE amazon.customers;
ANALYZE amazon.addresses;
ANALYZE amazon.orders;
ANALYZE amazon.order_items;
ANALYZE amazon.returns;
ANALYZE amazon.product_reviews;
ANALYZE amazon.cart_items;

-- =========================================================
-- END OF DATA LOADING
-- =========================================================

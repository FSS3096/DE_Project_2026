
-- =========================================================
-- AMAZON ONLINE SHOPPING DATABASE
-- CP1 - PHASE 2: SCHEMA CREATION
-- PostgreSQL 15+
-- =========================================================

CREATE SCHEMA IF NOT EXISTS amazon;
SET search_path TO amazon;

-- =========================================================
-- DROP EXISTING TABLES (REVERSE DEPENDENCY ORDER)
-- =========================================================

DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS returns CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS cities CASCADE;

-- =========================================================
-- 1. CITIES
-- =========================================================

CREATE TABLE cities (
    city_id BIGINT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,

    CONSTRAINT uq_cities_name_state
        UNIQUE (city_name, state)
);

-- =========================================================
-- 2. CATEGORIES
-- =========================================================

CREATE TABLE categories (
    category_id BIGINT PRIMARY KEY,
    category_name VARCHAR(150) NOT NULL,
    parent_category_id BIGINT,
    is_digital BOOLEAN NOT NULL,

    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
);

-- =========================================================
-- 3. SELLERS
-- =========================================================

CREATE TABLE sellers (
    seller_id BIGINT PRIMARY KEY,
    business_name VARCHAR(100) NOT NULL,
    gstin VARCHAR(15) NOT NULL UNIQUE,
    city_id BIGINT NOT NULL,
    joined_on DATE NOT NULL,
    seller_rating NUMERIC(3,2) NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT fk_sellers_city
        FOREIGN KEY (city_id)
        REFERENCES cities(city_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_seller_rating
        CHECK (seller_rating BETWEEN 0 AND 5),

    CONSTRAINT chk_seller_status
        CHECK (status IN ('ACTIVE', 'CLOSED', 'SUSPENDED'))
);

-- =========================================================
-- 4. PRODUCTS
-- =========================================================

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY,
    asin VARCHAR(10) NOT NULL UNIQUE,
    seller_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    mrp NUMERIC(12,2) NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    stock_qty INTEGER NOT NULL,
    is_prime_eligible BOOLEAN NOT NULL,
    avg_rating NUMERIC(3,2),
    review_count INTEGER NOT NULL,
    listed_on DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT fk_products_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_product_mrp
        CHECK (mrp > 0),

    CONSTRAINT chk_product_price
        CHECK (price > 0 AND price <= mrp),

    CONSTRAINT chk_product_stock
        CHECK (stock_qty >= 0),

    CONSTRAINT chk_product_avg_rating
        CHECK (avg_rating IS NULL OR avg_rating BETWEEN 1 AND 5),

    CONSTRAINT chk_product_review_count
        CHECK (review_count >= 0),

    CONSTRAINT chk_product_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'OUT_OF_STOCK'))
);

-- =========================================================
-- 5. CUSTOMERS
-- =========================================================

CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    city_id BIGINT NOT NULL,
    signup_date DATE NOT NULL,
    is_prime BOOLEAN NOT NULL,
    prime_since DATE,

    CONSTRAINT fk_customers_city
        FOREIGN KEY (city_id)
        REFERENCES cities(city_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_prime_since
        CHECK (is_prime = TRUE OR prime_since IS NULL)
);

-- =========================================================
-- 6. ADDRESSES
-- =========================================================

CREATE TABLE addresses (
    address_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    label VARCHAR(20) NOT NULL,
    line1 VARCHAR(255) NOT NULL,
    city_id BIGINT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    is_default BOOLEAN NOT NULL,

    CONSTRAINT fk_addresses_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_addresses_city
        FOREIGN KEY (city_id)
        REFERENCES cities(city_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_address_label
        CHECK (label IN ('HOME', 'WORK')),

    CONSTRAINT chk_address_pincode
        CHECK (pincode ~ '^[0-9]{6}$')
);

-- =========================================================
-- 7. ORDERS
-- =========================================================

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    address_id BIGINT,
    ordered_at TIMESTAMPTZ NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_order_payment
        CHECK (
            payment_method IN (
                'CARD',
                'COD',
                'EMI',
                'GIFT_CARD',
                'NETBANKING',
                'UPI'
            )
        ),

    CONSTRAINT chk_order_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_order_status
        CHECK (
            status IN (
                'CANCELLED',
                'DELIVERED',
                'OUT_FOR_DELIVERY',
                'PACKED',
                'PLACED',
                'RETURNED',
                'SHIPPED'
            )
        ),

    CONSTRAINT chk_order_shipping_time
        CHECK (
            shipped_at IS NULL
            OR shipped_at >= ordered_at
        ),

    CONSTRAINT chk_order_delivery_time
        CHECK (
            delivered_at IS NULL
            OR shipped_at IS NULL
            OR delivered_at >= shipped_at
        )
);

-- =========================================================
-- 8. ORDER ITEMS
-- =========================================================

CREATE TABLE order_items (
    order_id BIGINT NOT NULL,
    line_no SMALLINT NOT NULL,
    product_id BIGINT NOT NULL,
    seller_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, line_no),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_order_item_line
        CHECK (line_no > 0),

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_item_price
        CHECK (unit_price > 0)
);

-- =========================================================
-- 9. RETURNS
-- =========================================================

CREATE TABLE returns (
    return_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    line_no SMALLINT NOT NULL,
    reason VARCHAR(40) NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL,
    refund_amount NUMERIC(12,2),

    CONSTRAINT fk_returns_order_item
        FOREIGN KEY (order_id, line_no)
        REFERENCES order_items(order_id, line_no)
        ON DELETE RESTRICT,

    CONSTRAINT chk_return_reason
        CHECK (
            reason IN (
                'DAMAGED',
                'NOT_AS_DESCRIBED',
                'NO_LONGER_NEEDED',
                'QUALITY_ISSUE',
                'SIZE_ISSUE',
                'WRONG_ITEM'
            )
        ),

    CONSTRAINT chk_return_status
        CHECK (
            status IN (
                'PICKED_UP',
                'REFUNDED',
                'REJECTED',
                'REQUESTED'
            )
        ),

    CONSTRAINT chk_refund_amount
        CHECK (
            refund_amount IS NULL
            OR refund_amount >= 0
        )
);

-- =========================================================
-- 10. PRODUCT REVIEWS
-- =========================================================

CREATE TABLE product_reviews (
    review_id BIGINT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    rating SMALLINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    verified_purchase BOOLEAN NOT NULL,
    helpful_votes INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_reviews_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5),

    CONSTRAINT chk_review_helpful_votes
        CHECK (helpful_votes >= 0)
);

-- =========================================================
-- 11. CART ITEMS
-- =========================================================

CREATE TABLE cart_items (
    customer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    added_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT pk_cart_items
        PRIMARY KEY (customer_id, product_id),

    CONSTRAINT fk_cart_items_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_cart_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_cart_quantity
        CHECK (quantity > 0)
);

-- =========================================================
-- END OF SCHEMA CREATION
-- =========================================================

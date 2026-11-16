# Database Schema Design – Amazon Online Shopping Database

## 1. Database Overview

The project uses PostgreSQL 18 to manage Amazon India's online shopping operations. The database stores information about customers, sellers, products, categories, addresses, orders, order items, returns, reviews, and cart information.

The schema is created inside the `amazon` database schema and follows relational database principles using primary keys, foreign keys, unique constraints, NOT NULL constraints, and CHECK constraints.

The design is based on 11 provided CSV files containing **355,584 records** in total.

## 2. Tables and Data Dictionary

### 2.1 Cities

Stores city information for customers and sellers.

| Column | Data Type | Constraint |
|---|---|---|
| city_id | BIGINT | PRIMARY KEY |
| city_name | VARCHAR(100) | NOT NULL |
| state | VARCHAR(100) | NOT NULL |

A unique constraint is applied to `(city_name, state)`.

### 2.2 Categories

Stores product categories in a hierarchical structure.

| Column | Data Type | Constraint |
|---|---|---|
| category_id | BIGINT | PRIMARY KEY |
| category_name | VARCHAR(150) | NOT NULL |
| parent_category_id | BIGINT | NULL, SELF-REFERENCING FOREIGN KEY |
| is_digital | BOOLEAN | NOT NULL |

The parent category references another row in the same table.

### 2.3 Sellers

Stores information about businesses selling products.

| Column | Data Type | Constraint |
|---|---|---|
| seller_id | BIGINT | PRIMARY KEY |
| business_name | VARCHAR(100) | NOT NULL |
| gstin | VARCHAR(15) | UNIQUE, NOT NULL |
| city_id | BIGINT | FOREIGN KEY, NOT NULL |
| joined_on | DATE | NOT NULL |
| seller_rating | NUMERIC(3,2) | NOT NULL |
| status | VARCHAR(20) | NOT NULL |

### 2.4 Products

Stores product listings, prices, stock, and ratings.

| Column | Data Type | Constraint |
|---|---|---|
| product_id | BIGINT | PRIMARY KEY |
| asin | VARCHAR(10) | UNIQUE, NOT NULL |
| seller_id | BIGINT | FOREIGN KEY, NOT NULL |
| category_id | BIGINT | FOREIGN KEY, NOT NULL |
| title | VARCHAR(255) | NOT NULL |
| brand | VARCHAR(100) | NOT NULL |
| mrp | NUMERIC(12,2) | NOT NULL |
| price | NUMERIC(12,2) | NOT NULL |
| stock_qty | INTEGER | NOT NULL |
| is_prime_eligible | BOOLEAN | NOT NULL |
| avg_rating | NUMERIC(3,2) | NULL allowed |
| review_count | INTEGER | NOT NULL |
| listed_on | DATE | NOT NULL |
| status | VARCHAR(20) | NOT NULL |

### 2.5 Customers

Stores customer account and Prime membership information.

| Column | Data Type | Constraint |
|---|---|---|
| customer_id | BIGINT | PRIMARY KEY |
| full_name | VARCHAR(150) | NOT NULL |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| phone | VARCHAR(20) | UNIQUE, NOT NULL |
| city_id | BIGINT | FOREIGN KEY, NOT NULL |
| signup_date | DATE | NOT NULL |
| is_prime | BOOLEAN | NOT NULL |
| prime_since | DATE | NULL allowed |

### 2.6 Addresses

Stores customer delivery addresses.

| Column | Data Type | Constraint |
|---|---|---|
| address_id | BIGINT | PRIMARY KEY |
| customer_id | BIGINT | FOREIGN KEY, NOT NULL |
| label | VARCHAR(20) | NOT NULL |
| line1 | VARCHAR(255) | NOT NULL |
| city_id | BIGINT | FOREIGN KEY, NOT NULL |
| pincode | VARCHAR(10) | NOT NULL |
| is_default | BOOLEAN | NOT NULL |

The supplied dataset was verified to contain exactly one default address for every customer.

### 2.7 Orders

Stores customer order information.

| Column | Data Type | Constraint |
|---|---|---|
| order_id | BIGINT | PRIMARY KEY |
| customer_id | BIGINT | FOREIGN KEY, NOT NULL |
| address_id | BIGINT | FOREIGN KEY, NULL allowed |
| ordered_at | TIMESTAMPTZ | NOT NULL |
| payment_method | VARCHAR(20) | NOT NULL |
| total_amount | NUMERIC(12,2) | NOT NULL |
| status | VARCHAR(30) | NOT NULL |
| shipped_at | TIMESTAMPTZ | NULL allowed |
| delivered_at | TIMESTAMPTZ | NULL allowed |

An address can be NULL for orders containing only digital products. This was verified against the supplied dataset.

### 2.8 Order Items

Stores individual products included in an order.

| Column | Data Type | Constraint |
|---|---|---|
| order_id | BIGINT | COMPOSITE PRIMARY KEY, FOREIGN KEY |
| line_no | SMALLINT | COMPOSITE PRIMARY KEY |
| product_id | BIGINT | FOREIGN KEY, NOT NULL |
| seller_id | BIGINT | FOREIGN KEY, NOT NULL |
| quantity | INTEGER | NOT NULL |
| unit_price | NUMERIC(12,2) | NOT NULL |

The composite primary key is `(order_id, line_no)` because each order can contain multiple product lines.

### 2.9 Returns

Stores return requests for individual order items.

| Column | Data Type | Constraint |
|---|---|---|
| return_id | BIGINT | PRIMARY KEY |
| order_id | BIGINT | COMPOSITE FOREIGN KEY, NOT NULL |
| line_no | SMALLINT | COMPOSITE FOREIGN KEY, NOT NULL |
| reason | VARCHAR(40) | NOT NULL |
| requested_at | TIMESTAMPTZ | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| refund_amount | NUMERIC(12,2) | NULL allowed |

The foreign key `(order_id, line_no)` references the composite primary key of `order_items`.

### 2.10 Product Reviews

Stores customer reviews and ratings.

| Column | Data Type | Constraint |
|---|---|---|
| review_id | BIGINT | PRIMARY KEY |
| product_id | BIGINT | FOREIGN KEY, NOT NULL |
| customer_id | BIGINT | FOREIGN KEY, NOT NULL |
| rating | SMALLINT | NOT NULL |
| title | VARCHAR(255) | NOT NULL |
| body | TEXT | NULL allowed |
| verified_purchase | BOOLEAN | NOT NULL |
| helpful_votes | INTEGER | NOT NULL |
| created_at | TIMESTAMPTZ | NOT NULL |

### 2.11 Cart Items

Stores products currently added to customer carts.

| Column | Data Type | Constraint |
|---|---|---|
| customer_id | BIGINT | COMPOSITE PRIMARY KEY, FOREIGN KEY |
| product_id | BIGINT | COMPOSITE PRIMARY KEY, FOREIGN KEY |
| quantity | INTEGER | NOT NULL |
| added_at | TIMESTAMPTZ | NOT NULL |

The composite primary key is `(customer_id, product_id)` because the same customer should have only one cart entry for a product.

## 3. Primary Keys and Foreign Keys

| Table | Primary Key | Foreign Keys |
|---|---|---|
| cities | city_id | None |
| categories | category_id | parent_category_id → categories.category_id |
| sellers | seller_id | city_id → cities.city_id |
| products | product_id | seller_id → sellers.seller_id; category_id → categories.category_id |
| customers | customer_id | city_id → cities.city_id |
| addresses | address_id | customer_id → customers.customer_id; city_id → cities.city_id |
| orders | order_id | customer_id → customers.customer_id; address_id → addresses.address_id |
| order_items | order_id, line_no | order_id → orders.order_id; product_id → products.product_id; seller_id → sellers.seller_id |
| returns | return_id | (order_id, line_no) → order_items |
| product_reviews | review_id | product_id → products.product_id; customer_id → customers.customer_id |
| cart_items | customer_id, product_id | customer_id → customers.customer_id; product_id → products.product_id |

## 4. Relationships and Cardinalities

1. Cities to Customers: One-to-Many.
2. Cities to Sellers: One-to-Many.
3. Cities to Addresses: One-to-Many.
4. Categories to Products: One-to-Many.
5. Categories to Categories: Self-referencing One-to-Many.
6. Sellers to Products: One-to-Many.
7. Customers to Addresses: One-to-Many.
8. Customers to Orders: One-to-Many.
9. Orders to Order Items: One-to-Many.
10. Products to Order Items: One-to-Many.
11. Order Items to Returns: One-to-Zero-or-One in the supplied dataset.
12. Customers to Product Reviews: One-to-Many.
13. Products to Product Reviews: One-to-Many.
14. Customers to Products through Cart Items: Many-to-Many.

## 5. Constraints and Business Rules

The following constraints are implemented in the schema:

1. All primary keys must be unique and NOT NULL.
2. Customer email must be unique.
3. Customer phone number must be unique.
4. Seller GSTIN must be unique.
5. Product ASIN must be unique.
6. City name and state combination must be unique.
7. Product price must be greater than zero and not exceed MRP.
8. Product MRP must be greater than zero.
9. Stock quantity must be non-negative.
10. Product average rating must be between 1 and 5 when present.
11. Product review count must be non-negative.
12. Seller rating must be between 0 and 5.
13. Review rating must be between 1 and 5.
14. Review helpful votes must be non-negative.
15. Order total amount must be non-negative.
16. Order item quantity must be positive.
17. Order item unit price must be positive.
18. Cart item quantity must be positive.
19. Address pincodes must contain six digits.
20. Address labels must be HOME or WORK.
21. Payment methods, order statuses, seller statuses, product statuses, return reasons, and return statuses must belong to their specified allowed values.
22. Order shipping and delivery timestamps must satisfy the implemented CHECK conditions.

Some additional business rules are verified through data-validation queries rather than enforced as database constraints. These include ensuring that each customer has exactly one default address and that an order item's seller matches the seller of its product.

## 6. NULL Values and Their Meaning

NULL values represent missing or not-yet-applicable information.

| Column | Reason for NULL |
|---|---|
| categories.parent_category_id | Top-level categories have no parent |
| customers.prime_since | Membership date may be unavailable |
| products.avg_rating | Product has no available rating |
| orders.address_id | Digital-product orders do not require delivery addresses |
| orders.shipped_at | Shipping timestamp is unavailable |
| orders.delivered_at | Delivery timestamp is unavailable |
| returns.refund_amount | Refund amount is unavailable or not applicable |
| product_reviews.body | Review text was not provided |

These columns should not be made NOT NULL because the supplied dataset contains legitimate NULL values.

## 7. Normalization and Functional Dependencies

The database is designed to follow Third Normal Form (3NF).

### Main Functional Dependencies

- cities: city_id → city_name, state
- categories: category_id → category_name, parent_category_id, is_digital
- sellers: seller_id → business_name, gstin, city_id, joined_on, seller_rating, status
- products: product_id → asin, seller_id, category_id, title, brand, mrp, price, stock_qty, is_prime_eligible, avg_rating, review_count, listed_on, status
- customers: customer_id → full_name, email, phone, city_id, signup_date, is_prime, prime_since
- addresses: address_id → customer_id, label, line1, city_id, pincode, is_default
- orders: order_id → customer_id, address_id, ordered_at, payment_method, total_amount, status, shipped_at, delivered_at
- order_items: (order_id, line_no) → product_id, seller_id, quantity, unit_price
- returns: return_id → order_id, line_no, reason, requested_at, status, refund_amount
- product_reviews: review_id → product_id, customer_id, rating, title, body, verified_purchase, helpful_votes, created_at
- cart_items: (customer_id, product_id) → quantity, added_at

Each table has a primary key that determines its remaining attributes. The composite-key tables use combinations of columns as their primary keys.

### Redundant and Derived Attributes

Some attributes are stored for practical reasons:

- `products.avg_rating` and `products.review_count` are summaries of product reviews. They are retained to support product-page queries.
- `orders.total_amount` is a stored order-level amount used for reporting.
- `order_items.seller_id` duplicates seller information available through products. It is retained to represent the seller associated with the order line.

The consistency of `order_items.seller_id` with the product's seller is verified through a data-integrity query.

## 8. Data Validation and Integrity Checks

The supplied CSV files contain 11 tables and 355,584 records.

| Table | Actual Rows |
|---|---:|
| cities | 10 |
| categories | 40 |
| sellers | 1,500 |
| products | 30,000 |
| customers | 30,000 |
| addresses | 45,000 |
| orders | 120,000 |
| order_items | 240,000 |
| returns | 5,374 |
| product_reviews | 38,662 |
| cart_items | 44,998 |
| **Total** | **355,584** |

### Verified Integrity Checks

| Check | Result |
|---|---:|
| Orders with mismatched customer and address ownership | 0 |
| Order items with seller_id different from product seller_id | 0 |
| Returns referencing missing order items | 0 |
| Customers without exactly one default address | 0 |
| Orders without addresses containing non-digital products | 0 |

### Additional Observations

- There are 5,882 orders with NULL addresses.
- All orders with NULL addresses contain only digital products.
- There are 7,968 products with NULL average ratings.
- There are 13,811 reviews with NULL review bodies.
- There are 1,388 returns with NULL refund amounts.
- There are 21,034 customers with NULL Prime membership dates.

These values are legitimate dataset characteristics and should be preserved.

## 9. Referential Integrity and Delete Rules

The schema uses `ON DELETE RESTRICT` for foreign-key relationships.

This prevents deleting records that are referenced by dependent records and protects historical transaction data.

The implemented rules include:

- Cities: RESTRICT deletion when referenced by customers, sellers, or addresses.
- Categories: RESTRICT deletion when referenced by products or child categories.
- Sellers: RESTRICT deletion when referenced by products or order items.
- Products: RESTRICT deletion when referenced by order items, reviews, or cart items.
- Customers: RESTRICT deletion when referenced by addresses, orders, reviews, or cart items.
- Addresses: RESTRICT deletion when referenced by orders.
- Orders: RESTRICT deletion when referenced by order items.
- Order items: RESTRICT deletion when referenced by returns.

These rules help prevent accidental loss of important records.

## 10. Conclusion

The Amazon Online Shopping Database organizes the supplied data into 11 related tables containing 355,584 records.

Primary keys, foreign keys, unique constraints, NOT NULL constraints, and CHECK constraints help maintain data accuracy and consistency.

The database was successfully created and populated using PostgreSQL. All 11 CSV files were imported successfully, and the verified integrity checks returned zero invalid records.

The design supports customer operations, seller management, product browsing, order processing, returns, reviews, cart management, and reporting. It also provides a foundation for future query execution analysis, indexing, and optimization.
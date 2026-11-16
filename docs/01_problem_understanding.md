# Problem Understanding – Amazon Online Shopping Database

## 1. Introduction

Amazon India is an online marketplace where multiple sellers offer products to customers. The system manages customers, sellers, products, categories, shopping carts, orders, deliveries, returns and product reviews.

The existing database has no documented schema, resulting in slow queries and data management issues. The objective is to rebuild a properly structured PostgreSQL database and improve query performance while maintaining data accuracy and supporting future growth.

## 2. Business Problems and Stakeholders

| ID | Business Requirement | Stakeholder | Classification | Related Queries |
|---|---|---|---|---|
| P1 | Improve product searching and browsing across multiple category levels. | Customer, Category Manager | Customer-facing / Real-time | R01, R02, R14 |
| P2 | Retrieve product ratings, review breakdowns and frequently bought-together products quickly. | Customer | Customer-facing / Real-time | R03, R11, R24 |
| P3 | Retrieve customer order history and order details efficiently. | Customer | Customer-facing / Real-time | R04, R23 |
| P4 | Improve seller dashboards for monthly orders, low stock and price management. | Seller | Reporting / Analytics | R06, R07, R15, W02, W03 |
| P5 | Identify delayed shipments and process orders waiting for dispatch efficiently. | Logistics | Customer-facing / Real-time | R05, R21, W05 |
| P6 | Identify saved addresses that have never been used for an order. | Admin | Reporting / Analytics | R13 |
| P7 | Identify abandoned carts and improve cart cleanup and marketing campaigns. | Marketing | Reporting / Analytics | R10, W04, W06 |
| P8 | Detect suspicious verified-purchase reviews and analyze review content. | Trust & Safety | Reporting / Analytics | R16, R17 |
| P9 | Generate category, Prime, return, customer spending and financial reports efficiently while supporting future traffic growth. | Category Manager, Prime Team, Finance | Reporting / Analytics | R08, R09, R12, R18, R19, R20, W01 |

## 3. Assumptions

1. Every customer, seller, product and order has a unique identifier.
2. Product categories follow a hierarchical structure using parent-child relationships.
3. Customers can save multiple delivery addresses.
4. Digital products do not require delivery addresses.
5. An order can contain multiple products and order items.
6. Returns are associated with individual order items.
7. Prime membership is identified using the `is_prime` field.
8. Product reviews can be verified or unverified.
9. Order and shipment timestamps preserve timezone information.
10. Query optimization must maintain the original query results.

## 4. Conclusion

The project aims to build a reliable, well-structured and efficient PostgreSQL database for Amazon India's online shopping system. Proper schema design, normalization, constraints, indexing and query optimization will improve database performance and support future business growth.
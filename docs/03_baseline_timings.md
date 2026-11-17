# CP2 – Baseline Query Timings and Performance Analysis

## 1. Objective

The objective of this phase is to measure the initial performance of the Amazon Online Shopping Database before introducing additional performance indexes.

The baseline benchmark evaluates the execution time of 30 SQL queries and records their execution plans. These results will serve as a reference for comparing database performance after optimization.

## 2. Benchmark Environment

| Parameter | Details |
|---|---|
| Project | Amazon Online Shopping Database |
| Database | amazon_db |
| DBMS | PostgreSQL |
| Workload File | `queries/workload_30.sql` |
| Benchmark Script | `benchmarks/run_benchmark.sh` |
| Execution Method | `EXPLAIN (ANALYZE, BUFFERS)` |
| Executions per Query | 3 |
| Total Queries | 30 |
| Read Queries | 24 |
| Write Queries | 6 |

## 3. Baseline Results

The baseline benchmark results are stored in:

`benchmarks/results/baseline/summary.csv`

Individual execution plans are stored in:

`benchmarks/results/baseline/`

Each query was executed three times. The average, median, minimum, and maximum execution times were recorded.

### 3.1 Complete Query Timing Results

All execution times are in milliseconds (ms).

| Query ID | Type | Average | Median | Minimum | Maximum |
|---|---|---:|---:|---:|---:|
| R01 | READ | 15.161 | 14.079 | 13.303 | 18.101 |
| R02 | READ | 5.603 | 5.544 | 5.141 | 6.125 |
| R03 | READ | 3.170 | 3.146 | 2.907 | 3.458 |
| R04 | READ | 9.231 | 9.088 | 7.181 | 11.425 |
| R05 | READ | 9.408 | 10.341 | 7.119 | 10.765 |
| R06 | READ | 12.208 | 8.392 | 7.866 | 20.367 |
| R07 | READ | 2.837 | 2.729 | 2.401 | 3.381 |
| R08 | READ | 30.948 | 28.595 | 25.082 | 39.167 |
| R09 | READ | 31.222 | 25.633 | 23.319 | 44.715 |
| R10 | READ | 15.257 | 15.001 | 14.843 | 15.926 |
| R11 | READ | 5.031 | 5.022 | 4.972 | 5.100 |
| R12 | READ | 57.767 | 57.216 | 56.534 | 59.551 |
| R13 | READ | 18.606 | 14.927 | 13.524 | 27.368 |
| R14 | READ | 4.089 | 4.139 | 3.961 | 4.167 |
| R15 | READ | 21.744 | 20.869 | 20.804 | 23.559 |
| R16 | READ | 8.605 | 8.587 | 8.472 | 8.756 |
| R17 | READ | 49.012 | 49.210 | 48.316 | 49.510 |
| R18 | READ | 10.654 | 10.833 | 10.241 | 10.889 |
| R19 | READ | 9055.106 | 9063.069 | 9028.749 | 9073.501 |
| R20 | READ | 7.941 | 8.142 | 7.493 | 8.189 |
| R21 | READ | 5.644 | 5.638 | 5.525 | 5.768 |
| R22 | READ | 26.659 | 26.119 | 24.142 | 29.716 |
| R23 | READ | 0.077 | 0.074 | 0.071 | 0.086 |
| R24 | READ | 0.030 | 0.026 | 0.023 | 0.040 |
| W01 | WRITE | 0.527 | 0.406 | 0.404 | 0.770 |
| W02 | WRITE | 0.503 | 0.512 | 0.477 | 0.519 |
| W03 | WRITE | 3.586 | 3.846 | 2.862 | 4.051 |
| W04 | WRITE | 71.752 | 39.320 | 29.941 | 145.995 |
| W05 | WRITE | 7.986 | 7.979 | 7.660 | 8.320 |
| W06 | WRITE | 6.430 | 6.391 | 6.302 | 6.598 |

### 3.2 Execution Plan Scan Information

The following scan nodes were recorded in the benchmark summary.

| Query ID | Recorded Scan Nodes |
|---|---|
| R01 | Seq Scan on products |
| R02 | Seq Scan on categories, products |
| R03 | Seq Scan on product_reviews |
| R04 | Seq Scan on orders; Index Only Scan on order_items |
| R05 | Seq Scan on orders |
| R06 | Seq Scan on order_items; Index Scan on orders |
| R07 | Seq Scan on products |
| R08 | Seq Scan on order_items, orders, products |
| R09 | Seq Scan on orders, customers |
| R10 | Seq Scan on orders, cart_items, products |
| R11 | Seq Scan and Index Scan on order_items |
| R12 | Seq Scan on order_items, products, categories, returns |
| R13 | Seq Scan on addresses, orders |
| R14 | Seq Scan on products |
| R15 | Seq Scan on order_items, orders, sellers |
| R16 | Seq Scan on product_reviews, products, categories |
| R17 | Seq Scan on order_items, orders, product_reviews |
| R18 | Seq Scan on orders, customers |
| R19 | Seq Scan on categories, products, order_items; Index Scan on orders |
| R20 | Seq Scan on orders |
| R21 | Seq Scan on orders |
| R22 | Seq Scan on orders |
| R23 | Index Scan on order_items, orders, products, sellers |
| R24 | Index Scan on products |
| W01 | No scan node |
| W02 | Index Scan on products |
| W03 | Seq Scan on categories, products |
| W04 | No scan node |
| W05 | Index Scan on orders |
| W06 | Seq Scan on cart_items |

Note: The original summary output for R23 contains the text `onsellers` at the end of the scan-node description. The table above interprets this as an Index Scan on sellers; verify against the raw R23 plan if necessary.

## 4. Baseline Performance Analysis

### 4.1 Read Query Analysis

The read workload consists of 24 queries, R01 to R24.

The results show that several queries use sequential scans to retrieve data from tables. Other queries use indexes, including primary-key and unique indexes.

Important observations:

- R19 is the slowest read query, with an average execution time of 9055.106 ms.
- R12 takes 57.767 ms on average.
- R17 takes 49.012 ms on average.
- R08 and R09 take 30.948 ms and 31.222 ms respectively.
- R23 and R24 have the lowest average execution times among the read queries.

Sequential scans are not automatically inefficient. Their performance depends on table size, query conditions, data selectivity, and the amount of data that must be retrieved.

### 4.2 Write Query Analysis

The write workload consists of six queries, W01 to W06.

Important observations:

- W01 has an average execution time of 0.527 ms.
- W02 has an average execution time of 0.503 ms.
- W03 takes 3.586 ms on average.
- W04 has an average execution time of 71.752 ms.
- W05 takes 7.986 ms on average.
- W06 takes 6.430 ms on average.

W04 shows considerable variation between its minimum execution time of 29.941 ms and maximum execution time of 145.995 ms.

Write operations can have different execution-plan structures from read queries. Some operations may not produce a scan node in the recorded plan.

## 5. Detailed Analysis of R19

R19 is the slowest query in the entire baseline workload.

Its average execution time is:

**9055.106 ms (approximately 9.06 seconds).**

The raw execution plans show that PostgreSQL performs sequential scans on the `order_items` table inside two correlated subqueries.

Important observations from the execution plan:

1. The outer query performs a sequential scan on the `products` table.
2. It returns 937 products belonging to the Mobiles category.
3. Two correlated subqueries execute 937 times each.
4. Each subquery performs a sequential scan on approximately 240,000 rows in `order_items`.
5. The first subquery also accesses the `orders` table using its primary-key index.
6. The execution plan records 4,251,310 shared buffer hits.
7. The final execution time is approximately 9 seconds in all three runs.

The repeated sequential scans on `order_items` are the main performance bottleneck.

### Optimization Opportunity

An index on `order_items(product_id)` should be investigated because the execution plan repeatedly filters this table using `product_id`.

The correlated subqueries can also be examined to determine whether their repeated work can be reduced.

These changes should be evaluated during the optimization phase, and their impact should be measured against the baseline results.

## 6. Explanation of Scan Types

### 6.1 Sequential Scan

A sequential scan reads rows from a table to find the records that satisfy a query condition.

It can be appropriate when a query needs a large percentage of the table's rows. However, repeated sequential scans on large tables can increase execution time.

### 6.2 Index Scan

An index scan uses an index to locate matching rows instead of examining the entire table.

It is often useful when a query needs a relatively small number of rows.

### 6.3 Index Only Scan

An index-only scan retrieves the required data directly from the index when PostgreSQL can satisfy the query without accessing the table for every row.

### 6.4 No Scan Node

Some write operations do not show a scan node in the recorded execution plan. This does not mean the operation was not executed; it means the recorded plan did not contain a scan operation.

## 7. Key Findings

The baseline benchmark produced the following findings:

1. All 30 workload queries were benchmarked three times.
2. R19 is the slowest query, with an average execution time of 9055.106 ms.
3. R12 and R17 are other relatively expensive read queries.
4. R23 and R24 have very low average execution times.
5. Sequential scans appear in many of the recorded execution plans.
6. W04 has significant variation in execution time across its three runs.
7. The R19 execution plan identifies repeated sequential scans on `order_items` as a major optimization opportunity.

## 8. Conclusion

The baseline benchmark establishes the initial performance of the Amazon Online Shopping Database for all 30 workload queries.

The results identify queries with higher execution times and execution plans that deserve further investigation.

R19 is the most important optimization candidate because its correlated subqueries repeatedly scan the `order_items` table, resulting in a high execution time and substantial buffer activity.

The recorded average execution times and raw execution plans provide a reference for evaluating the effectiveness of performance optimization in the next phase.

The baseline results are preserved in `benchmarks/results/baseline/` and will be compared with the optimized benchmark results after indexes and other performance improvements are introduced.
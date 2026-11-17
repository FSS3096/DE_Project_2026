
# CP2 – Baseline Query Timings

## 1. Objective

This document records the baseline execution timings of the
SQL workload before performance indexes were introduced.

## 2. Benchmark Environment

- Database: Amazon Online Shopping Database
- DBMS: PostgreSQL
- Benchmark script: benchmarks/run_benchmark.sh
- Workload: queries/workload_30.sql
- Execution method: EXPLAIN (ANALYZE, BUFFERS)

## 3. Baseline Results

Baseline results are stored in:

`benchmarks/results/before/summary.csv`

The benchmark records:
- Query ID
- Query type
- Average execution time
- Median execution time
- Minimum execution time
- Maximum execution time
- Execution plan scan nodes

## 4. Optimized Results

After introducing performance indexes, the workload
was executed again.

Optimized results are stored in:

`benchmarks/results/after/summary.csv`

## 5. Comparison

A comparison of baseline and optimized execution
times will be documented using the two benchmark
summary files.

## 6. Conclusion

The benchmark results provide a basis for evaluating
the impact of indexing on query execution performance.

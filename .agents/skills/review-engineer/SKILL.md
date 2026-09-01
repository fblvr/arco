---
name: review-engineer
description: Use when validating business logic, Fan-outs, dimensional modeling integrity, and JOIN cardinalities
---

# Senior Data Engineer Validation

## Overview
You act as a gatekeeper against logical data corruption, ensuring that the integration of multiple source systems into the Medallion Architecture does not produce silent errors, overlaps, or fan-outs.

## When to Use
- When evaluating the cardinality of a `JOIN` (e.g., joining an Order table with an Order Item table).
- When a Fact table unions data from two distinct systems (e.g., `erp_a` and `erp_b`).
- When validating the exclusion of Test/Dummy data.

## The Iron Law
**A technically correct query that duplicates business metrics is a failed query.**
Always prove uniqueness and granularity before performing aggregations.

## Red Flags - STOP and Start Over
1. Joining a 1:N table to a 1:1 table without prior aggregation, causing silent Fan-out (inflating financial metrics).
2. `UNION ALL` across multiple source systems without prefixing IDs (e.g., `id_pedido` from ERP A colliding with `id_pedido` from ERP B).
3. Absence of defensive filtering against known dummy data (e.g., `LIKE '%TESTE%'`, `LIKE '%DUMMY%'`).
4. Hardcoding IDs in `WHERE` clauses instead of filtering by boolean flags or status codes.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "The IDs are unique in their systems." | But they collide when UNIONed in a single Fact table. Implement surrogate keys or prefixes like `'ERP_A_' \|\| cast(id as varchar)`. |
| "Fan-out doesn't matter, we can filter it later in the dashboard." | Fact tables must represent a singular grain. Fan-out breaks SUM() aggregations at the core. Fix the cardinality before the JOIN or adjust the table's declared grain. |
| "I didn't filter TESTE because the business user might want to see it." | Analytical tables represent real operations. Test data corrupts ARPU, CAC, and Churn metrics. Filter it actively in Silver/Gold layers. |

## Quick Reference Pattern (Handling Overlap)

**Compliant (Union with Prefixing):**
```sql
WITH erp_a AS (
    SELECT
        'ERP_A_' || CAST(doc_entry AS VARCHAR) AS id_pedido,
        doc_date AS data_pedido,
        'ERP A' AS origem
    FROM {{ ref('stg_erp_a_sales_order') }}
),
erp_b AS (
    SELECT
        'ERP_B_' || CAST(id_pedido AS VARCHAR) AS id_pedido,
        dt_pedido AS data_pedido,
        'ERP B' AS origem
    FROM {{ ref('stg_erp_b_pedido') }}
)
SELECT * FROM erp_a UNION ALL SELECT * FROM erp_b
```

## Remediation Steps
If a query introduces a potential fan-out, immediately isolate the N-side of the relationship into a separate CTE, apply `GROUP BY` to roll it up to the correct granularity, and only then execute the `JOIN` to the main dimension.

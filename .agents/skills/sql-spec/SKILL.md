---
name: sql-spec
description: Use when validating, writing, or reviewing SQL queries in the analytics pipeline to prevent formatting and structural anomalies
---

# SQL Specifications & Guardrails

## Overview
This skill acts as the final gatekeeper for SQL code quality within the Medallion Architecture. It enforces determinism, readability, and performance for queries running on DuckDB.

## When to Use
- When writing a `.sql` file anywhere in `models/`.
- When reviewing a Merge Request containing `.sql` modifications.
- When an agent proposes an ad-hoc query to investigate data.

## The Iron Law
**Violating the letter of the rules is violating the spirit of the rules.**
Code must be readable by humans, debuggable in isolation, and strictly typed.

## Red Flags - STOP and Start Over
If you observe ANY of the following in the code being written or reviewed, REJECT it immediately:
1. `SELECT *` without explicit column specification (except in `SELECT * FROM final` at the end of a model).
2. Subqueries within the `FROM` or `WHERE` clauses (`SELECT id FROM (SELECT * FROM a)`).
3. Native SQL keywords in lowercase (`select`, `from`, `join`, `where`).
4. Implicit casting of business keys (e.g. comparing string dates without `CAST(col AS DATE)`).
5. Non-descriptive CTE names (e.g., `t1`, `cte_1`, `temp`, `source`).

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "It's just a staging table, SELECT * is fine." | Staging is a contract. `SELECT *` breaks silently when source tables change. Explicit columns guarantee pipeline stability. |
| "A subquery here is shorter and faster." | Readability and DAG tracing are paramount. CTEs allow line-by-line debugging. Refactor to `WITH` clause. |
| "dbt compiles it fine in lowercase." | Readability dictates UPPERCASE for keywords to distinguish them from column names visually. Refactor it. |
| "The column is already a string, no need to cast." | Explicit `CAST(col AS VARCHAR)` in Staging prevents silent schema shifts if the source DB changes the underlying type. |

## Quick Reference Pattern

**Do (Compliant):**
```sql
WITH crm_accounts AS (
    SELECT 
        CAST(account_id AS VARCHAR) AS id_escola,
        UPPER(name) AS nome_escola
    FROM {{ ref('stg_crm_account') }}
),
active_accounts AS (
    SELECT 
        id_escola,
        nome_escola
    FROM crm_accounts
    WHERE nome_escola NOT LIKE '%TESTE%'
)
SELECT * FROM active_accounts;
```

**Don't (Violation):**
```sql
select * from (
    select account_id as id_escola, name from {{ ref('stg_crm_account') }}
) t1
where t1.name not like '%TESTE%'
```

## Remediation Steps
If a violation occurs, do not attempt to "patch" the subquery. Drop the statement, establish a `WITH` block, map out the required transformations logically, and assign descriptive names to each CTE block.

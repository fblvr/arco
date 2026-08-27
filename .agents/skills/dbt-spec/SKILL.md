---
name: dbt-spec
description: Use when creating new models, validating folder structures, or enforcing dbt architectural governance
---

# dbt Architectural Governance

## Overview
This skill guarantees that the physical file structure and metadata of the dbt project strictly adhere to the Medallion Architecture standards and Arco Educação documentation requirements.

## When to Use
- Before calling a model complete.
- When organizing files in `models/staging`, `models/marts/core`, or `models/marts/analytics`.
- When verifying if a model is fully documented.

## The Iron Law
**No model exists without its metadata.**
A `.sql` file without an accompanying deeply populated `.yml` file is considered broken code.

## Red Flags - STOP and Start Over
1. Model `file_name.sql` does not have a `file_name.yml` in the exact same directory.
2. YAML file is missing the `meta` tag at the model level (must contain `summary`, `owner`, `business_context`, `changelog`).
3. YAML file is missing `meta: { contains_pii: true, classification: Restricted }` on columns that contain PII (email, phone, cnpj, names).
4. YAML file documents ONLY primary keys, omitting standard columns.
5. Using manual `regexp_replace` inside a `.sql` file for cleaning PII instead of calling centralized macros (e.g. `normalize_phone`, `normalize_cnpj`, `hash_pii`).
6. Mixing domains (e.g., placing `fct_vendas` in the staging folder).

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Only PKs need tests, so I only documented them." | The YAML acts as the Data Catalog. Every column exposed in the SELECT must be documented. Add them. |
| "I'll do the regex here because it's just this one model." | PII cleaning logic must be centralized. If a rule changes, we update one macro, not 50 models. Use the Macro. |
| "I put all YAMLs in one giant schema.yml file per folder." | Centralized YAMLs cause merge conflicts and are hard to navigate. Break them down: 1 `.yml` per `.sql`. |
| "I don't have the business context to fill the YAML." | Investigate the source tables or infer from the skill `senior-analyst`. Do not leave `business_context` empty. |

## Quick Reference Pattern (YAML Standard)

**Compliant `file_name.yml`:**
```yaml
version: 2
models:
  - name: fct_vendas
    description: "Fato de Vendas consolidadas unindo pedidos."
    meta:
      summary: "Tabela Fato de pedidos de venda."
      business_context: "Contém transações monetárias (pedidos). Ignora dados de teste."
      owner: "@data-engineering"
      changelog:
        - date: "2026-08-27"
          author: "Data Team"
          changes: "Initial refactor"
    columns:
      - name: id_pedido
        description: "Surrogate key do pedido."
        tests:
          - unique
          - not_null
      - name: origem
        description: "Sistema gerador."
```

## Remediation Steps
If a `.sql` file is found orphaned or with a poor YAML, immediately create the accompanying YAML. If an ad-hoc regex is found stripping characters from a CNPJ or Phone, extract it, ensure the Macro exists in `macros/`, and invoke `{{ clean_cnpj('col') }}` instead.

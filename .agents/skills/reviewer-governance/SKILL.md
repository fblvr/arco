---
name: reviewer-governance
description: Use when validating repository structure, pipeline constraints, audit compliance, and general CI/CD health
---

# Repository & Audit Governance

## Overview
This skill guarantees the health of the broader ecosystem. It evaluates whether the dbt project follows strict engineering playbooks, if CI/CD hooks are possible, and if global standards are respected.

## When to Use
- During final code review before marking a task as Complete.
- When checking if playbooks and system documentation match the state of the codebase.
- When performing a repository health-check.

## The Iron Law
**Undocumented architecture is technical debt.**

## Red Flags - STOP and Start Over
1. `Makefile` exists but lacks commands for critical workflows (e.g., missing `build-dbt` or `test-dbt`).
2. Ad-hoc Python scripts scattered in the root directory without being packaged or deleted (messy workspace).
3. Hardcoded connection strings or passwords in `.sql` or `profiles.yml` (Security breach).
4. No utilization of `.agents/skills` - if agents are operating without their guardrails loaded.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "I left the python script there just in case we need to run it again." | Dead code and one-off scripts clutter the repository. Delete `generate_*.py` scripts after use. |
| "I'll add the Make command later." | Runbooks must be updated simultaneously with architectural changes. |
| "I put the data path directly in the python script." | Use environment variables or central config. Hardcoding causes "works on my machine" syndrome. |

## Audit Checklist
Whenever invoked to validate governance, systematically check:
1. **Clean Root:** Are there loose `.csv` or `.py` files that should be deleted or moved to `scripts/` or `data/`?
2. **Build Readiness:** Does `make build-dbt` execute the full DAG successfully?
3. **Security:** Are PII columns (Phone, CNPJ, Email, Name) being hashed via `hash_pii` macro before entering analytical views?

## Remediation Steps
If loose scripts are found, delete them via terminal command. If PII is exposed in Silver/Gold layers, halt the pipeline and enforce the `hash_pii` macro. If the `Makefile` is missing targets, edit it to include standard `dbt deps`, `dbt build` commands.

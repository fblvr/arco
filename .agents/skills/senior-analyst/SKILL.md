---
name: senior-analyst
description: Use when analyzing business requirements, deriving insights, or understanding the Arco Educação operational domains
---

# Senior Business Analyst (Arco Educação Context)

## Overview
This skill acts as the brain trust for Arco Educação's core business model. You must use this domain knowledge to architect data solutions that answer real-world executive questions, rather than just moving tables.

## When to Use
- When deciding how to join cross-system tables (e.g., CRM to Support).
- When writing the `business_context` metadata in YAML files.
- When generating analytical aggregations (Gold Layer) designed for executive dashboards.
- Quando for avaliar e responder perguntas de negócios complexas, atuando como um avaliador do Data Warehouse vs Camada Raw.

## Base de Conhecimento Obrigatória
Antes de gerar qualquer análise ou resposta baseada no modelo Dimensional (Mart), o Senior Analyst DEVE OBRIGATORIAMENTE ler e consultar:
1. `arco_analytics/docs/architecture.md`: Para entender o diagrama ER e a topologia oficial.
2. `walkthrough.md` e `task.md` na raiz de artefatos: Para entender as regras de negócios inferidas (como o expurgo de fan-outs e a formação do *is_cancelado*).
3. Os arquivos YML dentro de `arco_analytics/models/marts/core/` e `arco_analytics/models/marts/analytics/`, que são a Fonte da Verdade definitiva para os campos `domain`, `grain`, `business_rules`, e `join_logic`.

## The Iron Law
**Data has no value unless it maps to the real-world operation.**
Every model must clearly answer: "How does this help Arco deliver educational solutions?"

## Deep Domain Context: Arco Educação

Arco is a massive B2B educational ecosystem in Brazil. 
The operational cycle relies on the convergence of three pillars:

1. **Commercial (CRM - Salesforce/etc.):**
   - Entities: `crm_account` (Schools), `crm_service_contract` (Contracts), `crm_product` (Educational Solutions like SAE, SAS, Positivo).
   - *Goal:* Track which school adopted which teaching system and what their Annual Contract Value (ACV) is.

2. **Fulfillment & Logistics (ERP A / ERP B):**
   - Entities: `erp_a_sales_order`, `erp_b_pedido`, `erp_a_delivery`.
   - *Goal:* Once the contract is signed, the school must receive physical books (apostilas) and digital licenses. ERP A typically handles the main brands, while ERP B might handle acquired companies or distinct logistical centers. 
   - *Pain Point:* Late deliveries of physical books cause extreme churn because students start the academic year without material.

3. **Customer Success & Support (Zendesk/Atendimento):**
   - Entities: `support_ticket`, `support_user`.
   - *Goal:* Schools (teachers/directors) open tickets when materials are delayed, or digital platforms have bugs. 
   - *Pain Point:* High ticket volume for a specific school heavily correlates with logistical failures (ERP) and predicts contract cancellation (CRM).

## Red Flags - STOP and Start Over
1. Building analytical tables that silo the data (e.g. only looking at Support Tickets without crossing with Sales/Deliveries).
2. Not accounting for the fact that a "Customer" in ERP A is the same entity as an "Account" in CRM.
3. Writing generic `business_context` in YAMLs like "Table of orders". It MUST be "Table of book orders used to calculate fulfillment SLA".

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "I don't know how these tables connect." | The common thread is the School (Account/Customer). Connect CRM Account ID with ERP Customer ID (using normalized CNPJs if IDs don't match directly). |
| "I just built a table of total tickets." | Total tickets is useless. We need "Total tickets by School crossed with Late Deliveries". Provide actionable intelligence. |

## Quick Reference Use Cases
When building Gold (Analytics) models, aim for these intersections:
- **Churn Risk Matrix:** `dim_escolas` JOINED WITH `fct_vendas` (Total Value) JOINED WITH `fct_tickets` (Volume of complaints).
- **Logistics SLA:** Time between `erp_a_sales_order` (Order placed) and `erp_a_delivery` (Books arrived at the school).

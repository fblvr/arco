WITH erp_a AS (
    SELECT slpcode as id_vendedor_sistema, slpname as nome_vendedor, 'ERP A' as sistema_origem
    FROM {{ ref('stg_erp_a_salesperson') }}
),
erp_b AS (
    SELECT id_vendedor as id_vendedor_sistema, nome as nome_vendedor, 'ERP B' as sistema_origem
    FROM {{ ref('stg_erp_b_vendedor') }}
)
SELECT 
    REPLACE(sistema_origem, ' ', '_') || '_' || id_vendedor_sistema as id_vendedor_sk,
    id_vendedor_sistema,
    nome_vendedor,
    sistema_origem
FROM erp_a
UNION ALL
SELECT 
    REPLACE(sistema_origem, ' ', '_') || '_' || id_vendedor_sistema as id_vendedor_sk,
    id_vendedor_sistema,
    nome_vendedor,
    sistema_origem
FROM erp_b

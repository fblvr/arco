WITH all_products AS (
    SELECT id as id_produto_origem, name as nome_produto, brand__c as marca, 'CRM' as sistema FROM {{ ref('stg_crm_product') }}
    UNION ALL
    SELECT itemcode, itemname, NULL, 'ERP A' FROM {{ ref('stg_erp_a_sales_order_item') }}
    UNION ALL
    SELECT cod_produto, desc_produto, NULL, 'ERP B' FROM {{ ref('stg_erp_b_item_pedido') }}
)
SELECT 
    MD5(UPPER(nome_produto)) AS id_produto_unificado,
    MAX(nome_produto) AS nome_produto,
    MAX(marca) AS marca,
    MAX(CASE WHEN sistema = 'CRM' THEN id_produto_origem END) AS id_produto_crm,
    MAX(CASE WHEN sistema = 'ERP A' THEN id_produto_origem END) AS id_produto_erp_a,
    MAX(CASE WHEN sistema = 'ERP B' THEN id_produto_origem END) AS id_produto_erp_b
FROM all_products
GROUP BY UPPER(nome_produto)

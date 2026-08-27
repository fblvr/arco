WITH stg_fin_nota_fiscal_raw AS (
    SELECT
        CAST("id_nf" AS BIGINT) AS id_nf,
        CAST("numero_nf" AS VARCHAR) AS numero_nf,
        CAST("serie_nf" AS BIGINT) AS serie_nf,
        CAST("id_pedido_erp_b" AS BIGINT) AS id_pedido_erp_b,
        {{ hash_pii(clean_cnpj('CAST("cnpj_cliente" AS VARCHAR)')) }} AS cnpj_cliente,
        CAST("nome_cliente" AS VARCHAR) AS nome_cliente,
        CAST("dt_emissao" AS DATE) AS dt_emissao,
        CAST("valor_total" AS DOUBLE) AS valor_total,
        CAST("valor_impostos" AS DOUBLE) AS valor_impostos,
        {{ hash_pii(clean_cnpj('CAST("cnpj_transportadora" AS VARCHAR)')) }} AS cnpj_transportadora,
        CAST("nome_transportadora" AS VARCHAR) AS nome_transportadora,
        CAST("codigo_rastreio" AS VARCHAR) AS codigo_rastreio,
        CAST("dt_prevista_entrega" AS DATE) AS dt_prevista_entrega,
        CAST("dt_entrega_real" AS DATE) AS dt_entrega_real,
        CAST("status_entrega" AS VARCHAR) AS status_entrega,
        CAST("qtd_entregue" AS BIGINT) AS qtd_entregue,
        CAST("dt_criacao" AS TIMESTAMP) AS dt_criacao
    FROM {{ source('financeiro', 'fin_nota_fiscal') }}
)
SELECT * FROM stg_fin_nota_fiscal_raw
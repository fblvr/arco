WITH dim_contratos_raw AS (
    SELECT
        id AS id_contrato,
        accountid AS id_cliente_crm,
        contractnumber AS id_contrato_origem,
        startdate AS data_inicio,
        enddate AS data_fim,
        {{ normalize_status('status') }} AS status
    FROM {{ ref('stg_crm_service_contract') }}
)
SELECT * FROM dim_contratos_raw

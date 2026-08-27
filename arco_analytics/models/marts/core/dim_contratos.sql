WITH dim_contratos_raw AS (
    SELECT
        CAST(id AS VARCHAR) AS id_contrato,
        CAST(accountid AS VARCHAR) AS id_cliente_crm,
        contractnumber AS id_contrato_origem,
        startdate AS data_inicio,
        enddate AS data_fim,
        {{ normalize_status('status') }} AS status
    FROM {{ ref('stg_crm_service_contract') }}
)
SELECT * FROM dim_contratos_raw

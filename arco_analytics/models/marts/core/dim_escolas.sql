WITH crm AS (
    SELECT cnpj__c as cnpj, name as nome_escola, createddate as created_date 
    FROM {{ ref('stg_crm_account') }} WHERE cnpj__c IS NOT NULL
),
erp_a AS (
    SELECT cnpj, MAX(cardname) as nome_escola, MIN(createdate) as created_date
    FROM {{ ref('stg_erp_a_customer') }} WHERE cnpj IS NOT NULL GROUP BY cnpj
),
erp_b AS (
    SELECT cnpj, MAX(nome_escola) as nome_escola, MIN(dt_cadastro) as created_date
    FROM {{ ref('stg_erp_b_escola') }} WHERE cnpj IS NOT NULL AND email IS NOT NULL AND email <> '' GROUP BY cnpj
),
zendesk AS (
    SELECT external_id as cnpj, MAX(name) as nome_escola, MIN(created_at) as created_date
    FROM {{ ref('stg_support_organization') }} WHERE external_id IS NOT NULL GROUP BY external_id
),
zendesk_tickets AS (
    SELECT custom_field_cnpj as cnpj, MAX('Escola s/ Cadastro (Zendesk)') as nome_escola, MIN(created_at) as created_date
    FROM {{ ref('stg_support_ticket') }} WHERE custom_field_cnpj IS NOT NULL GROUP BY custom_field_cnpj
),
all_cnpjs AS (
    SELECT cnpj FROM crm
    UNION SELECT cnpj FROM erp_a
    UNION SELECT cnpj FROM erp_b
    UNION SELECT cnpj FROM zendesk
    UNION SELECT cnpj FROM zendesk_tickets
)
SELECT
    a.cnpj AS id_escola,
    COALESCE(c.nome_escola, ea.nome_escola, eb.nome_escola, z.nome_escola, zt.nome_escola) AS nome_escola,
    LEAST(c.created_date, ea.created_date, eb.created_date, z.created_date, zt.created_date) AS data_cadastro,
    c.cnpj IS NOT NULL AS has_crm,
    ea.cnpj IS NOT NULL AS has_erp_a,
    eb.cnpj IS NOT NULL AS has_erp_b,
    (z.cnpj IS NOT NULL OR zt.cnpj IS NOT NULL) AS has_zendesk
FROM all_cnpjs a
LEFT JOIN crm c ON a.cnpj = c.cnpj
LEFT JOIN erp_a ea ON a.cnpj = ea.cnpj
LEFT JOIN erp_b eb ON a.cnpj = eb.cnpj
LEFT JOIN zendesk z ON a.cnpj = z.cnpj
LEFT JOIN zendesk_tickets zt ON a.cnpj = zt.cnpj

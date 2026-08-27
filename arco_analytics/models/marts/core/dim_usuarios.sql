WITH crm_users AS (
    SELECT 
        id as id_usuario_sistema,
        name as nome_usuario,
        email,
        'CRM' as sistema_origem
    FROM {{ ref('stg_crm_user') }}
),
support_users AS (
    SELECT 
        id as id_usuario_sistema,
        name as nome_usuario,
        email,
        'Support Zendesk' as sistema_origem
    FROM {{ ref('stg_support_user') }}
)
SELECT 
    MD5(sistema_origem || '_' || id_usuario_sistema) as id_usuario_sk,
    id_usuario_sistema,
    nome_usuario,
    email,
    sistema_origem
FROM crm_users
UNION ALL
SELECT 
    MD5(sistema_origem || '_' || id_usuario_sistema) as id_usuario_sk,
    id_usuario_sistema,
    nome_usuario,
    email,
    sistema_origem
FROM support_users

WITH stg_support_ticket_tag_raw AS (
    SELECT
        CAST("ticket_id" AS BIGINT) AS ticket_id,
        CAST("tag" AS STRING) AS tag
    FROM {{ source('atendimento', 'support_ticket_tag') }}
)
SELECT * FROM stg_support_ticket_tag_raw
{% macro normalize_status(column_name) %}
    CASE 
        WHEN UPPER({{ column_name }}) IN ('CANCELLED', 'CANCELADO') THEN 'CANCELLED'
        WHEN UPPER({{ column_name }}) IN ('O', 'OPEN', 'PENDING', 'PENDENTE', 'E') THEN 'PENDING'
        WHEN UPPER({{ column_name }}) IN ('IN_PROGRESS', 'EM_ANDAMENTO', 'P') THEN 'IN_PROGRESS'
        WHEN UPPER({{ column_name }}) IN ('DELIVERED', 'ENTREGUE', 'A') THEN 'DELIVERED'
        WHEN UPPER({{ column_name }}) IN ('CLOSED', 'SOLVED') THEN 'CLOSED'
        ELSE UPPER({{ column_name }})
    END
{% endmacro %}

{% macro normalize_cnpj(column_name) %}
    REGEXP_REPLACE(CAST({{ column_name }} AS VARCHAR), '[^0-9]', '', 'g')
{% endmacro %}

{% macro normalize_cnpj(column_name) %}
    regexp_replace(CAST({{ column_name }} AS STRING), '[^0-9]', '')
{% endmacro %}

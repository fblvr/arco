{% macro hash_pii(column_name) %}
    TO_HEX(md5(cast({{ column_name }} as STRING)))
{% endmacro %}

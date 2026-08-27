import duckdb

con = duckdb.connect("data/case.duckdb")

tables = [
    ("main_silver.dim_escolas", "id_escola"),
    ("main_silver.dim_produtos", "id_produto_unificado"),
    ("main_silver.dim_vendedores", "id_vendedor_sk"),
    ("main_silver.dim_contratos", "id_contrato"),
    ("main_silver.dim_usuarios", "id_usuario_sk"),
    ("main_silver.fct_vendas", "id_pedido"),
    ("main_silver.fct_vendas_itens", "id_item_pedido"),
    ("main_silver.fct_logistica_entregas", "id_entrega"),
    ("main_silver.fct_tickets", "id_ticket"),
    ("main_gold.obt_churn_risk_escolas", "id_escola"),
    ("main_gold.obt_logistica_sla", "id_entrega")
]

print("=== INICIANDO AUDITORIA QUÂNTICA (EVIDÊNCIA BRUTA) ===")

# 1. Unicidade e Integridade de PKs
print("\n--- 1. CHECAGEM DE CHAVES PRIMÁRIAS E NULOS ---")
for table, pk in tables:
    try:
        # Check nulls
        null_count = con.sql(f"SELECT COUNT(*) FROM {table} WHERE {pk} IS NULL").fetchone()[0]
        # Check dupes
        dupe_count = con.sql(f"SELECT COUNT(*) FROM (SELECT {pk} FROM {table} GROUP BY {pk} HAVING COUNT(*) > 1) t").fetchone()[0]
        # Total rows
        total_rows = con.sql(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        
        print(f"[{table}] Total Linhas: {total_rows} | PKs Nulas: {null_count} | PKs Duplicadas: {dupe_count}")
    except Exception as e:
        print(f"[{table}] ERRO: {str(e)}")

# 2. Fan-Out no Join de Vendas e Itens
print("\n--- 2. VALIDAÇÃO DE CARDINALIDADE (FAN-OUT) EM VENDAS ---")
try:
    total_fct_vendas = con.sql("SELECT COUNT(*) FROM main_silver.fct_vendas").fetchone()[0]
    total_vendas_joins = con.sql("""
        SELECT COUNT(DISTINCT v.id_pedido) 
        FROM main_silver.fct_vendas v
        JOIN main_silver.fct_vendas_itens vi ON v.id_pedido = vi.id_pedido
    """).fetchone()[0]
    print(f"FCT_VENDAS Header: {total_fct_vendas}")
    print(f"FCT_VENDAS Distinct IDs após JOIN com Itens: {total_vendas_joins}")
except Exception as e:
    print(f"ERRO: {e}")

# 3. Validação de Regras de Negócio (Status Normalization)
print("\n--- 3. VALIDAÇÃO DE NORMALIZAÇÃO DE STATUS ---")
try:
    status_contratos = con.sql("SELECT status, count(*) as count FROM main_silver.dim_contratos GROUP BY status").fetchall()
    status_tickets = con.sql("SELECT status, count(*) as count FROM main_silver.fct_tickets GROUP BY status").fetchall()
    print(f"DIM_CONTRATOS Status Grain: {status_contratos}")
    print(f"FCT_TICKETS Status Grain: {status_tickets}")
except Exception as e:
    print(f"ERRO: {e}")


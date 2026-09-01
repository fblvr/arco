# Regras de Negócio e Convenções do Data Warehouse

Este documento consolida as regras de negócio inferidas da operação e implementadas nas camadas Staging e Marts do dbt.

## 1. Identificação Universal (Chave CNPJ)
O ecossistema da Arco utiliza o **CNPJ** como chave universal para consolidar clientes entre o CRM, ERP A, ERP B e Zendesk.
- **Sanitização:** Todos os CNPJs devem ser limpos de caracteres especiais. A macro `clean_cnpj` extrai numerais de strings sujas utilizando `REGEXP_REPLACE(coluna, '[^0-9]', '')`.
- **Zendesk (Tickets e Organizations):** A chave do cliente não possui integridade rigorosa. O CNPJ é procurado no `external_id` ou de forma bruta dentro da descrição (campo `details`) da organização, via função de `COALESCE`.

## 2. Lógica Anti-Dummy e Limpeza de Lixo
As bases de produção não validam regras rígidas e acumulam dados de homologação.
- **E-mails Internos:** Clientes com domínio `@arco` são desconsiderados (filtrados no Staging de CRM, ERP A e ERP B) para não poluir tabelas de análise.
- **CNPJs Nulos Repetitivos:** Entradas contendo CNPJs como `00000000000000` ou `11111111111111` são excluídas na construção das dimensões transversais (ex: `dim_escolas`).

## 3. Gestão de Status e Cancelamento
O conceito de "Cancelado" difere entre os sistemas de backoffice:
- **ERP A:** O campo `docstatus` com valor `'C'` significa **Concluded** (Concluído/Entregue), indicando sucesso logístico. O cancelamento é regido estritamente pelo campo flag `cancelled = 'Y'`.
- **ERP B:** O campo de status pode conter o literal `'C'`, `'CANCELLED'` ou `'CANCELADO'`, e neste sistema, `'C'` de fato significa **Cancelado**.
A macro `normalize_status` removeu a generalização do `'C'` para evitar o super-faturamento de churn no ERP A. A modelagem (`fct_vendas`) lida explicitamente com essa ramificação semântica.

## 4. Colisão de Chaves Primárias (Union All)
Múltiplos ERPs partilham a mesma sequencia numérica para identificadores (ex: Id de vendedor `1`, Pedido `5000`).
Ao inserir esses dados em Tabelas Fato únicas (`fct_vendas`), o sistema **deve prefixar** as chaves primárias originárias com o nome do sistema (ex: `'ERPA_' || id_vendedor`). Essa regra é mandatória para evitar silent Fan-outs e sobreposição.

## 5. Nomenclatura (Context-First)
Todas as tabelas da camada Staging devem forçar a nomenclatura das colunas para o padrão `snake_case`, com a primeira palavra definindo o **contexto** lógico do domínio.
Exemplo:
- Incorreto: `id_pedido`, `nome_escola`, `dt_cadastro`
- Correto: `pedido_id`, `escola_nome`, `cadastro_data`
Isso garante o agrupamento alfabético das entidades nas documentações e ferramentas de BI.

## 6. Padrão de Estilização SQL
Todos os scripts `.sql` devem seguir 4 espaços de indentação para blocos de `SELECT` dentro de CTEs, facilitando a legibilidade e manutenção.

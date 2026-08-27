# Catálogo Oficial de Regras de Negócio (Arco Educação)

Este documento centraliza as regras lógicas e empíricas aplicadas no Data Warehouse. Ele serve como o norte para qualquer auditoria, evitando suposições cegas sobre métricas e transformações.

## 1. Tratamento de Sandboxes (Escolas de Teste)
**Problema:** Bases transacionais de ERP frequentemente possuem registros criados pela TI para homologação (ex: "ESCOLA DE HOMOLOGAÇÃO", "TESTE SISTEMA").
**Regra Aplicada:** A Dimensão de Escolas (`dim_escolas`) implementa um hard-filtering em tempo de processamento Core. Registros de ERP que não possuam e-mail, ou que o nome/e-mail contenham as strings lógicas de sandbox, são extirpados.
**Impacto Dimensional:** A cardinalidade da Gold sempre será (Total Staging - Sandboxes Excluídos). O volume não será 1:1.

## 2. Padrão de Órfãos em Pedidos (Fato Vendas)
**Problema:** Encontrado Join de Vendas (Header) vs Itens (Detail) gerando menos IDs únicos após o cruzamento, indicando Pedidos sem Itens.
**Regra Aplicada:** No ERP A, 5 registros foram mapeados sem amarrações filhas. Uma auditoria revelou que todos possuíam `status_pedido = 'CANCELLED'`.
**Documentação:** Órfãos com status Cancelado/Draft são esperados e legítimos. Eles representam aberturas de tela que não chegaram a gerar um item de faturamento. Não há vazamento ou Fan-Out nesses cenários.

## 3. Deduplicação Multissistema (Prevenção de Fan-Out)
**Problema:** Produtos ou Contas podem ter a mesma Nomenclatura no CRM (Salesforce) e no ERP B, mas IDs independentes. Um JOIN cego geraria duplicação cartesiana (Fan-out).
**Regra Aplicada:** Nas agregações de Core, dados de múltiplas origens são unidos (UNION ALL) e agregados via `GROUP BY UPPER(nome)`, forçando uma "Golden Record" baseada no nome normalizado, ao invés de depender de chaves fracas cruzadas erroneamente.

## 4. Normalização de Data Quality
Para garantir agrupamentos (GROUP BY) consistentes na Gold:
* **Status:** A macro `normalize_status` empilha strings como `[pending, open, PENDENTE, E]` sob o padrão único `PENDING`, e `[C, CANCELADO, CANCELLED]` como `CANCELLED`.
* **Telefones:** A macro `normalize_phone` corta DDI nacional (+55, 55) em início de string, espaços, traços e parenteses (DDI).
* **CNPJ:** A macro `normalize_cnpj` aplica máscara Regex cortando strings até sobrarem estritamente números contínuos, antes de aplicar a criptografia MD5 (LGPD).

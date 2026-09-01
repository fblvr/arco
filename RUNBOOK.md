# Arco Analytics - Runbook de Infraestrutura e Operação

Este documento centraliza as etapas para provisionar o ambiente local de Data Engineering (dbt + DuckDB) do zero em qualquer máquina macOS/Linux. 

## 1. Pré-Requisitos do Sistema

Certifique-se de que a máquina possui:
- **Homebrew** instalado (gerenciador de pacotes para macOS).
- **Python 3.9+** instalado (`python3 --version`).
- **Git** instalado.

---

## 2. Instalação das Ferramentas Nativas (CLI)

O projeto utiliza o DuckDB como motor analítico embarcado. Instale o CLI oficial para ter um terminal SQL profissional.

```bash
# Instalar o DuckDB via Homebrew
brew install duckdb

# Validar instalação
duckdb --version
```

---

## 3. Configuração do Ambiente Virtual Python e GCP

O dbt e os scripts auxiliares rodam de forma isolada para não poluir o sistema operacional. O ambiente real de Data Warehouse (Bronze, Silver, Gold) está hospedado no Google BigQuery.

```bash
# Clone o repositório e entre na pasta
git clone <url-do-repo>
cd arco

# Crie e ative o ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instale os requisitos (inclui dbt-bigquery)
pip install -r requirements.txt

# Autentique na Google Cloud para dar permissão ao dbt
gcloud auth application-default login
```

---

## 4. Inicialização do Data Warehouse (DBT - BigQuery)

O processamento analítico dimensional e de staging ocorre de forma 100% nativa na Google Cloud (BigQuery) usando o projeto e dataset definidos no seu `profiles.yml`.

```bash
# Entre na pasta do projeto dbt
cd arco_analytics

# Baixar dependências (packages como dbt-utils)
dbt deps

# Utilize o Makefile (na raiz) para rodar o build completo
cd ..
make build-dbt
```

### Execução Manual Avançada do DBT
Caso deseje debugar falhas ou rodar camadas específicas do BigQuery:
```bash
cd arco_analytics

# Rodar apenas as staging
dbt run --select staging

# Rodar os testes nativos configurados nos YMLs
dbt test

# Compilar todo o projeto
dbt build
```

---

## 5. Operação e Exploração Analítica

Com a infraestrutura provisionada e as tabelas `silver` e `gold` construídas, a exploração dos dados pode ser feita diretamente no CLI nativo do banco.

```bash
# Acesse o ambiente interativo SQL na raiz do projeto
duckdb data/case.duckdb
```

### Comandos Úteis dentro do DuckDB:
- `.tables`: Lista todas as tabelas e schemas disponíveis.
- `.schema <tabela>`: Visualiza a DDL de uma tabela.
- `SELECT * FROM silver.dim_escolas;`: Realiza queries consumindo a camada tratada.
- `.quit` ou `.exit`: Encerra o terminal.

### Execução de Scripts `.sql` Externos
Para rodar scripts SQL extensos construídos no editor, direcione-os para o DuckDB:
```bash
duckdb data/case.duckdb < meu_script.sql
```

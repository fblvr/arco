# Instalando o DuckDB

Pré-requisito: DuckDB 1.5.0+.

## macOS

```bash
brew install duckdb
```

## Windows / Linux

Baixe o binário da CLI direto na página oficial de releases: https://duckdb.org/docs/installation/

## Alternativa via Python

Se preferir explorar via notebook/Python em vez da CLI:

```bash
pip install duckdb
```

## Conferindo a instalação

```bash
duckdb --version
```

## Abrindo o banco do case

Na pasta `data/` do material recebido:

```bash
duckdb case.duckdb
```

Se preferir uma interface gráfica em vez do terminal, veja `guia-dbeaver.md`, incluso no material.

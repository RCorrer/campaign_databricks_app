# Campaign Orchestrator

Aplicação web para Databricks Apps com frontend React e backend FastAPI.

## Estrutura principal

- `frontend/index.html`: entrada do Vite
- `frontend/src/pages`: páginas separadas por etapa
- `backend/api/routes.py`: rotas HTTP
- `backend/services/campaign_service.py`: regras de negócio e dados demo
- `backend/services/query_builder.py`: geração do SQL de segmentação
- `config/semantic_mapping.yaml`: arquivo de/para
- `sql/00_catalogs_and_schemas.sql`: criação do catálogo e schemas
- `sql/01_campaign_app_tables.sql`: tabelas Delta de metadados da aplicação
- `sql/02_customer_base_tables.sql`: base mestre de clientes
- `sql/03_customer_360_tables.sql`: 10 tabelas 360 de negócio
- `sql/04_seed_customer_data.sql`: massa de dados compatível entre todas as tabelas
- `sql/05_campaign_sources_views.sql`: views de universo inicial e view enriquecida
- `sql/06_business_contracts.sql`: view consolidada da definição atual da campanha

## Ordem de execução dos arquivos SQL

1. `sql/00_catalogs_and_schemas.sql`
2. `sql/01_campaign_app_tables.sql`
3. `sql/02_customer_base_tables.sql`
4. `sql/03_customer_360_tables.sql`
5. `sql/04_seed_customer_data.sql`
6. `sql/05_campaign_sources_views.sql`
7. `sql/06_business_contracts.sql`

## Build do frontend

```bash
npm install
npm run build
```

## Backend

```bash
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## Observações

- O `index.html` fica dentro de `frontend/`.
- O build gera a pasta `dist/` na raiz do projeto.
- O SQL usa o padrão Databricks com nomes completos `catalog.schema.table`.
- As views em `main.campaign_sources` já trazem os campos necessários para o builder no-code do protótipo.

# Campaign Databricks App

CRM/CDP de campanhas para Databricks Apps com:
- Frontend React + Vite
- Backend FastAPI
- Persistência via Databricks `WorkspaceClient()` + `statement_execution`
- Segmentação no-code com público inicial, filtros nativos e cruzamentos temáticos
- Materialização da audiência em `main.campaign_execution.campaign_audience`

## Requisitos
- Databricks App com recurso de SQL Warehouse
- Variável `DATABRICKS_WAREHOUSE_ID` disponível no runtime do app
- Grants aplicados ao service principal do app
- SQLs executados na ordem da pasta `sql/`

## Ordem dos SQLs
1. `sql/00_reset_all_project_objects.sql`
2. `sql/01_catalogs_and_schemas.sql`
3. `sql/02_customer_base_tables.sql`
4. `sql/03_customer_360_tables.sql`
5. `sql/04_campaign_app_tables.sql`
6. `sql/05_campaign_execution_tables.sql`
7. `sql/06_seed_customer_data.sql`
8. `sql/07_campaign_sources_views.sql`
9. `sql/08_seed_campaign_data.sql`
10. `sql/09_business_contracts.sql`
11. `sql/10_app_grants.sql`

## Desenvolvimento local
### Backend
```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Build no Databricks App
O build do frontend é feito pelo próprio Databricks App via Vite.

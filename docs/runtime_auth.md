# Runtime auth no Databricks App

O projeto usa `WorkspaceClient()` sem host/token explícitos.

Requisitos:
- resource de SQL Warehouse no App
- variável `DATABRICKS_WAREHOUSE_ID` vinda de `valueFrom: sql-warehouse`
- grants do arquivo `sql/08_app_grants.sql` aplicados ao service principal do App

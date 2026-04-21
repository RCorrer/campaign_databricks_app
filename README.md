# Campaign Databricks App

Aplicação CRM inspirada em Salesforce Data Cloud / CDP para execução dentro de Databricks Apps.

## Arquitetura funcional

A segmentação segue este fluxo:

1. o usuário escolhe um **público inicial** em `main.campaign_sources`
2. aplica **filtros nativos** sobre campos da própria view inicial
3. aplica **cruzamentos temáticos** com tabelas de `main.customer_360` por `cpf_cnpj`
4. o resultado final materializa somente os `cpf_cnpj` elegíveis em `main.campaign_execution`
5. os metadados e versões ficam em `main.campaign_app`

## Schemas

- `main.campaign_app`: metadados, briefing, segmentação, ativação, histórico
- `main.customer_base`: base mestre de clientes
- `main.customer_360`: bases temáticas para cruzamento
- `main.campaign_sources`: views de público inicial
- `main.campaign_execution`: audiência final e log de execução

## Ordem de execução dos SQLs

1. `sql/00_catalogs_and_schemas.sql`
2. `sql/01_campaign_app_tables.sql`
3. `sql/02_customer_base_tables.sql`
4. `sql/03_customer_360_tables.sql`
5. `sql/06_campaign_execution_tables.sql`
6. `sql/04_seed_customer_data.sql`
7. `sql/05_campaign_sources_views.sql`
8. `sql/07_business_contracts.sql`

## Observação de deploy

Não versione `node_modules/` nem `dist/`. O build usa `node ./node_modules/vite/bin/vite.js build --config vite.config.js` para evitar o erro de permissão do binário do Vite no Databricks Apps.

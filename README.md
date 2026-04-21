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

Execute exatamente nesta ordem:

1. `sql/00_catalogs_and_schemas.sql`
2. `sql/01_campaign_app_tables.sql`
3. `sql/02_customer_base_tables.sql`
4. `sql/03_customer_360_tables.sql`
5. `sql/04_seed_customer_data.sql`
6. `sql/05_campaign_sources_views.sql`
7. `sql/06_campaign_execution_tables.sql`
8. `sql/07_business_contracts.sql`

## O que cada etapa cria

### 1. `00_catalogs_and_schemas.sql`
Cria o catálogo `main` e os schemas do projeto.

### 2. `01_campaign_app_tables.sql`
Cria as tabelas de metadados da aplicação.

### 3. `02_customer_base_tables.sql`
Cria a tabela mestre `main.customer_base.customer_master`.

### 4. `03_customer_360_tables.sql`
Cria as 10 tabelas temáticas de CRM e banking:
- contas
- saldos
- cartões
- gastos de cartão
- investimentos
- elegibilidade
- perfil de crédito
- empréstimos
- canais digitais
- seguros

### 5. `04_seed_customer_data.sql`
Insere massa de dados consistente entre todas as tabelas usando os mesmos `cpf_cnpj`.

### 6. `05_campaign_sources_views.sql`
Cria as views de público inicial:
- `vw_publico_base_clientes`
- `vw_publico_prime`
- `vw_publico_exclusive`
- `vw_publico_pj`
- `vw_publico_varejo`
- `vw_publico_jovem_digital`

### 7. `06_campaign_execution_tables.sql`
Cria as tabelas de execução:
- `campaign_audience`
- `campaign_run_log`

### 8. `07_business_contracts.sql`
Cria a view consolidada `vw_campaign_current_definition`.

## Arquivos principais para configuração do app

- `config/semantic_mapping.yaml`: catálogo do builder no-code
- `backend/core/config.py`: namespaces e configurações do app
- `backend/services/query_builder.py`: geração do SQL da segmentação
- `backend/services/campaign_service.py`: fluxo da campanha e SQL de ativação
- `frontend/src/pages/SegmentationPage.jsx`: tela de segmentação
- `frontend/src/pages/ActivationPage.jsx`: tela de ativação

## Build local

```bash
npm install
npm run build
```

## Backend local

```bash
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```


## Acessos do Databricks App

- Arquivo de grants: `sql/08_app_grants.sql`
- Guia rápido: `docs/app_access.md`
- Substitua `<APP_SERVICE_PRINCIPAL>` pelo principal exato do app antes de executar o SQL.


## Persistência real no Databricks

Nesta versão, o backend grava e lê campanhas diretamente nas tabelas do Unity Catalog usando o SQL Warehouse configurado via:

- `DATABRICKS_HOST`
- `DATABRICKS_TOKEN`
- `DATABRICKS_WAREHOUSE_ID`

Se você já criou `main.campaign_app.campaign_header` em uma versão antiga sem a coluna `description`, execute também:

- `sql/09_campaign_app_add_description.sql`
- `sql/07_business_contracts.sql`
- `sql/08_app_grants.sql`


## Autenticação no Databricks App

Este projeto usa o mesmo padrão do app de exemplo: o backend acessa o Databricks com `WorkspaceClient()` e `statement_execution`, sem exigir `DATABRICKS_HOST` nem `DATABRICKS_TOKEN` no ambiente do App.

Variável obrigatória no `app.yaml`:
- `DATABRICKS_WAREHOUSE_ID`

Também é necessário:
- ter o SQL Warehouse adicionado como resource do App
- executar `sql/08_app_grants.sql` para dar acesso ao service principal do App

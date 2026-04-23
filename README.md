# Orquestrador de Campanhas no Databricks App

Aplicação CRM/CDP para criação, preparação, segmentação e ativação de campanhas dentro do Databricks Apps.

## Importante

Esta versão remove os contratos antigos em inglês e mantém o projeto alinhado em PT-BR:

- schemas em PT-BR
- tabelas em PT-BR
- colunas em PT-BR
- backend em PT-BR
- frontend consumindo rotas em PT-BR
- SQLs ordenados para execução limpa

O layout do frontend foi mantido na mesma proposta visual: painel em cards e fluxo por etapas de preparação, segmentação e ativação.

## Estrutura

```text
backend/
  api/rotas.py
  configuracoes/configuracao.py
  modelos/contratos.py
  repositorios/databricks_sql.py
  servicos/campanha.py
  servicos/construtor_consulta.py
  utilitarios/
config/
  mapeamento_semantico.yaml
frontend/
  src/
sql/
  00_limpar_schemas.sql
  01_catalogos_e_schemas.sql
  02_tabelas_aplicacao_campanhas.sql
  03_tabela_base_clientes.sql
  04_tabelas_cliente_360.sql
  05_carga_dados_clientes.sql
  06_views_fontes_campanha.sql
  07_tabelas_execucao_campanha.sql
  08_view_contrato_negocio.sql
  09_permissoes_app.sql
app.yaml
main.py
requirements.txt
package.json
```

## Ordem de execução dos SQLs

Execute exatamente nesta ordem:

1. `sql/00_limpar_schemas.sql`
2. `sql/01_catalogos_e_schemas.sql`
3. `sql/02_tabelas_aplicacao_campanhas.sql`
4. `sql/03_tabela_base_clientes.sql`
5. `sql/04_tabelas_cliente_360.sql`
6. `sql/05_carga_dados_clientes.sql`
7. `sql/06_views_fontes_campanha.sql`
8. `sql/07_tabelas_execucao_campanha.sql`
9. `sql/08_view_contrato_negocio.sql`
10. `sql/09_permissoes_app.sql`

Antes de executar `09_permissoes_app.sql`, substitua `<APP_SERVICE_PRINCIPAL>` pelo service principal do Databricks App.

## Databricks App

A variável obrigatória é:

```text
DATABRICKS_WAREHOUSE_ID
```

O backend usa `WorkspaceClient()` com `statement_execution`, compatível com execução no Databricks App.

## Build

```bash
npm run build
```

## Execução local

```bash
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## Fluxo funcional

1. Criar campanha no painel.
2. Abrir fluxo da campanha.
3. Salvar briefing na etapa Preparação.
4. Salvar segmentação na etapa Segmentação.
5. Ativar campanha na etapa Ativação.
6. Conferir público em `main.execucao_campanha.campanha_publico`.

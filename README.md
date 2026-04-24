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
  vite.config.js
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
  10_carga_dados_campanhas.sql
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
11. `sql/10_carga_dados_campanhas.sql` *(opcional - carga de campanhas de teste)*

### Importante sobre permissões

Antes de executar `09_permissoes_app.sql`, substitua o UUID de exemplo `54bb9d86-5e09-4386-a51a-30ac477e8155` pelo Service Principal ID do seu Databricks App.

### Carga de dados de teste

O arquivo `10_carga_dados_campanhas.sql` é opcional e serve para popular o banco com campanhas de exemplo para testar a aplicação. Execute-o após os demais SQLs se desejar ter dados de demonstração.

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

## Arquitetura

### Backend

* **FastAPI** para API REST
* **Databricks SDK** para integração com SQL Warehouse via Statement Execution API
* **Pydantic** para validação de dados e contratos
* **PyYAML** para mapeamento semântico de público e campos

### Frontend

* **React** com Vite para interface de usuário
* **React Router** para navegação entre páginas
* **API Client** customizado com fetch para comunicação com backend

### Banco de Dados

* **Unity Catalog** com schemas organizados por domínio:
  * `aplicacao_campanhas` - metadados e versionamento
  * `base_clientes` - base mestre de clientes
  * `cliente_360` - visões temáticas dos clientes
  * `fontes_campanha` - views de público inicial
  * `execucao_campanha` - audiência materializada e logs

## Funcionalidades

### Gestão de Campanhas

* Criar, listar, editar e excluir campanhas
* Controle de status com transições validadas
* Versionamento de segmentações
* Histórico de alterações e auditoria

### Briefing

* Desafio e resultado esperado
* Canais de comunicação
* Restrições e regras de negócio
* Observações

### Segmentação

* Seleção de público inicial (base, prime, exclusive, PJ, varejo, jovem digital)
* Regras de inclusão e exclusão nativas (campos da base)
* Regras de inclusão e exclusão temáticas (tabelas cliente_360)
* SQL preview para validação
* Contagem estimada de público

### Ativação

* Materialização como TABLE ou VIEW
* Modo de execução MANUAL ou AGENDADO
* Datas de vigência
* Criação automática de objeto no schema execucao_campanha
* Log de execução

## Observações Técnicas

* O frontend serve arquivos estáticos após o build via FastAPI
* A API usa prefixo `/api` para todas as rotas
* SQL dinâmico é gerado de forma segura usando funções de escape
* Statement Execution API aguarda conclusão com polling
* Mapeamento semântico define campos e tabelas disponíveis para segmentação

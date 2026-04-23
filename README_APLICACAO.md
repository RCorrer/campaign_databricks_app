# Patch PT-BR - CRM/CDP Databricks App

Este pacote parte da versão atual do repositório `RCorrer/campaign_databricks_app` e ajusta a camada ativa de banco/backend para português.

## O que foi alterado

- Inclusão de um SQL inicial para limpar todos os schemas do projeto.
- Renumeração e ordenação dos SQLs por ordem real de execução.
- Renomeação dos schemas, tabelas, colunas e comentários do banco para português.
- Ajuste do backend ativo (`campaign_service.py`) para usar os novos nomes do banco.
- Ajuste do `query_builder.py` para usar campos e tabelas em português na segmentação.
- Ajuste do `semantic_mapping.yaml` para apontar para views/tabelas/colunas em português.
- Desativação explícita dos services soltos que estavam desalinhados e não eram usados pelas rotas atuais.

## Mapeamento de arquivos

### Substituir no projeto

| Arquivo no pacote | Destino no repositório |
|---|---|
| `backend/core/config.py` | `backend/core/config.py` |
| `backend/services/campaign_service.py` | `backend/services/campaign_service.py` |
| `backend/services/query_builder.py` | `backend/services/query_builder.py` |
| `backend/services/execution_service.py` | `backend/services/execution_service.py` |
| `backend/services/dashboard_service.py` | `backend/services/dashboard_service.py` |
| `config/semantic_mapping.yaml` | `config/semantic_mapping.yaml` |

### Substituir a pasta SQL

Remova ou arquive os SQLs antigos e use os arquivos abaixo:

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

## Ordem de execução

Para recriar tudo do zero:

```text
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
```

## Observação importante

O frontend e os contratos Pydantic ainda possuem chaves técnicas em inglês porque isso exigiria uma migração maior de API e telas. A mudança deste pacote cobre o banco, o backend ativo e o catálogo de segmentação. A próxima etapa recomendada é migrar `contracts.py`, `routes.py` e as páginas React para nomes totalmente em português.

## Checklist de validação

Depois de aplicar e executar os SQLs:

1. Abrir o App.
2. Criar uma campanha.
3. Salvar o briefing.
4. Salvar a segmentação usando um público inicial.
5. Ativar a campanha.
6. Conferir as tabelas:
   - `main.aplicacao_campanhas.campanha_cabecalho`
   - `main.aplicacao_campanhas.campanha_segmentacao_versao`
   - `main.aplicacao_campanhas.campanha_ativacao_versao`
   - `main.execucao_campanha.campanha_audiencia`
   - `main.execucao_campanha.campanha_log_execucao`

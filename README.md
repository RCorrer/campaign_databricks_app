# Campaign Orchestrator for Databricks Apps

Aplicação web para gestão de campanhas inspirada no fluxo de **Salesforce Workflow + Data Cloud**, adaptada para execução em **Databricks Apps** com front-end React e back-end FastAPI.

## Objetivo

O software foi redesenhado para suportar o ciclo:

1. **Preparação**: criação e refinamento do briefing
2. **Segmentação**: definição no-code do público com abas de universo inicial, inclusão e exclusão
3. **Ativação**: geração do público materializado e publicação controlada por vigência
4. **Operação**: ativo, pausado, concluído, encerrado ou cancelado

## Estrutura

```text
campaign_databricks_app/
├── app.yaml
├── main.py
├── requirements.txt
├── package.json
├── vite.config.js
├── index.html
├── backend/
│   ├── api/
│   ├── core/
│   ├── models/
│   ├── repositories/
│   ├── services/
│   └── utils/
├── frontend/
│   └── src/
├── config/
├── sql/
├── docs/
└── scripts/
```

## Regras principais

### 1. Preparação
- A campanha nasce em `PREPARACAO`.
- O briefing é versionado.
- Regras, objetivos, canais e vigência ficam salvos em metadados.
- Alterações geram auditoria.

### 2. Segmentação
- O usuário segmenta via interface no-code.
- Existem 3 abas:
  - **Universo inicial**: escolhe views base do schema de origem.
  - **Inclusão**: regras positivas.
  - **Exclusão**: regras negativas.
- O motor usa um arquivo de/para para traduzir `assunto -> tabela/view -> campo -> operador`.
- Todas as tabelas de negócio são relacionadas por `cpf_cnpj`.

### 3. Ativação
- Quando ativada, a campanha gera uma tabela Delta com:
  - `campaign_id`
  - `cpf_cnpj`
  - `segmentation_ts`
  - `activation_start_date`
  - `activation_end_date`
  - `rule_version`
- A ativação sempre usa a versão vigente do briefing + segmentação.
- Alterações em regras após ativação geram nova versão.

### 4. Estados finais e transições
- Fluxo principal: `PREPARACAO -> SEGMENTACAO -> ATIVACAO -> ATIVO`
- A partir de `ATIVO`, pode ir para `PAUSADO`, voltar para `ATIVO`, ou encerrar em `CONCLUIDO` / `ENCERRADO`
- `CANCELADO` pode ocorrer em qualquer etapa
- `CONCLUIDO` ocorre por fim natural da vigência
- `ENCERRADO` ocorre por ação manual antes do fim

## Como executar localmente

### Backend
```bash
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend
```bash
npm install
npm run build
```

## Variáveis de ambiente

- `DATABRICKS_HOST`
- `DATABRICKS_TOKEN`
- `DATABRICKS_WAREHOUSE_ID`
- `UC_CATALOG`
- `UC_METADATA_SCHEMA`
- `UC_BUSINESS_SCHEMA`
- `CAMPAIGN_SOURCE_SCHEMA`
- `CAMPAIGN_MAPPING_FILE`

## Observação

O projeto foi estruturado para servir como **base arquitetural completa**, com APIs, contratos, documentação, DDL inicial e um front-end que representa o fluxo do produto. A parte de execução SQL foi preparada para Databricks SQL Warehouse e Delta tables.

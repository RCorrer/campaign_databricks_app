# Campaign Orchestrator

Aplicação web para Databricks Apps com frontend React e backend FastAPI.

## Estrutura principal

- `frontend/index.html`: entrada do Vite
- `frontend/src/pages`: páginas separadas por etapa
- `backend/api/routes.py`: rotas HTTP
- `backend/services/campaign_service.py`: regras de negócio e dados demo
- `backend/services/query_builder.py`: geração do SQL de segmentação
- `config/semantic_mapping.yaml`: arquivo de/para
- `sql/01_metadata_tables.sql`: criação das tabelas Delta
- `sql/02_business_contracts.sql`: view consolidada

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

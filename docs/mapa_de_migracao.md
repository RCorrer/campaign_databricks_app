# Mapa de migração dos nomes principais

## Schemas

| Antes | Depois |
|---|---|
| `main.campaign_app` | `main.aplicacao_campanhas` |
| `main.customer_base` | `main.base_clientes` |
| `main.customer_360` | `main.cliente_360` |
| `main.campaign_sources` | `main.fontes_campanha` |
| `main.campaign_execution` | `main.execucao_campanha` |

## Tabelas principais

| Antes | Depois |
|---|---|
| `campaign_header` | `campanha_cabecalho` |
| `campaign_briefing_version` | `campanha_briefing_versao` |
| `campaign_segmentation_version` | `campanha_segmentacao_versao` |
| `campaign_activation_version` | `campanha_ativacao_versao` |
| `campaign_status_history` | `campanha_historico_status` |
| `campaign_audit_event` | `campanha_evento_auditoria` |
| `campaign_audience` | `campanha_audiencia` |
| `campaign_run_log` | `campanha_log_execucao` |
| `customer_master` | `cliente_mestre` |
| `vw_campaign_current_definition` | `vw_definicao_atual_campanha` |

## Próxima etapa sugerida

Migrar os nomes das chaves da API e dos componentes React para português, por exemplo:

| Atual | Próximo |
|---|---|
| `campaign_id` | `id_campanha` |
| `name` | `nome` |
| `theme` | `tema` |
| `objective` | `objetivo` |
| `segmentation` | `segmentacao` |
| `activation` | `ativacao` |

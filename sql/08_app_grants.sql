-- Template de grants para o service principal do Databricks App.
-- Substitua <APP_SERVICE_PRINCIPAL> pelo nome exato do principal do app.
-- Exemplo: `service-principal:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

-- =========================
-- Catálogo e schemas
-- =========================
GRANT USE CATALOG ON CATALOG main TO `<APP_SERVICE_PRINCIPAL>`;

GRANT USE SCHEMA ON SCHEMA main.campaign_app TO `<APP_SERVICE_PRINCIPAL>`;
GRANT USE SCHEMA ON SCHEMA main.customer_base TO `<APP_SERVICE_PRINCIPAL>`;
GRANT USE SCHEMA ON SCHEMA main.customer_360 TO `<APP_SERVICE_PRINCIPAL>`;
GRANT USE SCHEMA ON SCHEMA main.campaign_sources TO `<APP_SERVICE_PRINCIPAL>`;
GRANT USE SCHEMA ON SCHEMA main.campaign_execution TO `<APP_SERVICE_PRINCIPAL>`;

-- A aplicação gera comandos de CREATE OR REPLACE TABLE no schema de execução.
GRANT CREATE TABLE ON SCHEMA main.campaign_execution TO `<APP_SERVICE_PRINCIPAL>`;

-- =========================
-- Objetos lidos pela aplicação
-- =========================
-- campaign_sources (públicos iniciais)
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_base_clientes TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_prime TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_exclusive TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_pj TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_varejo TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_jovem_digital TO `<APP_SERVICE_PRINCIPAL>`;

-- customer_base
GRANT SELECT ON TABLE main.customer_base.customer_master TO `<APP_SERVICE_PRINCIPAL>`;

-- customer_360 (temas de cruzamento)
GRANT SELECT ON TABLE main.customer_360.tb_contas TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_saldos_conta TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_cartoes TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_gastos_cartao TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_investimentos TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_elegibilidade_ofertas TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_credito_perfil TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_emprestimos TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_canais_digitais TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.customer_360.tb_seguro_produtos TO `<APP_SERVICE_PRINCIPAL>`;

-- campaign_app (metadados e contratos)
GRANT SELECT ON TABLE main.campaign_app.campaign_header TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.campaign_app.campaign_briefing_version TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.campaign_app.campaign_segmentation_version TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.campaign_app.campaign_activation_version TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.campaign_app.campaign_status_history TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON TABLE main.campaign_app.campaign_audit_event TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT ON VIEW main.campaign_app.vw_campaign_current_definition TO `<APP_SERVICE_PRINCIPAL>`;

-- =========================
-- Objetos escritos pela aplicação
-- =========================
GRANT SELECT, MODIFY ON TABLE main.campaign_execution.campaign_audience TO `<APP_SERVICE_PRINCIPAL>`;
GRANT SELECT, MODIFY ON TABLE main.campaign_execution.campaign_run_log TO `<APP_SERVICE_PRINCIPAL>`;

-- Opcional: se você quiser que o app também persista metadados diretamente nas tabelas
-- de main.campaign_app, habilite MODIFY nelas.
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_header TO `<APP_SERVICE_PRINCIPAL>`;
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_briefing_version TO `<APP_SERVICE_PRINCIPAL>`;
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_segmentation_version TO `<APP_SERVICE_PRINCIPAL>`;
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_activation_version TO `<APP_SERVICE_PRINCIPAL>`;
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_status_history TO `<APP_SERVICE_PRINCIPAL>`;
-- GRANT MODIFY ON TABLE main.campaign_app.campaign_audit_event TO `<APP_SERVICE_PRINCIPAL>`;

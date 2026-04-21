-- Grants para o service principal do Databricks App.
-- Principal validado para este projeto: 54bb9d86-5e09-4386-a51a-30ac477e8155

-- =========================
-- Catálogo e schemas
-- =========================
GRANT USE CATALOG ON CATALOG main TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT USE SCHEMA ON SCHEMA main.campaign_app TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.customer_base TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.customer_360 TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.campaign_sources TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.campaign_execution TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- A aplicação gera comandos de CREATE OR REPLACE TABLE no schema de execução.
GRANT CREATE TABLE ON SCHEMA main.campaign_execution TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- =========================
-- Objetos lidos pela aplicação
-- =========================
-- campaign_sources (públicos iniciais)
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_base_clientes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_prime TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_exclusive TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_pj TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_varejo TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_sources.vw_publico_jovem_digital TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- customer_base
GRANT SELECT ON TABLE main.customer_base.customer_master TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- customer_360 (temas de cruzamento)
GRANT SELECT ON TABLE main.customer_360.tb_contas TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_saldos_conta TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_cartoes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_gastos_cartao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_investimentos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_elegibilidade_ofertas TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_credito_perfil TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_emprestimos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_canais_digitais TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.customer_360.tb_seguro_produtos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- campaign_app (metadados e contratos)
GRANT SELECT ON TABLE main.campaign_app.campaign_header TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campaign_app.campaign_briefing_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campaign_app.campaign_segmentation_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campaign_app.campaign_activation_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campaign_app.campaign_status_history TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campaign_app.campaign_audit_event TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.campaign_app.vw_campaign_current_definition TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- =========================
-- Objetos escritos pela aplicação
-- =========================
GRANT SELECT, MODIFY ON TABLE main.campaign_execution.campaign_audience TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.campaign_execution.campaign_run_log TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_header TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_briefing_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_segmentation_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_activation_version TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_status_history TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT MODIFY ON TABLE main.campaign_app.campaign_audit_event TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

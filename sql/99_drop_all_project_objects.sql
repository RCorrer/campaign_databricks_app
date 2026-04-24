-- Execute este script para remover todos os objetos do projeto CRM
-- Ordem reversa: views -> tabelas -> schemas

DROP VIEW IF EXISTS main.campaign_app.vw_campaign_current_definition;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_jovem_digital;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_varejo;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_pj;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_exclusive;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_prime;
DROP VIEW IF EXISTS main.campaign_sources.vw_publico_base_clientes;

DROP TABLE IF EXISTS main.campaign_execution.campaign_run_log;
DROP TABLE IF EXISTS main.campaign_execution.campaign_audience;

DROP TABLE IF EXISTS main.campaign_app.campaign_audit_event;
DROP TABLE IF EXISTS main.campaign_app.campaign_status_history;
DROP TABLE IF EXISTS main.campaign_app.campaign_activation_version;
DROP TABLE IF EXISTS main.campaign_app.campaign_segmentation_version;
DROP TABLE IF EXISTS main.campaign_app.campaign_briefing_version;
DROP TABLE IF EXISTS main.campaign_app.campaign_header;

DROP TABLE IF EXISTS main.customer_360.tb_seguro_produtos;
DROP TABLE IF EXISTS main.customer_360.tb_canais_digitais;
DROP TABLE IF EXISTS main.customer_360.tb_emprestimos;
DROP TABLE IF EXISTS main.customer_360.tb_credito_perfil;
DROP TABLE IF EXISTS main.customer_360.tb_elegibilidade_ofertas;
DROP TABLE IF EXISTS main.customer_360.tb_investimentos;
DROP TABLE IF EXISTS main.customer_360.tb_gastos_cartao;
DROP TABLE IF EXISTS main.customer_360.tb_cartoes;
DROP TABLE IF EXISTS main.customer_360.tb_saldos_conta;
DROP TABLE IF EXISTS main.customer_360.tb_contas;
DROP TABLE IF EXISTS main.customer_base.customer_master;

DROP SCHEMA IF EXISTS main.campaign_sources CASCADE;
DROP SCHEMA IF EXISTS main.campaign_execution CASCADE;
DROP SCHEMA IF EXISTS main.customer_360 CASCADE;
DROP SCHEMA IF EXISTS main.customer_base CASCADE;
DROP SCHEMA IF EXISTS main.campaign_app CASCADE;

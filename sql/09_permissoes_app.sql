-- ============================================================
-- 09 - Permissões do Databricks App
-- ============================================================
-- Substitua o valor abaixo pelo service principal real do Databricks App.
-- Exemplo atual conhecido do projeto: 54bb9d86-5e09-4386-a51a-30ac477e8155

GRANT USE CATALOG ON CATALOG main TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT USE SCHEMA ON SCHEMA main.aplicacao_campanhas TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.base_clientes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.cliente_360 TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.fontes_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.execucao_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT CREATE TABLE ON SCHEMA main.execucao_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT CREATE VIEW ON SCHEMA main.execucao_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_cabecalho TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_briefing_versao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_segmentacao_versao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_ativacao_versao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_historico_status TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.aplicacao_campanhas.campanha_evento_auditoria TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT SELECT ON VIEW main.aplicacao_campanhas.vw_definicao_atual_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT SELECT ON TABLE main.base_clientes.cliente_mestre TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_contas TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_saldos_conta TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_cartoes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_gastos_cartao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_investimentos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_elegibilidade_ofertas TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_credito_perfil TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_emprestimos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_canais_digitais TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.tb_seguro_produtos TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_base_clientes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_prime TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_exclusive TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_pj TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_varejo TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON VIEW main.fontes_campanha.vw_publico_jovem_digital TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

GRANT SELECT, MODIFY ON TABLE main.execucao_campanha.campanha_audiencia TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT, MODIFY ON TABLE main.execucao_campanha.campanha_log_execucao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

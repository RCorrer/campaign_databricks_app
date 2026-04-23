-- ============================================================
-- 00 - Limpeza completa dos schemas do projeto
-- ============================================================
-- Use este arquivo quando quiser recriar todo o ambiente do zero.
-- Ele remove tabelas, views e schemas usados pela aplicação.
-- Atenção: todos os dados de campanha, clientes e execução serão apagados.

DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_jovem_digital;
DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_varejo;
DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_pj;
DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_exclusive;
DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_prime;
DROP VIEW IF EXISTS main.fontes_campanha.vw_publico_base_clientes;
DROP VIEW IF EXISTS main.aplicacao_campanhas.vw_definicao_atual_campanha;

DROP TABLE IF EXISTS main.execucao_campanha.campanha_audiencia;
DROP TABLE IF EXISTS main.execucao_campanha.campanha_log_execucao;

DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_ativacao_versao;
DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_segmentacao_versao;
DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_briefing_versao;
DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_historico_status;
DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_evento_auditoria;
DROP TABLE IF EXISTS main.aplicacao_campanhas.campanha_cabecalho;

DROP TABLE IF EXISTS main.cliente_360.tb_contas;
DROP TABLE IF EXISTS main.cliente_360.tb_saldos_conta;
DROP TABLE IF EXISTS main.cliente_360.tb_cartoes;
DROP TABLE IF EXISTS main.cliente_360.tb_gastos_cartao;
DROP TABLE IF EXISTS main.cliente_360.tb_investimentos;
DROP TABLE IF EXISTS main.cliente_360.tb_elegibilidade_ofertas;
DROP TABLE IF EXISTS main.cliente_360.tb_credito_perfil;
DROP TABLE IF EXISTS main.cliente_360.tb_emprestimos;
DROP TABLE IF EXISTS main.cliente_360.tb_canais_digitais;
DROP TABLE IF EXISTS main.cliente_360.tb_seguro_produtos;

DROP TABLE IF EXISTS main.base_clientes.cliente_mestre;

DROP SCHEMA IF EXISTS main.execucao_campanha;
DROP SCHEMA IF EXISTS main.fontes_campanha;
DROP SCHEMA IF EXISTS main.aplicacao_campanhas;
DROP SCHEMA IF EXISTS main.cliente_360;
DROP SCHEMA IF EXISTS main.base_clientes;

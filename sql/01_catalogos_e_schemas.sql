-- ============================================================
-- 01 - Catálogo e schemas do projeto
-- ============================================================

CREATE CATALOG IF NOT EXISTS main;

CREATE SCHEMA IF NOT EXISTS main.aplicacao_campanhas
COMMENT 'Metadados, briefing, segmentação, ativação, histórico e auditoria das campanhas.';

CREATE SCHEMA IF NOT EXISTS main.base_clientes
COMMENT 'Base mestre de clientes usada como origem principal da aplicação.';

CREATE SCHEMA IF NOT EXISTS main.cliente_360
COMMENT 'Tabelas temáticas com visão 360 do cliente para cruzamentos de segmentação.';

CREATE SCHEMA IF NOT EXISTS main.fontes_campanha
COMMENT 'Views de públicos iniciais disponíveis para criação de campanhas.';

CREATE SCHEMA IF NOT EXISTS main.execucao_campanha
COMMENT 'Audiências materializadas e logs de execução das campanhas.';

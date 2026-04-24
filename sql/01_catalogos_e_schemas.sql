CREATE CATALOG IF NOT EXISTS main;

CREATE SCHEMA IF NOT EXISTS main.aplicacao_campanhas COMMENT 'Metadados, versões, status e auditoria das campanhas';
CREATE SCHEMA IF NOT EXISTS main.base_clientes COMMENT 'Base mestre de clientes';
CREATE SCHEMA IF NOT EXISTS main.cliente_360 COMMENT 'Visão temática 360 dos clientes';
CREATE SCHEMA IF NOT EXISTS main.fontes_campanha COMMENT 'Views de público inicial para campanhas';
CREATE SCHEMA IF NOT EXISTS main.execucao_campanha COMMENT 'Audiência final materializada e logs de execução';

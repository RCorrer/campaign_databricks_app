-- Remove todos os objetos dos schemas antigos e novos do projeto.
-- Use somente em ambiente de desenvolvimento ou homologação.

DROP SCHEMA IF EXISTS main.campaign_app CASCADE;
DROP SCHEMA IF EXISTS main.customer_base CASCADE;
DROP SCHEMA IF EXISTS main.customer_360 CASCADE;
DROP SCHEMA IF EXISTS main.campaign_sources CASCADE;
DROP SCHEMA IF EXISTS main.campaign_execution CASCADE;

DROP SCHEMA IF EXISTS main.aplicacao_campanhas CASCADE;
DROP SCHEMA IF EXISTS main.base_clientes CASCADE;
DROP SCHEMA IF EXISTS main.cliente_360 CASCADE;
DROP SCHEMA IF EXISTS main.fontes_campanha CASCADE;
DROP SCHEMA IF EXISTS main.execucao_campanha CASCADE;

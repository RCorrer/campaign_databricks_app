-- ============================================================
-- Grants para o service principal do Databricks App (Customer Insights)
-- Principal: 54bb9d86-5e09-4386-a51a-30ac477e8155
-- Objetivo: Permitir leitura das tabelas de campanhas e clientes,
--           e criação de views no schema de leads.
-- ============================================================

-- ---------------------------
-- Catálogo
-- ---------------------------
GRANT USE CATALOG ON CATALOG main TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- ---------------------------
-- Schemas
-- ---------------------------
GRANT USE SCHEMA ON SCHEMA main.publico_alvo    TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.cliente_360     TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.campanhas       TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT USE SCHEMA ON SCHEMA main.leads_campanha  TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- ---------------------------
-- Tabelas de domínio (leitura)
-- ---------------------------

-- publico_alvo
GRANT SELECT ON TABLE main.publico_alvo.clientes TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- cliente_360
GRANT SELECT ON TABLE main.cliente_360.conta                 TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.saldo                 TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.elegibilidade         TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.bens_patrimonio       TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.credito               TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.transacoes            TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.engajamento_digital   TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.produtos_contratados  TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.endividamento         TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.cliente_360.investimentos_perfil  TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- campanhas
GRANT SELECT ON TABLE main.campanhas.brieffing          TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
GRANT SELECT ON TABLE main.campanhas.regras_segmentacao TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;

-- ---------------------------
-- Criação de views no schema de leads
-- (No metastore 1.0, CREATE TABLE permite criar tabelas e views)
-- ---------------------------
GRANT CREATE TABLE ON SCHEMA main.leads_campanha TO `54bb9d86-5e09-4386-a51a-30ac477e8155`;
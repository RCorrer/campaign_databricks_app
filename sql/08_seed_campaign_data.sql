DELETE FROM main.campaign_execution.campaign_audience;
DELETE FROM main.campaign_execution.campaign_run_log;
DELETE FROM main.campaign_app.campaign_activation_version;
DELETE FROM main.campaign_app.campaign_segmentation_version;
DELETE FROM main.campaign_app.campaign_briefing_version;
DELETE FROM main.campaign_app.campaign_status_history;
DELETE FROM main.campaign_app.campaign_audit_event;
DELETE FROM main.campaign_app.campaign_header;

INSERT INTO main.campaign_app.campaign_header VALUES
('CMP-PRIME001', 'Campanha Prime Cartões', 'CARTOES', 'Upsell cartão premium', 'Relacionamento', 'Oferta para base prime', 'Email', 'ALTA', 'CRM Cartões', 'CONVERSAO', 1000, 'PREPARACAO', NULL, 'MENSAL', DATE('2026-05-01'), DATE('2026-05-31'), 1, false, NULL, current_timestamp(), current_timestamp(), 'seed', 'seed'),
('CMP-CRED001', 'Crédito Pré-aprovado Varejo', 'CREDITO', 'Crédito pessoal', 'Cross Sell', 'Oferta crédito varejo', 'Push', 'MEDIA', 'CRM Crédito', 'CLIENTES_ATIVADOS', 500, 'SEGMENTACAO', NULL, 'MENSAL', DATE('2026-05-01'), DATE('2026-05-31'), 1, false, NULL, current_timestamp(), current_timestamp(), 'seed', 'seed'),
('CMP-INV001', 'Investimentos Exclusive', 'INVESTIMENTOS', 'Aumentar ticket', 'Relacionamento', 'Clientes exclusive', 'Gerente', 'ALTA', 'CRM Investimentos', 'AUM', 250000, 'ATIVO', NULL, 'MENSAL', DATE('2026-05-01'), DATE('2026-05-31'), 1, false, current_timestamp(), current_timestamp(), current_timestamp(), 'seed', 'seed');

INSERT INTO main.campaign_app.campaign_briefing_version VALUES
('CMP-PRIME001', 1, 'Selecionar clientes prime aderentes', 'Gerar audiência qualificada', '["Email"]', 'Clientes do PR', 'Começar pela base prime', 'Seed', true, current_timestamp(), 'seed'),
('CMP-CRED001', 1, 'Selecionar clientes varejo para crédito', 'Gerar audiência de crédito', '["Push"]', 'Sem atraso > 30 dias', 'Usar pré aprovado', 'Seed', true, current_timestamp(), 'seed'),
('CMP-INV001', 1, 'Selecionar clientes exclusive para investimentos', 'Aumentar captação', '["Gerente"]', 'Foco em alta renda', 'Usar perfil investidor', 'Seed', true, current_timestamp(), 'seed');

INSERT INTO main.campaign_app.campaign_segmentation_version VALUES
('CMP-CRED001', 1, 'varejo', 'main.campaign_sources.vw_publico_varejo', '[{"field":"uf","operator":"=","value":"PR"}]', '[{"theme":"credito","field":"limite_pre_aprovado","operator":">","value":10000}]', '[{"theme":"credito","field":"atraso_max_dias","operator":">","value":30}]', 1, 2, 'SELECT cpf_cnpj FROM main.campaign_sources.vw_publico_varejo', 350, true, current_timestamp(), 'seed'),
('CMP-INV001', 1, 'exclusive', 'main.campaign_sources.vw_publico_exclusive', '[{"field":"uf","operator":"=","value":"PR"}]', '[{"theme":"investimentos","field":"valor_total_investido","operator":">","value":50000}]', '[]', 1, 1, 'SELECT cpf_cnpj FROM main.campaign_sources.vw_publico_exclusive', 120, true, current_timestamp(), 'seed');

INSERT INTO main.campaign_app.campaign_activation_version VALUES
('CMP-INV001', 1, 1, 'main.campaign_execution.campaign_audience', 'SNAPSHOT', DATE('2026-05-01'), DATE('2026-05-31'), current_timestamp(), NULL, true, current_timestamp(), 'seed');

INSERT INTO main.campaign_app.campaign_status_history VALUES
('CMP-PRIME001', NULL, 'PREPARACAO', 'Criação seed', current_timestamp(), 'seed'),
('CMP-CRED001', NULL, 'SEGMENTACAO', 'Criação seed', current_timestamp(), 'seed'),
('CMP-INV001', NULL, 'ATIVO', 'Criação seed', current_timestamp(), 'seed');

INSERT INTO main.campaign_app.campaign_audit_event VALUES
('CMP-PRIME001', 'SEED', '{"seed":true}', current_timestamp(), 'seed'),
('CMP-CRED001', 'SEED', '{"seed":true}', current_timestamp(), 'seed'),
('CMP-INV001', 'SEED', '{"seed":true}', current_timestamp(), 'seed');

INSERT INTO main.campaign_execution.campaign_run_log VALUES
(uuid(), 'CMP-INV001', 1, 1, 'SUCCEEDED', current_timestamp(), current_timestamp(), 120, 'seed sql', NULL);

INSERT INTO main.campaign_execution.campaign_audience
SELECT 'CMP-INV001', 1, 1, cpf_cnpj, current_timestamp(), DATE('2026-05-01'), DATE('2026-05-31'), 'ATIVO', 'exclusive', current_timestamp()
FROM main.campaign_sources.vw_publico_exclusive
LIMIT 120;

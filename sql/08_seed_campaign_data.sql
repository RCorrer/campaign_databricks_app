DELETE FROM main.campaign_execution.campaign_run_log;
DELETE FROM main.campaign_execution.campaign_audience;
DELETE FROM main.campaign_app.campaign_audit_event;
DELETE FROM main.campaign_app.campaign_status_history;
DELETE FROM main.campaign_app.campaign_activation_version;
DELETE FROM main.campaign_app.campaign_segmentation_version;
DELETE FROM main.campaign_app.campaign_briefing_version;
DELETE FROM main.campaign_app.campaign_header;

INSERT INTO main.campaign_app.campaign_header
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')) as campaign_id,
  concat('Campanha ', id) as campaign_name,
  CASE
    WHEN id % 5 = 0 THEN 'CARTOES'
    WHEN id % 5 = 1 THEN 'CREDITO'
    WHEN id % 5 = 2 THEN 'INVESTIMENTOS'
    WHEN id % 5 = 3 THEN 'SEGUROS'
    ELSE 'PIX'
  END as theme,
  'Expansão de carteira' as objective,
  'Aumentar conversão comercial' as strategy,
  concat('Descrição da campanha ', id) as description,
  CASE WHEN id % 3 = 0 THEN 'EMAIL' WHEN id % 3 = 1 THEN 'PUSH' ELSE 'SMS' END as primary_channel,
  CASE WHEN id % 3 = 0 THEN 'ALTA' WHEN id % 3 = 1 THEN 'MEDIA' ELSE 'BAIXA' END as priority,
  CASE WHEN id % 2 = 0 THEN 'CRM' ELSE 'COMERCIAL' END as owner_team,
  'Conversão' as goal_kpi,
  CAST(100 + id * 10 AS DECIMAL(18,2)) as goal_value,
  CASE
    WHEN id % 4 = 0 THEN 'ATIVO'
    WHEN id % 4 = 1 THEN 'PREPARACAO'
    WHEN id % 4 = 2 THEN 'SEGMENTACAO'
    ELSE 'PAUSADO'
  END as status,
  NULL as status_reason,
  'MENSAL' as periodicity,
  date_add(current_date(), CAST(id AS INT)) as start_date,
  date_add(current_date(), CAST(30 + id AS INT)) as end_date,
  3 as max_impacts_month,
  false as control_group_enabled,
  current_timestamp() as last_run_at,
  current_timestamp() as created_at,
  current_timestamp() as updated_at,
  'system' as created_by,
  'system' as updated_by
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_briefing_version
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  concat('Desafio da campanha ', id),
  'Aumentar receita incremental',
  '["EMAIL","PUSH"]',
  'Sem restrições críticas',
  'Regras de negócio padrão',
  'Seed inicial',
  true,
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_segmentation_version
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  CASE WHEN id % 2 = 0 THEN 'PRIME' ELSE 'VAREJO' END,
  CASE WHEN id % 2 = 0
    THEN 'main.campaign_sources.vw_publico_prime'
    ELSE 'main.campaign_sources.vw_publico_varejo'
  END,
  '[{"field":"renda_mensal","operator":">=","value":5000}]',
  '[{"theme":"cartoes","field":"tipo_cartao","operator":"=","value":"BLACK"}]',
  '[]',
  1,
  1,
  'SELECT cpf_cnpj FROM main.customer_base.customer_master',
  250 + id,
  true,
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_activation_version
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  1,
  concat('AUDIENCE_', lpad(cast(id as string), 4, '0')),
  'SNAPSHOT',
  date_add(current_date(), CAST(id AS INT)),
  date_add(current_date(), CAST(30 + id AS INT)),
  current_timestamp(),
  NULL,
  true,
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_status_history
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  CASE WHEN id % 2 = 0 THEN 'ATIVO' ELSE 'PREPARACAO' END,
  'Carga inicial',
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_audit_event
SELECT
  concat('AUDIT_', lpad(cast(id as string), 6, '0')),
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  'SEED_INSERT',
  'Carga inicial da campanha',
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_execution.campaign_run_log
SELECT
  concat('RUN_', lpad(cast(id as string), 6, '0')),
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  1,
  'SUCCESS',
  current_timestamp(),
  current_timestamp(),
  250 + id,
  'seed execution',
  NULL
FROM range(1, 21);

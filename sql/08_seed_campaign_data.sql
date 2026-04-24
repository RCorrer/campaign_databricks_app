DELETE FROM main.campaign_execution.campaign_run_log;
DELETE FROM main.campaign_execution.campaign_audience;
DELETE FROM main.campaign_app.campaign_audit_event;
DELETE FROM main.campaign_app.campaign_status_history;
DELETE FROM main.campaign_app.campaign_activation_version;
DELETE FROM main.campaign_app.campaign_segmentation_version;
DELETE FROM main.campaign_app.campaign_briefing_version;
DELETE FROM main.campaign_app.campaign_header;

INSERT INTO main.campaign_app.campaign_header (
  campaign_id, campaign_name, theme, objective, strategy, description, primary_channel, priority,
  owner_team, goal_kpi, goal_value, status, status_reason, periodicity, start_date, end_date,
  max_impacts_month, control_group_enabled, last_run_at, created_at, updated_at, created_by, updated_by
)
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

INSERT INTO main.campaign_app.campaign_briefing_version (
  campaign_id, version_no, challenge, target_business_outcome, channels_json,
  constraints, business_rules, notes, is_current, created_at, created_by
)
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

INSERT INTO main.campaign_app.campaign_segmentation_version (
  campaign_id, version_no, initial_audience_code, initial_audience_view, native_rules_json,
  include_rules_json, exclude_rules_json, native_rule_count, thematic_rule_count,
  generated_sql, estimated_count, is_current, created_at, created_by
)
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  CASE WHEN id % 2 = 0 THEN 'PRIME' ELSE 'VAREJO' END,
  CASE WHEN id % 2 = 0 THEN 'main.campaign_sources.vw_publico_prime'
       ELSE 'main.campaign_sources.vw_publico_varejo'
  END,
  '[{"field":"renda_mensal","operator":">=","value":5000}]',
  '[{"theme":"cartoes","field":"produto_cartao","operator":"=","value":"BLACK"}]',
  '[]',
  1,
  1,
  'SELECT cpf_cnpj FROM main.customer_base.customer_master',
  CAST(250 + id AS BIGINT),
  true,
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_activation_version (
  campaign_id, version_no, segmentation_version_no, execution_target_name, activation_mode,
  start_date, end_date, activated_at, deactivated_at, is_current, created_at, created_by
)
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

INSERT INTO main.campaign_app.campaign_status_history (
  campaign_id, from_status, to_status, reason, changed_at, changed_by
)
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  NULL as from_status,
  CASE
    WHEN id % 4 = 0 THEN 'ATIVO'
    WHEN id % 4 = 1 THEN 'PREPARACAO'
    WHEN id % 4 = 2 THEN 'SEGMENTACAO'
    ELSE 'PAUSADO'
  END as to_status,
  'Carga inicial' as reason,
  current_timestamp() as changed_at,
  'system' as changed_by
FROM range(1, 21);

INSERT INTO main.campaign_app.campaign_audit_event (
  campaign_id, event_type, payload_json, created_at, created_by
)
SELECT
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  'SEED_INSERT',
  concat(
    '{"source":"08_seed_campaign_data.sql","campaign_name":"Campanha ',
    cast(id as string),
    '","theme":"',
    CASE
      WHEN id % 5 = 0 THEN 'CARTOES'
      WHEN id % 5 = 1 THEN 'CREDITO'
      WHEN id % 5 = 2 THEN 'INVESTIMENTOS'
      WHEN id % 5 = 3 THEN 'SEGUROS'
      ELSE 'PIX'
    END,
    '"}'
  ) as payload_json,
  current_timestamp(),
  'system'
FROM range(1, 21);

INSERT INTO main.campaign_execution.campaign_run_log (
  run_id, campaign_id, segmentation_version_no, activation_version_no, status,
  started_at, finished_at, row_count, executed_sql, error_message
)
SELECT
  concat('RUN_', lpad(cast(id as string), 6, '0')),
  concat('CAMP_', lpad(cast(id as string), 4, '0')),
  1,
  1,
  'SUCCESS',
  current_timestamp(),
  current_timestamp(),
  CAST(250 + id AS BIGINT),
  'seed execution',
  NULL
FROM range(1, 21);

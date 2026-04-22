CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_header (
  campaign_id STRING,
  campaign_name STRING,
  theme STRING,
  objective STRING,
  strategy STRING,
  description STRING,
  primary_channel STRING,
  priority STRING,
  owner_team STRING,
  goal_kpi STRING,
  goal_value DECIMAL(18,2),
  status STRING,
  status_reason STRING,
  periodicity STRING,
  start_date DATE,
  end_date DATE,
  max_impacts_month INT,
  control_group_enabled BOOLEAN,
  last_run_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  created_by STRING,
  updated_by STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_briefing_version (
  campaign_id STRING,
  version_no INT,
  challenge STRING,
  target_business_outcome STRING,
  channels_json STRING,
  constraints STRING,
  business_rules STRING,
  notes STRING,
  is_current BOOLEAN,
  created_at TIMESTAMP,
  created_by STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_segmentation_version (
  campaign_id STRING,
  version_no INT,
  initial_audience_code STRING,
  initial_audience_view STRING,
  native_rules_json STRING,
  include_rules_json STRING,
  exclude_rules_json STRING,
  native_rule_count INT,
  thematic_rule_count INT,
  generated_sql STRING,
  estimated_count BIGINT,
  is_current BOOLEAN,
  created_at TIMESTAMP,
  created_by STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_activation_version (
  campaign_id STRING,
  version_no INT,
  segmentation_version_no INT,
  execution_target_name STRING,
  activation_mode STRING,
  start_date DATE,
  end_date DATE,
  activated_at TIMESTAMP,
  deactivated_at TIMESTAMP,
  is_current BOOLEAN,
  created_at TIMESTAMP,
  created_by STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_status_history (
  campaign_id STRING,
  from_status STRING,
  to_status STRING,
  reason STRING,
  changed_at TIMESTAMP,
  changed_by STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_audit_event (
  campaign_id STRING,
  event_type STRING,
  payload_json STRING,
  created_at TIMESTAMP,
  created_by STRING
) USING DELTA;

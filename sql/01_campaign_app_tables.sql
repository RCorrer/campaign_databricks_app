CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_header (
  campaign_id STRING NOT NULL,
  campaign_name STRING NOT NULL,
  theme STRING,
  objective STRING,
  strategy STRING,
  status STRING NOT NULL,
  periodicity STRING,
  start_date DATE,
  end_date DATE,
  max_impacts_month INT,
  control_group_enabled BOOLEAN,
  current_version INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  created_by STRING,
  updated_by STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_briefing_version (
  campaign_id STRING NOT NULL,
  version_id INT NOT NULL,
  challenge STRING,
  target_business_outcome STRING,
  channels ARRAY<STRING>,
  constraints ARRAY<STRING>,
  business_rules ARRAY<STRING>,
  notes STRING,
  created_at TIMESTAMP,
  created_by STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_segmentation_version (
  campaign_id STRING NOT NULL,
  version_id INT NOT NULL,
  initial_audience_code STRING NOT NULL,
  universe_view STRING NOT NULL,
  native_include_rules_json STRING,
  native_exclude_rules_json STRING,
  include_rules_json STRING,
  exclude_rules_json STRING,
  preview_sql STRING,
  estimated_audience BIGINT,
  created_at TIMESTAMP,
  created_by STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_activation_version (
  campaign_id STRING NOT NULL,
  version_id INT NOT NULL,
  materialization_mode STRING,
  activation_object_name STRING,
  activation_sql STRING,
  effective_start_date DATE,
  effective_end_date DATE,
  activation_status STRING,
  activated_at TIMESTAMP,
  activated_by STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_status_history (
  campaign_id STRING NOT NULL,
  from_status STRING,
  to_status STRING NOT NULL,
  change_reason STRING,
  changed_at TIMESTAMP,
  changed_by STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_app.campaign_audit_event (
  campaign_id STRING NOT NULL,
  event_name STRING NOT NULL,
  payload_json STRING,
  event_ts TIMESTAMP,
  event_user STRING
)
USING DELTA;

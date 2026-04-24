CREATE TABLE IF NOT EXISTS main.campaign_execution.campaign_audience (
  campaign_id STRING,
  segmentation_version_no INT,
  activation_version_no INT,
  cpf_cnpj STRING,
  dt_segmentacao TIMESTAMP,
  dt_inicio_vigencia DATE,
  dt_fim_vigencia DATE,
  status_audiencia STRING,
  initial_audience_code STRING,
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_execution.campaign_run_log (
  run_id STRING,
  campaign_id STRING,
  segmentation_version_no INT,
  activation_version_no INT,
  status STRING,
  started_at TIMESTAMP,
  finished_at TIMESTAMP,
  row_count BIGINT,
  executed_sql STRING,
  error_message STRING
) USING DELTA;

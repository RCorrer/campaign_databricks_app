CREATE TABLE IF NOT EXISTS main.campaign_execution.campaign_audience (
  campaign_id STRING NOT NULL,
  segmentation_version INT NOT NULL,
  cpf_cnpj STRING NOT NULL,
  dt_segmentacao TIMESTAMP,
  dt_inicio_vigencia DATE,
  dt_fim_vigencia DATE,
  status_audiencia STRING,
  origem_publico STRING,
  materialization_mode STRING,
  execution_mode STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.campaign_execution.campaign_run_log (
  campaign_id STRING NOT NULL,
  segmentation_version INT NOT NULL,
  run_ts TIMESTAMP,
  execution_mode STRING,
  materialization_mode STRING,
  output_object STRING,
  total_records BIGINT,
  snapshot_object STRING,
  run_status STRING,
  error_message STRING
)
USING DELTA;

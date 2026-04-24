CREATE TABLE IF NOT EXISTS main.execucao_campanha.campanha_publico (
  id_campanha STRING,
  versao_segmentacao INT,
  cpf_cnpj STRING,
  data_segmentacao TIMESTAMP,
  data_inicio_vigencia DATE,
  data_fim_vigencia DATE,
  status_publico STRING,
  origem_publico STRING,
  modo_materializacao STRING,
  modo_execucao STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.execucao_campanha.campanha_log_execucao (
  id_campanha STRING,
  versao_segmentacao INT,
  executado_em TIMESTAMP,
  modo_execucao STRING,
  modo_materializacao STRING,
  objeto_saida STRING,
  total_registros BIGINT,
  objeto_snapshot STRING,
  status_execucao STRING,
  mensagem_erro STRING
)
USING DELTA;

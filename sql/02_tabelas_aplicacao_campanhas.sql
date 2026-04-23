CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_cabecalho (
  id_campanha STRING NOT NULL COMMENT 'Identificador da campanha',
  nome_campanha STRING COMMENT 'Nome da campanha',
  tema STRING COMMENT 'Tema da campanha',
  objetivo STRING COMMENT 'Objetivo principal',
  estrategia STRING COMMENT 'Estratégia resumida',
  descricao STRING COMMENT 'Descrição da campanha',
  status STRING COMMENT 'Status atual do ciclo de vida',
  periodicidade STRING COMMENT 'Periodicidade planejada',
  data_inicio DATE COMMENT 'Data inicial planejada',
  data_fim DATE COMMENT 'Data final planejada',
  maximo_impactos_mes INT COMMENT 'Limite mensal de impactos por cliente',
  grupo_controle_habilitado BOOLEAN COMMENT 'Indica uso de grupo de controle',
  versao_atual INT COMMENT 'Versão atual de trabalho',
  criado_em TIMESTAMP COMMENT 'Data de criação',
  atualizado_em TIMESTAMP COMMENT 'Data de atualização',
  criado_por STRING COMMENT 'Usuário criador',
  atualizado_por STRING COMMENT 'Último usuário que atualizou'
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_briefing_versao (
  id_campanha STRING NOT NULL,
  versao_id INT NOT NULL,
  desafio STRING,
  resultado_negocio_esperado STRING,
  canais ARRAY<STRING>,
  restricoes ARRAY<STRING>,
  regras_negocio ARRAY<STRING>,
  observacoes STRING,
  criado_em TIMESTAMP,
  criado_por STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_segmentacao_versao (
  id_campanha STRING NOT NULL,
  versao_id INT NOT NULL,
  codigo_publico_inicial STRING,
  view_publico_inicial STRING,
  regras_inclusao_nativa_json STRING,
  regras_exclusao_nativa_json STRING,
  regras_inclusao_json STRING,
  regras_exclusao_json STRING,
  sql_previa STRING,
  publico_estimado BIGINT,
  criado_em TIMESTAMP,
  criado_por STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_ativacao_versao (
  id_campanha STRING NOT NULL,
  versao_id INT NOT NULL,
  modo_materializacao STRING,
  objeto_ativacao STRING,
  sql_ativacao STRING,
  data_inicio_vigencia DATE,
  data_fim_vigencia DATE,
  status_ativacao STRING,
  ativado_em TIMESTAMP,
  ativado_por STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_historico_status (
  id_campanha STRING NOT NULL,
  status_origem STRING,
  status_destino STRING,
  motivo_alteracao STRING,
  alterado_em TIMESTAMP,
  alterado_por STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_evento_auditoria (
  id_campanha STRING NOT NULL,
  nome_evento STRING,
  payload_json STRING,
  evento_em TIMESTAMP,
  usuario_evento STRING
)
USING DELTA;

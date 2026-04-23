CREATE OR REPLACE VIEW main.aplicacao_campanhas.vw_definicao_atual_campanha AS
SELECT c.id_campanha,
       c.nome_campanha,
       c.tema,
       c.objetivo,
       c.estrategia,
       c.descricao,
       c.status,
       c.periodicidade,
       CAST(c.data_inicio AS STRING) AS data_inicio,
       CAST(c.data_fim AS STRING) AS data_fim,
       c.maximo_impactos_mes,
       c.grupo_controle_habilitado,
       c.versao_atual,
       b.desafio,
       b.resultado_negocio_esperado,
       b.canais,
       b.restricoes,
       b.regras_negocio,
       b.observacoes,
       s.codigo_publico_inicial,
       s.view_publico_inicial,
       s.regras_inclusao_nativa_json,
       s.regras_exclusao_nativa_json,
       s.regras_inclusao_json,
       s.regras_exclusao_json,
       s.sql_previa,
       s.publico_estimado,
       a.modo_materializacao,
       a.objeto_ativacao,
       a.sql_ativacao,
       CAST(a.data_inicio_vigencia AS STRING) AS data_inicio_vigencia,
       CAST(a.data_fim_vigencia AS STRING) AS data_fim_vigencia,
       a.status_ativacao
  FROM main.aplicacao_campanhas.campanha_cabecalho c
  LEFT JOIN main.aplicacao_campanhas.campanha_briefing_versao b
    ON b.id_campanha = c.id_campanha
   AND b.versao_id = c.versao_atual
  LEFT JOIN main.aplicacao_campanhas.campanha_segmentacao_versao s
    ON s.id_campanha = c.id_campanha
   AND s.versao_id = c.versao_atual
  LEFT JOIN main.aplicacao_campanhas.campanha_ativacao_versao a
    ON a.id_campanha = c.id_campanha
   AND a.versao_id = c.versao_atual;

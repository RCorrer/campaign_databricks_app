-- ============================================================
-- 08 - View consolidada da definição atual da campanha
-- ============================================================

CREATE OR REPLACE VIEW main.aplicacao_campanhas.vw_definicao_atual_campanha
COMMENT 'Contrato consolidado da definição atual de cada campanha.'
AS
SELECT
    cabecalho.id_campanha,
    cabecalho.nome_campanha,
    cabecalho.tema,
    cabecalho.objetivo,
    cabecalho.estrategia,
    cabecalho.descricao,
    cabecalho.status,
    cabecalho.periodicidade,
    cabecalho.data_inicio,
    cabecalho.data_fim,
    cabecalho.maximo_impactos_mes,
    cabecalho.grupo_controle_habilitado,
    cabecalho.versao_atual,
    briefing.desafio,
    briefing.resultado_negocio_alvo,
    briefing.canais,
    briefing.restricoes,
    briefing.regras_negocio,
    briefing.observacoes,
    segmentacao.codigo_publico_inicial,
    segmentacao.view_universo,
    segmentacao.regras_nativas_inclusao_json,
    segmentacao.regras_nativas_exclusao_json,
    segmentacao.regras_inclusao_json,
    segmentacao.regras_exclusao_json,
    segmentacao.sql_previa,
    segmentacao.audiencia_estimada,
    ativacao.modo_materializacao,
    ativacao.nome_objeto_ativacao,
    ativacao.sql_ativacao,
    ativacao.data_inicio_vigencia,
    ativacao.data_fim_vigencia,
    ativacao.status_ativacao
FROM main.aplicacao_campanhas.campanha_cabecalho cabecalho
LEFT JOIN main.aplicacao_campanhas.campanha_briefing_versao briefing
    ON cabecalho.id_campanha = briefing.id_campanha
   AND cabecalho.versao_atual = briefing.id_versao
LEFT JOIN main.aplicacao_campanhas.campanha_segmentacao_versao segmentacao
    ON cabecalho.id_campanha = segmentacao.id_campanha
   AND cabecalho.versao_atual = segmentacao.id_versao
LEFT JOIN main.aplicacao_campanhas.campanha_ativacao_versao ativacao
    ON cabecalho.id_campanha = ativacao.id_campanha
   AND cabecalho.versao_atual = ativacao.id_versao;

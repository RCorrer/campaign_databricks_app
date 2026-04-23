-- ============================================================
-- 07 - Tabelas de execução de campanhas
-- ============================================================

CREATE TABLE IF NOT EXISTS main.execucao_campanha.campanha_audiencia (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    versao_segmentacao INT NOT NULL COMMENT 'Versão da segmentação usada.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente elegível.',
    data_segmentacao TIMESTAMP COMMENT 'Data e hora da segmentação.',
    data_inicio_vigencia DATE COMMENT 'Início da vigência da audiência.',
    data_fim_vigencia DATE COMMENT 'Fim da vigência da audiência.',
    status_audiencia STRING COMMENT 'Status do cliente na audiência.',
    origem_publico STRING COMMENT 'Código do público inicial de origem.',
    modo_materializacao STRING COMMENT 'Modo de materialização usado.',
    modo_execucao STRING COMMENT 'Modo de execução usado.'
)
USING DELTA
COMMENT 'Audiência final materializada por campanha.';

CREATE TABLE IF NOT EXISTS main.execucao_campanha.campanha_log_execucao (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    versao_segmentacao INT NOT NULL COMMENT 'Versão da segmentação usada.',
    executado_em TIMESTAMP COMMENT 'Data e hora da execução.',
    modo_execucao STRING COMMENT 'Modo de execução.',
    modo_materializacao STRING COMMENT 'Modo de materialização.',
    objeto_saida STRING COMMENT 'Objeto criado para a ativação.',
    total_registros BIGINT COMMENT 'Quantidade total de registros materializados.',
    objeto_snapshot STRING COMMENT 'Objeto de snapshot, quando aplicável.',
    status_execucao STRING COMMENT 'Status da execução.',
    mensagem_erro STRING COMMENT 'Mensagem de erro, quando houver.'
)
USING DELTA
COMMENT 'Log das execuções de campanhas.';

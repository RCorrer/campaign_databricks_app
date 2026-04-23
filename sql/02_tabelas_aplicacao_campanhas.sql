-- ============================================================
-- 02 - Tabelas da aplicação de campanhas
-- ============================================================

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_cabecalho (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    nome_campanha STRING NOT NULL COMMENT 'Nome exibido para a campanha.',
    tema STRING COMMENT 'Tema comercial ou estratégico da campanha.',
    objetivo STRING COMMENT 'Objetivo principal da campanha.',
    estrategia STRING COMMENT 'Estratégia resumida da campanha.',
    descricao STRING COMMENT 'Descrição livre da campanha.',
    status STRING NOT NULL COMMENT 'Status atual da campanha.',
    periodicidade STRING COMMENT 'Periodicidade da campanha.',
    data_inicio DATE COMMENT 'Data de início planejada.',
    data_fim DATE COMMENT 'Data de fim planejada.',
    maximo_impactos_mes INT COMMENT 'Quantidade máxima de impactos por mês.',
    grupo_controle_habilitado BOOLEAN COMMENT 'Indica se a campanha usa grupo de controle.',
    versao_atual INT COMMENT 'Versão corrente da definição da campanha.',
    criado_em TIMESTAMP COMMENT 'Data e hora de criação.',
    atualizado_em TIMESTAMP COMMENT 'Data e hora da última atualização.',
    criado_por STRING COMMENT 'Usuário responsável pela criação.',
    atualizado_por STRING COMMENT 'Usuário responsável pela última atualização.'
)
USING DELTA
COMMENT 'Cabeçalho principal das campanhas.';

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_briefing_versao (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    id_versao INT NOT NULL COMMENT 'Número da versão do briefing.',
    desafio STRING COMMENT 'Desafio de negócio da campanha.',
    resultado_negocio_alvo STRING COMMENT 'Resultado esperado de negócio.',
    canais ARRAY<STRING> COMMENT 'Canais planejados para a campanha.',
    restricoes ARRAY<STRING> COMMENT 'Restrições operacionais ou comerciais.',
    regras_negocio ARRAY<STRING> COMMENT 'Regras de negócio declaradas.',
    observacoes STRING COMMENT 'Observações adicionais.',
    criado_em TIMESTAMP COMMENT 'Data e hora de criação da versão.',
    criado_por STRING COMMENT 'Usuário responsável pela versão.'
)
USING DELTA
COMMENT 'Versões de briefing das campanhas.';

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_segmentacao_versao (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    id_versao INT NOT NULL COMMENT 'Número da versão da segmentação.',
    codigo_publico_inicial STRING NOT NULL COMMENT 'Código do público inicial selecionado.',
    view_universo STRING NOT NULL COMMENT 'View usada como universo inicial da segmentação.',
    regras_nativas_inclusao_json STRING COMMENT 'Regras nativas de inclusão em formato JSON.',
    regras_nativas_exclusao_json STRING COMMENT 'Regras nativas de exclusão em formato JSON.',
    regras_inclusao_json STRING COMMENT 'Regras temáticas de inclusão em formato JSON.',
    regras_exclusao_json STRING COMMENT 'Regras temáticas de exclusão em formato JSON.',
    sql_previa STRING COMMENT 'SQL gerado para prévia da audiência.',
    audiencia_estimada BIGINT COMMENT 'Quantidade estimada de clientes elegíveis.',
    criado_em TIMESTAMP COMMENT 'Data e hora de criação da versão.',
    criado_por STRING COMMENT 'Usuário responsável pela versão.'
)
USING DELTA
COMMENT 'Versões de segmentação das campanhas.';

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_ativacao_versao (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    id_versao INT NOT NULL COMMENT 'Número da versão da ativação.',
    modo_materializacao STRING COMMENT 'Modo de materialização escolhido.',
    nome_objeto_ativacao STRING COMMENT 'Tabela ou view criada para a audiência ativada.',
    sql_ativacao STRING COMMENT 'SQL usado para materializar a audiência.',
    data_inicio_vigencia DATE COMMENT 'Início da vigência da ativação.',
    data_fim_vigencia DATE COMMENT 'Fim da vigência da ativação.',
    status_ativacao STRING COMMENT 'Status da ativação.',
    ativado_em TIMESTAMP COMMENT 'Data e hora da ativação.',
    ativado_por STRING COMMENT 'Usuário responsável pela ativação.'
)
USING DELTA
COMMENT 'Versões de ativação das campanhas.';

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_historico_status (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    status_origem STRING COMMENT 'Status anterior da campanha.',
    status_destino STRING NOT NULL COMMENT 'Novo status da campanha.',
    motivo_alteracao STRING COMMENT 'Motivo informado para a alteração.',
    alterado_em TIMESTAMP COMMENT 'Data e hora da alteração.',
    alterado_por STRING COMMENT 'Usuário responsável pela alteração.'
)
USING DELTA
COMMENT 'Histórico de mudanças de status das campanhas.';

CREATE TABLE IF NOT EXISTS main.aplicacao_campanhas.campanha_evento_auditoria (
    id_campanha STRING NOT NULL COMMENT 'Identificador técnico da campanha.',
    nome_evento STRING NOT NULL COMMENT 'Nome técnico do evento auditado.',
    payload_json STRING COMMENT 'Conteúdo do evento em formato JSON.',
    evento_em TIMESTAMP COMMENT 'Data e hora do evento.',
    evento_usuario STRING COMMENT 'Usuário responsável pelo evento.'
)
USING DELTA
COMMENT 'Eventos de auditoria das campanhas.';

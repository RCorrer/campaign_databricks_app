CREATE SCHEMA IF NOT EXISTS main.campanhas;

CREATE TABLE IF NOT EXISTS main.campanhas.brieffing (
    id_campanha        INT NOT NULL COMMENT 'Identificador único da campanha.',
    nome               STRING COMMENT 'Nome amigável da campanha.',
    tema               STRING COMMENT 'Tema central (ex: Aniversário, Consignado, Seguro Auto).',
    segmento           STRING COMMENT 'Segmento de clientes alvo (Prime, Exclusive, PJ Premium, etc.).',
    objetivo           STRING COMMENT 'Objetivo principal da campanha (ex: aquisição, retenção, upgrade).',
    estrategia         STRING COMMENT 'Descrição da estratégia/abordagem de comunicação.',
    canal              STRING COMMENT 'Canais de disparo (ex: email, push, SMS, WhatsApp).',
    data_inicio        DATE COMMENT 'Data de início da campanha.',
    data_fim           DATE COMMENT 'Data de término prevista.',
    publico_alvo       STRING COMMENT 'Descrição qualitativa do público-alvo.',
    regras_inclusao    STRING COMMENT 'Resumo textual ou JSON simplificado das regras de inclusão.',
    regras_exclusao    STRING COMMENT 'Resumo textual ou JSON simplificado das regras de exclusão.',
    status             STRING COMMENT 'Situação da campanha: planejada, aprovada, em execução, finalizada, cancelada.'
)
USING delta
COMMENT 'Tabela de briefing de campanhas de CRM, contendo informações estratégicas e de planejamento.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (id_campanha);

CREATE TABLE IF NOT EXISTS main.campanhas.regras_segmentacao (
    id_campanha    INT NOT NULL COMMENT 'Identificador da campanha, chave estrangeira para main.campanhas.brieffing.',
    definicao      STRING COMMENT 'Documento JSON com a definição completa da segmentação (base, joins, inclusão, exclusão, colunas).'
)
USING delta
COMMENT 'Armazena a definição técnica da segmentação de cada campanha em formato JSON estruturado.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (id_campanha);
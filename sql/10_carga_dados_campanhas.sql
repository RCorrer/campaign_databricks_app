-- =====================================================
-- MASSA DE DADOS - CAMPANHAS (PT-BR)
-- Arquivo sugerido: 08_carga_dados_campanhas.sql
-- =====================================================

INSERT INTO main.aplicacao_campanhas.campanha_cabecalho (
    id_campanha,
    nome_campanha,
    tema,
    objetivo,
    estrategia,
    descricao,
    status,
    periodicidade,
    data_inicio,
    data_fim,
    maximo_impactos_mes,
    grupo_controle_ativo,
    versao_atual,
    criado_em,
    atualizado_em,
    criado_por,
    atualizado_por
)
VALUES (
    'CMP-000001',
    'Campanha Prime Investimentos',
    'Investimentos',
    'Aumentar adesão em produtos de investimento',
    'Oferta direcionada para clientes com alta renda',
    'Campanha para clientes com potencial de investimento premium',
    'ATIVO',
    'MENSAL',
    DATE('2026-04-01'),
    DATE('2026-06-30'),
    4,
    TRUE,
    1,
    current_timestamp(),
    current_timestamp(),
    'sistema',
    'sistema'
);

INSERT INTO main.aplicacao_campanhas.campanha_cabecalho (
    id_campanha,
    nome_campanha,
    tema,
    objetivo,
    estrategia,
    descricao,
    status,
    periodicidade,
    data_inicio,
    data_fim,
    maximo_impactos_mes,
    grupo_controle_ativo,
    versao_atual,
    criado_em,
    atualizado_em,
    criado_por,
    atualizado_por
)
VALUES (
    'CMP-000002',
    'Campanha Jovem Digital',
    'Canais Digitais',
    'Aumentar uso do aplicativo',
    'Push e comunicação digital',
    'Estimular clientes jovens a utilizarem canais digitais',
    'PREPARACAO',
    'SEMANAL',
    DATE('2026-05-01'),
    DATE('2026-07-31'),
    8,
    FALSE,
    1,
    current_timestamp(),
    current_timestamp(),
    'sistema',
    'sistema'
);

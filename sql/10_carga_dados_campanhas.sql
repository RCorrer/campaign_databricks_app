-- ============================================================
-- 08 - Carga de dados de campanhas
-- ============================================================
-- Executar após:
-- 01_catalogos_e_schemas.sql
-- 02_tabelas_aplicacao_campanhas.sql
-- 03_tabela_base_clientes.sql
-- 04_tabelas_cliente_360.sql
-- 05_carga_dados_clientes.sql
-- 06_views_fontes_campanha.sql
-- 07_tabelas_execucao_campanha.sql
-- ============================================================

-- ============================================================
-- Limpeza da massa de campanhas de exemplo
-- ============================================================

DELETE FROM main.aplicacao_campanhas.campanha_evento_auditoria
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

DELETE FROM main.aplicacao_campanhas.campanha_historico_status
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

DELETE FROM main.aplicacao_campanhas.campanha_ativacao_versao
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

DELETE FROM main.aplicacao_campanhas.campanha_segmentacao_versao
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

DELETE FROM main.aplicacao_campanhas.campanha_briefing_versao
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

DELETE FROM main.aplicacao_campanhas.campanha_cabecalho
WHERE id_campanha IN ('CMP-000001', 'CMP-000002', 'CMP-000003');

-- ============================================================
-- Cabeçalho das campanhas
-- ============================================================

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
    grupo_controle_habilitado,
    versao_atual,
    criado_em,
    atualizado_em,
    criado_por,
    atualizado_por
)
VALUES
(
    'CMP-000001',
    'Campanha Prime Investimentos',
    'Investimentos',
    'Aumentar adesão em produtos de investimento',
    'Oferta direcionada para clientes com alta renda',
    'Campanha para clientes com potencial de investimento premium.',
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
),
(
    'CMP-000002',
    'Campanha Jovem Digital',
    'Canais Digitais',
    'Aumentar uso do aplicativo',
    'Comunicação por push e canais digitais',
    'Campanha para estimular clientes jovens a utilizarem canais digitais.',
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
),
(
    'CMP-000003',
    'Campanha Crédito Consignado',
    'Crédito',
    'Aumentar contratação de crédito consignado',
    'Oferta personalizada para clientes elegíveis',
    'Campanha para clientes com perfil elegível e baixo risco de crédito.',
    'SEGMENTACAO',
    'QUINZENAL',
    DATE('2026-05-15'),
    DATE('2026-08-15'),
    3,
    TRUE,
    1,
    current_timestamp(),
    current_timestamp(),
    'sistema',
    'sistema'
);

-- ============================================================
-- Briefing das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_briefing_versao (
    id_campanha,
    id_versao,
    desafio,
    resultado_negocio_alvo,
    canais,
    restricoes,
    regras_negocio,
    observacoes,
    criado_em,
    criado_por
)
VALUES
(
    'CMP-000001',
    1,
    'Baixa conversão em produtos de investimento premium.',
    'Aumentar contratação de CDB, fundos e carteiras recomendadas.',
    ARRAY('APP', 'EMAIL', 'GERENTE'),
    ARRAY('Não impactar clientes inadimplentes', 'Respeitar limite de impactos mensal'),
    ARRAY('Priorizar clientes com renda alta', 'Priorizar clientes com saldo disponível'),
    'Campanha prioritária do trimestre.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000002',
    1,
    'Baixo engajamento de clientes jovens nos canais digitais.',
    'Aumentar acessos e transações realizadas pelo aplicativo.',
    ARRAY('APP', 'PUSH', 'EMAIL'),
    ARRAY('Não impactar clientes sem aceite de comunicação digital'),
    ARRAY('Priorizar clientes com baixa frequência de acesso ao app'),
    'Campanha em fase de preparação.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000003',
    1,
    'Aumentar conversão em crédito com menor risco operacional.',
    'Aumentar contratação de crédito consignado em clientes elegíveis.',
    ARRAY('APP', 'SMS', 'GERENTE'),
    ARRAY('Excluir clientes com restrição de crédito', 'Excluir clientes sem margem disponível'),
    ARRAY('Priorizar clientes com relacionamento ativo'),
    'Campanha em fase de segmentação.',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Segmentação das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_segmentacao_versao (
    id_campanha,
    id_versao,
    codigo_publico_inicial,
    view_universo,
    regras_nativas_inclusao_json,
    regras_nativas_exclusao_json,
    regras_inclusao_json,
    regras_exclusao_json,
    sql_previa,
    audiencia_estimada,
    criado_em,
    criado_por
)
VALUES
(
    'CMP-000001',
    1,
    'prime',
    'main.fontes_campanha.vw_publico_prime',
    '[{"campo":"renda_mensal","operador":">=","valor":15000}]',
    '[{"campo":"status_cliente","operador":"=","valor":"INATIVO"}]',
    '[{"dominio":"investimentos","campo":"saldo_investido","operador":">=","valor":50000}]',
    '[{"dominio":"credito","campo":"inadimplente","operador":"=","valor":true}]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_prime',
    18500,
    current_timestamp(),
    'sistema'
),
(
    'CMP-000002',
    1,
    'jovem_digital',
    'main.fontes_campanha.vw_publico_jovem_digital',
    '[{"campo":"idade","operador":"BETWEEN","valor":"18,29"}]',
    '[]',
    '[{"dominio":"canais_digitais","campo":"acessos_app_30d","operador":"<","valor":3}]',
    '[]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_jovem_digital',
    42000,
    current_timestamp(),
    'sistema'
),
(
    'CMP-000003',
    1,
    'varejo',
    'main.fontes_campanha.vw_publico_varejo',
    '[{"campo":"renda_mensal","operador":">=","valor":3000}]',
    '[{"campo":"status_cliente","operador":"=","valor":"INATIVO"}]',
    '[{"dominio":"credito","campo":"elegivel_consignado","operador":"=","valor":true}]',
    '[{"dominio":"credito","campo":"inadimplente","operador":"=","valor":true}]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_varejo',
    27500,
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Ativação das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_ativacao_versao (
    id_campanha,
    id_versao,
    modo_materializacao,
    nome_objeto_ativacao,
    sql_ativacao,
    data_inicio_vigencia,
    data_fim_vigencia,
    status_ativacao,
    ativado_em,
    ativado_por
)
VALUES
(
    'CMP-000001',
    1,
    'TABELA',
    'main.execucao_campanha.audiencia_campanha',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_prime',
    DATE('2026-04-01'),
    DATE('2026-06-30'),
    'ATIVO',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Histórico de status
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_historico_status (
    id_campanha,
    status_origem,
    status_destino,
    motivo_alteracao,
    alterado_em,
    alterado_por
)
VALUES
(
    'CMP-000001',
    NULL,
    'PREPARACAO',
    'Criação inicial da campanha.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000001',
    'PREPARACAO',
    'SEGMENTACAO',
    'Briefing aprovado para segmentação.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000001',
    'SEGMENTACAO',
    'ATIVO',
    'Campanha ativada após validação da audiência.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000002',
    NULL,
    'PREPARACAO',
    'Criação inicial da campanha.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000003',
    NULL,
    'PREPARACAO',
    'Criação inicial da campanha.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000003',
    'PREPARACAO',
    'SEGMENTACAO',
    'Campanha enviada para refinamento de público.',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Auditoria
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_evento_auditoria (
    id_campanha,
    nome_evento,
    payload_json,
    evento_em,
    evento_usuario
)
VALUES
(
    'CMP-000001',
    'CRIACAO_CAMPANHA',
    '{"origem":"carga_dados","status":"ATIVO"}',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000001',
    'ATIVACAO_CAMPANHA',
    '{"origem":"carga_dados","audiencia_estimada":18500}',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000002',
    'CRIACAO_CAMPANHA',
    '{"origem":"carga_dados","status":"PREPARACAO"}',
    current_timestamp(),
    'sistema'
),
(
    'CMP-000003',
    'CRIACAO_CAMPANHA',
    '{"origem":"carga_dados","status":"SEGMENTACAO"}',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- 10 - Carga de dados de campanhas para teste da aplicação
-- ============================================================
-- Objetivo:
-- Criar uma massa de campanhas compatível com os SQLs atuais do repositório.
--
-- Executar após:
-- 00_limpar_schemas.sql
-- 01_catalogos_e_schemas.sql
-- 02_tabelas_aplicacao_campanhas.sql
-- 03_tabela_base_clientes.sql
-- 04_tabelas_cliente_360.sql
-- 05_carga_dados_clientes.sql
-- 06_views_fontes_campanha.sql
-- 07_tabelas_execucao_campanha.sql
-- 08_view_contrato_negocio.sql
-- 09_permissoes_app.sql
-- ============================================================

-- ============================================================
-- Limpeza da massa de campanhas de teste
-- ============================================================

DELETE FROM main.execucao_campanha.campanha_publico
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.execucao_campanha.campanha_log_execucao
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_evento_auditoria
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_historico_status
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_ativacao_versao
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_segmentacao_versao
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_briefing_versao
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

DELETE FROM main.aplicacao_campanhas.campanha_cabecalho
WHERE id_campanha IN ('CMP-TESTE-001', 'CMP-TESTE-002', 'CMP-TESTE-003', 'CMP-TESTE-004', 'CMP-TESTE-005');

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
    'CMP-TESTE-001',
    'Campanha Prime Investimentos',
    'Investimentos',
    'Aumentar adesão a produtos de investimento',
    'Oferta consultiva para clientes Prime com maior saldo disponível',
    'Campanha de teste para validar o fluxo completo de preparação, segmentação e ativação.',
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
    'CMP-TESTE-002',
    'Campanha Jovem Digital',
    'Canais Digitais',
    'Aumentar engajamento no aplicativo',
    'Comunicação digital via push e e-mail',
    'Campanha em preparação para clientes jovens com alto potencial de uso digital.',
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
    'CMP-TESTE-003',
    'Campanha Crédito Varejo',
    'Crédito',
    'Aumentar contratação de crédito pessoal',
    'Oferta personalizada para clientes varejo com perfil elegível',
    'Campanha em segmentação para testar filtros de renda, risco e relacionamento.',
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
),
(
    'CMP-TESTE-004',
    'Campanha PJ Capital de Giro',
    'Pessoa Jurídica',
    'Estimular contratação de capital de giro',
    'Oferta para empresas com saldo e movimentação recorrente',
    'Campanha de teste voltada para clientes pessoa jurídica.',
    'PREPARACAO',
    'MENSAL',
    DATE('2026-06-01'),
    DATE('2026-09-30'),
    5,
    TRUE,
    1,
    current_timestamp(),
    current_timestamp(),
    'sistema',
    'sistema'
),
(
    'CMP-TESTE-005',
    'Campanha Exclusive Cartões',
    'Cartões',
    'Aumentar uso de cartão em clientes Exclusive',
    'Oferta de benefício progressivo por gasto mensal',
    'Campanha ativa para testar público materializado e log de execução.',
    'ATIVO',
    'MENSAL',
    DATE('2026-04-15'),
    DATE('2026-07-15'),
    6,
    TRUE,
    1,
    current_timestamp(),
    current_timestamp(),
    'sistema',
    'sistema'
);

-- ============================================================
-- Briefings das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_briefing_versao (
    id_campanha,
    versao_id,
    desafio,
    resultado_negocio_esperado,
    canais,
    restricoes,
    regras_negocio,
    observacoes,
    criado_em,
    criado_por
)
VALUES
(
    'CMP-TESTE-001',
    1,
    'Baixa conversão em produtos de investimento em clientes de alta renda.',
    'Aumentar a contratação de produtos de investimento e elevar o saldo investido.',
    array('APP', 'EMAIL', 'GERENTE'),
    array('Não impactar clientes sem consentimento de marketing', 'Respeitar limite mensal de impactos'),
    array('Priorizar clientes Prime', 'Priorizar clientes com saldo médio elevado'),
    'Campanha usada para validar fluxo completo com status ativo.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-002',
    1,
    'Clientes jovens usam pouco os canais digitais transacionais.',
    'Aumentar acessos ao aplicativo e transações digitais.',
    array('APP', 'PUSH', 'EMAIL'),
    array('Não impactar clientes sem consentimento digital'),
    array('Priorizar clientes do público jovem digital', 'Priorizar clientes com app ativo'),
    'Campanha mantida em preparação para testar edição de briefing.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-003',
    1,
    'Necessidade de aumentar contratação de crédito com controle de risco.',
    'Aumentar conversão de crédito pessoal em clientes elegíveis.',
    array('APP', 'SMS', 'GERENTE'),
    array('Excluir clientes com risco alto', 'Excluir clientes sem relacionamento ativo'),
    array('Priorizar varejo com renda compatível', 'Aplicar filtros de elegibilidade'),
    'Campanha em segmentação para validar regras de público.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-004',
    1,
    'Empresas elegíveis ainda não contrataram capital de giro.',
    'Aumentar contratação de capital de giro em clientes PJ.',
    array('EMAIL', 'GERENTE', 'WHATSAPP'),
    array('Não impactar empresas inativas', 'Validar consentimento de comunicação'),
    array('Priorizar clientes PJ', 'Priorizar empresas com saldo e relacionamento ativo'),
    'Campanha para validar público PJ.',
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-005',
    1,
    'Clientes Exclusive possuem limite disponível, mas baixo uso de cartão.',
    'Aumentar gasto médio mensal em cartão.',
    array('APP', 'EMAIL', 'PUSH'),
    array('Não impactar clientes bloqueados', 'Respeitar limite de impactos'),
    array('Priorizar clientes Exclusive', 'Priorizar clientes com cartão ativo'),
    'Campanha ativa para validar execução e público.',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Segmentações das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_segmentacao_versao (
    id_campanha,
    versao_id,
    codigo_publico_inicial,
    view_publico_inicial,
    regras_inclusao_nativa_json,
    regras_exclusao_nativa_json,
    regras_inclusao_json,
    regras_exclusao_json,
    sql_previa,
    publico_estimado,
    criado_em,
    criado_por
)
VALUES
(
    'CMP-TESTE-001',
    1,
    'prime',
    'main.fontes_campanha.vw_publico_prime',
    '[{"campo":"segmento","operador":"=","valor":"prime"}]',
    '[]',
    '[{"tabela":"main.cliente_360.investimentos","campo":"valor_investido","operador":">=","valor":30000}]',
    '[{"tabela":"main.base_clientes.cliente_mestre","campo":"faixa_risco","operador":"=","valor":"alto"}]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_prime',
    1,
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-002',
    1,
    'jovem_digital',
    'main.fontes_campanha.vw_publico_jovem_digital',
    '[{"campo":"segmento","operador":"=","valor":"jovem_digital"}]',
    '[]',
    '[{"tabela":"main.cliente_360.canais_digitais","campo":"usa_app","operador":"=","valor":true}]',
    '[]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_jovem_digital',
    1,
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-003',
    1,
    'varejo',
    'main.fontes_campanha.vw_publico_varejo',
    '[{"campo":"segmento","operador":"=","valor":"varejo"}]',
    '[]',
    '[{"tabela":"main.cliente_360.saldos","campo":"saldo_medio_90d","operador":">=","valor":2000}]',
    '[{"tabela":"main.base_clientes.cliente_mestre","campo":"faixa_risco","operador":"=","valor":"alto"}]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_varejo',
    1,
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-004',
    1,
    'pj',
    'main.fontes_campanha.vw_publico_pj',
    '[{"campo":"tipo_cliente","operador":"=","valor":"PJ"}]',
    '[]',
    '[{"tabela":"main.cliente_360.saldos","campo":"saldo_total","operador":">=","valor":50000}]',
    '[]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_pj',
    1,
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-005',
    1,
    'exclusive',
    'main.fontes_campanha.vw_publico_exclusive',
    '[{"campo":"segmento","operador":"=","valor":"exclusive"}]',
    '[]',
    '[{"tabela":"main.cliente_360.cartoes","campo":"possui_cartao","operador":"=","valor":true}]',
    '[]',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_exclusive',
    1,
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Ativações das campanhas
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_ativacao_versao (
    id_campanha,
    versao_id,
    modo_materializacao,
    objeto_ativacao,
    sql_ativacao,
    data_inicio_vigencia,
    data_fim_vigencia,
    status_ativacao,
    ativado_em,
    ativado_por
)
VALUES
(
    'CMP-TESTE-001',
    1,
    'TABELA',
    'main.execucao_campanha.campanha_publico',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_prime',
    DATE('2026-04-01'),
    DATE('2026-06-30'),
    'ATIVO',
    current_timestamp(),
    'sistema'
),
(
    'CMP-TESTE-005',
    1,
    'TABELA',
    'main.execucao_campanha.campanha_publico',
    'SELECT cpf_cnpj FROM main.fontes_campanha.vw_publico_exclusive',
    DATE('2026-04-15'),
    DATE('2026-07-15'),
    'ATIVO',
    current_timestamp(),
    'sistema'
);

-- ============================================================
-- Histórico de status das campanhas
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
('CMP-TESTE-001', NULL, 'PREPARACAO', 'Criação inicial da campanha.', current_timestamp(), 'sistema'),
('CMP-TESTE-001', 'PREPARACAO', 'SEGMENTACAO', 'Briefing aprovado para segmentação.', current_timestamp(), 'sistema'),
('CMP-TESTE-001', 'SEGMENTACAO', 'ATIVO', 'Campanha ativada para testes.', current_timestamp(), 'sistema'),
('CMP-TESTE-002', NULL, 'PREPARACAO', 'Criação inicial da campanha.', current_timestamp(), 'sistema'),
('CMP-TESTE-003', NULL, 'PREPARACAO', 'Criação inicial da campanha.', current_timestamp(), 'sistema'),
('CMP-TESTE-003', 'PREPARACAO', 'SEGMENTACAO', 'Campanha enviada para segmentação.', current_timestamp(), 'sistema'),
('CMP-TESTE-004', NULL, 'PREPARACAO', 'Criação inicial da campanha PJ.', current_timestamp(), 'sistema'),
('CMP-TESTE-005', NULL, 'PREPARACAO', 'Criação inicial da campanha.', current_timestamp(), 'sistema'),
('CMP-TESTE-005', 'PREPARACAO', 'SEGMENTACAO', 'Segmentação aprovada.', current_timestamp(), 'sistema'),
('CMP-TESTE-005', 'SEGMENTACAO', 'ATIVO', 'Campanha ativada para testes.', current_timestamp(), 'sistema');

-- ============================================================
-- Eventos de auditoria
-- ============================================================

INSERT INTO main.aplicacao_campanhas.campanha_evento_auditoria (
    id_campanha,
    nome_evento,
    payload_json,
    evento_em,
    usuario_evento
)
VALUES
('CMP-TESTE-001', 'CRIACAO_CAMPANHA', '{"origem":"massa_teste","status":"ATIVO"}', current_timestamp(), 'sistema'),
('CMP-TESTE-001', 'SALVAR_BRIEFING', '{"versao":1}', current_timestamp(), 'sistema'),
('CMP-TESTE-001', 'SALVAR_SEGMENTACAO', '{"versao":1,"publico_estimado":1}', current_timestamp(), 'sistema'),
('CMP-TESTE-001', 'ATIVAR_CAMPANHA', '{"versao":1,"publico_materializado":1}', current_timestamp(), 'sistema'),
('CMP-TESTE-002', 'CRIACAO_CAMPANHA', '{"origem":"massa_teste","status":"PREPARACAO"}', current_timestamp(), 'sistema'),
('CMP-TESTE-003', 'CRIACAO_CAMPANHA', '{"origem":"massa_teste","status":"SEGMENTACAO"}', current_timestamp(), 'sistema'),
('CMP-TESTE-004', 'CRIACAO_CAMPANHA', '{"origem":"massa_teste","status":"PREPARACAO"}', current_timestamp(), 'sistema'),
('CMP-TESTE-005', 'CRIACAO_CAMPANHA', '{"origem":"massa_teste","status":"ATIVO"}', current_timestamp(), 'sistema'),
('CMP-TESTE-005', 'ATIVAR_CAMPANHA', '{"versao":1,"publico_materializado":1}', current_timestamp(), 'sistema');

-- ============================================================
-- Público materializado de exemplo
-- ============================================================

INSERT INTO main.execucao_campanha.campanha_publico (
    id_campanha,
    versao_segmentacao,
    cpf_cnpj,
    data_segmentacao,
    data_inicio_vigencia,
    data_fim_vigencia,
    status_publico,
    origem_publico,
    modo_materializacao,
    modo_execucao
)
VALUES
(
    'CMP-TESTE-001',
    1,
    '11111111111',
    current_timestamp(),
    DATE('2026-04-01'),
    DATE('2026-06-30'),
    'ATIVO',
    'prime',
    'TABELA',
    'LOTE'
),
(
    'CMP-TESTE-005',
    1,
    '55555555555',
    current_timestamp(),
    DATE('2026-04-15'),
    DATE('2026-07-15'),
    'ATIVO',
    'exclusive',
    'TABELA',
    'LOTE'
);

-- ============================================================
-- Logs de execução de exemplo
-- ============================================================

INSERT INTO main.execucao_campanha.campanha_log_execucao (
    id_campanha,
    versao_segmentacao,
    executado_em,
    modo_execucao,
    modo_materializacao,
    objeto_saida,
    total_registros,
    objeto_snapshot,
    status_execucao,
    mensagem_erro
)
VALUES
(
    'CMP-TESTE-001',
    1,
    current_timestamp(),
    'LOTE',
    'TABELA',
    'main.execucao_campanha.campanha_publico',
    1,
    NULL,
    'SUCESSO',
    NULL
),
(
    'CMP-TESTE-005',
    1,
    current_timestamp(),
    'LOTE',
    'TABELA',
    'main.execucao_campanha.campanha_publico',
    1,
    NULL,
    'SUCESSO',
    NULL
);

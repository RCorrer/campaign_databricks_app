-- ============================================================
-- 06 - Views de públicos iniciais
-- ============================================================

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_base_clientes
COMMENT 'Público inicial com todos os clientes elegíveis da base mestre.'
AS
SELECT
    base.cpf_cnpj,
    base.tipo_cliente,
    base.nome_completo,
    base.nome_preferido,
    CAST(FLOOR(months_between(current_date(), base.data_nascimento) / 12) AS INT) AS idade_anos,
    base.genero,
    base.estado_civil,
    base.profissao,
    base.renda_mensal,
    base.faixa_renda,
    base.cidade,
    base.uf,
    base.cep,
    base.segmento,
    base.subsegmento,
    CAST(months_between(current_date(), conta.data_abertura) AS INT) AS meses_relacionamento,
    base.data_inicio_relacionamento,
    base.status_cadastro,
    base.consentimento_marketing,
    base.faixa_risco
FROM main.base_clientes.cliente_mestre base
LEFT JOIN main.cliente_360.tb_contas conta
    ON base.cpf_cnpj = conta.cpf_cnpj;

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_prime
COMMENT 'Público inicial de clientes pessoa física do segmento Prime.'
AS
SELECT *
FROM main.fontes_campanha.vw_publico_base_clientes
WHERE tipo_cliente = 'PF'
  AND segmento = 'PRIME';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_exclusive
COMMENT 'Público inicial de clientes pessoa física dos segmentos Exclusive e Private.'
AS
SELECT *
FROM main.fontes_campanha.vw_publico_base_clientes
WHERE tipo_cliente = 'PF'
  AND segmento IN ('EXCLUSIVE', 'PRIVATE');

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_pj
COMMENT 'Público inicial de clientes pessoa jurídica.'
AS
SELECT *
FROM main.fontes_campanha.vw_publico_base_clientes
WHERE tipo_cliente = 'PJ';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_varejo
COMMENT 'Público inicial de clientes pessoa física de varejo e alta renda.'
AS
SELECT *
FROM main.fontes_campanha.vw_publico_base_clientes
WHERE tipo_cliente = 'PF'
  AND segmento IN ('VAREJO', 'ALTA_RENDA', 'PRIME');

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_jovem_digital
COMMENT 'Público inicial de clientes jovens com consentimento de marketing.'
AS
SELECT *
FROM main.fontes_campanha.vw_publico_base_clientes
WHERE tipo_cliente = 'PF'
  AND idade_anos BETWEEN 18 AND 30
  AND consentimento_marketing = true;

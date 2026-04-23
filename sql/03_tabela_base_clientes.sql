-- ============================================================
-- 03 - Tabela mestre de clientes
-- ============================================================

CREATE TABLE IF NOT EXISTS main.base_clientes.cliente_mestre (
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    tipo_cliente STRING NOT NULL COMMENT 'Tipo do cliente: pessoa física ou pessoa jurídica.',
    nome_completo STRING NOT NULL COMMENT 'Nome completo ou razão social.',
    nome_preferido STRING COMMENT 'Nome preferido do cliente.',
    data_nascimento DATE COMMENT 'Data de nascimento ou fundação.',
    genero STRING COMMENT 'Gênero informado.',
    estado_civil STRING COMMENT 'Estado civil informado.',
    profissao STRING COMMENT 'Profissão ou ramo de atuação.',
    renda_mensal DECIMAL(18,2) COMMENT 'Renda mensal declarada ou estimada.',
    faixa_renda STRING COMMENT 'Faixa de renda do cliente.',
    cidade STRING COMMENT 'Cidade principal do cliente.',
    uf STRING COMMENT 'Unidade federativa.',
    cep STRING COMMENT 'CEP principal.',
    segmento STRING COMMENT 'Segmento comercial do cliente.',
    subsegmento STRING COMMENT 'Subsegmento comercial do cliente.',
    data_inicio_relacionamento DATE COMMENT 'Data de entrada do cliente.',
    status_cadastro STRING COMMENT 'Status cadastral ou KYC.',
    consentimento_marketing BOOLEAN COMMENT 'Indica consentimento para ações de marketing.',
    faixa_risco STRING COMMENT 'Faixa de risco do cliente.'
)
USING DELTA
COMMENT 'Base mestre de clientes.';

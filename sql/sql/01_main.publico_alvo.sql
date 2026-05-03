-- Catálogo/Schema: main.publico_alvo
-- Armazena visão cadastral e demográfica única por CPF/CNPJ.

CREATE SCHEMA IF NOT EXISTS main.leads_campanha;
CREATE SCHEMA IF NOT EXISTS main.publico_alvo;

CREATE TABLE IF NOT EXISTS main.publico_alvo.clientes (
    cpf_cnpj            STRING COMMENT 'CPF (11 caracteres) ou CNPJ (14 caracteres), chave única do cliente.',
    nome                STRING COMMENT 'Nome completo ou razão social.',
    tipo_pessoa         STRING COMMENT 'Tipo de cliente: PF (Pessoa Física) ou PJ (Pessoa Jurídica).',
    segmento            STRING COMMENT 'Segmento de relacionamento: Prime, Exclusive, PJ Premium, Varejo, etc.',
    idade               INT COMMENT 'Idade em anos completos (apenas para PF, NULL para PJ).',
    uf                  STRING COMMENT 'Unidade Federativa da residência principal (2 caracteres).',
    cidade              STRING COMMENT 'Cidade da residência principal.',
    agencia_principal   STRING COMMENT 'Código da agência principal de relacionamento.',
    conta_principal     STRING COMMENT 'Número da conta corrente/poupança principal.',
    email               STRING COMMENT 'Email válido para contato.',
    telefone_ddd        STRING COMMENT 'Código DDD do telefone celular principal.',
    telefone_numero     STRING COMMENT 'Número do telefone celular principal (sem DDD).',
    data_abertura_conta DATE COMMENT 'Data de abertura do primeiro vínculo com o banco.'
)
USING delta
COMMENT 'Tabela mestra de clientes com dados cadastrais e demográficos, visão 1:1 por CPF/CNPJ.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);
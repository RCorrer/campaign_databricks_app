-- ============================================================
-- 04 - Tabelas temáticas da visão 360 do cliente
-- ============================================================

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_contas (
    id_conta STRING NOT NULL COMMENT 'Identificador da conta.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    tipo_conta STRING COMMENT 'Tipo da conta.',
    status_conta STRING COMMENT 'Status da conta.',
    data_abertura DATE COMMENT 'Data de abertura da conta.',
    codigo_agencia STRING COMMENT 'Código da agência.',
    nome_gerente STRING COMMENT 'Nome do gerente responsável.',
    nome_pacote STRING COMMENT 'Pacote contratado.',
    limite_cheque_especial DECIMAL(18,2) COMMENT 'Limite de cheque especial.'
)
USING DELTA
COMMENT 'Dados de contas dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_saldos_conta (
    id_conta STRING NOT NULL COMMENT 'Identificador da conta.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    data_referencia DATE COMMENT 'Data de referência do saldo.',
    saldo_medio_30d DECIMAL(18,2) COMMENT 'Saldo médio dos últimos 30 dias.',
    saldo_medio_90d DECIMAL(18,2) COMMENT 'Saldo médio dos últimos 90 dias.',
    portabilidade_salario BOOLEAN COMMENT 'Indica portabilidade de salário.',
    credito_mensal DECIMAL(18,2) COMMENT 'Volume mensal de créditos.',
    debito_mensal DECIMAL(18,2) COMMENT 'Volume mensal de débitos.'
)
USING DELTA
COMMENT 'Saldos e movimentação de contas.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_cartoes (
    id_cartao STRING NOT NULL COMMENT 'Identificador do cartão.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    produto_cartao STRING COMMENT 'Produto do cartão.',
    bandeira_cartao STRING COMMENT 'Bandeira do cartão.',
    status_cartao STRING COMMENT 'Status do cartão.',
    limite_credito DECIMAL(18,2) COMMENT 'Limite total de crédito.',
    limite_disponivel DECIMAL(18,2) COMMENT 'Limite disponível.',
    dia_vencimento_fatura INT COMMENT 'Dia de vencimento da fatura.',
    indicador_ativo BOOLEAN COMMENT 'Indica se o cartão está ativo.'
)
USING DELTA
COMMENT 'Dados de cartões dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_gastos_cartao (
    id_cartao STRING NOT NULL COMMENT 'Identificador do cartão.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    mes_referencia DATE COMMENT 'Mês de referência.',
    gasto_medio_3m DECIMAL(18,2) COMMENT 'Gasto médio dos últimos 3 meses.',
    gasto_medio_6m DECIMAL(18,2) COMMENT 'Gasto médio dos últimos 6 meses.',
    proporcao_ecommerce DECIMAL(10,4) COMMENT 'Proporção de compras em comércio eletrônico.',
    indicador_compra_internacional BOOLEAN COMMENT 'Indica compra internacional.',
    proporcao_parcelamento DECIMAL(10,4) COMMENT 'Proporção de compras parceladas.'
)
USING DELTA
COMMENT 'Gastos de cartão dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_investimentos (
    id_conta_investimento STRING NOT NULL COMMENT 'Identificador da conta de investimento.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    possui_investimento BOOLEAN COMMENT 'Indica se o cliente possui investimento.',
    perfil_investidor STRING COMMENT 'Perfil de investidor.',
    total_investido DECIMAL(18,2) COMMENT 'Total investido.',
    saldo_renda_fixa DECIMAL(18,2) COMMENT 'Saldo em renda fixa.',
    saldo_fundos DECIMAL(18,2) COMMENT 'Saldo em fundos.',
    saldo_previdencia DECIMAL(18,2) COMMENT 'Saldo em previdência.',
    data_ultimo_investimento DATE COMMENT 'Data do último investimento.'
)
USING DELTA
COMMENT 'Dados de investimentos dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_elegibilidade_ofertas (
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    produto STRING NOT NULL COMMENT 'Produto elegível.',
    status_elegibilidade STRING COMMENT 'Status da elegibilidade.',
    elegivel BOOLEAN COMMENT 'Indica se o cliente é elegível.',
    limite_pre_aprovado DECIMAL(18,2) COMMENT 'Limite pré-aprovado.',
    score_oferta INT COMMENT 'Score de propensão à oferta.',
    prioridade_campanha STRING COMMENT 'Prioridade comercial da campanha.',
    data_referencia DATE COMMENT 'Data de referência da elegibilidade.'
)
USING DELTA
COMMENT 'Elegibilidade de clientes a ofertas.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_credito_perfil (
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    score_bureau INT COMMENT 'Score externo de crédito.',
    score_interno INT COMMENT 'Score interno de crédito.',
    comprometimento_renda_pct DECIMAL(10,4) COMMENT 'Percentual de comprometimento de renda.',
    atraso_maximo_dias_12m INT COMMENT 'Maior atraso nos últimos 12 meses.',
    renda_presumida DECIMAL(18,2) COMMENT 'Renda presumida.',
    propensao_credito DECIMAL(10,4) COMMENT 'Propensão a crédito.',
    risco_credito STRING COMMENT 'Classificação de risco de crédito.',
    restricao_bureau BOOLEAN COMMENT 'Indica restrição em bureau.'
)
USING DELTA
COMMENT 'Perfil de crédito dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_emprestimos (
    id_emprestimo STRING NOT NULL COMMENT 'Identificador do empréstimo.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    produto_emprestimo STRING COMMENT 'Produto do empréstimo.',
    status_emprestimo STRING COMMENT 'Status do empréstimo.',
    valor_parcela DECIMAL(18,2) COMMENT 'Valor da parcela.',
    saldo_devedor DECIMAL(18,2) COMMENT 'Saldo devedor.',
    proximo_vencimento DATE COMMENT 'Data do próximo vencimento.',
    dias_atraso INT COMMENT 'Dias de atraso.',
    garantia BOOLEAN COMMENT 'Indica se há garantia.'
)
USING DELTA
COMMENT 'Contratos de empréstimo dos clientes.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_canais_digitais (
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    app_ativo BOOLEAN COMMENT 'Indica uso ativo do aplicativo.',
    internet_banking_ativo BOOLEAN COMMENT 'Indica uso ativo do internet banking.',
    pix_ativo BOOLEAN COMMENT 'Indica uso ativo do Pix.',
    data_ultimo_login DATE COMMENT 'Data do último login.',
    qtd_logins_30d INT COMMENT 'Quantidade de logins nos últimos 30 dias.',
    aceite_push BOOLEAN COMMENT 'Indica aceite de notificações push.',
    aceite_whatsapp BOOLEAN COMMENT 'Indica aceite de WhatsApp.',
    frequencia_transacional STRING COMMENT 'Faixa de frequência transacional.'
)
USING DELTA
COMMENT 'Engajamento dos clientes em canais digitais.';

CREATE TABLE IF NOT EXISTS main.cliente_360.tb_seguro_produtos (
    id_apolice STRING NOT NULL COMMENT 'Identificador da apólice.',
    cpf_cnpj STRING NOT NULL COMMENT 'Documento do cliente.',
    tipo_seguro STRING COMMENT 'Tipo de seguro.',
    status_apolice STRING COMMENT 'Status da apólice.',
    premio_mensal DECIMAL(18,2) COMMENT 'Prêmio mensal.',
    pacote_assistencia STRING COMMENT 'Pacote de assistência.',
    data_renovacao DATE COMMENT 'Data de renovação.'
)
USING DELTA
COMMENT 'Produtos de seguro dos clientes.';

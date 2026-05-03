CREATE SCHEMA IF NOT EXISTS main.cliente_360;

CREATE TABLE IF NOT EXISTS main.cliente_360.conta (
    cpf_cnpj        STRING NOT NULL COMMENT 'Chave estrangeira para main.publico_alvo.clientes.',
    tipo_conta      STRING COMMENT 'Tipo de conta: corrente, salario, poupanca.',
    status_conta    STRING COMMENT 'Situação atual: ativa, encerrada, bloqueada.',
    agencia         STRING COMMENT 'Agência da conta principal.',
    data_abertura   DATE COMMENT 'Data de abertura desta conta.',
    pacote_servico  STRING COMMENT 'Pacote de serviços contratado: Standard, Prime, Exclusive.'
)
USING delta
COMMENT 'Informações consolidadas sobre a conta corrente/poupança principal do cliente.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.saldo (
    cpf_cnpj               STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    saldo_atual            DECIMAL(18,2) COMMENT 'Saldo atual na conta principal.',
    saldo_medio_3m        DECIMAL(18,2) COMMENT 'Média do saldo nos últimos 3 meses.',
    saldo_investimento    DECIMAL(18,2) COMMENT 'Total aplicado em investimentos (fundos, CDB, etc.).',
    saldo_total           DECIMAL(18,2) COMMENT 'Soma de todos os saldos e investimentos.',
    aplicacoes_automaticas_flag BOOLEAN COMMENT 'Indica se o cliente possui alguma aplicação automática ativa.'
)
USING delta
COMMENT 'Visão consolidada de saldos e investimentos do cliente, atualizada periodicamente.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.elegibilidade (
    cpf_cnpj           STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    elegivel_credito   BOOLEAN COMMENT 'Está elegível para alguma linha de crédito pessoal.',
    limite_preaprov    DECIMAL(18,2) COMMENT 'Valor de limite pré‑aprovado para crédito ou cartão.',
    taxa_juros_min     DECIMAL(5,2) COMMENT 'Menor taxa de juros ofertável para este cliente (a.a).',
    elegivel_consignado BOOLEAN COMMENT 'Possui margem para crédito consignado.',
    elegivel_cartao    BOOLEAN COMMENT 'Está apto a receber um novo cartão de crédito.',
    data_validade      DATE COMMENT 'Data até a qual a pré‑aprovação permanece válida.'
)
USING delta
COMMENT 'Indica produtos para os quais o cliente já está pré‑aprovado, com limites e taxas.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.bens_patrimonio (
    cpf_cnpj              STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    valor_total_bens      DECIMAL(18,2) COMMENT 'Valor estimado total dos bens declarados/conhecidos.',
    qtd_imoveis           INT COMMENT 'Número de imóveis.',
    qtd_veiculos          INT COMMENT 'Número de veículos.',
    declaracao_ir_total   DECIMAL(18,2) COMMENT 'Valor total da última declaração de IR (se disponível).',
    possui_embarcacao     BOOLEAN COMMENT 'Possui embarcação registrada.',
    possui_aeronave       BOOLEAN COMMENT 'Possui aeronave registrada.'
)
USING delta
COMMENT 'Patrimônio tangível do cliente, usado para segmentação de alta renda e seguros.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.credito (
    cpf_cnpj               STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    score_interno          INT COMMENT 'Score interno do banco (0‑1000).',
    score_bureau           INT COMMENT 'Score de bureau de crédito (ex.: Serasa, Boa Vista).',
    limite_credito_total   DECIMAL(18,2) COMMENT 'Soma de todos os limites de crédito já concedidos.',
    utilizacao_percentual  DECIMAL(5,2) COMMENT 'Percentual de utilização do limite total (0‑100).',
    atrasos_12m            INT COMMENT 'Quantidade de atrasos nos últimos 12 meses.',
    possui_emprestimo_ativo BOOLEAN COMMENT 'Indica se há algum empréstimo pessoal ativo.',
    data_ultima_contratacao DATE COMMENT 'Data da contratação mais recente de produto de crédito.'
)
USING delta
COMMENT 'Visão consolidada do perfil de crédito e nível de risco do cliente.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.transacoes (
    cpf_cnpj              STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    qtd_transacoes_30d    INT COMMENT 'Quantidade de transações nos últimos 30 dias.',
    volume_total_30d      DECIMAL(18,2) COMMENT 'Volume financeiro total transacionado nos últimos 30 dias.',
    ticket_medio          DECIMAL(18,2) COMMENT 'Ticket médio das transações no período.',
    categoria_predominante STRING COMMENT 'Categoria mais frequente (alimentação, combustível, viagens, etc.).',
    transacoes_internacionais_flag BOOLEAN COMMENT 'Realizou ao menos uma transação internacional nos últimos 3 meses.'
)
USING delta
COMMENT 'Comportamento transacional recente, útil para ofertas de cartão e seguros.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.engajamento_digital (
    cpf_cnpj                STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    ultimo_acesso_app       DATE COMMENT 'Data do último login no aplicativo.',
    ultimo_login_ib         DATE COMMENT 'Data do último login no Internet Banking.',
    acessos_app_30d         INT COMMENT 'Quantidade de acessos ao app nos últimos 30 dias.',
    push_optin              BOOLEAN COMMENT 'Aceitou receber notificações push.',
    canal_preferido         STRING COMMENT 'Canal de comunicação mais utilizado: app, ib, whatsapp, agencia.',
    cliente_digital_ativo    BOOLEAN COMMENT 'Pelo menos 1 acesso digital nos últimos 90 dias.'
)
USING delta
COMMENT 'Nível de engajamento digital, essencial para definir canal e elegibilidade de comunicação.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.produtos_contratados (
    cpf_cnpj             STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    qtd_produtos_total   INT COMMENT 'Total de produtos ativos com o banco.',
    tem_cartao_credito   BOOLEAN COMMENT 'Possui ao menos um cartão de crédito ativo.',
    tem_seguro           BOOLEAN COMMENT 'Possui seguro contratado (vida, auto, residencial, etc.).',
    tem_previdencia      BOOLEAN COMMENT 'Possui plano de previdência ativo.',
    tem_investimento     BOOLEAN COMMENT 'Possui aplicação em produtos de investimento.',
    tem_conta_digital    BOOLEAN COMMENT 'Possui conta digital ativa.',
    tem_emprestimo       BOOLEAN COMMENT 'Possui empréstimo pessoal ou consignado ativo.'
)
USING delta
COMMENT 'Flags indicando quais produtos o cliente já possui, usado para supressão de comunicações e cross‑sell.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.endividamento (
    cpf_cnpj                   STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    divida_total_sfn           DECIMAL(18,2) COMMENT 'Dívida total no Sistema Financeiro Nacional (SCR).',
    comprometimento_renda_pct  DECIMAL(5,2) COMMENT 'Percentual da renda comprometido com dívidas.',
    parcelas_em_aberto         INT COMMENT 'Número de parcelas em aberto de todas as operações de crédito.',
    renegociacao_12m_flag      BOOLEAN COMMENT 'Passou por processo de renegociação nos últimos 12 meses.',
    possui_cheque_especial_ativo BOOLEAN COMMENT 'Possui contrato de cheque especial ativo.'
)
USING delta
COMMENT 'Indicadores de endividamento para políticas de risco, limites regulatórios e ofertas de renegociação.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);

CREATE TABLE IF NOT EXISTS main.cliente_360.investimentos_perfil (
    cpf_cnpj                STRING NOT NULL COMMENT 'Chave estrangeira para clientes.',
    perfil_risco            STRING COMMENT 'Perfil de risco: conservador, moderado, arrojado.',
    total_investido         DECIMAL(18,2) COMMENT 'Soma total aplicada em todos os produtos de investimento.',
    percentual_renda_fixa   DECIMAL(5,2) COMMENT 'Percentual do total investido em renda fixa.',
    percentual_renda_var    DECIMAL(5,2) COMMENT 'Percentual em renda variável.',
    possui_previdencia      BOOLEAN COMMENT 'Já possui plano de previdência (pode ser nulo ou confirmar na tabela produtos_contratados).',
    data_ultimo_aporte      DATE COMMENT 'Data da última aplicação realizada.'
)
USING delta
COMMENT 'Perfil de investimento e carteira atual, útil para migração de poupança, ofertas de previdência e assessoria.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
)
CLUSTER BY (cpf_cnpj);
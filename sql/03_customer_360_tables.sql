-- Tabelas analíticas e operacionais 360 dos clientes
CREATE TABLE IF NOT EXISTS main.customer_360.tb_contas (
  account_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  account_type STRING,
  account_status STRING,
  opened_date DATE,
  branch_code STRING,
  manager_name STRING,
  package_name STRING,
  overdraft_limit DECIMAL(18,2)
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_saldos_conta (
  account_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  snapshot_date DATE,
  avg_balance_30d DECIMAL(18,2),
  avg_balance_90d DECIMAL(18,2),
  salary_portability BOOLEAN,
  monthly_credit_turnover DECIMAL(18,2),
  monthly_debit_turnover DECIMAL(18,2)
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_cartoes (
  card_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  product_name STRING,
  card_brand STRING,
  card_status STRING,
  credit_limit DECIMAL(18,2),
  available_limit DECIMAL(18,2),
  invoice_due_day INT,
  active_flag BOOLEAN
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_gastos_cartao (
  card_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  reference_month DATE,
  avg_spend_3m DECIMAL(18,2),
  avg_spend_6m DECIMAL(18,2),
  ecommerce_ratio DECIMAL(10,4),
  intl_purchase_flag BOOLEAN,
  installment_ratio DECIMAL(10,4)
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_investimentos (
  investment_account_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  has_investment BOOLEAN,
  investor_profile STRING,
  total_invested DECIMAL(18,2),
  fixed_income_balance DECIMAL(18,2),
  funds_balance DECIMAL(18,2),
  pension_balance DECIMAL(18,2),
  last_investment_date DATE
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_elegibilidade_ofertas (
  cpf_cnpj STRING NOT NULL,
  produto STRING NOT NULL,
  status_elegibilidade STRING,
  elegivel BOOLEAN,
  limite_pre_aprovado DECIMAL(18,2),
  score_oferta INT,
  campaign_priority STRING,
  reference_date DATE
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_credito_perfil (
  cpf_cnpj STRING NOT NULL,
  bureau_score INT,
  internal_score INT,
  comprometimento_renda_pct DECIMAL(10,4),
  atraso_max_dias_12m INT,
  renda_presumida DECIMAL(18,2),
  propensao_credito DECIMAL(10,4),
  risco_credito STRING,
  restricao_bureau BOOLEAN
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_emprestimos (
  loan_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  loan_product STRING,
  loan_status STRING,
  installment_value DECIMAL(18,2),
  outstanding_balance DECIMAL(18,2),
  next_due_date DATE,
  delay_days INT,
  secured_flag BOOLEAN
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_canais_digitais (
  cpf_cnpj STRING NOT NULL,
  mobile_app_active BOOLEAN,
  internet_banking_active BOOLEAN,
  pix_active BOOLEAN,
  last_login_date DATE,
  login_count_30d INT,
  push_opt_in BOOLEAN,
  whatsapp_opt_in BOOLEAN,
  frequencia_transacional STRING
)
USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_seguro_produtos (
  policy_id STRING NOT NULL,
  cpf_cnpj STRING NOT NULL,
  insurance_type STRING,
  policy_status STRING,
  monthly_premium DECIMAL(18,2),
  assistance_bundle STRING,
  renewal_date DATE
)
USING DELTA;

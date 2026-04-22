CREATE TABLE IF NOT EXISTS main.customer_360.tb_contas (
  cpf_cnpj STRING,
  conta_id STRING,
  tipo_conta STRING,
  status_conta STRING,
  agencia STRING,
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_saldos_conta (
  cpf_cnpj STRING,
  conta_id STRING,
  saldo_atual DECIMAL(18,2),
  saldo_medio_90d DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_cartoes (
  cpf_cnpj STRING,
  cartao_id STRING,
  produto_cartao STRING,
  bandeira STRING,
  status_cartao STRING,
  limite_total DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_gastos_cartao (
  cpf_cnpj STRING,
  cartao_id STRING,
  gasto_medio_90d DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_investimentos (
  cpf_cnpj STRING,
  perfil_investidor STRING,
  valor_total_investido DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_elegibilidade_ofertas (
  cpf_cnpj STRING,
  oferta STRING,
  elegivel BOOLEAN,
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_credito_perfil (
  cpf_cnpj STRING,
  score_credito INT,
  atraso_max_dias INT,
  limite_pre_aprovado DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_emprestimos (
  cpf_cnpj STRING,
  emprestimo_id STRING,
  status_emprestimo STRING,
  saldo_devedor DECIMAL(18,2),
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_canais_digitais (
  cpf_cnpj STRING,
  canal_preferido STRING,
  ultimo_acesso_app DATE,
  created_at TIMESTAMP
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.customer_360.tb_seguro_produtos (
  cpf_cnpj STRING,
  produto_seguro STRING,
  status_seguro STRING,
  created_at TIMESTAMP
) USING DELTA;

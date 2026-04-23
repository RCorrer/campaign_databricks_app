CREATE TABLE IF NOT EXISTS main.cliente_360.contas (
  cpf_cnpj STRING, tipo_conta STRING, ativa BOOLEAN, data_abertura DATE
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.cliente_360.saldos (
  cpf_cnpj STRING, saldo_total DECIMAL(18,2), saldo_medio_90d DECIMAL(18,2)
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.cliente_360.cartoes (
  cpf_cnpj STRING, possui_cartao BOOLEAN, limite_total DECIMAL(18,2), gasto_medio_mensal DECIMAL(18,2)
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.cliente_360.investimentos (
  cpf_cnpj STRING, perfil_investidor STRING, valor_investido DECIMAL(18,2)
) USING DELTA;

CREATE TABLE IF NOT EXISTS main.cliente_360.canais_digitais (
  cpf_cnpj STRING, usa_app BOOLEAN, acessos_30d INT
) USING DELTA;

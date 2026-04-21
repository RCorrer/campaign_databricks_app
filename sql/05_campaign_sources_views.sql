-- View 360 enriquecida para consumo do orquestrador
CREATE OR REPLACE VIEW main.campaign_sources.vw_customer_360_enriched AS
SELECT
  base.cpf_cnpj,
  base.customer_type,
  base.full_name,
  base.city,
  base.state,
  base.segment,
  base.monthly_income,
  CAST(months_between(current_date(), account.opened_date) AS INT) AS tempo_relacionamento_meses,
  account.account_type,
  account.account_status AS status_conta,
  account.manager_name,
  account.package_name,
  saldo.avg_balance_30d,
  saldo.avg_balance_90d,
  saldo.monthly_credit_turnover,
  saldo.monthly_debit_turnover,
  card.product_name AS cartao_produto,
  card.card_status,
  card.credit_limit,
  card.available_limit,
  spend.avg_spend_6m AS ticket_medio_6m,
  digital.frequencia_transacional,
  investment.has_investment,
  investment.investor_profile,
  investment.total_invested,
  CASE
    WHEN investment.total_invested >= 300000 THEN 0.95
    WHEN investment.total_invested >= 100000 THEN 0.80
    WHEN investment.total_invested > 0 THEN 0.55
    ELSE 0.20
  END AS propensao_investimento,
  credit.bureau_score,
  credit.internal_score,
  credit.atraso_max_dias_12m,
  credit.propensao_credito,
  credit.risco_credito,
  insurance.insurance_type,
  offer.produto,
  offer.status_elegibilidade,
  offer.elegivel,
  offer.limite_pre_aprovado,
  offer.score_oferta
FROM main.customer_base.customer_master base
LEFT JOIN main.customer_360.tb_contas account
  ON base.cpf_cnpj = account.cpf_cnpj
LEFT JOIN main.customer_360.tb_saldos_conta saldo
  ON account.account_id = saldo.account_id
LEFT JOIN main.customer_360.tb_cartoes card
  ON base.cpf_cnpj = card.cpf_cnpj
LEFT JOIN main.customer_360.tb_gastos_cartao spend
  ON card.card_id = spend.card_id
LEFT JOIN main.customer_360.tb_investimentos investment
  ON base.cpf_cnpj = investment.cpf_cnpj
LEFT JOIN main.customer_360.tb_credito_perfil credit
  ON base.cpf_cnpj = credit.cpf_cnpj
LEFT JOIN main.customer_360.tb_canais_digitais digital
  ON base.cpf_cnpj = digital.cpf_cnpj
LEFT JOIN main.customer_360.tb_seguro_produtos insurance
  ON base.cpf_cnpj = insurance.cpf_cnpj
LEFT JOIN main.customer_360.tb_elegibilidade_ofertas offer
  ON base.cpf_cnpj = offer.cpf_cnpj;

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_clientes_varejo AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE customer_type = 'PF'
  AND segment IN ('VAREJO','VAREJO_MEDIA_RENDA','VAREJO_ALTA_RENDA');

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_cartoes_ativos AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE card_status = 'ATIVO'
  AND status_conta = 'ATIVA';

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_investimentos AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE has_investment = true
  AND total_invested > 0;

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_alta_renda AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE monthly_income >= 12000
   OR segment IN ('ALTA_RENDA','PRIVATE');

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_credito_preaprovado AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE elegivel = true
  AND limite_pre_aprovado >= 20000;

CREATE OR REPLACE VIEW main.campaign_sources.vw_universo_empresas AS
SELECT *
FROM main.campaign_sources.vw_customer_360_enriched
WHERE customer_type = 'PJ';

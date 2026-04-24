CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_base_clientes AS
SELECT
  base.cpf_cnpj,
  base.customer_type,
  base.full_name,
  base.preferred_name,
  CAST(FLOOR(months_between(current_date(), base.birth_date) / 12) AS INT) AS age_years,
  base.gender,
  base.marital_status,
  base.profession,
  base.monthly_income,
  base.income_band,
  base.city,
  base.state,
  base.postal_code,
  base.segment,
  base.subsegment,
  CAST(months_between(current_date(), account.opened_date) AS INT) AS relationship_months,
  base.onboarding_date,
  base.kyc_status,
  base.marketing_consent,
  base.risk_bucket
FROM main.customer_base.customer_master base
LEFT JOIN main.customer_360.tb_contas account
  ON base.cpf_cnpj = account.cpf_cnpj;

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_prime AS
SELECT *
FROM main.campaign_sources.vw_publico_base_clientes
WHERE customer_type = 'PF'
  AND segment = 'PRIME';

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_exclusive AS
SELECT *
FROM main.campaign_sources.vw_publico_base_clientes
WHERE customer_type = 'PF'
  AND segment IN ('EXCLUSIVE', 'PRIVATE');

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_pj AS
SELECT *
FROM main.campaign_sources.vw_publico_base_clientes
WHERE customer_type = 'PJ';

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_varejo AS
SELECT *
FROM main.campaign_sources.vw_publico_base_clientes
WHERE customer_type = 'PF'
  AND segment IN ('VAREJO', 'ALTA_RENDA', 'PRIME');

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_jovem_digital AS
SELECT *
FROM main.campaign_sources.vw_publico_base_clientes
WHERE customer_type = 'PF'
  AND age_years BETWEEN 18 AND 30
  AND marketing_consent = true;

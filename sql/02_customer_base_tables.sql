CREATE TABLE IF NOT EXISTS main.customer_base.customer_master (
  cpf_cnpj STRING NOT NULL,
  customer_type STRING NOT NULL,
  full_name STRING NOT NULL,
  preferred_name STRING,
  birth_date DATE,
  gender STRING,
  marital_status STRING,
  profession STRING,
  monthly_income DECIMAL(18,2),
  income_band STRING,
  city STRING,
  state STRING,
  postal_code STRING,
  segment STRING,
  subsegment STRING,
  onboarding_date DATE,
  kyc_status STRING,
  marketing_consent BOOLEAN,
  risk_bucket STRING
)
USING DELTA;

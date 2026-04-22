CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_base_clientes AS
SELECT
  cpf_cnpj,
  customer_name,
  tipo_cliente,
  segmento,
  subsegmento,
  idade,
  cidade,
  uf,
  renda_mensal,
  faixa_renda
FROM main.customer_base.customer_master;

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_prime AS
SELECT * FROM main.campaign_sources.vw_publico_base_clientes
WHERE cpf_cnpj IN (
  SELECT cpf_cnpj FROM main.customer_base.customer_master WHERE is_prime = TRUE
);

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_exclusive AS
SELECT * FROM main.campaign_sources.vw_publico_base_clientes
WHERE cpf_cnpj IN (
  SELECT cpf_cnpj FROM main.customer_base.customer_master WHERE is_exclusive = TRUE
);

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_pj AS
SELECT * FROM main.campaign_sources.vw_publico_base_clientes
WHERE tipo_cliente = 'PJ';

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_varejo AS
SELECT * FROM main.campaign_sources.vw_publico_base_clientes
WHERE tipo_cliente = 'PF';

CREATE OR REPLACE VIEW main.campaign_sources.vw_publico_jovem_digital AS
SELECT * FROM main.campaign_sources.vw_publico_base_clientes
WHERE idade <= 30
  AND cpf_cnpj IN (
    SELECT cpf_cnpj FROM main.customer_base.customer_master WHERE is_jovem_digital = TRUE
  );

DELETE FROM main.customer_360.tb_seguro_produtos;
DELETE FROM main.customer_360.tb_canais_digitais;
DELETE FROM main.customer_360.tb_emprestimos;
DELETE FROM main.customer_360.tb_credito_perfil;
DELETE FROM main.customer_360.tb_elegibilidade_ofertas;
DELETE FROM main.customer_360.tb_investimentos;
DELETE FROM main.customer_360.tb_gastos_cartao;
DELETE FROM main.customer_360.tb_cartoes;
DELETE FROM main.customer_360.tb_saldos_conta;
DELETE FROM main.customer_360.tb_contas;
DELETE FROM main.customer_base.customer_master;

INSERT INTO main.customer_base.customer_master
SELECT
  lpad(cast(id as string), 11, '0') as cpf_cnpj,
  concat('Cliente ', id) as customer_name,
  CASE WHEN id % 7 = 0 THEN 'PJ' ELSE 'PF' END as tipo_cliente,
  CASE WHEN id % 10 < 3 THEN 'ALTA_RENDA' WHEN id % 10 < 7 THEN 'VAREJO' ELSE 'MASSA' END as segmento,
  CASE WHEN id % 5 = 0 THEN 'EXCLUSIVE' WHEN id % 3 = 0 THEN 'PRIME' ELSE 'PADRAO' END as subsegmento,
  18 + (id % 52) as idade,
  CASE WHEN id % 2 = 0 THEN 'F' ELSE 'M' END as sexo,
  CASE WHEN id % 4 = 0 THEN 'CASADO' ELSE 'SOLTEIRO' END as estado_civil,
  CASE WHEN id % 6 = 0 THEN 'Curitiba' WHEN id % 6 = 1 THEN 'São Paulo' WHEN id % 6 = 2 THEN 'Rio de Janeiro' WHEN id % 6 = 3 THEN 'Porto Alegre' WHEN id % 6 = 4 THEN 'Belo Horizonte' ELSE 'Florianópolis' END as cidade,
  CASE WHEN id % 6 in (0,5) THEN 'PR' WHEN id % 6 = 1 THEN 'SP' WHEN id % 6 = 2 THEN 'RJ' WHEN id % 6 = 3 THEN 'RS' ELSE 'MG' END as uf,
  lpad(cast(80000000 + id as string), 8, '0') as cep,
  CAST(1500 + (id * 137 % 60000) AS DECIMAL(18,2)) as renda_mensal,
  CASE WHEN (1500 + (id * 137 % 60000)) >= 25000 THEN 'ALTA' WHEN (1500 + (id * 137 % 60000)) >= 10000 THEN 'MEDIA' ELSE 'BAIXA' END as faixa_renda,
  CAST(5000 + (id * 999 % 1000000) AS DECIMAL(18,2)) as patrimonio_estimado,
  date_sub(current_date(), 365 + (id % 3000)) as data_relacionamento_inicio,
  CASE WHEN id % 4 = 0 THEN 'RELACIONAMENTO_FORTE' ELSE 'RELACIONAMENTO_PADRAO' END as cluster_relacionamento,
  CASE WHEN id % 3 = 0 THEN true ELSE false END as is_prime,
  CASE WHEN id % 5 = 0 THEN true ELSE false END as is_exclusive,
  CASE WHEN id % 7 = 0 THEN true ELSE false END as is_pj,
  CASE WHEN id % 7 != 0 THEN true ELSE false END as is_varejo,
  CASE WHEN id % 9 = 0 THEN true ELSE false END as is_jovem_digital,
  current_timestamp() as created_at
FROM range(1, 1001);

INSERT INTO main.customer_360.tb_contas
SELECT cpf_cnpj, concat('CONTA-', cpf_cnpj), CASE WHEN tipo_cliente = 'PJ' THEN 'CORRENTE_PJ' ELSE 'CORRENTE' END, 'ATIVA', concat('AG', substr(cpf_cnpj, 1, 4)), current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_saldos_conta
SELECT cpf_cnpj, concat('CONTA-', cpf_cnpj), CAST(renda_mensal * 2 AS DECIMAL(18,2)), CAST(renda_mensal * 1.5 AS DECIMAL(18,2)), current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_cartoes
SELECT
  cpf_cnpj,
  concat('CARTAO-', cpf_cnpj),
  CASE WHEN is_exclusive THEN 'BLACK' WHEN is_prime THEN 'PLATINUM' ELSE 'GOLD' END,
  CASE WHEN cast(substr(cpf_cnpj, 11, 1) as int) % 2 = 0 THEN 'VISA' ELSE 'MASTERCARD' END,
  'ATIVO',
  CAST(renda_mensal * 3 AS DECIMAL(18,2)),
  current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_gastos_cartao
SELECT cpf_cnpj, concat('CARTAO-', cpf_cnpj), CAST(renda_mensal * 0.35 AS DECIMAL(18,2)), current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_investimentos
SELECT
  cpf_cnpj,
  CASE WHEN is_exclusive THEN 'ARROJADO' WHEN is_prime THEN 'MODERADO' ELSE 'CONSERVADOR' END,
  CAST(patrimonio_estimado * 0.4 AS DECIMAL(18,2)),
  current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_elegibilidade_ofertas
SELECT cpf_cnpj, 'CARTAO_BLACK', CASE WHEN renda_mensal >= 15000 AND NOT is_exclusive THEN true ELSE false END, current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_elegibilidade_ofertas
SELECT cpf_cnpj, 'CREDITO_PRE_APROVADO', CASE WHEN renda_mensal >= 8000 THEN true ELSE false END, current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_credito_perfil
SELECT
  cpf_cnpj,
  400 + cast(substr(cpf_cnpj, 10, 2) as int) * 5,
  cast(substr(cpf_cnpj, 9, 1) as int) * 3,
  CAST(renda_mensal * 4 AS DECIMAL(18,2)),
  current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_emprestimos
SELECT cpf_cnpj, concat('EMP-', cpf_cnpj), 'ATIVO', CAST(renda_mensal * 6 AS DECIMAL(18,2)), current_timestamp()
FROM main.customer_base.customer_master
WHERE cast(substr(cpf_cnpj, 11, 1) as int) % 3 = 0;

INSERT INTO main.customer_360.tb_canais_digitais
SELECT cpf_cnpj, CASE WHEN is_jovem_digital THEN 'APP' ELSE 'INTERNET_BANKING' END, date_sub(current_date(), cast(substr(cpf_cnpj, 11, 1) as int)), current_timestamp()
FROM main.customer_base.customer_master;

INSERT INTO main.customer_360.tb_seguro_produtos
SELECT cpf_cnpj, CASE WHEN is_pj THEN 'SEGURO_EMPRESARIAL' ELSE 'SEGURO_RESIDENCIAL' END, 'ATIVO', current_timestamp()
FROM main.customer_base.customer_master
WHERE cast(substr(cpf_cnpj, 11, 1) as int) % 4 = 0;

-- =========================================================
-- 1. CRIAÇÃO DE UMA TABELA TEMPORÁRIA COM OS 1.100 CPF/CNPJ ÚNICOS
-- =========================================================
CREATE OR REPLACE TEMP VIEW universo_ids AS
SELECT
  cpf_cnpj,
  tipo_pessoa
FROM (
  SELECT
    -- PF: CPF falso com 11 dígitos (3 primeiros + 8 aleatórios)
    CONCAT(
      LPAD(CAST(FLOOR(RAND() * 900) AS STRING), 3, '0'),  -- 3 dígitos iniciais
      LPAD(CAST(CAST(FLOOR(RAND() * 100000000) AS BIGINT) AS STRING), 8, '0')  -- 8 aleatórios
    ) AS cpf_cnpj,
    'PF' AS tipo_pessoa
  FROM RANGE(990)  -- 990 PFs
  UNION ALL
  SELECT
    -- PJ: CNPJ falso com 14 dígitos (primeiro dígito 0-9, depois 13 aleatórios)
    CONCAT(
      CAST(FLOOR(RAND() * 10) AS STRING),
      LPAD(CAST(CAST(FLOOR(RAND() * 10000000000000) AS BIGINT) AS STRING), 13, '0')
    ) AS cnpj_falso,
    'PJ'
  FROM RANGE(110)  -- 110 PJs
) T;

-- =========================================================
-- 2. POPULA main.publico_alvo.clientes
-- =========================================================
INSERT INTO main.publico_alvo.clientes
SELECT
  cpf_cnpj,
  CASE WHEN tipo_pessoa = 'PF'
       THEN CONCAT('Cliente ', CAST(CAST(FLOOR(RAND()*10000) AS INT) AS STRING))
       ELSE CONCAT('Empresa ', CAST(CAST(FLOOR(RAND()*10000) AS INT) AS STRING))
  END AS nome,
  tipo_pessoa,
  CASE WHEN tipo_pessoa = 'PF'
       THEN ELT(CAST(FLOOR(RAND()*4) AS INT)+1, 'Prime', 'Exclusive', 'Varejo', 'Private')
       ELSE ELT(CAST(FLOOR(RAND()*3) AS INT)+1, 'PJ Premium', 'PJ Classic', 'PJ Prime')
  END AS segmento,
  CASE WHEN tipo_pessoa = 'PF' THEN CAST(FLOOR(18 + RAND()*80) AS INT) ELSE NULL END AS idade,
  ELT(CAST(FLOOR(RAND()*5) AS INT)+1, 'SP', 'RJ', 'MG', 'DF', 'RS') AS uf,
  ELT(CAST(FLOOR(RAND()*5) AS INT)+1, 'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Porto Alegre') AS cidade,
  CONCAT('AG-', LPAD(CAST(FLOOR(RAND()*9999) AS STRING), 4, '0')) AS agencia_principal,
  CONCAT('CC-', LPAD(CAST(FLOOR(RAND()*9999999) AS STRING), 7, '0')) AS conta_principal,
  CONCAT('email', CAST(FLOOR(RAND()*100000) AS STRING), '@dominio.com') AS email,
  CAST(FLOOR(11 + RAND()*89) AS STRING) AS telefone_ddd,
  CONCAT('9', LPAD(CAST(FLOOR(RAND()*99999999) AS STRING), 8, '0')) AS telefone_numero,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*7300) AS INT)) AS data_abertura_conta
FROM universo_ids;

-- =========================================================
-- 3. POPULA AS 10 TABELAS DO main.cliente_360
-- =========================================================
-- 3.1 conta
INSERT INTO main.cliente_360.conta
SELECT
  cpf_cnpj,
  ELT(CAST(FLOOR(RAND()*3) AS INT)+1, 'corrente', 'salario', 'poupanca') AS tipo_conta,
  ELT(CAST(FLOOR(RAND()*3) AS INT)+1, 'ativa', 'ativa', 'bloqueada') AS status_conta,
  CONCAT('AG-', LPAD(CAST(FLOOR(RAND()*9999) AS STRING), 4, '0')) AS agencia,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*3650) AS INT)) AS data_abertura,
  ELT(CAST(FLOOR(RAND()*3) AS INT)+1, 'Standard', 'Prime', 'Exclusive') AS pacote_servico
FROM universo_ids;

-- 3.2 saldo
INSERT INTO main.cliente_360.saldo
SELECT
  cpf_cnpj,
  ROUND(RAND()*100000, 2) AS saldo_atual,
  ROUND(RAND()*80000, 2) AS saldo_medio_3m,
  ROUND(RAND()*200000, 2) AS saldo_investimento,
  ROUND(RAND()*300000, 2) AS saldo_total,
  CASE WHEN RAND() > 0.5 THEN TRUE ELSE FALSE END AS aplicacoes_automaticas_flag
FROM universo_ids;

-- 3.3 elegibilidade
INSERT INTO main.cliente_360.elegibilidade
SELECT
  cpf_cnpj,
  CASE WHEN RAND() > 0.3 THEN TRUE ELSE FALSE END AS elegivel_credito,
  CASE WHEN RAND() > 0.3 THEN ROUND(RAND()*50000, 2) ELSE NULL END AS limite_preaprov,
  CASE WHEN RAND() > 0.3 THEN ROUND(1.0 + RAND()*5.0, 2) ELSE NULL END AS taxa_juros_min,
  CASE WHEN RAND() > 0.4 THEN TRUE ELSE FALSE END AS elegivel_consignado,
  CASE WHEN RAND() > 0.4 THEN TRUE ELSE FALSE END AS elegivel_cartao,
  DATE_ADD(CURRENT_DATE(), CAST(FLOOR(RAND()*30) AS INT)) AS data_validade
FROM universo_ids;

-- 3.4 bens_patrimonio
INSERT INTO main.cliente_360.bens_patrimonio
SELECT
  cpf_cnpj,
  ROUND(RAND()*5000000, 2) AS valor_total_bens,
  CAST(FLOOR(RAND()*10) AS INT) AS qtd_imoveis,
  CAST(FLOOR(RAND()*5) AS INT) AS qtd_veiculos,
  ROUND(RAND()*2000000, 2) AS declaracao_ir_total,
  CASE WHEN RAND() > 0.95 THEN TRUE ELSE FALSE END AS possui_embarcacao,
  CASE WHEN RAND() > 0.98 THEN TRUE ELSE FALSE END AS possui_aeronave
FROM universo_ids;

-- 3.5 credito
INSERT INTO main.cliente_360.credito
SELECT
  cpf_cnpj,
  CAST(FLOOR(200 + RAND()*800) AS INT) AS score_interno,
  CAST(FLOOR(200 + RAND()*800) AS INT) AS score_bureau,
  ROUND(RAND()*100000, 2) AS limite_credito_total,
  ROUND(RAND()*100, 2) AS utilizacao_percentual,
  CAST(FLOOR(RAND()*10) AS INT) AS atrasos_12m,
  CASE WHEN RAND() > 0.4 THEN TRUE ELSE FALSE END AS possui_emprestimo_ativo,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*365) AS INT)) AS data_ultima_contratacao
FROM universo_ids;

-- 3.6 transacoes
INSERT INTO main.cliente_360.transacoes
SELECT
  cpf_cnpj,
  CAST(FLOOR(RAND()*200) AS INT) AS qtd_transacoes_30d,
  ROUND(RAND()*50000, 2) AS volume_total_30d,
  ROUND(RAND()*500, 2) AS ticket_medio,
  ELT(CAST(FLOOR(RAND()*5) AS INT)+1,
      'alimentação', 'combustível', 'viagens', 'saúde', 'educação') AS categoria_predominante,
  CASE WHEN RAND() > 0.8 THEN TRUE ELSE FALSE END AS transacoes_internacionais_flag
FROM universo_ids;

-- 3.7 engajamento_digital
INSERT INTO main.cliente_360.engajamento_digital
SELECT
  cpf_cnpj,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*90) AS INT)) AS ultimo_acesso_app,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*180) AS INT)) AS ultimo_login_ib,
  CAST(FLOOR(RAND()*60) AS INT) AS acessos_app_30d,
  CASE WHEN RAND() > 0.2 THEN TRUE ELSE FALSE END AS push_optin,
  ELT(CAST(FLOOR(RAND()*4) AS INT)+1, 'app', 'ib', 'whatsapp', 'agencia') AS canal_preferido,
  CASE WHEN RAND() > 0.15 THEN TRUE ELSE FALSE END AS cliente_digital_ativo
FROM universo_ids;

-- 3.8 produtos_contratados
INSERT INTO main.cliente_360.produtos_contratados
SELECT
  cpf_cnpj,
  CAST(FLOOR(RAND()*10) AS INT) AS qtd_produtos_total,
  CASE WHEN RAND() > 0.5 THEN TRUE ELSE FALSE END AS tem_cartao_credito,
  CASE WHEN RAND() > 0.7 THEN TRUE ELSE FALSE END AS tem_seguro,
  CASE WHEN RAND() > 0.8 THEN TRUE ELSE FALSE END AS tem_previdencia,
  CASE WHEN RAND() > 0.6 THEN TRUE ELSE FALSE END AS tem_investimento,
  CASE WHEN RAND() > 0.4 THEN TRUE ELSE FALSE END AS tem_conta_digital,
  CASE WHEN RAND() > 0.6 THEN TRUE ELSE FALSE END AS tem_emprestimo
FROM universo_ids;

-- 3.9 endividamento
INSERT INTO main.cliente_360.endividamento
SELECT
  cpf_cnpj,
  ROUND(RAND()*100000, 2) AS divida_total_sfn,
  ROUND(RAND()*70, 2) AS comprometimento_renda_pct,
  CAST(FLOOR(RAND()*24) AS INT) AS parcelas_em_aberto,
  CASE WHEN RAND() > 0.85 THEN TRUE ELSE FALSE END AS renegociacao_12m_flag,
  CASE WHEN RAND() > 0.7 THEN TRUE ELSE FALSE END AS possui_cheque_especial_ativo
FROM universo_ids;

-- 3.10 investimentos_perfil
INSERT INTO main.cliente_360.investimentos_perfil
SELECT
  cpf_cnpj,
  ELT(CAST(FLOOR(RAND()*3) AS INT)+1,
      'conservador', 'moderado', 'arrojado') AS perfil_risco,
  ROUND(RAND()*200000, 2) AS total_investido,
  ROUND(RAND()*100, 2) AS percentual_renda_fixa,
  ROUND(100 - percentual_renda_fixa, 2) AS percentual_renda_var,
  CASE WHEN RAND() > 0.8 THEN TRUE ELSE FALSE END AS possui_previdencia,
  DATE_ADD(CURRENT_DATE(), - CAST(FLOOR(RAND()*365) AS INT)) AS data_ultimo_aporte
FROM universo_ids;
-- ============================================================
-- 05 - Carga mínima de dados de clientes para demonstração
-- ============================================================

INSERT INTO main.base_clientes.cliente_mestre
(cpf_cnpj, tipo_cliente, nome_completo, nome_preferido, data_nascimento, genero, estado_civil, profissao, renda_mensal, faixa_renda, cidade, uf, cep, segmento, subsegmento, data_inicio_relacionamento, status_cadastro, consentimento_marketing, faixa_risco)
VALUES
('10000000001', 'PF', 'Ana Souza', 'Ana', DATE '1988-05-10', 'F', 'CASADO', 'Médica', 18500.00, 'ALTA', 'Curitiba', 'PR', '80000000', 'PRIME', 'RENDA_ALTA', DATE '2018-01-15', 'APROVADO', true, 'BAIXO'),
('10000000002', 'PF', 'Bruno Lima', 'Bruno', DATE '1999-09-20', 'M', 'SOLTEIRO', 'Analista', 5200.00, 'MEDIA', 'Curitiba', 'PR', '81000000', 'VAREJO', 'DIGITAL', DATE '2022-03-01', 'APROVADO', true, 'MEDIO'),
('10000000003', 'PF', 'Carla Martins', 'Carla', DATE '1976-11-02', 'F', 'CASADO', 'Empresária', 32000.00, 'ALTA', 'São Paulo', 'SP', '01000000', 'PRIVATE', 'ALTA_RENDA', DATE '2015-07-10', 'APROVADO', true, 'BAIXO'),
('20000000000190', 'PJ', 'Empresa Alfa Ltda', 'Alfa', DATE '2010-01-01', NULL, NULL, 'Comércio', 90000.00, 'PJ_ALTA', 'Curitiba', 'PR', '82000000', 'EMPRESAS', 'PJ', DATE '2020-02-20', 'APROVADO', true, 'MEDIO');

INSERT INTO main.cliente_360.tb_contas
(id_conta, cpf_cnpj, tipo_conta, status_conta, data_abertura, codigo_agencia, nome_gerente, nome_pacote, limite_cheque_especial)
VALUES
('CC001', '10000000001', 'CORRENTE', 'ATIVA', DATE '2018-01-15', '0001', 'Mariana', 'Prime Total', 15000.00),
('CC002', '10000000002', 'CORRENTE', 'ATIVA', DATE '2022-03-01', '0002', 'Pedro', 'Digital', 1500.00),
('CC003', '10000000003', 'CORRENTE', 'ATIVA', DATE '2015-07-10', '0003', 'Mariana', 'Private', 50000.00),
('CC004', '20000000000190', 'EMPRESARIAL', 'ATIVA', DATE '2020-02-20', '0004', 'Renato', 'Empresas', 80000.00);

INSERT INTO main.cliente_360.tb_cartoes
(id_cartao, cpf_cnpj, produto_cartao, bandeira_cartao, status_cartao, limite_credito, limite_disponivel, dia_vencimento_fatura, indicador_ativo)
VALUES
('CAR001', '10000000001', 'Visa Infinite', 'VISA', 'ATIVO', 45000.00, 28000.00, 10, true),
('CAR002', '10000000002', 'Gold', 'MASTERCARD', 'ATIVO', 7000.00, 2500.00, 15, true),
('CAR003', '10000000003', 'Black', 'MASTERCARD', 'ATIVO', 90000.00, 62000.00, 5, true);

INSERT INTO main.cliente_360.tb_investimentos
(id_conta_investimento, cpf_cnpj, possui_investimento, perfil_investidor, total_investido, saldo_renda_fixa, saldo_fundos, saldo_previdencia, data_ultimo_investimento)
VALUES
('INV001', '10000000001', true, 'MODERADO', 180000.00, 90000.00, 60000.00, 30000.00, DATE '2026-03-01'),
('INV002', '10000000002', false, 'CONSERVADOR', 0.00, 0.00, 0.00, 0.00, NULL),
('INV003', '10000000003', true, 'ARROJADO', 950000.00, 250000.00, 500000.00, 200000.00, DATE '2026-03-15');

INSERT INTO main.cliente_360.tb_canais_digitais
(cpf_cnpj, app_ativo, internet_banking_ativo, pix_ativo, data_ultimo_login, qtd_logins_30d, aceite_push, aceite_whatsapp, frequencia_transacional)
VALUES
('10000000001', true, true, true, DATE '2026-04-20', 34, true, true, 'ALTA'),
('10000000002', true, true, true, DATE '2026-04-22', 58, true, true, 'ALTA'),
('10000000003', true, true, true, DATE '2026-04-18', 18, true, false, 'MEDIA'),
('20000000000190', true, true, true, DATE '2026-04-21', 22, true, true, 'MEDIA');

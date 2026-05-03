INSERT INTO main.campanhas.brieffing VALUES
(1, 'Aquisição Cartão Básico', 'Cartão de Crédito', 'Varejo', 'Aquisição', 'Oferta de cartão sem anuidade para clientes com conta-salário', 'Email, Push', '2026-05-01', '2026-06-30', 'Clientes PF com conta-salário ativa há mais de 6 meses, sem cartão de crédito', 'conta-salário ativa, tempo de banco > 6 meses', 'já possui cartão ativo, supressão geral, opt-out email', 'planejada'),
(2, 'Upgrade Prime', 'Pacote de Serviços', 'Exclusive', 'Upgrade', 'Migração de clientes Standard com alto volume de investimentos para Prime', 'Email, App', '2026-05-10', '2026-07-10', 'Clientes PF com pacote Standard, saldo investimento > 50 mil, sem pacote Prime atual', 'pacote atual Standard, saldo_investimento >= 50000', 'supressão geral, já possui pacote Prime ou Exclusive', 'planejada'),
(3, 'Crédito Consignado INSS', 'Crédito Consignado', 'Varejo', 'Aquisição', 'Oferta de crédito consignado para aposentados e pensionistas elegíveis', 'SMS, Push', '2026-05-15', '2026-08-15', 'Clientes PF elegíveis para consignado, com margem disponível', 'elegivel_consignado = true', 'score de risco > 800, endividamento > 50%, supressão geral', 'planejada'),
(4, 'Investimento CDB Premium', 'Investimentos', 'Prime', 'Aquisição', 'Oferta de CDB com taxa especial para clientes de alta renda sem investimentos', 'Email, App', '2026-06-01', '2026-07-31', 'Clientes Prime com saldo corrente > 100 mil e nenhum investimento ativo', 'segmento Prime, saldo_atual > 100000, não possui investimento', 'supressão geral, opt-out email', 'planejada'),
(5, 'Seguro Residencial', 'Seguros', 'Exclusive, Prime', 'Cross-sell', 'Oferta de seguro residencial para clientes com alto patrimônio imobiliário', 'Email, Ligação', '2026-06-10', '2026-08-10', 'Clientes com mais de 2 imóveis e sem seguro contratado', 'qtd_imoveis >= 2, não possui seguro', 'supressão geral, cliente já tem seguro residencial (produto)', 'planejada'),
(6, 'Conta Digital Jovem', 'Conta Digital', 'Varejo', 'Aquisição', 'Abertura de conta digital para clientes entre 18-25 anos com engajamento digital', 'Push, WhatsApp', '2026-06-15', '2026-08-15', 'Jovens 18-25 anos, sem conta digital, que acessam app regularmente', 'idade entre 18 e 25, cliente_digital_ativo, não tem conta digital', 'supressão geral, já possui conta digital', 'planejada'),
(7, 'Plano Previdência Futura', 'Previdência', 'Private, Prime', 'Aquisição', 'Oferta de previdência privada para clientes conservadores com grande volume de renda fixa', 'Email, Ligação', '2026-07-01', '2026-09-30', 'Clientes perfil conservador, com >200 mil em renda fixa, sem previdência', 'perfil_risco = conservador, total_investido > 200000, percentual_renda_fixa > 70, não tem previdência', 'supressão geral, já possui previdência', 'planejada'),
(8, 'Negocie sua Dívida', 'Renegociação', 'Todos', 'Recuperação', 'Campanha de renegociação para clientes com atrasos nos últimos 12 meses', 'SMS, Ligação', '2026-07-10', '2026-08-20', 'Clientes com atrasos > 2 nos últimos 12 meses e parcelas em aberto', 'atrasos_12m >= 2, parcelas_em_aberto > 0', 'renegociacao_12m_flag = true, supressão geral', 'planejada'),
(9, 'Cartão Platinum Travel', 'Cartão de Crédito', 'Exclusive, Prime', 'Upgrade', 'Upgrade para cartão Platinum com milhas para clientes com transações internacionais', 'Email, App', '2026-08-01', '2026-09-30', 'Clientes com cartão de crédito ativo, transações internacionais recentes, sem cartão Platinum', 'tem_cartao_credito, transacoes_internacionais_flag = true', 'já possui cartão Platinum, supressão geral', 'planejada'),
(10, 'Cheque Especial', 'Crédito', 'Varejo', 'Aquisição', 'Oferta de cheque especial para clientes com conta corrente e limite pré-aprovado', 'Push, SMS', '2026-08-05', '2026-10-05', 'Clientes com conta ativa, limite pré-aprovado > 2000, sem cheque especial', 'status_conta ativa, limite_preaprov >= 2000', 'possui_cheque_especial_ativo = true, supressão geral', 'planejada'),
(11, 'Seguro Auto Essencial', 'Seguros', 'Varejo, Prime', 'Cross-sell', 'Oferta de seguro auto para clientes com veículos e sem seguro', 'Email, Push', '2026-08-15', '2026-10-15', 'Clientes PF com veículo(s), sem seguro contratado', 'qtd_veiculos >= 1, não tem seguro', 'supressão geral, já possui seguro auto', 'planejada'),
(12, 'Portabilidade Salário', 'Relacionamento', 'Varejo', 'Aquisição', 'Convide clientes com conta-salário em outro banco para portabilidade', 'Email, Ligação', '2026-09-01', '2026-11-01', 'Clientes com conta-salário externa (identificados via crédito de salário)', 'tipo_conta = salario, canal preferido = app ou ib', 'não está na base de portabilidade, supressão geral', 'planejada'),
(13, 'Crédito Pessoal Rápido', 'Crédito Pessoal', 'Varejo, Prime', 'Aquisição', 'Empréstimo pessoal com taxa reduzida para clientes com bom score', 'Email, SMS', '2026-09-15', '2026-11-15', 'Clientes elegíveis a crédito pessoal, score interno > 600', 'elegivel_credito = true, score_interno > 600', 'possui_emprestimo_ativo = true, comprometimento > 40%, supressão geral', 'planejada'),
(14, 'Cashback Internacional', 'Cartão de Crédito', 'Prime, Exclusive', 'Uso/Engajamento', 'Estimular uso do cartão no exterior com cashback de 5%', 'Email, Push', '2026-10-01', '2026-12-31', 'Clientes com cartão de crédito ativo que viajam (transações internacionais)', 'tem_cartao_credito, transacoes_internacionais_flag = true', 'supressão geral, cartão bloqueado', 'planejada'),
(15, 'Feliz Aniversário', 'Relacionamento', 'Todos', 'Fidelização', 'Mensagem de aniversário com oferta de limite extra', 'Email, SMS, Push', '2026-01-01', '2026-12-31', 'Clientes PF aniversariantes do mês', 'mês de aniversário igual ao mês corrente', 'supressão geral', 'planejada'),
(16, 'Aumente seu Limite', 'Crédito', 'Varejo, Prime', 'Upgrade', 'Aumento de limite de crédito para bons pagadores com utilização alta', 'Email, App', '2026-10-10', '2026-12-10', 'Clientes com limite > 0, utilização > 70%, atrasos = 0, score > 700', 'tem_cartao_credito, utilizacao_percentual > 70, atrasos_12m = 0, score_interno > 700', 'supressão geral, crédito suspenso', 'planejada'),
(17, 'Seguro Viagem', 'Seguros', 'Prime, Exclusive', 'Cross-sell', 'Seguro viagem para clientes com transações internacionais recentes', 'Email, Push', '2026-11-01', '2027-01-31', 'Clientes com transações internacionais nos últimos 90 dias', 'transacoes_internacionais_flag = true', 'já possui seguro viagem, supressão geral', 'planejada'),
(18, 'Dê adeus à Poupança', 'Investimentos', 'Varejo, Prime', 'Migração', 'Migrar saldo da poupança para CDB de alta liquidez', 'Email, App', '2026-11-15', '2027-01-15', 'Clientes com mais de 10 mil na poupança e perfil conservador', 'tipo_conta poupanca, saldo_atual > 10000, perfil_risco conservador', 'supressão geral, já possui investimento CDB', 'planejada'),
(19, 'Indique e Ganhe', 'MGM', 'Todos', 'Aquisição', 'Indicação de amigos para abertura de conta digital', 'Email, Push, WhatsApp', '2026-12-01', '2027-02-28', 'Clientes digitais ativos que não realizaram indicação recentemente', 'cliente_digital_ativo, não ter indicado nos últimos 6 meses', 'supressão geral, bloqueio de campanhas', 'planejada'),
(20, 'Reative sua Conta', 'Reativação', 'Varejo', 'Retenção', 'Reativação de clientes com conta encerrada ou inativa há mais de 6 meses', 'Email, Ligação', '2026-12-10', '2027-03-10', 'Clientes com status conta encerrada ou sem movimentação há 180 dias', 'status_conta encerrada ou última transação > 180 dias', 'supressão geral, falecidos', 'planejada');


INSERT INTO main.campanhas.regras_segmentacao VALUES
(1, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "co.tipo_conta = ''salario''"},
    {"condicao": "DATEDIFF(MONTH, c.data_abertura_conta, CURRENT_DATE) > 6"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.produtos_contratados WHERE tem_cartao_credito = true)"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(2, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.saldo", "alias": "s", "on": "c.cpf_cnpj = s.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "co.pacote_servico = ''Standard''"},
    {"condicao": "s.saldo_investimento >= 50000"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.conta WHERE pacote_servico IN (''Prime'', ''Exclusive''))"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "s.saldo_investimento"]
}'),
(3, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.elegibilidade", "alias": "el", "on": "c.cpf_cnpj = el.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.credito", "alias": "cr", "on": "c.cpf_cnpj = cr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.endividamento", "alias": "en", "on": "c.cpf_cnpj = en.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "el.elegivel_consignado = true"}
  ],
  "exclusao": [
    {"condicao": "cr.score_interno > 800"},
    {"condicao": "en.comprometimento_renda_pct > 50"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.telefone_ddd", "c.telefone_numero"]
}'),
(4, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.saldo", "alias": "s", "on": "c.cpf_cnpj = s.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "c.segmento = ''Prime''"},
    {"condicao": "s.saldo_atual > 100000"},
    {"condicao": "pr.tem_investimento = false OR pr.tem_investimento IS NULL"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"},
    {"tipo": "optout", "canal": "email"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(5, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.bens_patrimonio", "alias": "bp", "on": "c.cpf_cnpj = bp.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "bp.qtd_imoveis >= 2"},
    {"condicao": "pr.tem_seguro = false OR pr.tem_seguro IS NULL"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "bp.qtd_imoveis"]
}'),
(6, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.engajamento_digital", "alias": "ed", "on": "c.cpf_cnpj = ed.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "c.idade BETWEEN 18 AND 25"},
    {"condicao": "ed.cliente_digital_ativo = true"},
    {"condicao": "pr.tem_conta_digital = false OR pr.tem_conta_digital IS NULL"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.telefone_ddd", "c.telefone_numero"]
}'),
(7, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.investimentos_perfil", "alias": "ip", "on": "c.cpf_cnpj = ip.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "ip.perfil_risco = ''conservador''"},
    {"condicao": "ip.total_investido > 200000"},
    {"condicao": "ip.percentual_renda_fixa > 70"},
    {"condicao": "pr.tem_previdencia = false OR pr.tem_previdencia IS NULL"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "ip.total_investido"]
}'),
(8, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.credito", "alias": "cr", "on": "c.cpf_cnpj = cr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.endividamento", "alias": "en", "on": "c.cpf_cnpj = en.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "cr.atrasos_12m >= 2"},
    {"condicao": "en.parcelas_em_aberto > 0"}
  ],
  "exclusao": [
    {"condicao": "en.renegociacao_12m_flag = true"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.telefone_ddd", "c.telefone_numero"]
}'),
(9, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.transacoes", "alias": "tr", "on": "c.cpf_cnpj = tr.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "pr.tem_cartao_credito = true"},
    {"condicao": "tr.transacoes_internacionais_flag = true"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(10, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.elegibilidade", "alias": "el", "on": "c.cpf_cnpj = el.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.endividamento", "alias": "en", "on": "c.cpf_cnpj = en.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "co.status_conta = ''ativa''"},
    {"condicao": "el.limite_preaprov >= 2000"}
  ],
  "exclusao": [
    {"condicao": "en.possui_cheque_especial_ativo = true"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.telefone_ddd", "c.telefone_numero"]
}'),
(11, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.bens_patrimonio", "alias": "bp", "on": "c.cpf_cnpj = bp.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "bp.qtd_veiculos >= 1"},
    {"condicao": "pr.tem_seguro = false OR pr.tem_seguro IS NULL"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(12, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.engajamento_digital", "alias": "ed", "on": "c.cpf_cnpj = ed.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "co.tipo_conta = ''salario''"},
    {"condicao": "ed.canal_preferido IN (''app'', ''ib'')"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "c.telefone_ddd", "c.telefone_numero"]
}'),
(13, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.elegibilidade", "alias": "el", "on": "c.cpf_cnpj = el.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.credito", "alias": "cr", "on": "c.cpf_cnpj = cr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.endividamento", "alias": "en", "on": "c.cpf_cnpj = en.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "el.elegivel_credito = true"},
    {"condicao": "cr.score_interno > 600"}
  ],
  "exclusao": [
    {"condicao": "cr.possui_emprestimo_ativo = true"},
    {"condicao": "en.comprometimento_renda_pct > 40"},
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(14, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.transacoes", "alias": "tr", "on": "c.cpf_cnpj = tr.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "pr.tem_cartao_credito = true"},
    {"condicao": "tr.transacoes_internacionais_flag = true"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(15, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [],
  "inclusao": [
    {"condicao": "MONTH(c.data_abertura_conta) = MONTH(CURRENT_DATE) AND DAY(c.data_abertura_conta) = DAY(CURRENT_DATE)"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "c.telefone_ddd", "c.telefone_numero"]
}'),
(16, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.credito", "alias": "cr", "on": "c.cpf_cnpj = cr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "pr.tem_cartao_credito = true"},
    {"condicao": "cr.utilizacao_percentual > 70"},
    {"condicao": "cr.atrasos_12m = 0"},
    {"condicao": "cr.score_interno > 700"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(17, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.transacoes", "alias": "tr", "on": "c.cpf_cnpj = tr.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.produtos_contratados", "alias": "pr", "on": "c.cpf_cnpj = pr.cpf_cnpj", "tipo": "LEFT JOIN"}
  ],
  "inclusao": [
    {"condicao": "tr.transacoes_internacionais_flag = true"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(18, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.saldo", "alias": "s", "on": "c.cpf_cnpj = s.cpf_cnpj", "tipo": "INNER"},
    {"tabela": "main.cliente_360.investimentos_perfil", "alias": "ip", "on": "c.cpf_cnpj = ip.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "co.tipo_conta = ''poupanca''"},
    {"condicao": "s.saldo_atual > 10000"},
    {"condicao": "ip.perfil_risco = ''conservador''"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email"]
}'),
(19, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.engajamento_digital", "alias": "ed", "on": "c.cpf_cnpj = ed.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "ed.cliente_digital_ativo = true"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "c.telefone_ddd", "c.telefone_numero"]
}'),
(20, '{
  "base": {"tabela": "main.publico_alvo.clientes", "alias": "c"},
  "joins": [
    {"tabela": "main.cliente_360.conta", "alias": "co", "on": "c.cpf_cnpj = co.cpf_cnpj", "tipo": "INNER"}
  ],
  "inclusao": [
    {"condicao": "co.status_conta IN (''encerrada'', ''bloqueada'') OR co.data_abertura < DATE_SUB(CURRENT_DATE, 180)"}
  ],
  "exclusao": [
    {"tipo": "subquery", "condicao": "c.cpf_cnpj NOT IN (SELECT cpf_cnpj FROM main.cliente_360.supressao_geral)"}
  ],
  "colunas": ["c.cpf_cnpj", "c.nome", "c.email", "c.telefone_ddd", "c.telefone_numero"]
}');
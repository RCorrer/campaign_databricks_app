INSERT OVERWRITE main.base_clientes.cliente_mestre VALUES
('11111111111','Ana Souza','PF',28,'Curitiba','PR',6500.00,'prime',current_timestamp()),
('22222222222','Bruno Lima','PF',35,'Curitiba','PR',4200.00,'varejo',current_timestamp()),
('33333333333','Carla Rocha','PF',23,'São Paulo','SP',3100.00,'jovem_digital',current_timestamp()),
('44444444444','Delta Comércio','PJ',0,'Curitiba','PR',25000.00,'pj',current_timestamp()),
('55555555555','Eduardo Alves','PF',47,'Rio de Janeiro','RJ',12000.00,'exclusive',current_timestamp());

INSERT OVERWRITE main.cliente_360.contas VALUES
('11111111111','corrente',true,DATE '2020-01-10'),
('22222222222','corrente',true,DATE '2021-03-12'),
('33333333333','digital',true,DATE '2023-07-01'),
('44444444444','empresarial',true,DATE '2019-05-20'),
('55555555555','corrente',true,DATE '2018-11-08');

INSERT OVERWRITE main.cliente_360.saldos VALUES
('11111111111',18000.00,14500.00),
('22222222222',3200.00,2800.00),
('33333333333',900.00,700.00),
('44444444444',75000.00,69000.00),
('55555555555',52000.00,48000.00);

INSERT OVERWRITE main.cliente_360.cartoes VALUES
('11111111111',true,25000.00,4200.00),
('22222222222',true,7000.00,1800.00),
('33333333333',true,2500.00,900.00),
('44444444444',false,0.00,0.00),
('55555555555',true,50000.00,8500.00);

INSERT OVERWRITE main.cliente_360.investimentos VALUES
('11111111111','moderado',35000.00),
('22222222222','conservador',5000.00),
('33333333333','iniciante',800.00),
('44444444444','conservador',150000.00),
('55555555555','arrojado',250000.00);

INSERT OVERWRITE main.cliente_360.canais_digitais VALUES
('11111111111',true,28),
('22222222222',true,12),
('33333333333',true,45),
('44444444444',false,2),
('55555555555',true,20);

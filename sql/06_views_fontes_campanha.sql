CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_base_clientes AS
SELECT * FROM main.base_clientes.cliente_mestre;

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_prime AS
SELECT * FROM main.base_clientes.cliente_mestre WHERE segmento = 'prime';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_exclusive AS
SELECT * FROM main.base_clientes.cliente_mestre WHERE segmento = 'exclusive';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_pj AS
SELECT * FROM main.base_clientes.cliente_mestre WHERE tipo_pessoa = 'PJ';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_varejo AS
SELECT * FROM main.base_clientes.cliente_mestre WHERE segmento = 'varejo';

CREATE OR REPLACE VIEW main.fontes_campanha.vw_publico_jovem_digital AS
SELECT * FROM main.base_clientes.cliente_mestre WHERE segmento = 'jovem_digital';

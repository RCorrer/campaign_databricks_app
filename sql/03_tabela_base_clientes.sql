CREATE TABLE IF NOT EXISTS main.base_clientes.cliente_mestre (
  cpf_cnpj STRING NOT NULL,
  nome_cliente STRING,
  tipo_pessoa STRING,
  idade INT,
  cidade STRING,
  uf STRING,
  renda_mensal DECIMAL(18,2),
  segmento STRING,
  criado_em TIMESTAMP
)
USING DELTA;

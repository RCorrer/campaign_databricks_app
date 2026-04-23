-- Execute este script apenas se você já criou a tabela campaign_header em uma versão anterior do projeto sem a coluna description.
ALTER TABLE main.campaign_app.campaign_header ADD COLUMNS (
  description STRING
);

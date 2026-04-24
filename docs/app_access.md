# Acessos necessários para o Databricks App

## Recursos mínimos

1. **SQL Warehouse**
   - recurso do app com permissão **Can use**

2. **Unity Catalog**
   - catálogo: `main`
   - schemas:
     - `main.campaign_app`
     - `main.customer_base`
     - `main.customer_360`
     - `main.campaign_sources`
     - `main.campaign_execution`

## Objetos que o app precisa ler

### Schema `main.campaign_sources`
- `vw_publico_base_clientes`
- `vw_publico_prime`
- `vw_publico_exclusive`
- `vw_publico_pj`
- `vw_publico_varejo`
- `vw_publico_jovem_digital`

### Schema `main.customer_base`
- `customer_master`

### Schema `main.customer_360`
- `tb_contas`
- `tb_saldos_conta`
- `tb_cartoes`
- `tb_gastos_cartao`
- `tb_investimentos`
- `tb_elegibilidade_ofertas`
- `tb_credito_perfil`
- `tb_emprestimos`
- `tb_canais_digitais`
- `tb_seguro_produtos`

### Schema `main.campaign_app`
- `campaign_header`
- `campaign_briefing_version`
- `campaign_segmentation_version`
- `campaign_activation_version`
- `campaign_status_history`
- `campaign_audit_event`
- `vw_campaign_current_definition`

## Objetos que o app precisa escrever

### Schema `main.campaign_execution`
- `campaign_audience`
- `campaign_run_log`

## Arquivo de grants

Use `sql/08_app_grants.sql` e substitua o placeholder:

- `<APP_SERVICE_PRINCIPAL>`

pelo nome exato do service principal do app.

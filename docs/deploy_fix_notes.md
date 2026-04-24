# Deploy Fix Notes

- Build atualizado para chamar o CLI do Vite via `node ./node_modules/vite/bin/vite.js` e evitar o wrapper quebrado em `.bin/vite`.
- `postinstall` adiciona permissão de execução aos binários do esbuild no ambiente Linux do Databricks Apps.
- `delete_campaign` e `change_status` tratam concorrência Delta com retry simples e resposta idempotente.
- `get_campaign` responde 404 quando a campanha não existir.

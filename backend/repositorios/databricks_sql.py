from __future__ import annotations

import os
import time
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.sql import StatementState

from backend.configuracoes.configuracao import configuracao


class RepositorioDatabricksSQL:
    def __init__(self) -> None:
        self.cliente = WorkspaceClient()
        self.warehouse_id = configuracao.databricks_warehouse_id or os.getenv("DATABRICKS_WAREHOUSE_ID")
        if not self.warehouse_id:
            raise RuntimeError("DATABRICKS_WAREHOUSE_ID não definido")

    def executar(self, sql: str) -> list[dict]:
        resposta = self.cliente.statement_execution.execute_statement(
            warehouse_id=self.warehouse_id,
            statement=sql,
            wait_timeout="30s",
            disposition="INLINE",
        )
        statement_id = resposta.statement_id
        while resposta.status and resposta.status.state in {StatementState.PENDING, StatementState.RUNNING}:
            time.sleep(1)
            resposta = self.cliente.statement_execution.get_statement(statement_id)
        estado = resposta.status.state if resposta.status else None
        if estado != StatementState.SUCCEEDED:
            mensagem = resposta.status.error.message if resposta.status and resposta.status.error else "Erro ao executar SQL"
            raise RuntimeError(mensagem)
        if not resposta.result or not resposta.result.data_array:
            return []
        colunas = [c.name for c in resposta.manifest.schema.columns]
        return [dict(zip(colunas, linha)) for linha in resposta.result.data_array]

    def executar_script(self, comandos: list[str]) -> None:
        for comando in comandos:
            if comando and comando.strip():
                self.executar(comando)

    def escalar(self, sql: str, padrao=None):
        linhas = self.executar(sql)
        if not linhas:
            return padrao
        primeira = linhas[0]
        if not primeira:
            return padrao
        return next(iter(primeira.values()))


repositorio_sql = RepositorioDatabricksSQL()

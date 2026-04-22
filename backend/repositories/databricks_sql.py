from __future__ import annotations

import time
from typing import Any

from databricks.sdk import WorkspaceClient

from backend.core.config import settings


class DatabricksSQLRepository:
    def __init__(self) -> None:
        self.client = WorkspaceClient()
        self.warehouse_id = settings.databricks_warehouse_id

    def execute(self, statement: str, wait_timeout: str = "20s") -> list[list[Any]]:
        response = self.client.statement_execution.execute_statement(
            warehouse_id=self.warehouse_id,
            statement=statement,
            wait_timeout=wait_timeout,
        )
        return self._collect(response.statement_id)

    def _collect(self, statement_id: str) -> list[list[Any]]:
        for _ in range(60):
            result = self.client.statement_execution.get_statement(statement_id)
            state = str(result.status.state)

            if "SUCCEEDED" in state:
                if result.result and result.result.data_array:
                    return result.result.data_array
                return []

            if any(x in state for x in ["FAILED", "CANCELED", "CLOSED"]):
                raise RuntimeError(str(getattr(result.status, "error", "Erro ao executar SQL no Databricks")))

            time.sleep(0.5)

        raise TimeoutError("Timeout executando statement no Databricks SQL")

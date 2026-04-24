from __future__ import annotations

import time
from typing import Any

from databricks.sdk import WorkspaceClient

from backend.core.config import settings


class DatabricksSQLRepository:
    def __init__(self) -> None:
        self.client = WorkspaceClient()
        self.warehouse_id = settings.databricks_warehouse_id

    def execute(self, statement: str, wait_timeout: str = "20s", retries: int = 1) -> list[list[Any]]:
        last_error: Exception | None = None
        for attempt in range(retries + 1):
            try:
                response = self.client.statement_execution.execute_statement(
                    warehouse_id=self.warehouse_id,
                    statement=statement,
                    wait_timeout=wait_timeout,
                )
                return self._collect(response.statement_id)
            except RuntimeError as exc:
                message = str(exc)
                if "DELTA_CONCURRENT_DELETE_READ" in message and attempt < retries:
                    time.sleep(0.8 * (attempt + 1))
                    last_error = exc
                    continue
                raise
        if last_error:
            raise last_error
        return []

    def execute_script(self, statements: list[str], wait_timeout: str = "20s", retries: int = 1) -> None:
        for statement in statements:
            clean = statement.strip()
            if clean:
                self.execute(clean, wait_timeout=wait_timeout, retries=retries)

    def _collect(self, statement_id: str) -> list[list[Any]]:
        for _ in range(60):
            result = self.client.statement_execution.get_statement(statement_id)
            state = str(result.status.state)

            if "SUCCEEDED" in state:
                if result.result and result.result.data_array:
                    return result.result.data_array
                return []

            if any(x in state for x in ["FAILED", "CANCELED", "CLOSED"]):
                message = str(getattr(result.status, "error", "Erro ao executar SQL no Databricks"))
                raise RuntimeError(message)

            time.sleep(0.5)

        raise TimeoutError("Timeout executando statement no Databricks SQL")

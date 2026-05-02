import time
from typing import Any

from databricks.sdk import WorkspaceClient

from app.config import settings


class DatabricksSQLRepository:
    def __init__(self) -> None:
        self.client: WorkspaceClient | None = None
        self.warehouse_id = settings.databricks_warehouse_id

    def _ensure_client(self) -> WorkspaceClient:
        if not self.warehouse_id:
            raise RuntimeError("DATABRICKS_WAREHOUSE_ID não definido")
        if self.client is None:
            self.client = WorkspaceClient()
        return self.client

    def execute(self, statement: str) -> list[dict[str, Any]]:
        client = self._ensure_client()
        response = client.statement_execution.execute_statement(
            warehouse_id=self.warehouse_id,
            statement=statement,
        )
        statement_id = response.statement_id

        for _ in range(120):
            result = client.statement_execution.get_statement(statement_id)
            state = str(result.status.state)

            if "SUCCEEDED" in state:
                return self._to_rows(result)

            if any(token in state for token in ["FAILED", "CANCELED", "CLOSED"]):
                error = getattr(result.status, "error", None)
                message = getattr(error, "message", None) or str(error) or "Erro executando SQL no Databricks"
                raise RuntimeError(message)

            time.sleep(1)

        raise TimeoutError("Timeout aguardando execução SQL no Databricks")

    def execute_script(self, statements: list[str]) -> None:
        for statement in statements:
            clean = statement.strip()
            if clean:
                self.execute(clean)

    def scalar(self, statement: str, default: Any = None) -> Any:
        rows = self.execute(statement)
        if not rows:
            return default
        first = rows[0]
        if not first:
            return default
        return next(iter(first.values()))

    def _to_rows(self, result) -> list[dict[str, Any]]:
        execution_result = getattr(result, "result", None)
        data = getattr(execution_result, "data_array", None) or []

        columns: list[str] = []
        manifest = getattr(result, "manifest", None)
        if manifest and getattr(manifest, "schema", None):
            schema = manifest.schema
            if getattr(schema, "columns", None):
                columns = [getattr(col, "name", f"col_{idx}") for idx, col in enumerate(schema.columns)]

        rows: list[dict[str, Any]] = []
        for row in data:
            if isinstance(row, dict):
                rows.append(row)
                continue
            if not columns:
                columns = [f"col_{idx}" for idx in range(len(row))]
            rows.append({columns[idx]: row[idx] for idx in range(min(len(columns), len(row)))})
        return rows


sql_repository = DatabricksSQLRepository()

import time
from databricks.sdk import WorkspaceClient
from app.config import AppConfig
from typing import Dict, Any, List

class DatabricksSQLClient:
    def __init__(self):
        self.warehouse_id = AppConfig.get_warehouse_id()
        self.client = WorkspaceClient()

    def execute_query(self, sql: str, params: Dict[str, Any] = None, timeout: int = 60) -> List[List]:
        if params:
            param_list = [{"name": k, "value": v} for k, v in params.items()]
        else:
            param_list = []

        response = self.client.statement_execution.execute_statement(
            warehouse_id=self.warehouse_id,
            statement=sql,
            parameters=param_list
        )
        statement_id = response.statement_id

        for _ in range(int(timeout / 2)):
            result = self.client.statement_execution.get_statement(statement_id)
            estado = str(result.status.state)
            if "SUCCEEDED" in estado:
                return result.result.data_array if result.result else []
            if any(x in estado for x in ["FAILED", "CANCELED", "CLOSED"]):
                raise RuntimeError(f"Query falhou: {getattr(result.status, 'error', 'Erro desconhecido')}")
            time.sleep(2)
        raise TimeoutError("Timeout aguardando query")

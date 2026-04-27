from app.config import AppConfig
from app.infra.db.databricks_client import DatabricksSQLClient
from app.repositories.lead_repository import LeadRepository
from typing import List, Dict, Any

class LeadRepositoryImpl(LeadRepository):
    def __init__(self, db_client: DatabricksSQLClient):
        self.db = db_client
        self.catalog = AppConfig.get_catalog()
        self.schema = AppConfig.get_schema_leads()

    def create_view(self, view_name: str, sql_query: str) -> None:
        full_name = view_name if "." in view_name else f"{self.catalog}.{self.schema}.{view_name}"
        self.db.execute_query(f"CREATE OR REPLACE VIEW {full_name} AS {sql_query}")

    def drop_view(self, view_name: str) -> None:
        full_name = view_name if "." in view_name else f"{self.catalog}.{self.schema}.{view_name}"
        self.db.execute_query(f"DROP VIEW IF EXISTS {full_name}")

    def list_views(self) -> List[str]:
        data = self.db.execute_query(f"SHOW VIEWS IN {self.catalog}.{self.schema}")
        return [r[1] for r in data] if data else []

    def get_leads_from_view(self, view_name: str, limit: int = 100) -> List[Dict[str, Any]]:
        full_name = view_name if "." in view_name else f"{self.catalog}.{self.schema}.{view_name}"
        sql = f"SELECT * FROM {full_name} LIMIT {limit}"
        data = self.db.execute_query(sql)
        if not data:
            return []
        # Retorna dicionário simples usando índices como chave (idealmente buscar metadados)
        return [dict(enumerate(row)) for row in data]

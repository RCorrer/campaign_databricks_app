import os

class AppConfig:
    """Configurações centralizadas do aplicativo."""

    # Databricks Warehouse ID – deve vir da variável de ambiente
    databricks_warehouse_id: str = os.getenv("DATABRICKS_WAREHOUSE_ID")

    # Schemas do Unity Catalog
    uc_catalog: str = "main"
    uc_publico_alvo_schema: str = "publico_alvo"
    uc_cliente_360_schema: str = "cliente_360"
    uc_campanhas_schema: str = "campanhas"

    @property
    def publico_alvo_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.uc_publico_alvo_schema}"

    @property
    def cliente_360_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.uc_cliente_360_schema}"

    @property
    def campanhas_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.uc_campanhas_schema}"


settings = AppConfig()

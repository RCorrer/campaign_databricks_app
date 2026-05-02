import os

class AppConfig:
    @staticmethod
    def get_warehouse_id() -> str:
        val = os.getenv("DATABRICKS_WAREHOUSE_ID")
        if not val:
            raise RuntimeError("DATABRICKS_WAREHOUSE_ID não definido")
        return val

    @staticmethod
    def get_catalog() -> str:
        return os.getenv("UC_CATALOG", "main")

    @staticmethod
    def get_schema_publico_alvo() -> str:
        return os.getenv("UC_SCHEMA_PUBLICO_ALVO", "publico_alvo")

    @staticmethod
    def get_schema_cliente_360() -> str:
        return os.getenv("UC_SCHEMA_CLIENTE_360", "cliente_360")

    @staticmethod
    def get_schema_campanhas() -> str:
        return os.getenv("UC_SCHEMA_CAMPANHAS", "campanhas")

    @staticmethod
    def get_schema_leads() -> str:
        return os.getenv("UC_SCHEMA_LEADS", "leads_campanha")

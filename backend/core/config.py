from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "crm-cdp-databricks-app"
    app_version: str = "1.0.0"
    databricks_warehouse_id: str
    uc_catalog: str = "main"
    schema_customer_base: str = "base_clientes"
    schema_customer_360: str = "cliente_360"
    schema_campaign_sources: str = "fontes_campanha"
    schema_campaign_app: str = "aplicacao_campanhas"
    schema_campaign_execution: str = "execucao_campanha"
    semantic_mapping_file: str = "config/semantic_mapping.yaml"

    @property
    def metadata_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.schema_campaign_app}"

    @property
    def execution_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.schema_campaign_execution}"

    @property
    def source_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.schema_campaign_sources}"

    @property
    def customer_base_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.schema_customer_base}"

    @property
    def customer_360_namespace(self) -> str:
        return f"{self.uc_catalog}.{self.schema_customer_360}"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "Campaign Orchestrator"
    app_version: str = "1.0.0"

    databricks_host: str | None = None
    databricks_token: str | None = None
    databricks_warehouse_id: str | None = None

    uc_catalog: str = "main"
    uc_metadata_schema: str = "campaign_app"
    uc_business_schema: str = "customer_360"
    campaign_source_schema: str = "campaign_sources"
    campaign_mapping_file: str = "config/semantic_mapping.yaml"


settings = Settings()

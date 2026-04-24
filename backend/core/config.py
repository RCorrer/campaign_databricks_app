from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "campaign-databricks-app"
    databricks_warehouse_id: str

    uc_catalog: str = "main"
    schema_customer_base: str = "customer_base"
    schema_customer_360: str = "customer_360"
    schema_campaign_sources: str = "campaign_sources"
    schema_campaign_app: str = "campaign_app"
    schema_campaign_execution: str = "campaign_execution"

    semantic_mapping_file: str = "config/semantic_mapping.yaml"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()

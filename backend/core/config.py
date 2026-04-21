from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', extra='ignore')

    app_name: str = 'Campaign Orchestrator'
    app_version: str = '3.0.0'

    databricks_host: str | None = None
    databricks_token: str | None = None
    databricks_warehouse_id: str | None = None

    uc_catalog: str = 'main'
    uc_metadata_schema: str = 'campaign_app'
    uc_business_schema: str = 'customer_360'
    uc_customer_base_schema: str = 'customer_base'
    campaign_source_schema: str = 'campaign_sources'
    campaign_execution_schema: str = 'campaign_execution'
    campaign_mapping_file: str = 'config/semantic_mapping.yaml'
    dist_dir: str = 'dist'

    @property
    def metadata_namespace(self) -> str:
        return f'{self.uc_catalog}.{self.uc_metadata_schema}'

    @property
    def source_namespace(self) -> str:
        return f'{self.uc_catalog}.{self.campaign_source_schema}'

    @property
    def business_namespace(self) -> str:
        return f'{self.uc_catalog}.{self.uc_business_schema}'

    @property
    def customer_base_namespace(self) -> str:
        return f'{self.uc_catalog}.{self.uc_customer_base_schema}'

    @property
    def execution_namespace(self) -> str:
        return f'{self.uc_catalog}.{self.campaign_execution_schema}'

    @property
    def mapping_path(self) -> Path:
        return Path(self.campaign_mapping_file)


settings = Settings()

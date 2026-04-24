from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


class Configuracao(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    nome_app: str = "Orquestrador de Campanhas"
    versao_app: str = "4.0.0"
    databricks_warehouse_id: str | None = None

    catalogo_uc: str = "main"
    schema_aplicacao_campanhas: str = "aplicacao_campanhas"
    schema_cliente_360: str = "cliente_360"
    schema_base_clientes: str = "base_clientes"
    schema_fontes_campanha: str = "fontes_campanha"
    schema_execucao_campanha: str = "execucao_campanha"
    arquivo_mapeamento: str = "config/mapeamento_semantico.yaml"

    @property
    def ns_aplicacao(self) -> str:
        return f"{self.catalogo_uc}.{self.schema_aplicacao_campanhas}"

    @property
    def ns_cliente_360(self) -> str:
        return f"{self.catalogo_uc}.{self.schema_cliente_360}"

    @property
    def ns_base_clientes(self) -> str:
        return f"{self.catalogo_uc}.{self.schema_base_clientes}"

    @property
    def ns_fontes(self) -> str:
        return f"{self.catalogo_uc}.{self.schema_fontes_campanha}"

    @property
    def ns_execucao(self) -> str:
        return f"{self.catalogo_uc}.{self.schema_execucao_campanha}"

    @property
    def caminho_mapeamento(self) -> Path:
        return Path(self.arquivo_mapeamento)


configuracao = Configuracao()

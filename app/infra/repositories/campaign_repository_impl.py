from app.config import AppConfig
from app.domain.campaign import CampaignBrieffing, CampaignCreate, CampaignUpdate
from app.infra.db.databricks_client import DatabricksSQLClient
from app.repositories.campaign_repository import CampaignRepository
from app.exceptions.campaign_exceptions import CampaignNotFoundException
from typing import List, Optional
import json

class CampaignRepositoryImpl(CampaignRepository):
    def __init__(self, db_client: DatabricksSQLClient):
        self.db = db_client
        cat = AppConfig.get_catalog()
        sch = AppConfig.get_schema_campanhas()
        self.table = f"{cat}.{sch}.brieffing"

    def get_brieffing(self, campaign_id: int) -> Optional[CampaignBrieffing]:
        sql = f"SELECT * FROM {self.table} WHERE id_campanha = :id"
        rows = self.db.execute_query(sql, {"id": campaign_id})
        if not rows:
            return None
        return self._row_to_campaign(rows[0])

    def list_all(self) -> List[CampaignBrieffing]:
        sql = f"SELECT * FROM {self.table} ORDER BY id_campanha"
        rows = self.db.execute_query(sql)
        return [self._row_to_campaign(r) for r in rows]

    def create(self, campaign: CampaignCreate) -> CampaignBrieffing:
        # Obter próximo ID (MAX+1 ou 1 se tabela vazia)
        max_id_sql = f"SELECT COALESCE(MAX(id_campanha), 0) + 1 FROM {self.table}"
        new_id = self.db.execute_query(max_id_sql)[0][0]

        insert_sql = f"""
        INSERT INTO {self.table}
        (id_campanha, nome, tema, segmento, objetivo, estrategia, canal,
         data_inicio, data_fim, publico_alvo, regras_inclusao, regras_exclusao, status)
        VALUES
        (:id, :nome, :tema, :segmento, :objetivo, :estrategia, :canal,
         :data_inicio, :data_fim, :publico_alvo, :regras_inclusao, :regras_exclusao, :status)
        """
        params = {
            "id": new_id,
            "nome": campaign.nome,
            "tema": campaign.tema,
            "segmento": campaign.segmento,
            "objetivo": campaign.objetivo,
            "estrategia": campaign.estrategia,
            "canal": campaign.canal,
            "data_inicio": campaign.data_inicio.isoformat() if campaign.data_inicio else None,
            "data_fim": campaign.data_fim.isoformat() if campaign.data_fim else None,
            "publico_alvo": campaign.publico_alvo,
            "regras_inclusao": campaign.regras_inclusao,
            "regras_exclusao": campaign.regras_exclusao,
            "status": campaign.status or "planejada"
        }
        self.db.execute_query(insert_sql, params)
        return self.get_brieffing(new_id)

    def update(self, campaign_id: int, campaign: CampaignUpdate) -> CampaignBrieffing:
        existing = self.get_brieffing(campaign_id)
        if not existing:
            raise CampaignNotFoundException(campaign_id)

        update_fields = campaign.model_dump(exclude_unset=True)
        if not update_fields:
            return existing

        set_clauses = [f"{key} = :{key}" for key in update_fields]
        set_sql = ", ".join(set_clauses)
        update_sql = f"UPDATE {self.table} SET {set_sql} WHERE id_campanha = :id"
        params = {**update_fields, "id": campaign_id}
        self.db.execute_query(update_sql, params)
        return self.get_brieffing(campaign_id)

    def _row_to_campaign(self, row: list) -> CampaignBrieffing:
        return CampaignBrieffing(
            id_campanha=row[0],
            nome=row[1],
            tema=row[2],
            segmento=row[3],
            objetivo=row[4],
            estrategia=row[5],
            canal=row[6],
            data_inicio=row[7].isoformat() if row[7] else None,
            data_fim=row[8].isoformat() if row[8] else None,
            publico_alvo=row[9],
            regras_inclusao=row[10],
            regras_exclusao=row[11],
            status=row[12]
        )

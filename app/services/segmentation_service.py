import json
from app.repositories.campaign_repository import CampaignRepository
from app.repositories.lead_repository import LeadRepository
from app.domain.segmentation import SegmentationDefinition
from app.infra.db.databricks_client import DatabricksSQLClient
from app.exceptions.campaign_exceptions import CampaignNotFoundException

class SegmentationService:
    def __init__(self, campaign_repo: CampaignRepository, lead_repo: LeadRepository, db_client: DatabricksSQLClient):
        self.campaign_repo = campaign_repo
        self.lead_repo = lead_repo
        self.db = db_client

    def build_campaign_view(self, campaign_id: int) -> str:
        brief = self.campaign_repo.get_brieffing(campaign_id)
        if not brief:
            raise CampaignNotFoundException(campaign_id)

        regras = self.campaign_repo.get_regras_segmentacao(campaign_id)
        if not regras:
            raise ValueError(f"Regras de segmentação não encontradas para campanha {campaign_id}")

        seg_def = SegmentationDefinition.parse_obj(regras.definicao)
        query = self._build_query(seg_def)

        view_name = f"leads_campanha_{campaign_id}"
        full_view_name = f"main.leads_campanha.{view_name}"
        self.lead_repo.create_view(full_view_name, query)
        return view_name

    def _build_query(self, seg: SegmentationDefinition) -> str:
        base_table = f"{seg.base['tabela']} AS {seg.base['alias']}"
        select_clause = "SELECT " + ", ".join(seg.colunas)
        from_clause = f"FROM {base_table}"

        join_clauses = "".join(
            f" {j.tipo} {j.tabela} AS {j.alias} ON {j.on}" for j in seg.joins
        )

        conditions = [f"({inc.condicao})" for inc in seg.inclusao]
        for exc in seg.exclusao:
            if exc.tipo == "subquery":
                conditions.append(f"({exc.condicao})")
            # optout e outros tipos podem ser tratados de forma específica

        where_clause = ""
        if conditions:
            where_clause = "WHERE " + " AND ".join(conditions)

        return f"{select_clause} {from_clause}{join_clauses} {where_clause}".strip()

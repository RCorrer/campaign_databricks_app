from datetime import datetime
from uuid import uuid4

from backend.models.contracts import (
    ActivationPayload,
    BriefingPayload,
    CampaignCreate,
    CampaignSummary,
    SegmentationPayload,
    StatusChangePayload,
)
from backend.services.query_builder import QueryBuilderService


class CampaignService:
    def __init__(self):
        self.query_builder = QueryBuilderService()
        self._store: dict[str, dict] = {}

    def create_campaign(self, payload: CampaignCreate) -> CampaignSummary:
        campaign_id = f"CMP-{uuid4().hex[:10].upper()}"
        self._store[campaign_id] = {
            "campaign_id": campaign_id,
            "name": payload.name,
            "status": "PREPARACAO",
            "version": 1,
            "created_at": datetime.utcnow().isoformat(),
            "start_date": payload.start_date,
            "end_date": payload.end_date,
            "campaign": payload.model_dump(),
            "briefing": None,
            "segmentation": None,
            "activation": None,
            "timeline": [
                {
                    "event": "CAMPAIGN_CREATED",
                    "status": "PREPARACAO",
                    "timestamp": datetime.utcnow().isoformat(),
                }
            ],
        }
        return CampaignSummary(
            campaign_id=campaign_id,
            name=payload.name,
            status="PREPARACAO",
            start_date=payload.start_date,
            end_date=payload.end_date,
            version=1,
        )

    def list_campaigns(self) -> list[dict]:
        return list(self._store.values())

    def get_campaign(self, campaign_id: str) -> dict:
        return self._store[campaign_id]

    def save_briefing(self, campaign_id: str, payload: BriefingPayload) -> dict:
        campaign = self._store[campaign_id]
        campaign["briefing"] = payload.model_dump()
        campaign["status"] = "SEGMENTACAO"
        campaign["version"] += 1
        campaign["timeline"].append({
            "event": "BRIEFING_REFINED",
            "status": "SEGMENTACAO",
            "timestamp": datetime.utcnow().isoformat(),
        })
        return campaign

    def save_segmentation(self, campaign_id: str, payload: SegmentationPayload) -> dict:
        campaign = self._store[campaign_id]
        preview_sql = self.query_builder.build_preview_sql(payload)
        campaign["segmentation"] = {
            **payload.model_dump(),
            "preview_sql": preview_sql,
        }
        campaign["status"] = "ATIVACAO"
        campaign["version"] += 1
        campaign["timeline"].append({
            "event": "SEGMENTATION_SAVED",
            "status": "ATIVACAO",
            "timestamp": datetime.utcnow().isoformat(),
        })
        return campaign

    def activate(self, campaign_id: str, payload: ActivationPayload) -> dict:
        campaign = self._store[campaign_id]
        campaign["activation"] = {
            **payload.model_dump(),
            "activation_sql": self._build_activation_sql(campaign_id, campaign, payload),
        }
        campaign["status"] = "ATIVO" if payload.execution_mode == "RUN" else "ATIVACAO"
        campaign["version"] += 1
        campaign["timeline"].append({
            "event": "CAMPAIGN_ACTIVATED",
            "status": campaign["status"],
            "timestamp": datetime.utcnow().isoformat(),
        })
        return campaign

    def change_status(self, campaign_id: str, payload: StatusChangePayload) -> dict:
        campaign = self._store[campaign_id]
        campaign["status"] = payload.new_status
        campaign["timeline"].append({
            "event": "STATUS_CHANGED",
            "status": payload.new_status,
            "reason": payload.reason,
            "timestamp": datetime.utcnow().isoformat(),
        })
        return campaign

    def _build_activation_sql(self, campaign_id: str, campaign: dict, payload: ActivationPayload) -> str:
        segmentation_sql = (campaign.get("segmentation") or {}).get("preview_sql", "SELECT cpf_cnpj FROM origem")
        object_name = f"campaign_audience_{campaign_id.lower().replace('-', '_')}"
        ddl = "CREATE OR REPLACE TABLE" if payload.materialization_mode == "TABLE" else "CREATE OR REPLACE VIEW"
        return f"""
{ddl} {{catalog}}.{{metadata_schema}}.{object_name}
AS
SELECT
    '{campaign_id}' AS campaign_id,
    cpf_cnpj,
    current_timestamp() AS segmentation_ts,
    DATE('{payload.effective_start_date}') AS activation_start_date,
    DATE('{payload.effective_end_date}') AS activation_end_date,
    {campaign['version']} AS rule_version
FROM (
    {segmentation_sql}
)
""".strip()


campaign_service = CampaignService()

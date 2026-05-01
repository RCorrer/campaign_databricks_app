import json
from uuid import uuid4

from app.config import settings
from app.repositories.databricks_sql import sql_repository

STATUS_LABELS = {
    "planejada": "Planejada",
    "aprovada": "Aprovada",
    "em execução": "Em Execução",
    "finalizada": "Finalizada",
    "cancelada": "Cancelada",
}


class CampaignService:

    def list_campaigns(self) -> list[dict]:
        rows = sql_repository.execute(f"""
            SELECT
                id_campanha,
                nome,
                tema,
                objetivo,
                data_inicio,
                data_fim,
                status
            FROM {settings.campanhas_namespace}.brieffing
            ORDER BY data_inicio DESC
        """)
        return [
            {
                "campaign_id": str(row["id_campanha"]),
                "name": row["nome"],
                "theme": row["tema"],
                "objective": row["objetivo"],
                "status": row["status"],
                "status_label": STATUS_LABELS.get(row["status"], row["status"]),
                "start_date": str(row["data_inicio"]) if row["data_inicio"] else "",
                "end_date": str(row["data_fim"]) if row["data_fim"] else "",
                "version": 1,
                "allowed_transitions": [],
            }
            for row in rows
        ]

    def get_campaign(self, campaign_id: str) -> dict:
        campaigns = sql_repository.execute(f"""
            SELECT *
            FROM {settings.campanhas_namespace}.brieffing
            WHERE id_campanha = {campaign_id}
        """)
        if not campaigns:
            raise KeyError(campaign_id)
        campaign = campaigns[0]

        regras = sql_repository.execute(f"""
            SELECT definicao
            FROM {settings.campanhas_namespace}.regras_segmentacao
            WHERE id_campanha = {campaign_id}
            LIMIT 1
        """)
        definicao_json = regras[0]["definicao"] if regras else "{}"
        try:
            definicao = json.loads(definicao_json)
        except Exception:
            definicao = {}

        status = campaign.get("status", "planejada")
        return {
            "campaign_id": str(campaign["id_campanha"]),
            "name": campaign["nome"],
            "theme": campaign.get("tema"),
            "objective": campaign.get("objetivo"),
            "strategy": campaign.get("estrategia"),
            "description": campaign.get("publico_alvo"),
            "status": status,
            "status_label": STATUS_LABELS.get(status, status),
            "start_date": str(campaign.get("data_inicio", "")),
            "end_date": str(campaign.get("data_fim", "")),
            "version": 1,
            "campaign": {},
            "briefing": {
                "challenge": campaign.get("objetivo") or "",
                "target_business_outcome": "",
                "channels": (campaign.get("canal") or "").split(","),
                "constraints": [],
                "business_rules": [],
                "notes": campaign.get("publico_alvo") or "",
            },
            "segmentation": definicao,
            "activation": {},
            "allowed_transitions": [],
        }

    def create_campaign(self, payload: dict) -> dict:
        max_id = sql_repository.scalar(f"SELECT MAX(id_campanha) FROM {settings.campanhas_namespace}.brieffing")
        new_id = int(max_id or 0) + 1
        sql_repository.execute(f"""
            INSERT INTO {settings.campanhas_namespace}.brieffing
            (id_campanha, nome, tema, objetivo, estrategia, canal, data_inicio, data_fim, publico_alvo, status)
            VALUES ({new_id}, '{payload.get("name", "")}', '{payload.get("theme", "")}',
                    '{payload.get("objective", "")}', '{payload.get("strategy", "")}',
                    '{",".join(payload.get("channels", ["Email"]))}',
                    {date_or_null(payload.get("start_date"))}, {date_or_null(payload.get("end_date"))},
                    '{payload.get("description", "")}', 'planejada')
        """)
        return self.get_campaign(str(new_id))

    def update_campaign(self, campaign_id: str, payload: dict) -> dict:
        sets = []
        for field in ["nome", "tema", "objetivo", "estrategia", "data_inicio", "data_fim"]:
            if field in payload:
                val = payload[field]
                if val is None:
                    sets.append(f"{field} = NULL")
                else:
                    sets.append(f"{field} = '{val}'")
        if sets:
            sql_repository.execute(f"""
                UPDATE {settings.campanhas_namespace}.brieffing
                SET {', '.join(sets)}
                WHERE id_campanha = {campaign_id}
            """)
        return self.get_campaign(campaign_id)

    def delete_campaign(self, campaign_id: str) -> dict:
        sql_repository.execute(f"DELETE FROM {settings.campanhas_namespace}.brieffing WHERE id_campanha = {campaign_id}")
        sql_repository.execute(f"DELETE FROM {settings.campanhas_namespace}.regras_segmentacao WHERE id_campanha = {campaign_id}")
        return {"deleted": True, "campaign_id": campaign_id}

    def save_briefing(self, campaign_id: str, payload: dict) -> dict:
        return self.get_campaign(campaign_id)

    def save_segmentation(self, campaign_id: str, payload: dict) -> dict:
        definicao_json = json.dumps(payload, ensure_ascii=False)
        sql_repository.execute(f"DELETE FROM {settings.campanhas_namespace}.regras_segmentacao WHERE id_campanha = {campaign_id}")
        sql_repository.execute(f"""
            INSERT INTO {settings.campanhas_namespace}.regras_segmentacao (id_campanha, definicao)
            VALUES ({campaign_id}, '{definicao_json}')
        """)
        return self.get_campaign(campaign_id)

    def activate(self, campaign_id: str, payload: dict) -> dict:
        return self.get_campaign(campaign_id)

    def change_status(self, campaign_id: str, payload: dict) -> dict:
        new_status = payload.get("new_status")
        if new_status:
            sql_repository.execute(f"UPDATE {settings.campanhas_namespace}.brieffing SET status = '{new_status}' WHERE id_campanha = {campaign_id}")
        return self.get_campaign(campaign_id)

    def seed_demo_data(self) -> list[dict]:
        return self.list_campaigns()


def date_or_null(value):
    if not value:
        return "NULL"
    return f"DATE'{value}'"


campaign_service = CampaignService()

from __future__ import annotations

import json
import uuid
from datetime import datetime

from backend.models.contracts import (
    CampaignBriefingRequest,
    CampaignCreateRequest,
    CampaignUpdateRequest,
    SegmentationSaveRequest,
    StatusChangeRequest,
)
from backend.repositories.databricks_sql import DatabricksSQLRepository
from backend.services.catalog_service import CatalogService
from backend.services.query_builder import QueryBuilderService
from backend.utils.serializers import load_json
from backend.utils.sql_utils import parse_rows, sql_literal


ALLOWED_STATUS_FLOW = {
    "RASCUNHO": ["PREPARACAO", "CANCELADO"],
    "PREPARACAO": ["SEGMENTACAO", "CANCELADO"],
    "SEGMENTACAO": ["ATIVACAO", "PREPARACAO", "CANCELADO"],
    "ATIVACAO": ["ATIVO", "SEGMENTACAO", "CANCELADO"],
    "ATIVO": ["PAUSADO", "CONCLUIDO", "ENCERRADO", "CANCELADO"],
    "PAUSADO": ["ATIVO", "ENCERRADO", "CANCELADO"],
}


class CampaignService:
    DETAIL_COLUMNS = [
        "campaign_id", "campaign_name", "theme", "objective", "strategy", "description",
        "primary_channel", "priority", "owner_team", "goal_kpi", "goal_value", "status",
        "status_reason", "periodicity", "start_date", "end_date", "max_impacts_month",
        "control_group_enabled", "last_run_at", "challenge", "target_business_outcome",
        "channels_json", "constraints", "business_rules", "notes", "segmentation_version_no",
        "initial_audience_code", "initial_audience_view", "native_rules_json", "include_rules_json",
        "exclude_rules_json", "native_rule_count", "thematic_rule_count", "generated_sql",
        "estimated_count", "activation_version_no", "execution_target_name", "activation_mode",
        "activation_start_date", "activation_end_date", "activated_at", "deactivated_at",
        "updated_at", "created_at",
    ]

    def __init__(self, repo: DatabricksSQLRepository, catalog_service: CatalogService, query_builder: QueryBuilderService) -> None:
        self.repo = repo
        self.catalog_service = catalog_service
        self.query_builder = query_builder

    def create_campaign(self, req: CampaignCreateRequest) -> dict:
        campaign_id = f"CMP-{uuid.uuid4().hex[:10].upper()}"
        now = datetime.utcnow().isoformat()
        sql = f"""
INSERT INTO main.campaign_app.campaign_header (
  campaign_id, campaign_name, theme, objective, strategy, description,
  primary_channel, priority, owner_team, goal_kpi, goal_value, status, status_reason,
  periodicity, start_date, end_date, max_impacts_month, control_group_enabled,
  last_run_at, created_at, updated_at, created_by, updated_by
)
VALUES (
  {sql_literal(campaign_id)}, {sql_literal(req.name)}, {sql_literal(req.theme)}, {sql_literal(req.objective)},
  {sql_literal(req.strategy)}, {sql_literal(req.description)},
  {sql_literal(req.primary_channel)}, {sql_literal(req.priority)}, {sql_literal(req.owner_team)},
  {sql_literal(req.goal_kpi)}, {sql_literal(req.goal_value)},
  'PREPARACAO', NULL, {sql_literal(req.periodicity)}, DATE({sql_literal(req.start_date)}),
  DATE({sql_literal(req.end_date)}), {req.max_impacts_month}, {str(req.control_group_enabled).upper()},
  NULL, current_timestamp(), current_timestamp(), 'app', 'app'
)
"""
        self.repo.execute(sql)
        self.repo.execute(f"""
INSERT INTO main.campaign_app.campaign_status_history (
  campaign_id, from_status, to_status, reason, changed_at, changed_by
)
VALUES (
  {sql_literal(campaign_id)}, NULL, 'PREPARACAO', 'Criação da campanha', current_timestamp(), 'app'
)
""")
        self.repo.execute(f"""
INSERT INTO main.campaign_app.campaign_audit_event (
  campaign_id, event_type, payload_json, created_at, created_by
)
VALUES (
  {sql_literal(campaign_id)}, 'CREATE_CAMPAIGN', {sql_literal(json.dumps(req.model_dump()))}, current_timestamp(), 'app'
)
""")
        return {"campaign_id": campaign_id, "created_at": now}

    def update_campaign(self, campaign_id: str, req: CampaignUpdateRequest) -> dict:
        self._ensure_exists(campaign_id)
        self.repo.execute(f"""
UPDATE main.campaign_app.campaign_header
SET
  campaign_name = {sql_literal(req.name)},
  theme = {sql_literal(req.theme)},
  objective = {sql_literal(req.objective)},
  strategy = {sql_literal(req.strategy)},
  description = {sql_literal(req.description)},
  primary_channel = {sql_literal(req.primary_channel)},
  priority = {sql_literal(req.priority)},
  owner_team = {sql_literal(req.owner_team)},
  goal_kpi = {sql_literal(req.goal_kpi)},
  goal_value = {sql_literal(req.goal_value)},
  status_reason = {sql_literal(req.status_reason)},
  periodicity = {sql_literal(req.periodicity)},
  start_date = DATE({sql_literal(req.start_date)}),
  end_date = DATE({sql_literal(req.end_date)}),
  max_impacts_month = {req.max_impacts_month},
  control_group_enabled = {str(req.control_group_enabled).upper()},
  updated_at = current_timestamp(),
  updated_by = 'app'
WHERE campaign_id = {sql_literal(campaign_id)}
""")
        self.repo.execute(f"""
INSERT INTO main.campaign_app.campaign_audit_event (campaign_id, event_type, payload_json, created_at, created_by)
VALUES ({sql_literal(campaign_id)}, 'UPDATE_CAMPAIGN', {sql_literal(json.dumps(req.model_dump()))}, current_timestamp(), 'app')
""")
        return {"campaign_id": campaign_id, "updated": True}

    def save_briefing(self, campaign_id: str, req: CampaignBriefingRequest) -> dict:
        self._ensure_exists(campaign_id)
        self.repo.execute(f"UPDATE main.campaign_app.campaign_briefing_version SET is_current = FALSE WHERE campaign_id = {sql_literal(campaign_id)} AND is_current = TRUE")
        self.repo.execute(f"""
INSERT INTO main.campaign_app.campaign_briefing_version (
  campaign_id, version_no, challenge, target_business_outcome, channels_json,
  constraints, business_rules, notes, is_current, created_at, created_by
)
SELECT
  {sql_literal(campaign_id)},
  COALESCE(MAX(version_no), 0) + 1,
  {sql_literal(req.challenge)},
  {sql_literal(req.target_business_outcome)},
  {sql_literal(json.dumps(req.channels))},
  {sql_literal(req.constraints)},
  {sql_literal(req.business_rules)},
  {sql_literal(req.notes)},
  TRUE,
  current_timestamp(),
  'app'
FROM main.campaign_app.campaign_briefing_version
WHERE campaign_id = {sql_literal(campaign_id)}
""")
        self.repo.execute(f"INSERT INTO main.campaign_app.campaign_audit_event (campaign_id, event_type, payload_json, created_at, created_by) VALUES ({sql_literal(campaign_id)}, 'SAVE_BRIEFING', {sql_literal(json.dumps(req.model_dump()))}, current_timestamp(), 'app')")
        return {"campaign_id": campaign_id, "saved": True}

    def save_segmentation(self, campaign_id: str, req: SegmentationSaveRequest) -> dict:
        self._ensure_exists(campaign_id)
        mapping = self.catalog_service.get_full_catalog()
        sql_preview = self.query_builder.build_segmentation_sql(
            req.initial_audience_view,
            [r.model_dump() for r in req.native_rules],
            [r.model_dump() for r in req.include_rules],
            [r.model_dump() for r in req.exclude_rules],
            mapping,
        )
        count_sql = f"SELECT COUNT(*) FROM ({sql_preview}) q"
        count_rows = self.repo.execute(count_sql)
        estimated_count = int(count_rows[0][0]) if count_rows else 0
        self.repo.execute(f"UPDATE main.campaign_app.campaign_segmentation_version SET is_current = FALSE WHERE campaign_id = {sql_literal(campaign_id)} AND is_current = TRUE")
        self.repo.execute(f"""
INSERT INTO main.campaign_app.campaign_segmentation_version (
  campaign_id, version_no, initial_audience_code, initial_audience_view,
  native_rules_json, include_rules_json, exclude_rules_json,
  native_rule_count, thematic_rule_count, generated_sql, estimated_count,
  is_current, created_at, created_by
)
SELECT
  {sql_literal(campaign_id)},
  COALESCE(MAX(version_no), 0) + 1,
  {sql_literal(req.initial_audience_code)},
  {sql_literal(req.initial_audience_view)},
  {sql_literal(json.dumps([r.model_dump() for r in req.native_rules]))},
  {sql_literal(json.dumps([r.model_dump() for r in req.include_rules]))},
  {sql_literal(json.dumps([r.model_dump() for r in req.exclude_rules]))},
  {len(req.native_rules)},
  {len(req.include_rules) + len(req.exclude_rules)},
  {sql_literal(sql_preview)},
  {estimated_count},
  TRUE,
  current_timestamp(),
  'app'
FROM main.campaign_app.campaign_segmentation_version
WHERE campaign_id = {sql_literal(campaign_id)}
""")
        self.repo.execute(f"UPDATE main.campaign_app.campaign_header SET updated_at = current_timestamp(), updated_by = 'app' WHERE campaign_id = {sql_literal(campaign_id)}")
        return {"campaign_id": campaign_id, "estimated_count": estimated_count, "sql_preview": sql_preview}

    def preview_segmentation(self, req: SegmentationSaveRequest) -> dict:
        mapping = self.catalog_service.get_full_catalog()
        sql_preview = self.query_builder.build_segmentation_sql(
            req.initial_audience_view,
            [r.model_dump() for r in req.native_rules],
            [r.model_dump() for r in req.include_rules],
            [r.model_dump() for r in req.exclude_rules],
            mapping,
        )
        count_sql = f"SELECT COUNT(*) FROM ({sql_preview}) q"
        count_rows = self.repo.execute(count_sql)
        estimated_count = int(count_rows[0][0]) if count_rows else 0
        return {"estimated_count": estimated_count, "sql_preview": sql_preview}

    def get_campaign_detail(self, campaign_id: str) -> dict:
        rows = self.repo.execute(f"""
SELECT {', '.join(self.DETAIL_COLUMNS)}
FROM main.campaign_app.vw_campaign_current_definition
WHERE campaign_id = {sql_literal(campaign_id)}
""")
        if not rows:
            raise ValueError("Campanha não encontrada")
        item = parse_rows(rows, self.DETAIL_COLUMNS)[0]
        item["channels"] = load_json(item.pop("channels_json"), [])
        item["native_rules"] = load_json(item.pop("native_rules_json"), [])
        item["include_rules"] = load_json(item.pop("include_rules_json"), [])
        item["exclude_rules"] = load_json(item.pop("exclude_rules_json"), [])
        return item

    def change_status(self, campaign_id: str, req: StatusChangeRequest) -> dict:
        current_rows = self.repo.execute(f"SELECT status FROM main.campaign_app.campaign_header WHERE campaign_id = {sql_literal(campaign_id)}")
        if not current_rows:
            raise ValueError("Campanha não encontrada")
        current_status = str(current_rows[0][0])
        allowed = ALLOWED_STATUS_FLOW.get(current_status, [])
        if req.new_status not in allowed:
            raise ValueError(f"Transição inválida: {current_status} -> {req.new_status}")
        try:
            self.repo.execute_script([
                f"UPDATE main.campaign_app.campaign_header SET status = {sql_literal(req.new_status)}, status_reason = {sql_literal(req.reason)}, updated_at = current_timestamp(), updated_by = 'app' WHERE campaign_id = {sql_literal(campaign_id)}",
                f"INSERT INTO main.campaign_app.campaign_status_history (campaign_id, from_status, to_status, reason, changed_at, changed_by) VALUES ({sql_literal(campaign_id)}, {sql_literal(current_status)}, {sql_literal(req.new_status)}, {sql_literal(req.reason)}, current_timestamp(), 'app')",
            ], retries=1)
        except RuntimeError as exc:
            if "DELTA_CONCURRENT_DELETE_READ" in str(exc):
                raise ValueError("A campanha foi alterada ou excluída em outra ação. Atualize a lista e tente novamente.") from exc
            raise
        return {"campaign_id": campaign_id, "from_status": current_status, "to_status": req.new_status}

    def delete_campaign(self, campaign_id: str) -> dict:
        exists = self.repo.execute(f"SELECT campaign_id FROM main.campaign_app.campaign_header WHERE campaign_id = {sql_literal(campaign_id)} LIMIT 1")
        if not exists:
            return {"campaign_id": campaign_id, "deleted": True, "already_deleted": True}
        statements = [
            f"DELETE FROM main.campaign_execution.campaign_audience WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_execution.campaign_run_log WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_activation_version WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_segmentation_version WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_briefing_version WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_audit_event WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_status_history WHERE campaign_id = {sql_literal(campaign_id)}",
            f"DELETE FROM main.campaign_app.campaign_header WHERE campaign_id = {sql_literal(campaign_id)}",
        ]
        try:
            self.repo.execute_script(statements, retries=1)
        except RuntimeError as exc:
            if "DELTA_CONCURRENT_DELETE_READ" in str(exc):
                return {"campaign_id": campaign_id, "deleted": True, "already_deleted": True, "message": "Campanha já removida em operação concorrente."}
            raise
        return {"campaign_id": campaign_id, "deleted": True}

    def _ensure_exists(self, campaign_id: str) -> None:
        rows = self.repo.execute(f"SELECT campaign_id FROM main.campaign_app.campaign_header WHERE campaign_id = {sql_literal(campaign_id)} LIMIT 1")
        if not rows:
            raise ValueError("Campanha não encontrada")

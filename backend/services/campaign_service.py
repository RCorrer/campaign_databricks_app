import json
from datetime import datetime
from uuid import uuid4

from backend.core.config import settings
from backend.models.contracts import (
    ActivationPayload,
    BriefingPayload,
    CampaignCreate,
    CampaignSummary,
    CampaignUpdate,
    SegmentationPayload,
    StatusChangePayload,
)
from backend.repositories.databricks_sql import sql_repository
from backend.services.query_builder import QueryBuilderService
from backend.utils.mapping_loader import load_semantic_mapping


STATUS_LABELS = {
    'PREPARACAO': 'Preparação',
    'SEGMENTACAO': 'Segmentação',
    'ATIVACAO': 'Ativação',
    'ATIVO': 'Ativo',
    'PAUSADO': 'Pausado',
    'CONCLUIDO': 'Concluído',
    'ENCERRADO': 'Encerrado',
    'CANCELADO': 'Cancelado',
}


class CampaignService:
    def __init__(self):
        self.query_builder = QueryBuilderService()

    def seed_demo_data(self) -> list[dict]:
        return self.list_campaigns()

    def list_campaigns(self) -> list[dict]:
        rows = sql_repository.execute(f"""
            SELECT
              campaign_id,
              campaign_name,
              theme,
              objective,
              description,
              status,
              CAST(start_date AS STRING) AS start_date,
              CAST(end_date AS STRING) AS end_date,
              current_version
            FROM {settings.metadata_namespace}.campaign_header
            ORDER BY updated_at DESC, created_at DESC
        """)
        return [
            {
                'campaign_id': row['campaign_id'],
                'name': row['campaign_name'],
                'theme': row.get('theme'),
                'objective': row.get('objective'),
                'description': row.get('description'),
                'status': row.get('status'),
                'status_label': STATUS_LABELS.get(row.get('status'), row.get('status')),
                'start_date': row.get('start_date'),
                'end_date': row.get('end_date'),
                'version': int(row.get('current_version') or 1),
            }
            for row in rows
        ]

    def create_campaign(self, payload: CampaignCreate) -> CampaignSummary:
        campaign_id = f"CMP-{uuid4().hex[:10].upper()}"
        sql_repository.execute_script([
            f"""
            INSERT INTO {settings.metadata_namespace}.campaign_header (
              campaign_id, campaign_name, theme, objective, strategy, description, status,
              periodicity, start_date, end_date, max_impacts_month, control_group_enabled,
              current_version, created_at, updated_at, created_by, updated_by
            ) VALUES (
              {q(campaign_id)}, {q(payload.name)}, {q(payload.theme)}, {q(payload.objective)}, {q(payload.strategy)}, {q(payload.description)}, 'PREPARACAO',
              {q(payload.periodicity)}, {date_or_null(payload.start_date)}, {date_or_null(payload.end_date)}, {payload.max_impacts_month}, {bool_sql(payload.control_group_enabled)},
              1, current_timestamp(), current_timestamp(), current_user(), current_user()
            )
            """,
            self._status_history_sql(campaign_id, None, 'PREPARACAO', 'Criação da campanha'),
            self._audit_sql(campaign_id, 'CAMPAIGN_CREATED', payload.model_dump()),
        ])
        return CampaignSummary(
            campaign_id=campaign_id,
            name=payload.name,
            status='PREPARACAO',
            start_date=payload.start_date,
            end_date=payload.end_date,
            version=1,
        )

    def update_campaign(self, campaign_id: str, payload: CampaignUpdate) -> dict:
        self._ensure_campaign_exists(campaign_id)
        sql_repository.execute_script([
            f"""
            UPDATE {settings.metadata_namespace}.campaign_header
            SET campaign_name = {q(payload.name)},
                theme = {q(payload.theme)},
                objective = {q(payload.objective)},
                strategy = {q(payload.strategy)},
                description = {q(payload.description)},
                periodicity = {q(payload.periodicity)},
                start_date = {date_or_null(payload.start_date)},
                end_date = {date_or_null(payload.end_date)},
                max_impacts_month = {payload.max_impacts_month},
                control_group_enabled = {bool_sql(payload.control_group_enabled)},
                updated_at = current_timestamp(),
                updated_by = current_user()
            WHERE campaign_id = {q(campaign_id)}
            """,
            self._audit_sql(campaign_id, 'CAMPAIGN_UPDATED', payload.model_dump()),
        ])
        return self.get_campaign(campaign_id)

    def get_campaign(self, campaign_id: str) -> dict:
        rows = sql_repository.execute(f"""
            SELECT *
            FROM {settings.metadata_namespace}.vw_campaign_current_definition
            WHERE campaign_id = {q(campaign_id)}
        """)
        if not rows:
            raise KeyError(campaign_id)
        row = rows[0]
        header = sql_repository.execute(f"""
            SELECT description, strategy
            FROM {settings.metadata_namespace}.campaign_header
            WHERE campaign_id = {q(campaign_id)}
            LIMIT 1
        """)[0]
        status = row.get('status')
        result = {
            'campaign_id': row['campaign_id'],
            'name': row.get('campaign_name'),
            'theme': row.get('theme'),
            'objective': row.get('objective'),
            'strategy': row.get('strategy'),
            'description': header.get('description'),
            'status': status,
            'status_label': STATUS_LABELS.get(status, status),
            'start_date': row.get('start_date'),
            'end_date': row.get('end_date'),
            'version': int(row.get('current_version') or 1),
            'campaign': {
                'strategy': row.get('strategy'),
                'description': header.get('description'),
            },
            'briefing': {
                'challenge': row.get('challenge'),
                'target_business_outcome': row.get('target_business_outcome'),
                'channels': parse_array(row.get('channels')),
                'constraints': parse_array(row.get('constraints')),
                'business_rules': parse_array(row.get('business_rules')),
                'notes': row.get('notes'),
            },
            'segmentation': {
                'initial_audience_code': row.get('initial_audience_code'),
                'universe_view': row.get('universe_view'),
                'native_include_groups': parse_json(row.get('native_include_rules_json')) or [],
                'native_exclude_groups': parse_json(row.get('native_exclude_rules_json')) or [],
                'include_groups': parse_json(row.get('include_rules_json')) or [],
                'exclude_groups': parse_json(row.get('exclude_rules_json')) or [],
                'preview_sql': row.get('preview_sql'),
                'estimated_audience': row.get('estimated_audience'),
            },
            'activation': {
                'materialization_mode': row.get('materialization_mode'),
                'activation_object_name': row.get('activation_object_name'),
                'activation_sql': row.get('activation_sql'),
                'effective_start_date': row.get('effective_start_date'),
                'effective_end_date': row.get('effective_end_date'),
                'activation_status': row.get('activation_status'),
            },
        }
        return result

    def save_briefing(self, campaign_id: str, payload: BriefingPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)
        sql_repository.execute_script([
            f"DELETE FROM {settings.metadata_namespace}.campaign_briefing_version WHERE campaign_id = {q(campaign_id)} AND version_id = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campaign_briefing_version (
              campaign_id, version_id, challenge, target_business_outcome, channels,
              constraints, business_rules, notes, created_at, created_by
            ) VALUES (
              {q(campaign_id)}, {version}, {q(payload.challenge)}, {q(payload.target_business_outcome)}, {array_sql(payload.channels)},
              {array_sql(payload.constraints)}, {array_sql(payload.business_rules)}, {q(payload.notes)}, current_timestamp(), current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campaign_header SET updated_at = current_timestamp(), updated_by = current_user() WHERE campaign_id = {q(campaign_id)}",
            self._audit_sql(campaign_id, 'BRIEFING_SAVED', payload.model_dump()),
        ])
        return self.get_campaign(campaign_id)

    def save_segmentation(self, campaign_id: str, payload: SegmentationPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)
        preview_sql = self.query_builder.build_preview_sql(payload)
        estimated_audience = sql_repository.scalar(f"SELECT COUNT(*) AS total FROM ({preview_sql}) q", 0)
        sql_repository.execute_script([
            f"DELETE FROM {settings.metadata_namespace}.campaign_segmentation_version WHERE campaign_id = {q(campaign_id)} AND version_id = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campaign_segmentation_version (
              campaign_id, version_id, initial_audience_code, universe_view,
              native_include_rules_json, native_exclude_rules_json, include_rules_json, exclude_rules_json,
              preview_sql, estimated_audience, created_at, created_by
            ) VALUES (
              {q(campaign_id)}, {version}, {q(payload.initial_audience_code)}, {q(payload.universe_view)},
              {q(json.dumps([g.model_dump() for g in payload.native_include_groups]))},
              {q(json.dumps([g.model_dump() for g in payload.native_exclude_groups]))},
              {q(json.dumps([g.model_dump() for g in payload.include_groups]))},
              {q(json.dumps([g.model_dump() for g in payload.exclude_groups]))},
              {q(preview_sql)}, {int(estimated_audience or 0)}, current_timestamp(), current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campaign_header SET status = 'SEGMENTACAO', updated_at = current_timestamp(), updated_by = current_user() WHERE campaign_id = {q(campaign_id)}",
            self._status_history_sql(campaign_id, 'PREPARACAO', 'SEGMENTACAO', payload.save_as_version_note or 'Segmentação salva'),
            self._audit_sql(campaign_id, 'SEGMENTATION_SAVED', payload.model_dump()),
        ])
        return self.get_campaign(campaign_id)

    def activate(self, campaign_id: str, payload: ActivationPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)
        segmentation_rows = sql_repository.execute(f"""
            SELECT universe_view, preview_sql, initial_audience_code
            FROM {settings.metadata_namespace}.campaign_segmentation_version
            WHERE campaign_id = {q(campaign_id)} AND version_id = {version}
            LIMIT 1
        """)
        if not segmentation_rows:
            raise RuntimeError('Salve a segmentação antes de ativar a campanha')
        segmentation = segmentation_rows[0]
        object_name = f"{settings.execution_namespace}.audience_{campaign_id.lower().replace('-', '_')}_v{version}"
        audience_select = f"""
            SELECT
              {q(campaign_id)} AS campaign_id,
              {version} AS segmentation_version,
              cpf_cnpj,
              current_timestamp() AS dt_segmentacao,
              {date_or_null(payload.effective_start_date)} AS dt_inicio_vigencia,
              {date_or_null(payload.effective_end_date)} AS dt_fim_vigencia,
              'ATIVA' AS status_audiencia,
              {q(segmentation.get('initial_audience_code'))} AS origem_publico,
              {q(payload.materialization_mode)} AS materialization_mode,
              {q(payload.execution_mode)} AS execution_mode
            FROM ({segmentation['preview_sql']}) src
        """
        activation_sql = f"CREATE OR REPLACE TABLE {object_name} AS {audience_select}"
        sql_repository.execute_script([
            activation_sql,
            f"DELETE FROM {settings.execution_namespace}.campaign_audience WHERE campaign_id = {q(campaign_id)} AND segmentation_version = {version}",
            f"INSERT INTO {settings.execution_namespace}.campaign_audience {audience_select}",
            f"DELETE FROM {settings.execution_namespace}.campaign_run_log WHERE campaign_id = {q(campaign_id)} AND segmentation_version = {version}",
            f"""
            INSERT INTO {settings.execution_namespace}.campaign_run_log (
              campaign_id, segmentation_version, run_ts, execution_mode, materialization_mode,
              output_object, total_records, snapshot_object, run_status, error_message
            )
            SELECT
              {q(campaign_id)}, {version}, current_timestamp(), {q(payload.execution_mode)}, {q(payload.materialization_mode)},
              {q(object_name)}, COUNT(*), NULL, 'SUCCEEDED', NULL
            FROM {object_name}
            """,
            f"DELETE FROM {settings.metadata_namespace}.campaign_activation_version WHERE campaign_id = {q(campaign_id)} AND version_id = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campaign_activation_version (
              campaign_id, version_id, materialization_mode, activation_object_name, activation_sql,
              effective_start_date, effective_end_date, activation_status, activated_at, activated_by
            ) VALUES (
              {q(campaign_id)}, {version}, {q(payload.materialization_mode)}, {q(object_name)}, {q(activation_sql)},
              {date_or_null(payload.effective_start_date)}, {date_or_null(payload.effective_end_date)}, 'ATIVO', current_timestamp(), current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campaign_header SET status = 'ATIVO', updated_at = current_timestamp(), updated_by = current_user() WHERE campaign_id = {q(campaign_id)}",
            self._status_history_sql(campaign_id, 'SEGMENTACAO', 'ATIVO', 'Campanha ativada'),
            self._audit_sql(campaign_id, 'CAMPAIGN_ACTIVATED', payload.model_dump() | {'output_object': object_name}),
        ])
        return self.get_campaign(campaign_id)

    def change_status(self, campaign_id: str, payload: StatusChangePayload) -> dict:
        self._ensure_campaign_exists(campaign_id)
        current_status = sql_repository.scalar(
            f"SELECT status FROM {settings.metadata_namespace}.campaign_header WHERE campaign_id = {q(campaign_id)}",
            'PREPARACAO',
        )
        sql_repository.execute_script([
            f"UPDATE {settings.metadata_namespace}.campaign_header SET status = {q(payload.new_status)}, updated_at = current_timestamp(), updated_by = current_user() WHERE campaign_id = {q(campaign_id)}",
            self._status_history_sql(campaign_id, current_status, payload.new_status, payload.reason),
            self._audit_sql(campaign_id, 'STATUS_CHANGED', payload.model_dump()),
        ])
        return self.get_campaign(campaign_id)

    def _ensure_campaign_exists(self, campaign_id: str) -> None:
        exists = sql_repository.scalar(
            f"SELECT COUNT(*) FROM {settings.metadata_namespace}.campaign_header WHERE campaign_id = {q(campaign_id)}",
            0,
        )
        if int(exists or 0) == 0:
            raise KeyError(campaign_id)

    def _current_version(self, campaign_id: str) -> int:
        version = sql_repository.scalar(
            f"SELECT current_version FROM {settings.metadata_namespace}.campaign_header WHERE campaign_id = {q(campaign_id)}",
            1,
        )
        return int(version or 1)

    def _status_history_sql(self, campaign_id: str, from_status: str | None, to_status: str, reason: str | None) -> str:
        return f"""
        INSERT INTO {settings.metadata_namespace}.campaign_status_history (
          campaign_id, from_status, to_status, change_reason, changed_at, changed_by
        ) VALUES (
          {q(campaign_id)}, {q(from_status)}, {q(to_status)}, {q(reason)}, current_timestamp(), current_user()
        )
        """

    def _audit_sql(self, campaign_id: str, event_name: str, payload: dict) -> str:
        return f"""
        INSERT INTO {settings.metadata_namespace}.campaign_audit_event (
          campaign_id, event_name, payload_json, event_ts, event_user
        ) VALUES (
          {q(campaign_id)}, {q(event_name)}, {q(json.dumps(payload, ensure_ascii=False))}, current_timestamp(), current_user()
        )
        """


campaign_service = CampaignService()


def q(value) -> str:
    if value is None:
        return 'NULL'
    return "'" + str(value).replace("'", "''") + "'"


def bool_sql(value: bool) -> str:
    return 'true' if value else 'false'


def date_or_null(value: str | None) -> str:
    if not value:
        return 'NULL'
    return f"DATE {q(value)}"


def array_sql(values: list[str]) -> str:
    if not values:
        return 'array()'
    return 'array(' + ', '.join(q(v) for v in values) + ')'


def parse_json(value):
    if value in (None, ''):
        return None
    if isinstance(value, (list, dict)):
        return value
    return json.loads(value)


def parse_array(value):
    if value in (None, ''):
        return []
    if isinstance(value, list):
        return value
    text = str(value).strip()
    if text.startswith('['):
        try:
            return json.loads(text)
        except Exception:
            return []
    return [item.strip() for item in text.strip('{}').split(',') if item.strip()]


def _find_audience_view(audiences: list[dict], audience_code: str) -> str:
    for audience in audiences:
        if audience.get('code') == audience_code:
            return audience['source_view']
    raise ValueError(f'Público inicial não encontrado: {audience_code}')

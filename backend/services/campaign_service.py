import json
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

STATUS_LABELS = {
    "PREPARACAO": "Preparação",
    "SEGMENTACAO": "Segmentação",
    "ATIVACAO": "Ativação",
    "ATIVO": "Ativo",
    "PAUSADO": "Pausado",
    "CONCLUIDO": "Concluído",
    "ENCERRADO": "Encerrado",
    "CANCELADO": "Cancelado",
}

ALLOWED_TRANSITIONS = {
    "PREPARACAO": ["CANCELADO"],
    "SEGMENTACAO": ["PREPARACAO", "CANCELADO"],
    "ATIVACAO": ["SEGMENTACAO", "CANCELADO"],
    "ATIVO": ["PAUSADO", "CONCLUIDO", "ENCERRADO", "CANCELADO"],
    "PAUSADO": ["ATIVO", "ENCERRADO", "CANCELADO"],
    "CONCLUIDO": [],
    "ENCERRADO": [],
    "CANCELADO": [],
}


class CampaignService:
    def __init__(self):
        self.query_builder = QueryBuilderService()

    def seed_demo_data(self) -> list[dict]:
        return self.list_campaigns()

    def list_campaigns(self) -> list[dict]:
        rows = sql_repository.execute(f"""
            SELECT
                id_campanha,
                nome_campanha,
                tema,
                objetivo,
                descricao,
                status,
                CAST(data_inicio AS STRING) AS data_inicio,
                CAST(data_fim AS STRING) AS data_fim,
                versao_atual
            FROM {settings.metadata_namespace}.campanha_cabecalho
            ORDER BY atualizado_em DESC, criado_em DESC
        """)

        return [
            {
                "campaign_id": row["id_campanha"],
                "name": row["nome_campanha"],
                "theme": row.get("tema"),
                "objective": row.get("objetivo"),
                "description": row.get("descricao"),
                "status": row.get("status"),
                "status_label": STATUS_LABELS.get(row.get("status"), row.get("status")),
                "start_date": row.get("data_inicio"),
                "end_date": row.get("data_fim"),
                "version": int(row.get("versao_atual") or 1),
                "allowed_transitions": self._allowed_transitions(row.get("status")),
            }
            for row in rows
        ]

    def create_campaign(self, payload: CampaignCreate) -> CampaignSummary:
        campaign_id = f"CMP-{uuid4().hex[:10].upper()}"

        sql_repository.execute_script([
            f"""
            INSERT INTO {settings.metadata_namespace}.campanha_cabecalho (
                id_campanha,
                nome_campanha,
                tema,
                objetivo,
                estrategia,
                descricao,
                status,
                periodicidade,
                data_inicio,
                data_fim,
                maximo_impactos_mes,
                grupo_controle_habilitado,
                versao_atual,
                criado_em,
                atualizado_em,
                criado_por,
                atualizado_por
            )
            VALUES (
                {q(campaign_id)},
                {q(payload.name)},
                {q(payload.theme)},
                {q(payload.objective)},
                {q(payload.strategy)},
                {q(payload.description)},
                'PREPARACAO',
                {q(payload.periodicity)},
                {date_or_null(payload.start_date)},
                {date_or_null(payload.end_date)},
                {payload.max_impacts_month},
                {bool_sql(payload.control_group_enabled)},
                1,
                current_timestamp(),
                current_timestamp(),
                current_user(),
                current_user()
            )
            """,
            self._status_history_sql(campaign_id, None, "PREPARACAO", "Criação da campanha"),
            self._audit_sql(campaign_id, "CAMPANHA_CRIADA", payload.model_dump()),
        ])

        return CampaignSummary(
            campaign_id=campaign_id,
            name=payload.name,
            status="PREPARACAO",
            start_date=payload.start_date,
            end_date=payload.end_date,
            version=1,
        )

    def update_campaign(self, campaign_id: str, payload: CampaignUpdate) -> dict:
        self._ensure_campaign_exists(campaign_id)

        sql_repository.execute_script([
            f"""
            UPDATE {settings.metadata_namespace}.campanha_cabecalho
            SET nome_campanha = {q(payload.name)},
                tema = {q(payload.theme)},
                objetivo = {q(payload.objective)},
                estrategia = {q(payload.strategy)},
                descricao = {q(payload.description)},
                periodicidade = {q(payload.periodicity)},
                data_inicio = {date_or_null(payload.start_date)},
                data_fim = {date_or_null(payload.end_date)},
                maximo_impactos_mes = {payload.max_impacts_month},
                grupo_controle_habilitado = {bool_sql(payload.control_group_enabled)},
                atualizado_em = current_timestamp(),
                atualizado_por = current_user()
            WHERE id_campanha = {q(campaign_id)}
            """,
            self._audit_sql(campaign_id, "CAMPANHA_ATUALIZADA", payload.model_dump()),
        ])

        return self.get_campaign(campaign_id)

    def delete_campaign(self, campaign_id: str) -> dict:
        self._ensure_campaign_exists(campaign_id)

        activation_objects = sql_repository.execute(f"""
            SELECT nome_objeto_ativacao
            FROM {settings.metadata_namespace}.campanha_ativacao_versao
            WHERE id_campanha = {q(campaign_id)}
              AND nome_objeto_ativacao IS NOT NULL
        """)

        scripts = []
        for row in activation_objects:
            obj = row.get("nome_objeto_ativacao")
            if obj:
                scripts.append(f"DROP TABLE IF EXISTS {obj}")
                scripts.append(f"DROP VIEW IF EXISTS {obj}")

        scripts += [
            f"DELETE FROM {settings.execution_namespace}.campanha_audiencia WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.execution_namespace}.campanha_log_execucao WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_ativacao_versao WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_segmentacao_versao WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_briefing_versao WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_historico_status WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_evento_auditoria WHERE id_campanha = {q(campaign_id)}",
            f"DELETE FROM {settings.metadata_namespace}.campanha_cabecalho WHERE id_campanha = {q(campaign_id)}",
        ]

        sql_repository.execute_script(scripts)
        return {"deleted": True, "campaign_id": campaign_id}

    def get_campaign(self, campaign_id: str) -> dict:
        rows = sql_repository.execute(f"""
            SELECT *
            FROM {settings.metadata_namespace}.vw_definicao_atual_campanha
            WHERE id_campanha = {q(campaign_id)}
        """)

        if not rows:
            raise KeyError(campaign_id)

        row = rows[0]
        header = sql_repository.execute(f"""
            SELECT descricao, estrategia
            FROM {settings.metadata_namespace}.campanha_cabecalho
            WHERE id_campanha = {q(campaign_id)}
            LIMIT 1
        """)[0]

        status = row.get("status")

        return {
            "campaign_id": row["id_campanha"],
            "name": row.get("nome_campanha"),
            "theme": row.get("tema"),
            "objective": row.get("objetivo"),
            "strategy": row.get("estrategia"),
            "description": header.get("descricao"),
            "status": status,
            "status_label": STATUS_LABELS.get(status, status),
            "allowed_transitions": self._allowed_transitions(status),
            "start_date": row.get("data_inicio"),
            "end_date": row.get("data_fim"),
            "version": int(row.get("versao_atual") or 1),
            "campaign": {
                "strategy": row.get("estrategia"),
                "description": header.get("descricao"),
            },
            "briefing": {
                "challenge": row.get("desafio"),
                "target_business_outcome": row.get("resultado_negocio_alvo"),
                "channels": parse_array(row.get("canais")),
                "constraints": parse_array(row.get("restricoes")),
                "business_rules": parse_array(row.get("regras_negocio")),
                "notes": row.get("observacoes"),
            },
            "segmentation": {
                "initial_audience_code": row.get("codigo_publico_inicial"),
                "universe_view": row.get("view_universo"),
                "native_include_groups": parse_json(row.get("regras_nativas_inclusao_json")) or [],
                "native_exclude_groups": parse_json(row.get("regras_nativas_exclusao_json")) or [],
                "include_groups": parse_json(row.get("regras_inclusao_json")) or [],
                "exclude_groups": parse_json(row.get("regras_exclusao_json")) or [],
                "preview_sql": row.get("sql_previa"),
                "estimated_audience": row.get("audiencia_estimada"),
            },
            "activation": {
                "materialization_mode": row.get("modo_materializacao"),
                "activation_object_name": row.get("nome_objeto_ativacao"),
                "activation_sql": row.get("sql_ativacao"),
                "effective_start_date": row.get("data_inicio_vigencia"),
                "effective_end_date": row.get("data_fim_vigencia"),
                "activation_status": row.get("status_ativacao"),
            },
        }

    def save_briefing(self, campaign_id: str, payload: BriefingPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)

        sql_repository.execute_script([
            f"DELETE FROM {settings.metadata_namespace}.campanha_briefing_versao WHERE id_campanha = {q(campaign_id)} AND id_versao = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campanha_briefing_versao (
                id_campanha,
                id_versao,
                desafio,
                resultado_negocio_alvo,
                canais,
                restricoes,
                regras_negocio,
                observacoes,
                criado_em,
                criado_por
            )
            VALUES (
                {q(campaign_id)},
                {version},
                {q(payload.challenge)},
                {q(payload.target_business_outcome)},
                {array_sql(payload.channels)},
                {array_sql(payload.constraints)},
                {array_sql(payload.business_rules)},
                {q(payload.notes)},
                current_timestamp(),
                current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campanha_cabecalho SET atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {q(campaign_id)}",
            self._audit_sql(campaign_id, "BRIEFING_SALVO", payload.model_dump()),
        ])

        return self.get_campaign(campaign_id)

    def save_segmentation(self, campaign_id: str, payload: SegmentationPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)

        preview_sql = self.query_builder.build_preview_sql(payload)
        estimated_audience = sql_repository.scalar(f"SELECT COUNT(*) AS total FROM ({preview_sql}) q", 0)
        codigo_publico_inicial = payload.initial_audience_code.strip().lower()

        sql_repository.execute_script([
            f"DELETE FROM {settings.metadata_namespace}.campanha_segmentacao_versao WHERE id_campanha = {q(campaign_id)} AND id_versao = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campanha_segmentacao_versao (
                id_campanha,
                id_versao,
                codigo_publico_inicial,
                view_universo,
                regras_nativas_inclusao_json,
                regras_nativas_exclusao_json,
                regras_inclusao_json,
                regras_exclusao_json,
                sql_previa,
                audiencia_estimada,
                criado_em,
                criado_por
            )
            VALUES (
                {q(campaign_id)},
                {version},
                {q(codigo_publico_inicial)},
                {q(payload.universe_view)},
                {q(json.dumps([g.model_dump() for g in payload.native_include_groups], ensure_ascii=False))},
                {q(json.dumps([g.model_dump() for g in payload.native_exclude_groups], ensure_ascii=False))},
                {q(json.dumps([g.model_dump() for g in payload.include_groups], ensure_ascii=False))},
                {q(json.dumps([g.model_dump() for g in payload.exclude_groups], ensure_ascii=False))},
                {q(preview_sql)},
                {int(estimated_audience or 0)},
                current_timestamp(),
                current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campanha_cabecalho SET status = 'SEGMENTACAO', atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {q(campaign_id)}",
            self._status_history_sql(campaign_id, "PREPARACAO", "SEGMENTACAO", payload.save_as_version_note or "Segmentação salva"),
            self._audit_sql(campaign_id, "SEGMENTACAO_SALVA", payload.model_dump()),
        ])

        return self.get_campaign(campaign_id)

    def activate(self, campaign_id: str, payload: ActivationPayload) -> dict:
        version = self._current_version(campaign_id)
        self._ensure_campaign_exists(campaign_id)

        segmentation_rows = sql_repository.execute(f"""
            SELECT view_universo, sql_previa, codigo_publico_inicial
            FROM {settings.metadata_namespace}.campanha_segmentacao_versao
            WHERE id_campanha = {q(campaign_id)}
              AND id_versao = {version}
            LIMIT 1
        """)

        if not segmentation_rows:
            raise RuntimeError("Salve a segmentação antes de ativar a campanha")

        segmentation = segmentation_rows[0]
        object_name = f"{settings.execution_namespace}.audiencia_{campaign_id.lower().replace('-', '_')}_v{version}"

        audience_select = f"""
            SELECT
                {q(campaign_id)} AS id_campanha,
                {version} AS versao_segmentacao,
                cpf_cnpj,
                current_timestamp() AS data_segmentacao,
                {date_or_null(payload.effective_start_date)} AS data_inicio_vigencia,
                {date_or_null(payload.effective_end_date)} AS data_fim_vigencia,
                'ATIVA' AS status_audiencia,
                {q(segmentation.get('codigo_publico_inicial'))} AS origem_publico,
                {q(payload.materialization_mode)} AS modo_materializacao,
                {q(payload.execution_mode)} AS modo_execucao
            FROM ({segmentation['sql_previa']}) src
        """

        object_ddl = (
            f"CREATE OR REPLACE {payload.materialization_mode} {object_name} AS {audience_select}"
            if payload.materialization_mode != "TABLE"
            else f"CREATE OR REPLACE TABLE {object_name} AS {audience_select}"
        )

        sql_repository.execute_script([
            object_ddl,
            f"DELETE FROM {settings.execution_namespace}.campanha_audiencia WHERE id_campanha = {q(campaign_id)} AND versao_segmentacao = {version}",
            f"INSERT INTO {settings.execution_namespace}.campanha_audiencia {audience_select}",
            f"DELETE FROM {settings.execution_namespace}.campanha_log_execucao WHERE id_campanha = {q(campaign_id)} AND versao_segmentacao = {version}",
            f"""
            INSERT INTO {settings.execution_namespace}.campanha_log_execucao (
                id_campanha,
                versao_segmentacao,
                executado_em,
                modo_execucao,
                modo_materializacao,
                objeto_saida,
                total_registros,
                objeto_snapshot,
                status_execucao,
                mensagem_erro
            )
            SELECT
                {q(campaign_id)},
                {version},
                current_timestamp(),
                {q(payload.execution_mode)},
                {q(payload.materialization_mode)},
                {q(object_name)},
                COUNT(*),
                NULL,
                'SUCESSO',
                NULL
            FROM {object_name}
            """,
            f"DELETE FROM {settings.metadata_namespace}.campanha_ativacao_versao WHERE id_campanha = {q(campaign_id)} AND id_versao = {version}",
            f"""
            INSERT INTO {settings.metadata_namespace}.campanha_ativacao_versao (
                id_campanha,
                id_versao,
                modo_materializacao,
                nome_objeto_ativacao,
                sql_ativacao,
                data_inicio_vigencia,
                data_fim_vigencia,
                status_ativacao,
                ativado_em,
                ativado_por
            )
            VALUES (
                {q(campaign_id)},
                {version},
                {q(payload.materialization_mode)},
                {q(object_name)},
                {q(object_ddl)},
                {date_or_null(payload.effective_start_date)},
                {date_or_null(payload.effective_end_date)},
                'ATIVO',
                current_timestamp(),
                current_user()
            )
            """,
            f"UPDATE {settings.metadata_namespace}.campanha_cabecalho SET status = 'ATIVO', atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {q(campaign_id)}",
            self._status_history_sql(campaign_id, "SEGMENTACAO", "ATIVO", "Campanha ativada"),
            self._audit_sql(campaign_id, "CAMPANHA_ATIVADA", payload.model_dump() | {"objeto_saida": object_name}),
        ])

        return self.get_campaign(campaign_id)

    def change_status(self, campaign_id: str, payload: StatusChangePayload) -> dict:
        self._ensure_campaign_exists(campaign_id)

        current_status = sql_repository.scalar(
            f"SELECT status FROM {settings.metadata_namespace}.campanha_cabecalho WHERE id_campanha = {q(campaign_id)}",
            "PREPARACAO",
        )

        allowed = self._allowed_transitions(current_status)
        if payload.new_status not in allowed:
            raise ValueError(f"Transição inválida: {current_status} -> {payload.new_status}")

        sql_repository.execute_script([
            f"UPDATE {settings.metadata_namespace}.campanha_cabecalho SET status = {q(payload.new_status)}, atualizado_em = current_timestamp(), atualizado_por = current_user() WHERE id_campanha = {q(campaign_id)}",
            self._status_history_sql(campaign_id, current_status, payload.new_status, payload.reason),
            self._audit_sql(campaign_id, "STATUS_ALTERADO", payload.model_dump()),
        ])

        return self.get_campaign(campaign_id)

    def _ensure_campaign_exists(self, campaign_id: str) -> None:
        exists = sql_repository.scalar(
            f"SELECT COUNT(*) FROM {settings.metadata_namespace}.campanha_cabecalho WHERE id_campanha = {q(campaign_id)}",
            0,
        )
        if int(exists or 0) == 0:
            raise KeyError(campaign_id)

    def _current_version(self, campaign_id: str) -> int:
        version = sql_repository.scalar(
            f"SELECT versao_atual FROM {settings.metadata_namespace}.campanha_cabecalho WHERE id_campanha = {q(campaign_id)}",
            1,
        )
        return int(version or 1)

    def _status_history_sql(self, campaign_id: str, from_status: str | None, to_status: str, reason: str | None) -> str:
        return f"""
        INSERT INTO {settings.metadata_namespace}.campanha_historico_status (
            id_campanha,
            status_origem,
            status_destino,
            motivo_alteracao,
            alterado_em,
            alterado_por
        )
        VALUES (
            {q(campaign_id)},
            {q(from_status)},
            {q(to_status)},
            {q(reason)},
            current_timestamp(),
            current_user()
        )
        """

    def _audit_sql(self, campaign_id: str, event_name: str, payload: dict) -> str:
        return f"""
        INSERT INTO {settings.metadata_namespace}.campanha_evento_auditoria (
            id_campanha,
            nome_evento,
            payload_json,
            evento_em,
            evento_usuario
        )
        VALUES (
            {q(campaign_id)},
            {q(event_name)},
            {q(json.dumps(payload, ensure_ascii=False))},
            current_timestamp(),
            current_user()
        )
        """

    def _allowed_transitions(self, status: str | None) -> list[str]:
        return ALLOWED_TRANSITIONS.get(status or "PREPARACAO", [])


campaign_service = CampaignService()


def q(value) -> str:
    if value is None:
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"


def bool_sql(value: bool) -> str:
    return "true" if value else "false"


def date_or_null(value: str | None) -> str:
    if not value:
        return "NULL"
    return f"DATE {q(value)}"


def array_sql(values: list[str]) -> str:
    if not values:
        return "array()"
    return "array(" + ", ".join(q(v) for v in values) + ")"


def parse_json(value):
    if value in (None, ""):
        return None
    if isinstance(value, (list, dict)):
        return value
    return json.loads(value)


def parse_array(value):
    if value in (None, ""):
        return []
    if isinstance(value, list):
        return value
    text = str(value).strip()
    if text.startswith("["):
        try:
            return json.loads(text)
        except Exception:
            return []
    return [item.strip() for item in text.strip("{}").split(",") if item.strip()]

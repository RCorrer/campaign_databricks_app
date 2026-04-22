from __future__ import annotations

import json
import uuid

from backend.models.contracts import ActivationRequest
from backend.repositories.databricks_sql import DatabricksSQLRepository
from backend.utils.sql_utils import sql_literal


class ExecutionService:
    def __init__(self, repo: DatabricksSQLRepository) -> None:
        self.repo = repo

    def activate_campaign(self, campaign_id: str, req: ActivationRequest) -> dict:
        campaign_rows = self.repo.execute(
            f"""
            SELECT status
              FROM main.campaign_app.campaign_header
             WHERE campaign_id = {sql_literal(campaign_id)}
            """
        )
        if not campaign_rows:
            raise ValueError("Campanha não encontrada")

        current_status = str(campaign_rows[0][0])

        meta_rows = self.repo.execute(
            f"""
            SELECT initial_audience_code,
                   generated_sql
              FROM main.campaign_app.campaign_segmentation_version
             WHERE campaign_id = {sql_literal(campaign_id)}
               AND version_no = {req.segmentation_version_no}
            """
        )
        if not meta_rows:
            raise ValueError("Segmentação não encontrada")

        initial_audience_code = str(meta_rows[0][0]).strip().lower()
        generated_sql = str(meta_rows[0][1])

        activation_rows = self.repo.execute(
            f"""
            SELECT COALESCE(MAX(version_no), 0) + 1
              FROM main.campaign_app.campaign_activation_version
             WHERE campaign_id = {sql_literal(campaign_id)}
            """
        )
        activation_version_no = int(activation_rows[0][0]) if activation_rows else 1
        run_id = str(uuid.uuid4())

        self.repo.execute(
            f"""
            UPDATE main.campaign_app.campaign_activation_version
               SET is_current = FALSE
             WHERE campaign_id = {sql_literal(campaign_id)}
               AND is_current = TRUE
            """
        )

        self.repo.execute(
            f"""
            INSERT INTO main.campaign_app.campaign_activation_version (
                campaign_id,
                version_no,
                segmentation_version_no,
                execution_target_name,
                activation_mode,
                start_date,
                end_date,
                activated_at,
                deactivated_at,
                is_current,
                created_at,
                created_by
            )
            VALUES (
                {sql_literal(campaign_id)},
                {activation_version_no},
                {req.segmentation_version_no},
                {sql_literal('main.campaign_execution.campaign_audience')},
                {sql_literal(req.activation_mode)},
                DATE({sql_literal(req.start_date)}),
                DATE({sql_literal(req.end_date)}),
                current_timestamp(),
                NULL,
                TRUE,
                current_timestamp(),
                'app'
            )
            """
        )

        self.repo.execute(
            f"""
            INSERT INTO main.campaign_execution.campaign_run_log (
                run_id,
                campaign_id,
                segmentation_version_no,
                activation_version_no,
                status,
                started_at,
                finished_at,
                row_count,
                executed_sql,
                error_message
            )
            VALUES (
                {sql_literal(run_id)},
                {sql_literal(campaign_id)},
                {req.segmentation_version_no},
                {activation_version_no},
                'RUNNING',
                current_timestamp(),
                NULL,
                NULL,
                {sql_literal(generated_sql)},
                NULL
            )
            """
        )

        try:
            self.repo.execute(
                f"""
                DELETE FROM main.campaign_execution.campaign_audience
                 WHERE campaign_id = {sql_literal(campaign_id)}
                """
            )

            self.repo.execute(
                f"""
                INSERT INTO main.campaign_execution.campaign_audience (
                    campaign_id,
                    segmentation_version_no,
                    activation_version_no,
                    cpf_cnpj,
                    dt_segmentacao,
                    dt_inicio_vigencia,
                    dt_fim_vigencia,
                    status_audiencia,
                    initial_audience_code,
                    created_at
                )
                SELECT {sql_literal(campaign_id)},
                       {req.segmentation_version_no},
                       {activation_version_no},
                       q.cpf_cnpj,
                       current_timestamp(),
                       DATE({sql_literal(req.start_date)}),
                       DATE({sql_literal(req.end_date)}),
                       'ATIVO',
                       {sql_literal(initial_audience_code)},
                       current_timestamp()
                  FROM (
                      {generated_sql}
                  ) q
                """
            )

            count_rows = self.repo.execute(
                f"""
                SELECT COUNT(*)
                  FROM main.campaign_execution.campaign_audience
                 WHERE campaign_id = {sql_literal(campaign_id)}
                   AND activation_version_no = {activation_version_no}
                """
            )
            row_count = int(count_rows[0][0]) if count_rows else 0

            self.repo.execute(
                f"""
                UPDATE main.campaign_execution.campaign_run_log
                   SET status = 'SUCCEEDED',
                       finished_at = current_timestamp(),
                       row_count = {row_count}
                 WHERE run_id = {sql_literal(run_id)}
                """
            )

            self.repo.execute(
                f"""
                UPDATE main.campaign_app.campaign_header
                   SET status = 'ATIVO',
                       last_run_at = current_timestamp(),
                       updated_at = current_timestamp(),
                       updated_by = 'app'
                 WHERE campaign_id = {sql_literal(campaign_id)}
                """
            )

            if current_status != "ATIVO":
                self.repo.execute(
                    f"""
                    INSERT INTO main.campaign_app.campaign_status_history (
                        campaign_id,
                        from_status,
                        to_status,
                        reason,
                        changed_at,
                        changed_by
                    )
                    VALUES (
                        {sql_literal(campaign_id)},
                        {sql_literal(current_status)},
                        'ATIVO',
                        'Ativação da campanha',
                        current_timestamp(),
                        'app'
                    )
                    """
                )

            self.repo.execute(
                f"""
                INSERT INTO main.campaign_app.campaign_audit_event (
                    campaign_id,
                    event_type,
                    payload_json,
                    created_at,
                    created_by
                )
                VALUES (
                    {sql_literal(campaign_id)},
                    'ACTIVATE_CAMPAIGN',
                    {sql_literal(json.dumps({
                        "run_id": run_id,
                        "segmentation_version_no": req.segmentation_version_no,
                        "activation_version_no": activation_version_no,
                        "activation_mode": req.activation_mode,
                        "start_date": req.start_date,
                        "end_date": req.end_date,
                        "initial_audience_code": initial_audience_code,
                        "row_count": row_count,
                    }))},
                    current_timestamp(),
                    'app'
                )
                """
            )

            return {
                "campaign_id": campaign_id,
                "run_id": run_id,
                "segmentation_version_no": req.segmentation_version_no,
                "activation_version_no": activation_version_no,
                "row_count": row_count,
            }

        except Exception as exc:
            safe_error = str(exc).replace("'", "''")

            self.repo.execute(
                f"""
                UPDATE main.campaign_execution.campaign_run_log
                   SET status = 'FAILED',
                       finished_at = current_timestamp(),
                       error_message = '{safe_error}'
                 WHERE run_id = {sql_literal(run_id)}
                """
            )
            raise
from __future__ import annotations

from backend.repositories.databricks_sql import DatabricksSQLRepository
from backend.utils.sql_utils import parse_rows


class DashboardService:
    COLUMNS = [
        "campaign_id",
        "campaign_name",
        "theme",
        "status",
        "primary_channel",
        "priority",
        "owner_team",
        "start_date",
        "end_date",
        "native_rule_count",
        "thematic_rule_count",
        "last_run_at",
        "updated_at",
        "created_at",
    ]

    def __init__(self, repo: DatabricksSQLRepository) -> None:
        self.repo = repo

    def list_campaigns(self, status: str | None = None, theme: str | None = None, search: str | None = None):
        sql = """
SELECT
  campaign_id,
  campaign_name,
  theme,
  status,
  primary_channel,
  priority,
  owner_team,
  start_date,
  end_date,
  native_rule_count,
  thematic_rule_count,
  last_run_at,
  updated_at,
  created_at
FROM main.campaign_app.vw_campaign_dashboard
WHERE 1=1
"""
        if status:
            safe = status.replace("'", "''")
            sql += f" AND status = '{safe}'"
        if theme:
            safe = theme.replace("'", "''")
            sql += f" AND theme = '{safe}'"
        if search:
            safe = search.replace("'", "''").lower()
            sql += f" AND lower(campaign_name) LIKE '%{safe}%'"

        sql += " ORDER BY updated_at DESC, created_at DESC"
        return parse_rows(self.repo.execute(sql), self.COLUMNS)

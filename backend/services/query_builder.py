from __future__ import annotations

from typing import Any

from backend.utils.sql_utils import sql_literal


class QueryBuilderService:
    def build_segmentation_sql(
        self,
        initial_audience_view: str,
        native_rules: list[dict[str, Any]],
        include_rules: list[dict[str, Any]],
        exclude_rules: list[dict[str, Any]],
        mapping: dict[str, Any],
    ) -> str:
        native_clause = self._build_native_clause(native_rules)
        include_clause = self._build_thematic_exists(include_rules, mapping, positive=True)
        exclude_clause = self._build_thematic_exists(exclude_rules, mapping, positive=False)

        return f"""
WITH publico_inicial AS (
    SELECT *
    FROM {initial_audience_view}
),
base_filtrada AS (
    SELECT *
    FROM publico_inicial
    WHERE 1=1
    {native_clause}
)
SELECT DISTINCT b.cpf_cnpj
FROM base_filtrada b
WHERE 1=1
{include_clause}
{exclude_clause}
""".strip()

    def _build_native_clause(self, rules: list[dict[str, Any]]) -> str:
        clauses = []
        for rule in rules:
            clauses.append(f" AND {rule['field']} {rule['operator']} {sql_literal(rule['value'])}")
        return "\n".join(clauses)

    def _build_thematic_exists(self, rules: list[dict[str, Any]], mapping: dict[str, Any], positive: bool) -> str:
        clauses = []
        for idx, rule in enumerate(rules):
            theme = rule["theme"]
            theme_meta = mapping["themes"][theme]
            table_name = theme_meta["table"]
            keyword = "EXISTS" if positive else "NOT EXISTS"
            clauses.append(
                f"""
AND {keyword} (
    SELECT 1
    FROM {table_name} t{idx}
    WHERE t{idx}.cpf_cnpj = b.cpf_cnpj
      AND t{idx}.{rule['field']} {rule['operator']} {sql_literal(rule['value'])}
)
""".rstrip()
            )
        return "\n".join(clauses)

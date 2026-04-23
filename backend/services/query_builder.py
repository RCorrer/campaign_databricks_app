from __future__ import annotations

from backend.core.config import settings
from backend.models.contracts import RuleCondition, RuleGroup, SegmentationPayload
from backend.utils.mapping_loader import load_semantic_mapping

OPERADOR_SQL = {
    "EQUALS": "=",
    "IGUAL": "=",
    "NOT_EQUALS": "<>",
    "DIFERENTE": "<>",
    "GT": ">",
    "MAIOR_QUE": ">",
    "GTE": ">=",
    "MAIOR_OU_IGUAL": ">=",
    "LT": "<",
    "MENOR_QUE": "<",
    "LTE": "<=",
    "MENOR_OU_IGUAL": "<=",
    "IN": "IN",
    "EM": "IN",
    "NOT_IN": "NOT IN",
    "NAO_EM": "NOT IN",
    "CONTAINS": "LIKE",
    "CONTEM": "LIKE",
}


class QueryBuilderService:
    def __init__(self):
        self.mapping = load_semantic_mapping(settings.semantic_mapping_file)

    def build_preview_sql(self, segmentation: SegmentationPayload) -> str:
        source_view = segmentation.universe_view
        native_include_clause = self._build_native_clause(segmentation.native_include_groups, default_true=True)
        native_exclude_clause = self._build_native_clause(segmentation.native_exclude_groups, default_true=False)
        include_thematic_clause = self._build_thematic_clause(segmentation.include_groups, default_true=True)
        exclude_thematic_clause = self._build_thematic_clause(segmentation.exclude_groups, default_true=False)

        return f"""
        WITH publico_inicial AS (
            SELECT DISTINCT base.*
            FROM {source_view} base
        ),
        publico_filtrado AS (
            SELECT DISTINCT base.cpf_cnpj
            FROM publico_inicial base
            WHERE {native_include_clause}
              AND NOT ({native_exclude_clause})
              AND {include_thematic_clause}
              AND NOT ({exclude_thematic_clause})
        )
        SELECT cpf_cnpj
        FROM publico_filtrado
        """.strip()

    def _build_native_clause(self, groups: list[RuleGroup], default_true: bool) -> str:
        if not groups:
            return "1 = 1" if default_true else "1 = 0"
        fragments = [self._build_group_expression(group, alias="base") for group in groups if group.conditions]
        if not fragments:
            return "1 = 1" if default_true else "1 = 0"
        return "(" + " OR ".join(fragments) + ")"

    def _build_thematic_clause(self, groups: list[RuleGroup], default_true: bool) -> str:
        if not groups:
            return "1 = 1" if default_true else "1 = 0"
        fragments = [self._build_exists_expression(group) for group in groups if group.conditions]
        if not fragments:
            return "1 = 1" if default_true else "1 = 0"
        return "(" + " OR ".join(fragments) + ")"

    def _build_group_expression(self, group: RuleGroup, alias: str) -> str:
        condition_sql: list[str] = []
        for index, condition in enumerate(group.conditions):
            connector = "" if index == 0 else f" {condition.logical_connector} "
            operator = OPERADOR_SQL.get(condition.operator, "=")
            value = self._format_value(condition.value, condition.operator)
            condition_sql.append(f"{connector}{alias}.{condition.field} {operator} {value}")
        return "(" + "".join(condition_sql) + ")"

    def _build_exists_expression(self, group: RuleGroup) -> str:
        first = group.conditions[0]
        entity = first.entity or self._resolve_theme_table(first.theme)
        conditions_sql: list[str] = []
        for index, condition in enumerate(group.conditions):
            connector = "" if index == 0 else f" {condition.logical_connector} "
            operator = OPERADOR_SQL.get(condition.operator, "=")
            value = self._format_value(condition.value, condition.operator)
            conditions_sql.append(f"{connector}tema.{condition.field} {operator} {value}")
        return f"EXISTS (SELECT 1 FROM {entity} tema WHERE tema.cpf_cnpj = base.cpf_cnpj AND ({''.join(conditions_sql)}))"

    def _resolve_theme_table(self, theme_key: str | None) -> str:
        for theme in self.mapping.get("themes", []):
            if theme.get("key") == theme_key:
                return theme["table"]
        raise ValueError(f"Tema não mapeado: {theme_key}")

    def _format_value(self, value, operator: str) -> str:
        if operator in {"IN", "NOT_IN", "EM", "NAO_EM"} and isinstance(value, list):
            values = ", ".join(self._quote(v) for v in value)
            return f"({values})"
        if operator in {"CONTAINS", "CONTEM"}:
            return self._quote(f"%{value}%")
        return self._quote(value)

    def _quote(self, value) -> str:
        if isinstance(value, bool):
            return "true" if value else "false"
        if isinstance(value, (int, float)):
            return str(value)
        if value is None:
            return "NULL"
        return "'" + str(value).replace("'", "''") + "'"

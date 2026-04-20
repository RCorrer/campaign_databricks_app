from backend.models.contracts import RuleGroup, SegmentationPayload


OPERATOR_SQL = {
    "EQUALS": "=",
    "NOT_EQUALS": "<>",
    "GT": ">",
    "GTE": ">=",
    "LT": "<",
    "LTE": "<=",
    "IN": "IN",
    "NOT_IN": "NOT IN",
    "CONTAINS": "LIKE",
}


class QueryBuilderService:
    def build_where_clause(self, groups: list[RuleGroup]) -> str:
        parts: list[str] = []
        for group in groups:
            group_conditions: list[str] = []
            for condition in group.conditions:
                operator = OPERATOR_SQL.get(condition.operator, "=")
                value = self._format_value(condition.value, condition.operator)
                group_conditions.append(f"{condition.entity}.{condition.field} {operator} {value}")
            if group_conditions:
                parts.append("(" + " AND ".join(group_conditions) + ")")
        return " AND ".join(parts) if parts else "1=1"

    def build_preview_sql(self, segmentation: SegmentationPayload) -> str:
        base = f"SELECT base.cpf_cnpj FROM {{source_schema}}.{segmentation.universe_view} base"
        include_clause = self.build_where_clause(segmentation.include_groups)
        exclude_clause = self.build_where_clause(segmentation.exclude_groups)
        sql = f"""
WITH universo AS (
    {base}
),
incluidos AS (
    SELECT * FROM universo base WHERE {include_clause}
),
final AS (
    SELECT * FROM incluidos base WHERE NOT ({exclude_clause})
)
SELECT DISTINCT cpf_cnpj
FROM final
""".strip()
        return sql

    def _format_value(self, value, operator: str) -> str:
        if operator in {"IN", "NOT_IN"} and isinstance(value, list):
            values = ", ".join([self._quote(v) for v in value])
            return f"({values})"
        if operator == "CONTAINS":
            return self._quote(f"%{value}%")
        return self._quote(value)

    def _quote(self, value) -> str:
        if isinstance(value, (int, float)):
            return str(value)
        if value is None:
            return "NULL"
        return "'" + str(value).replace("'", "''") + "'"

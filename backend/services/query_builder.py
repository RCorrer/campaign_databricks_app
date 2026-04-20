from backend.core.config import settings
from backend.models.contracts import RuleGroup, SegmentationPayload


OPERATOR_SQL = {
    'EQUALS': '=',
    'NOT_EQUALS': '<>',
    'GT': '>',
    'GTE': '>=',
    'LT': '<',
    'LTE': '<=',
    'IN': 'IN',
    'NOT_IN': 'NOT IN',
    'CONTAINS': 'LIKE',
}


class QueryBuilderService:
    def build_where_clause(self, groups: list[RuleGroup], default_alias: str = 'base') -> str:
        if not groups:
            return '1 = 1'

        group_fragments: list[str] = []
        for group in groups:
            conditions: list[str] = []
            for condition in group.conditions:
                alias = default_alias
                operator = OPERATOR_SQL.get(condition.operator, '=')
                value = self._format_value(condition.value, condition.operator)
                conditions.append(f"{alias}.{condition.field} {operator} {value}")
            if conditions:
                group_fragments.append('(' + ' AND '.join(conditions) + ')')
        return ' OR '.join(group_fragments) if group_fragments else '1 = 1'

    def build_preview_sql(self, segmentation: SegmentationPayload) -> str:
        source_view = f"{settings.source_namespace}.{segmentation.universe_view}"
        include_clause = self.build_where_clause(segmentation.include_groups)
        exclude_clause = self.build_where_clause(segmentation.exclude_groups)

        return f"""
WITH universo_inicial AS (
    SELECT base.cpf_cnpj
    FROM {source_view} base
),
publico_incluido AS (
    SELECT base.cpf_cnpj
    FROM universo_inicial universo
    INNER JOIN {source_view} base
        ON universo.cpf_cnpj = base.cpf_cnpj
    WHERE {include_clause}
),
publico_final AS (
    SELECT incluido.cpf_cnpj
    FROM publico_incluido incluido
    LEFT JOIN {source_view} base
        ON incluido.cpf_cnpj = base.cpf_cnpj
    WHERE NOT ({exclude_clause})
)
SELECT DISTINCT cpf_cnpj
FROM publico_final
""".strip()

    def _format_value(self, value, operator: str) -> str:
        if operator in {'IN', 'NOT_IN'} and isinstance(value, list):
            values = ', '.join(self._quote(v) for v in value)
            return f'({values})'
        if operator == 'CONTAINS':
            return self._quote(f'%{value}%')
        return self._quote(value)

    def _quote(self, value) -> str:
        if isinstance(value, (int, float)):
            return str(value)
        if value is None:
            return 'NULL'
        return "'" + str(value).replace("'", "''") + "'"

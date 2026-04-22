from __future__ import annotations

from typing import Any


def sql_literal(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def parse_rows(result_rows: list[list[Any]], columns: list[str]) -> list[dict[str, Any]]:
    parsed: list[dict[str, Any]] = []
    for row in result_rows:
        parsed.append({columns[idx]: row[idx] if idx < len(row) else None for idx in range(len(columns))})
    return parsed

def literal(valor) -> str:
    if valor is None:
        return "NULL"
    if isinstance(valor, bool):
        return "true" if valor else "false"
    if isinstance(valor, (int, float)):
        return str(valor)
    return "'" + str(valor).replace("'", "''") + "'"


def data_ou_nulo(valor: str | None) -> str:
    if not valor:
        return "NULL"
    return f"DATE {literal(valor)}"


def array_sql(valores: list[str] | None) -> str:
    if not valores:
        return "array()"
    return "array(" + ", ".join(literal(v) for v in valores) + ")"

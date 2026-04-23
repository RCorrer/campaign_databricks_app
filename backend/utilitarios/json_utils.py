import json


def carregar_json(valor, padrao=None):
    if valor in (None, ""):
        return padrao
    if isinstance(valor, (list, dict)):
        return valor
    try:
        return json.loads(valor)
    except Exception:
        return padrao


def carregar_array(valor):
    if valor in (None, ""):
        return []
    if isinstance(valor, list):
        return valor
    texto = str(valor).strip()
    if texto.startswith("["):
        return carregar_json(texto, [])
    return [item.strip() for item in texto.strip("{}").split(",") if item.strip()]

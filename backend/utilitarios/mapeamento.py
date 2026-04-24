from pathlib import Path
import yaml


def carregar_mapeamento(caminho: str | Path) -> dict:
    with open(caminho, "r", encoding="utf-8") as arquivo:
        return yaml.safe_load(arquivo) or {}

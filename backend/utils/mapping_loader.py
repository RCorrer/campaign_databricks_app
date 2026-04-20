from pathlib import Path
import yaml


def load_semantic_mapping(path: str) -> dict:
    target = Path(path)
    if not target.exists():
        return {"topics": []}
    return yaml.safe_load(target.read_text(encoding="utf-8")) or {"topics": []}

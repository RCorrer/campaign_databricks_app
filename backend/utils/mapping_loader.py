from functools import lru_cache
import yaml


@lru_cache(maxsize=4)
def load_semantic_mapping(mapping_file: str) -> dict:
    with open(mapping_file, 'r', encoding='utf-8') as file:
        return yaml.safe_load(file) or {}

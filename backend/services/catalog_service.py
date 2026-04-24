from __future__ import annotations

import yaml

from backend.core.config import settings


class CatalogService:
    def __init__(self) -> None:
        with open(settings.semantic_mapping_file, "r", encoding="utf-8") as f:
            self.mapping = yaml.safe_load(f)

    def get_full_catalog(self):
        return self.mapping

    def get_initial_audiences(self):
        return self.mapping["initial_audiences"]

    def get_themes(self):
        return self.mapping["themes"]

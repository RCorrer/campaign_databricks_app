from abc import ABC, abstractmethod
from typing import List, Dict, Any

class LeadRepository(ABC):
    @abstractmethod
    def create_view(self, view_name: str, sql_query: str) -> None:
        pass

    @abstractmethod
    def drop_view(self, view_name: str) -> None:
        pass

    @abstractmethod
    def list_views(self) -> List[str]:
        pass

    @abstractmethod
    def get_leads_from_view(self, view_name: str, limit: int = 100) -> List[Dict[str, Any]]:
        pass

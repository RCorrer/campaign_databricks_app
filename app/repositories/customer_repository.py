from abc import ABC, abstractmethod
from app.domain.customer import Customer
from typing import List, Optional

class CustomerRepository(ABC):
    @abstractmethod
    def get_by_cpf_cnpj(self, cpf_cnpj: str) -> Optional[Customer]:
        pass

    @abstractmethod
    def list_by_segment(self, segmento: str, limit: int = 100) -> List[Customer]:
        pass

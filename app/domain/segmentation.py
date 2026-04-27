from pydantic import BaseModel
from typing import List, Dict, Optional

class JoinDefinition(BaseModel):
    tabela: str
    alias: str
    on: str
    tipo: str = "INNER"

class ConditionDefinition(BaseModel):
    tipo: Optional[str] = None
    condicao: str

class SegmentationDefinition(BaseModel):
    base: Dict[str, str]
    joins: List[JoinDefinition] = []
    inclusao: List[ConditionDefinition] = []
    exclusao: List[ConditionDefinition] = []
    colunas: List[str] = []

from pydantic import BaseModel, Field
from typing import Optional
from datetime import date

class CampaignBrieffing(BaseModel):
    id_campanha: int
    nome: Optional[str] = None
    tema: Optional[str] = None
    segmento: Optional[str] = None
    objetivo: Optional[str] = None
    estrategia: Optional[str] = None
    canal: Optional[str] = None
    data_inicio: Optional[date] = None
    data_fim: Optional[date] = None
    publico_alvo: Optional[str] = None
    regras_inclusao: Optional[str] = None
    regras_exclusao: Optional[str] = None
    status: Optional[str] = None

class CampaignCreate(BaseModel):
    nome: str = Field(..., min_length=1)
    tema: Optional[str] = None
    segmento: Optional[str] = None
    objetivo: Optional[str] = None
    estrategia: Optional[str] = None
    canal: Optional[str] = None
    data_inicio: Optional[date] = None
    data_fim: Optional[date] = None
    publico_alvo: Optional[str] = None
    regras_inclusao: Optional[str] = None
    regras_exclusao: Optional[str] = None
    status: Optional[str] = "planejada"

class CampaignUpdate(BaseModel):
    nome: Optional[str] = None
    tema: Optional[str] = None
    segmento: Optional[str] = None
    objetivo: Optional[str] = None
    estrategia: Optional[str] = None
    canal: Optional[str] = None
    data_inicio: Optional[date] = None
    data_fim: Optional[date] = None
    publico_alvo: Optional[str] = None
    regras_inclusao: Optional[str] = None
    regras_exclusao: Optional[str] = None
    status: Optional[str] = None

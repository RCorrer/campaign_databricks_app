from pydantic import BaseModel
from typing import Optional

class Customer(BaseModel):
    cpf_cnpj: str
    nome: str
    tipo_pessoa: str
    segmento: Optional[str] = None
    idade: Optional[int] = None
    uf: Optional[str] = None
    cidade: Optional[str] = None
    agencia_principal: Optional[str] = None
    conta_principal: Optional[str] = None
    email: Optional[str] = None
    telefone_ddd: Optional[str] = None
    telefone_numero: Optional[str] = None
    data_abertura_conta: Optional[str] = None

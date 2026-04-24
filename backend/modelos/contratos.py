from pydantic import BaseModel, Field


class CampanhaCriacao(BaseModel):
    nome: str
    tema: str | None = None
    objetivo: str | None = None
    estrategia: str | None = None
    descricao: str | None = None
    periodicidade: str | None = None
    data_inicio: str | None = None
    data_fim: str | None = None
    maximo_impactos_mes: int = 1
    grupo_controle_habilitado: bool = False


class CampanhaAtualizacao(CampanhaCriacao):
    pass


class ResumoCampanha(BaseModel):
    id_campanha: str
    nome: str
    status: str
    data_inicio: str | None = None
    data_fim: str | None = None
    versao: int = 1


class BriefingPayload(BaseModel):
    desafio: str | None = None
    resultado_negocio_esperado: str | None = None
    canais: list[str] = Field(default_factory=list)
    restricoes: list[str] = Field(default_factory=list)
    regras_negocio: list[str] = Field(default_factory=list)
    observacoes: str | None = None


class CondicaoRegra(BaseModel):
    tema: str | None = None
    entidade: str | None = None
    campo: str
    operador: str
    valor: str | int | float | bool | list[str | int | float | bool] | None = None
    conector_logico: str = "AND"


class GrupoRegra(BaseModel):
    nome: str | None = None
    condicoes: list[CondicaoRegra] = Field(default_factory=list)


class SegmentacaoPayload(BaseModel):
    codigo_publico_inicial: str
    view_publico_inicial: str
    grupos_inclusao_nativa: list[GrupoRegra] = Field(default_factory=list)
    grupos_exclusao_nativa: list[GrupoRegra] = Field(default_factory=list)
    grupos_inclusao: list[GrupoRegra] = Field(default_factory=list)
    grupos_exclusao: list[GrupoRegra] = Field(default_factory=list)
    observacao_versao: str | None = None


class AtivacaoPayload(BaseModel):
    modo_materializacao: str = "TABLE"
    modo_execucao: str = "MANUAL"
    data_inicio_vigencia: str | None = None
    data_fim_vigencia: str | None = None


class MudancaStatusPayload(BaseModel):
    novo_status: str
    motivo: str | None = None

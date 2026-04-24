from fastapi import APIRouter, HTTPException

from backend.configuracoes.configuracao import configuracao
from backend.modelos.contratos import (
    AtivacaoPayload,
    BriefingPayload,
    CampanhaAtualizacao,
    CampanhaCriacao,
    SegmentacaoPayload,
    MudancaStatusPayload,
)
from backend.servicos.campanha import servico_campanha
from backend.utilitarios.mapeamento import carregar_mapeamento

roteador_api = APIRouter()


@roteador_api.get("/saude")
def saude():
    return {"status": "ok", "aplicacao": configuracao.nome_app, "versao": configuracao.versao_app}


@roteador_api.get("/catalogo/construtor-segmentacao")
def catalogo_construtor_segmentacao():
    return carregar_mapeamento(configuracao.caminho_mapeamento)


@roteador_api.post("/demo/carregar")
def carregar_demo():
    return servico_campanha.carregar_demo()


@roteador_api.get("/campanhas")
def listar_campanhas():
    return servico_campanha.listar_campanhas()


@roteador_api.post("/campanhas")
def criar_campanha(payload: CampanhaCriacao):
    return servico_campanha.criar_campanha(payload)


@roteador_api.put("/campanhas/{id_campanha}")
def atualizar_campanha(id_campanha: str, payload: CampanhaAtualizacao):
    try:
        return servico_campanha.atualizar_campanha(id_campanha, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")


@roteador_api.delete("/campanhas/{id_campanha}")
def excluir_campanha(id_campanha: str):
    try:
        return servico_campanha.excluir_campanha(id_campanha)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")


@roteador_api.get("/campanhas/{id_campanha}")
def obter_campanha(id_campanha: str):
    try:
        return servico_campanha.obter_campanha(id_campanha)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")


@roteador_api.put("/campanhas/{id_campanha}/briefing")
def salvar_briefing(id_campanha: str, payload: BriefingPayload):
    try:
        return servico_campanha.salvar_briefing(id_campanha, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")


@roteador_api.put("/campanhas/{id_campanha}/segmentacao")
def salvar_segmentacao(id_campanha: str, payload: SegmentacaoPayload):
    try:
        return servico_campanha.salvar_segmentacao(id_campanha, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")


@roteador_api.post("/campanhas/{id_campanha}/ativacao")
def ativar_campanha(id_campanha: str, payload: AtivacaoPayload):
    try:
        return servico_campanha.ativar(id_campanha, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@roteador_api.post("/campanhas/{id_campanha}/status")
def alterar_status_campanha(id_campanha: str, payload: MudancaStatusPayload):
    try:
        return servico_campanha.alterar_status(id_campanha, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

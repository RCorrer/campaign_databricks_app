from fastapi import APIRouter, HTTPException
from app.services.campaign_service import campaign_service

router = APIRouter()

@router.get("/health")
def health():
    return {"status": "ok", "app": "Campaign Orchestrator", "version": "3.1.0"}

@router.get("/catalog/segmentation-builder")
def segmentation_builder_catalog():
    return {
        "initial_audiences": [
            {
                "code": "todos",
                "label": "Todos os clientes",
                "source_view": "main.publico_alvo.clientes",
                "description": "Clientes PF e PJ"
            }
        ],
        "native_fields": [
            {"field": "segmento", "label": "Segmento", "type": "string", "operators": ["EQUALS", "NOT_EQUALS", "IN", "NOT_IN"]},
            {"field": "idade", "label": "Idade", "type": "number", "operators": ["GT", "GTE", "LT", "LTE"]},
            {"field": "uf", "label": "UF", "type": "string", "operators": ["EQUALS", "NOT_EQUALS", "IN", "NOT_IN"]},
            {"field": "cidade", "label": "Cidade", "type": "string", "operators": ["EQUALS", "NOT_EQUALS", "CONTAINS"]},
        ],
        "themes": [
            {
                "key": "conta",
                "label": "Conta",
                "table": "main.cliente_360.conta",
                "fields": [
                    {"field": "tipo_conta", "label": "Tipo de Conta", "type": "string", "operators": ["EQUALS"]},
                    {"field": "status_conta", "label": "Status", "type": "string", "operators": ["EQUALS"]}
                ]
            },
            {
                "key": "credito",
                "label": "Crédito",
                "table": "main.cliente_360.credito",
                "fields": [
                    {"field": "score_interno", "label": "Score Interno", "type": "number", "operators": ["GT", "GTE"]}
                ]
            }
        ]
    }

@router.post("/demo/bootstrap")
def bootstrap_demo():
    return campaign_service.seed_demo_data()

@router.get("/campaigns")
def list_campaigns():
    return campaign_service.list_campaigns()

@router.post("/campaigns")
def create_campaign(payload: dict):
    return campaign_service.create_campaign(payload)

@router.put("/campaigns/{campaign_id}")
def update_campaign(campaign_id: str, payload: dict):
    try:
        return campaign_service.update_campaign(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.delete("/campaigns/{campaign_id}")
def delete_campaign(campaign_id: str):
    try:
        return campaign_service.delete_campaign(campaign_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.get("/campaigns/{campaign_id}")
def get_campaign(campaign_id: str):
    try:
        return campaign_service.get_campaign(campaign_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.put("/campaigns/{campaign_id}/briefing")
def save_briefing(campaign_id: str, payload: dict):
    try:
        return campaign_service.save_briefing(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.put("/campaigns/{campaign_id}/segmentation")
def save_segmentation(campaign_id: str, payload: dict):
    try:
        return campaign_service.save_segmentation(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.post("/campaigns/{campaign_id}/activation")
def activate_campaign(campaign_id: str, payload: dict):
    try:
        return campaign_service.activate(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")

@router.post("/campaigns/{campaign_id}/status")
def change_campaign_status(campaign_id: str, payload: dict):
    try:
        return campaign_service.change_status(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

from fastapi import APIRouter, HTTPException

from backend.core.config import settings
from backend.models.contracts import ActivationPayload, BriefingPayload, CampaignCreate, SegmentationPayload, StatusChangePayload
from backend.services.campaign_service import campaign_service
from backend.utils.mapping_loader import load_semantic_mapping

api_router = APIRouter()


@api_router.get('/health')
def health():
    return {'status': 'ok', 'app': settings.app_name, 'version': settings.app_version}


@api_router.get('/catalog/topics')
def catalog_topics():
    mapping = load_semantic_mapping(settings.campaign_mapping_file)
    return {'topics': mapping.get('topics', []), 'universe_views': mapping.get('universe_views', [])}


@api_router.post('/demo/bootstrap')
def bootstrap_demo():
    return campaign_service.seed_demo_data()


@api_router.get('/campaigns')
def list_campaigns():
    return campaign_service.list_campaigns()


@api_router.post('/campaigns')
def create_campaign(payload: CampaignCreate):
    return campaign_service.create_campaign(payload)


@api_router.get('/campaigns/{campaign_id}')
def get_campaign(campaign_id: str):
    try:
        return campaign_service.get_campaign(campaign_id)
    except KeyError:
        raise HTTPException(status_code=404, detail='Campanha não encontrada')


@api_router.put('/campaigns/{campaign_id}/briefing')
def save_briefing(campaign_id: str, payload: BriefingPayload):
    try:
        return campaign_service.save_briefing(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail='Campanha não encontrada')


@api_router.put('/campaigns/{campaign_id}/segmentation')
def save_segmentation(campaign_id: str, payload: SegmentationPayload):
    try:
        return campaign_service.save_segmentation(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail='Campanha não encontrada')


@api_router.post('/campaigns/{campaign_id}/activation')
def activate_campaign(campaign_id: str, payload: ActivationPayload):
    try:
        return campaign_service.activate(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail='Campanha não encontrada')


@api_router.post('/campaigns/{campaign_id}/status')
def change_campaign_status(campaign_id: str, payload: StatusChangePayload):
    try:
        return campaign_service.change_status(campaign_id, payload)
    except KeyError:
        raise HTTPException(status_code=404, detail='Campanha não encontrada')

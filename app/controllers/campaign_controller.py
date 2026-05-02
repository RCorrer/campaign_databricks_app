from fastapi import APIRouter, Depends, HTTPException
from app.services.campaign_service import CampaignService
from app.dependencies import get_campaign_service
from app.domain.campaign import CampaignCreate, CampaignUpdate, CampaignBrieffing
from app.exceptions.campaign_exceptions import CampaignNotFoundException
from typing import List

router = APIRouter()

@router.get("/", response_model=List[CampaignBrieffing])
def list_campaigns(service: CampaignService = Depends(get_campaign_service)):
    return service.list_campaigns()

@router.get("/{campaign_id}", response_model=CampaignBrieffing)
def get_campaign(campaign_id: int, service: CampaignService = Depends(get_campaign_service)):
    campaign = service.get_campaign(campaign_id)
    if not campaign:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")
    return campaign

@router.post("/", response_model=CampaignBrieffing, status_code=201)
def create_campaign(campaign: CampaignCreate, service: CampaignService = Depends(get_campaign_service)):
    try:
        return service.create_campaign(campaign)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{campaign_id}", response_model=CampaignBrieffing)
def update_campaign(campaign_id: int, campaign: CampaignUpdate, service: CampaignService = Depends(get_campaign_service)):
    try:
        return service.update_campaign(campaign_id, campaign)
    except CampaignNotFoundException:
        raise HTTPException(status_code=404, detail="Campanha não encontrada")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import APIRouter, Depends
from app.services.segmentation_service import SegmentationService
from app.dependencies import get_segmentation_service

router = APIRouter()

@router.post("/generate/{campaign_id}")
def generate_lead_view(campaign_id: int, service: SegmentationService = Depends(get_segmentation_service)):
    view_name = service.build_campaign_view(campaign_id)
    return {"message": f"View {view_name} criada com sucesso"}

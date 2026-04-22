from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from backend.models.contracts import (
    ActivationRequest,
    CampaignBriefingRequest,
    CampaignCreateRequest,
    CampaignUpdateRequest,
    SegmentationSaveRequest,
    StatusChangeRequest,
)
from backend.repositories.databricks_sql import DatabricksSQLRepository
from backend.services.catalog_service import CatalogService
from backend.services.campaign_service import CampaignService
from backend.services.dashboard_service import DashboardService
from backend.services.execution_service import ExecutionService
from backend.services.query_builder import QueryBuilderService

router = APIRouter()

repo = DatabricksSQLRepository()
catalog_service = CatalogService()
query_builder = QueryBuilderService()
dashboard_service = DashboardService(repo)
campaign_service = CampaignService(repo, catalog_service, query_builder)
execution_service = ExecutionService(repo)


@router.get("/health")
def health():
    return {"status": "ok"}


@router.get("/catalog/full")
def get_catalog_full():
    return catalog_service.get_full_catalog()


@router.get("/catalog/initial-audiences")
def get_initial_audiences():
    return catalog_service.get_initial_audiences()


@router.get("/catalog/themes")
def get_themes():
    return catalog_service.get_themes()


@router.get("/dashboard/campaigns")
def get_dashboard_campaigns(
    status: str | None = Query(default=None),
    theme: str | None = Query(default=None),
    search: str | None = Query(default=None),
):
    try:
        return dashboard_service.list_campaigns(status=status, theme=theme, search=search)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/campaigns")
def create_campaign(req: CampaignCreateRequest):
    try:
        return campaign_service.create_campaign(req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/campaigns/{campaign_id}")
def get_campaign(campaign_id: str):
    try:
        return campaign_service.get_campaign_detail(campaign_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.put("/campaigns/{campaign_id}")
def update_campaign(campaign_id: str, req: CampaignUpdateRequest):
    try:
        return campaign_service.update_campaign(campaign_id, req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.delete("/campaigns/{campaign_id}")
def delete_campaign(campaign_id: str):
    try:
        return campaign_service.delete_campaign(campaign_id)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.put("/campaigns/{campaign_id}/briefing")
def save_briefing(campaign_id: str, req: CampaignBriefingRequest):
    try:
        return campaign_service.save_briefing(campaign_id, req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.put("/campaigns/{campaign_id}/segmentation")
def save_segmentation(campaign_id: str, req: SegmentationSaveRequest):
    try:
        return campaign_service.save_segmentation(campaign_id, req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/campaigns/{campaign_id}/segmentation/preview")
def preview_segmentation(campaign_id: str, req: SegmentationSaveRequest):
    try:
        return campaign_service.preview_segmentation(req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/campaigns/{campaign_id}/activation")
def activate_campaign(campaign_id: str, req: ActivationRequest):
    try:
        return execution_service.activate_campaign(campaign_id, req)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/campaigns/{campaign_id}/status")
def change_status(campaign_id: str, req: StatusChangeRequest):
    try:
        return campaign_service.change_status(campaign_id, req)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

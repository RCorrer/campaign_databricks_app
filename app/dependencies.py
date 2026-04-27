from app.infra.db.databricks_client import DatabricksSQLClient
from app.infra.repositories.campaign_repository_impl import CampaignRepositoryImpl
from app.infra.repositories.lead_repository_impl import LeadRepositoryImpl
from app.services.campaign_service import CampaignService
from app.services.segmentation_service import SegmentationService

db_client = DatabricksSQLClient()
campaign_repo = CampaignRepositoryImpl(db_client)
lead_repo = LeadRepositoryImpl(db_client)

campaign_service = CampaignService(campaign_repo)
segmentation_service = SegmentationService(campaign_repo, lead_repo, db_client)

def get_campaign_service() -> CampaignService:
    return campaign_service

def get_segmentation_service() -> SegmentationService:
    return segmentation_service

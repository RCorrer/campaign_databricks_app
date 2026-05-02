from app.repositories.campaign_repository import CampaignRepository
from app.domain.campaign import CampaignBrieffing, CampaignCreate, CampaignUpdate
from typing import List

class CampaignService:
    def __init__(self, repository: CampaignRepository):
        self.repo = repository

    def get_campaign(self, campaign_id: int) -> CampaignBrieffing:
        return self.repo.get_brieffing(campaign_id)

    def list_campaigns(self) -> List[CampaignBrieffing]:
        return self.repo.list_all()

    def create_campaign(self, campaign: CampaignCreate) -> CampaignBrieffing:
        return self.repo.create(campaign)

    def update_campaign(self, campaign_id: int, campaign: CampaignUpdate) -> CampaignBrieffing:
        return self.repo.update(campaign_id, campaign)

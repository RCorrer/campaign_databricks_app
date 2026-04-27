from abc import ABC, abstractmethod
from app.domain.campaign import CampaignBrieffing, CampaignCreate, CampaignUpdate
from typing import List, Optional

class CampaignRepository(ABC):
    @abstractmethod
    def get_brieffing(self, campaign_id: int) -> Optional[CampaignBrieffing]:
        pass

    @abstractmethod
    def list_all(self) -> List[CampaignBrieffing]:
        pass

    @abstractmethod
    def create(self, campaign: CampaignCreate) -> CampaignBrieffing:
        pass

    @abstractmethod
    def update(self, campaign_id: int, campaign: CampaignUpdate) -> CampaignBrieffing:
        pass

class CampaignNotFoundException(Exception):
    def __init__(self, campaign_id: int):
        self.campaign_id = campaign_id
        super().__init__(f"Campanha {campaign_id} não encontrada")

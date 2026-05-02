import { useEffect, useState } from 'react'
import CampaignCard from '../components/CampaignCard'

export default function DashboardPage() {
  const [campaigns, setCampaigns] = useState([])

  useEffect(() => {
    fetch('/api/campaigns')
      .then(res => {
        if (!res.ok) throw new Error('Erro ao buscar campanhas')
        return res.json()
      })
      .then(data => setCampaigns(data))
      .catch(err => console.error(err))
  }, [])

  if (!campaigns.length) {
    return <p className="muted">Nenhuma campanha encontrada.</p>
  }

  return (
    <div className="cards-grid">
      {campaigns.map(campaign => (
        <CampaignCard key={campaign.campaign_id} campaign={campaign} />
      ))}
    </div>
  )
}

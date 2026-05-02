import { useEffect, useState } from 'react'
import CampaignCard from '../components/CampaignCard'

export default function DashboardPage() {
  const [campaigns, setCampaigns] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/campaigns')
      .then(res => res.json())
      .then(data => {
        setCampaigns(data)
        setLoading(false)
      })
      .catch(() => setLoading(false))
  }, [])

  if (loading) return <p className="muted">Carregando campanhas...</p>
  if (!campaigns.length) return <p className="muted">Nenhuma campanha encontrada.</p>

  return (
    <div className="cards-grid">
      {campaigns.map(campaign => (
        <CampaignCard key={campaign.campaign_id} campaign={campaign} />
      ))}
    </div>
  )
}

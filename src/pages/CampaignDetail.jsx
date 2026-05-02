import { useParams } from 'react-router-dom'
import { useEffect, useState } from 'react'

export default function CampaignDetail() {
  const { id } = useParams()
  const [campaign, setCampaign] = useState(null)

  useEffect(() => {
    fetch(`/api/campaigns/${id}`)
      .then(res => res.json())
      .then(data => setCampaign(data))
      .catch(err => console.error(err))
  }, [id])

  if (!campaign) return <p>Carregando...</p>

  return (
    <div className="card">
      <h2>{campaign.name}</h2>
      <p>{campaign.objective}</p>
      <div className="definition-list">
        <div><span>Status</span><strong>{campaign.status_label}</strong></div>
        <div><span>Início</span><strong>{campaign.start_date}</strong></div>
        <div><span>Fim</span><strong>{campaign.end_date}</strong></div>
        <div><span>Tema</span><strong>{campaign.theme}</strong></div>
        <div><span>Estratégia</span><strong>{campaign.strategy || '-'}</strong></div>
      </div>
      <pre>{JSON.stringify(campaign, null, 2)}</pre>
    </div>
  )
}

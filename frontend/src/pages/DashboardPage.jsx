import { useMemo, useState } from 'react'
import CampaignCard from '../components/CampaignCard'

export default function DashboardPage({ campaigns }) {
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('TODOS')

  const filteredCampaigns = useMemo(() => {
    return campaigns.filter((campaign) => {
      const normalizedSearch = search.toLowerCase().trim()
      const matchesSearch = !normalizedSearch || [
        campaign.campaign_id,
        campaign.name,
        campaign.theme,
        campaign.strategy,
        campaign.objective
      ].some((value) => String(value).toLowerCase().includes(normalizedSearch))

      const matchesStatus = status === 'TODOS' || campaign.status === status
      return matchesSearch && matchesStatus
    })
  }, [campaigns, search, status])

  const statusOptions = ['TODOS', 'PREPARACAO', 'SEGMENTACAO', 'ATIVACAO', 'ATIVO', 'PAUSADO', 'CONCLUIDO', 'ENCERRADO', 'CANCELADO']

  return (
    <section className="page-stack">
      <div className="card hero-banner">
        <div>
          <p className="eyebrow">Página inicial</p>
          <h2>Campanhas</h2>
          <p className="muted">Visualize campanhas de forma resumida, pesquise e filtre por status.</p>
        </div>
        <div className="hero-stats">
          <div><strong>{campaigns.length}</strong><span>Total</span></div>
          <div><strong>{campaigns.filter((item) => item.status === 'ATIVO').length}</strong><span>Ativas</span></div>
          <div><strong>{campaigns.filter((item) => item.status === 'PAUSADO').length}</strong><span>Pausadas</span></div>
        </div>
      </div>

      <div className="filters card">
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="Buscar por nome, código, tema ou estratégia"
        />

        <select value={status} onChange={(event) => setStatus(event.target.value)}>
          {statusOptions.map((option) => <option key={option} value={option}>{option}</option>)}
        </select>
      </div>

      <div className="cards-grid">
        {filteredCampaigns.map((campaign) => <CampaignCard key={campaign.campaign_id} campaign={campaign} />)}
      </div>
    </section>
  )
}

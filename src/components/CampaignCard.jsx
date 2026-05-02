import { Link } from 'react-router-dom'

export default function CampaignCard({ campaign }) {
  if (!campaign || !campaign.campaign_id) {
    return null // evita renderizar card quebrado enquanto dados não chegam
  }

  const statusClassMap = {
    planejada: 'status-planejada',
    aprovada: 'status-aprovada',
    'em execucao': 'status-execucao',
    finalizada: 'status-finalizada',
    cancelada: 'status-cancelada',
  }

  return (
    <article className="card campaign-card">
      <div className="campaign-card-top">
        <div>
          <p className="campaign-code">{campaign.campaign_id}</p>
          <h3>{campaign.name}</h3>
        </div>
        <span className={`status-pill ${statusClassMap[campaign.status] || ''}`}>
          {campaign.status_label}
        </span>
      </div>

      <div className="campaign-grid-info">
        <div><span>Tema</span><strong>{campaign.theme}</strong></div>
        <div><span>Objetivo</span><strong>{campaign.objective}</strong></div>
        <div><span>Vigência</span><strong>{campaign.start_date} a {campaign.end_date}</strong></div>
        <div><span>Versão</span><strong>v{campaign.version}</strong></div>
      </div>

      <p className="muted">{campaign.objective}</p>

      <div className="campaign-actions">
        <Link className="button secondary" to={`/campaigns/${campaign.campaign_id}`}>
          Abrir
        </Link>
      </div>
    </article>
  )
}

import { Link } from 'react-router-dom'

export default function CampaignCard({ campaign }) {
  return (
    <article className="card campaign-card">
      <div className="campaign-card-top">
        <div>
          <p className="campaign-code">{campaign.campaign_id}</p>
          <h3>{campaign.name}</h3>
        </div>
        <span className={`status-pill status-${campaign.status.toLowerCase()}`}>{campaign.status_label}</span>
      </div>

      <div className="campaign-grid-info">
        <div>
          <span>Tema</span>
          <strong>{campaign.theme}</strong>
        </div>
        <div>
          <span>Estratégia</span>
          <strong>{campaign.strategy}</strong>
        </div>
        <div>
          <span>Vigência</span>
          <strong>{campaign.start_date} a {campaign.end_date}</strong>
        </div>
        <div>
          <span>Versão</span>
          <strong>v{campaign.version}</strong>
        </div>
      </div>

      <p className="muted">{campaign.objective}</p>

      <div className="campaign-actions">
        <Link className="button secondary" to={`/campaigns/${campaign.campaign_id}/preparation`}>Preparação</Link>
        <Link className="button secondary" to={`/campaigns/${campaign.campaign_id}/segmentation`}>Segmentação</Link>
        <Link className="button secondary" to={`/campaigns/${campaign.campaign_id}/activation`}>Ativação</Link>
      </div>
    </article>
  )
}

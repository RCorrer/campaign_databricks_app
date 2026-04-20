import { Link } from 'react-router-dom'

export default function PreparationPage({ campaign }) {
  const briefing = campaign.briefing || {}

  return (
    <section className="page-stack">
      <div className="breadcrumb">
        <Link to="/">Campanhas</Link>
        <span>/</span>
        <span>Preparação</span>
      </div>

      <div className="card page-header-card">
        <div>
          <p className="eyebrow">Etapa 1</p>
          <h2>Preparação</h2>
          <p className="muted">Fase inicial onde o briefing é definido e refinado com regras, objetivos, restrições e canais.</p>
        </div>
        <span className={`status-pill status-${campaign.status.toLowerCase()}`}>{campaign.status_label}</span>
      </div>

      <div className="detail-grid">
        <div className="card">
          <h3>Resumo da campanha</h3>
          <div className="definition-list">
            <div><span>ID</span><strong>{campaign.campaign_id}</strong></div>
            <div><span>Nome</span><strong>{campaign.name}</strong></div>
            <div><span>Tema</span><strong>{campaign.theme}</strong></div>
            <div><span>Objetivo</span><strong>{campaign.objective}</strong></div>
            <div><span>Estratégia</span><strong>{campaign.strategy}</strong></div>
            <div><span>Vigência</span><strong>{campaign.start_date} a {campaign.end_date}</strong></div>
          </div>
        </div>

        <div className="card">
          <h3>Briefing refinado</h3>
          <div className="definition-list">
            <div><span>Desafio</span><strong>{briefing.challenge}</strong></div>
            <div><span>Resultado esperado</span><strong>{briefing.target_business_outcome}</strong></div>
            <div><span>Canais</span><strong>{(briefing.channels || []).join(', ')}</strong></div>
            <div><span>Restrições</span><strong>{(briefing.constraints || []).join(' | ')}</strong></div>
            <div><span>Regras</span><strong>{(briefing.business_rules || []).join(' | ')}</strong></div>
            <div><span>Notas</span><strong>{briefing.notes}</strong></div>
          </div>
        </div>
      </div>
    </section>
  )
}

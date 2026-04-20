import { useState } from 'react'
import { Link } from 'react-router-dom'
import RuleGroupCard from '../components/RuleGroupCard'

export default function SegmentationPage({ campaign, topics }) {
  const [tab, setTab] = useState('universo')
  const segmentation = campaign.segmentation || { include_groups: [], exclude_groups: [] }

  return (
    <section className="page-stack">
      <div className="breadcrumb">
        <Link to="/">Campanhas</Link>
        <span>/</span>
        <span>Segmentação</span>
      </div>

      <div className="card page-header-card">
        <div>
          <p className="eyebrow">Etapa 2</p>
          <h2>Segmentação no-code</h2>
          <p className="muted">A segmentação ocorre por caixas e campos, com universo inicial, inclusão e exclusão usando o arquivo de/para semântico.</p>
        </div>
        <span className={`status-pill status-${campaign.status.toLowerCase()}`}>{campaign.status_label}</span>
      </div>

      <div className="card tab-card">
        <div className="tabs">
          <button className={tab === 'universo' ? 'tab active' : 'tab'} onClick={() => setTab('universo')}>Universo inicial</button>
          <button className={tab === 'inclusao' ? 'tab active' : 'tab'} onClick={() => setTab('inclusao')}>Inclusão</button>
          <button className={tab === 'exclusao' ? 'tab active' : 'tab'} onClick={() => setTab('exclusao')}>Exclusão</button>
        </div>

        {tab === 'universo' && (
          <div className="tab-panel split-grid">
            <div className="card inner-card">
              <h3>View base</h3>
              <p><strong>{segmentation.universe_view}</strong></p>
              <p className="muted">Lê um schema específico com views de público inicial da campanha.</p>
            </div>
            <div className="card inner-card">
              <h3>Universos disponíveis</h3>
              <ul className="simple-list">
                {(campaign.available_universe_views || []).map((item) => <li key={item}>{item}</li>)}
              </ul>
            </div>
          </div>
        )}

        {tab === 'inclusao' && (
          <div className="tab-panel split-grid">
            <div>
              {segmentation.include_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />)}
            </div>
            <div className="card inner-card">
              <h3>Assuntos mapeados</h3>
              <ul className="simple-list">
                {topics.map((topic) => <li key={topic.key}>{topic.label}</li>)}
              </ul>
            </div>
          </div>
        )}

        {tab === 'exclusao' && (
          <div className="tab-panel split-grid">
            <div>
              {segmentation.exclude_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />)}
            </div>
            <div className="card inner-card">
              <h3>Descrição da regra</h3>
              <p className="muted">As regras ficam salvas em metadados versionados e podem ser reabertas para ajuste antes ou depois da ativação.</p>
            </div>
          </div>
        )}
      </div>

      <div className="card">
        <h3>Preview SQL</h3>
        <pre>{segmentation.preview_sql}</pre>
      </div>
    </section>
  )
}

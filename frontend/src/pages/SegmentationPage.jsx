import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import RuleGroupCard from '../components/RuleGroupCard'

export default function SegmentationPage({ campaign, builderCatalog }) {
  const [tab, setTab] = useState('publico')
  const segmentation = campaign.segmentation || {
    initial_audience_code: '',
    universe_view: '',
    native_include_groups: [],
    native_exclude_groups: [],
    include_groups: [],
    exclude_groups: []
  }

  const selectedAudience = useMemo(() => {
    return (builderCatalog.initial_audiences || []).find((item) => item.code === segmentation.initial_audience_code)
  }, [builderCatalog.initial_audiences, segmentation.initial_audience_code])

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
          <h2>Segmentação no-code de CRM</h2>
          <p className="muted">O fluxo começa em um público inicial de <code>main.campaign_sources</code>, aplica filtros nativos da view e depois cruza o público com temas do <code>main.customer_360</code> por <code>cpf_cnpj</code>.</p>
        </div>
        <span className={`status-pill status-${campaign.status.toLowerCase()}`}>{campaign.status_label}</span>
      </div>

      <div className="card tab-card">
        <div className="tabs">
          <button className={tab === 'publico' ? 'tab active' : 'tab'} onClick={() => setTab('publico')}>Público inicial</button>
          <button className={tab === 'nativo' ? 'tab active' : 'tab'} onClick={() => setTab('nativo')}>Atributos nativos</button>
          <button className={tab === 'inclusao' ? 'tab active' : 'tab'} onClick={() => setTab('inclusao')}>Inclusão por tema</button>
          <button className={tab === 'exclusao' ? 'tab active' : 'tab'} onClick={() => setTab('exclusao')}>Exclusão por tema</button>
        </div>

        {tab === 'publico' && (
          <div className="tab-panel split-grid">
            <div className="card inner-card">
              <h3>Público selecionado</h3>
              <div className="definition-list">
                <div><span>Código</span><strong>{segmentation.initial_audience_code || '-'}</strong></div>
                <div><span>Label</span><strong>{selectedAudience?.label || '-'}</strong></div>
                <div><span>View inicial</span><strong>{segmentation.universe_view || '-'}</strong></div>
              </div>
              <p className="muted">Essa view representa o entry audience da campanha e já traz os atributos nativos de cliente para filtros diretos.</p>
            </div>
            <div className="card inner-card">
              <h3>Públicos disponíveis</h3>
              <ul className="simple-list">
                {(builderCatalog.initial_audiences || []).map((item) => <li key={item.code}><strong>{item.label}</strong> — {item.source_view}</li>)}
              </ul>
            </div>
          </div>
        )}

        {tab === 'nativo' && (
          <div className="tab-panel split-grid">
            <div>
              <div className="card inner-card">
                <h3>Inclusão nativa</h3>
                {segmentation.native_include_groups.length ? segmentation.native_include_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />) : <p className="muted">Nenhuma regra nativa de inclusão configurada.</p>}
              </div>
              <div className="card inner-card">
                <h3>Exclusão nativa</h3>
                {segmentation.native_exclude_groups.length ? segmentation.native_exclude_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />) : <p className="muted">Nenhuma regra nativa de exclusão configurada.</p>}
              </div>
            </div>
            <div className="card inner-card">
              <h3>Campos da view inicial</h3>
              <ul className="simple-list">
                {(builderCatalog.native_fields || []).map((field) => <li key={field.field}><strong>{field.label}</strong> — {field.field}</li>)}
              </ul>
            </div>
          </div>
        )}

        {tab === 'inclusao' && (
          <div className="tab-panel split-grid">
            <div>
              {segmentation.include_groups.length ? segmentation.include_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />) : <p className="muted">Nenhum cruzamento temático de inclusão configurado.</p>}
            </div>
            <div className="card inner-card">
              <h3>Temas disponíveis</h3>
              <ul className="simple-list">
                {(builderCatalog.themes || []).map((theme) => <li key={theme.key}><strong>{theme.label}</strong> — {theme.table}</li>)}
              </ul>
            </div>
          </div>
        )}

        {tab === 'exclusao' && (
          <div className="tab-panel split-grid">
            <div>
              {segmentation.exclude_groups.length ? segmentation.exclude_groups.map((group, index) => <RuleGroupCard key={group.name + index} group={group} index={index} />) : <p className="muted">Nenhum cruzamento temático de exclusão configurado.</p>}
            </div>
            <div className="card inner-card">
              <h3>Lógica do builder</h3>
              <ul className="simple-list">
                <li>Seleciona o público inicial em <code>main.campaign_sources</code>.</li>
                <li>Aplica filtros nativos na própria view escolhida.</li>
                <li>Cruza com tabelas temáticas do <code>main.customer_360</code> por <code>cpf_cnpj</code>.</li>
                <li>Materializa somente os <code>cpf_cnpj</code> elegíveis no schema de execução.</li>
              </ul>
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

import { Link } from 'react-router-dom'

export default function ActivationPage({ campaign }) {
  const activation = campaign.activation || {}

  return (
    <section className="page-stack">
      <div className="breadcrumb">
        <Link to="/">Campanhas</Link>
        <span>/</span>
        <span>Ativação</span>
      </div>

      <div className="card page-header-card">
        <div>
          <p className="eyebrow">Etapa 3</p>
          <h2>Ativação e materialização da audiência</h2>
          <p className="muted">A ativação grava o resultado final no schema <code>main.campaign_execution</code>, preservando apenas os identificadores da campanha e os <code>cpf_cnpj</code> segmentados.</p>
        </div>
        <span className={`status-pill status-${campaign.status.toLowerCase()}`}>{campaign.status_label}</span>
      </div>

      <div className="detail-grid">
        <div className="card">
          <h3>Configuração</h3>
          <div className="definition-list">
            <div><span>Modo de materialização</span><strong>{activation.materialization_mode}</strong></div>
            <div><span>Modo de execução</span><strong>{activation.execution_mode}</strong></div>
            <div><span>Início</span><strong>{activation.effective_start_date}</strong></div>
            <div><span>Fim</span><strong>{activation.effective_end_date}</strong></div>
            <div><span>Objeto final</span><strong>{activation.activation_object_name}</strong></div>
            <div><span>Snapshot/log</span><strong>{activation.snapshot_object_name || '-'}</strong></div>
          </div>
        </div>

        <div className="card">
          <h3>Fluxo operacional</h3>
          <ul className="simple-list">
            <li>Pode voltar para Preparação para refinar o briefing.</li>
            <li>Pode voltar para Segmentação para ajustar regras no-code.</li>
            <li>O resultado final persiste somente a audiência segmentada e metadados de vigência.</li>
            <li>As execuções ficam registradas no log de execução.</li>
          </ul>
        </div>
      </div>

      <div className="card">
        <h3>SQL de ativação</h3>
        <pre>{activation.activation_sql}</pre>
      </div>
    </section>
  )
}

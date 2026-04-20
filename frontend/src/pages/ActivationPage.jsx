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
          <h2>Ativação</h2>
          <p className="muted">A ativação gera o objeto final com cpf_cnpj, data de segmentação, vigência e versão da regra.</p>
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
          </div>
        </div>

        <div className="card">
          <h3>Fluxo operacional</h3>
          <ul className="simple-list">
            <li>Pode voltar para Preparação para refinar o briefing.</li>
            <li>Pode voltar para Segmentação para ajustar regras.</li>
            <li>Pode pausar, encerrar, concluir ou cancelar.</li>
            <li>Alterações ficam registradas em histórico.</li>
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

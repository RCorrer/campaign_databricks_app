export default function FlowPage() {
  return (
    <section className="page-stack">
      <div className="card">
        <p className="eyebrow">Fluxo macro</p>
        <h2>Workflow da campanha</h2>
        <div className="flow-line">
          <span>Preparação</span>
          <i />
          <span>Segmentação</span>
          <i />
          <span>Ativação</span>
          <i />
          <span>Ativo</span>
        </div>
        <div className="flow-details">
          <div className="card inner-card"><strong>Pausado</strong><p className="muted">Pode retornar para Ativo.</p></div>
          <div className="card inner-card"><strong>Concluído</strong><p className="muted">Encerramento natural por data final.</p></div>
          <div className="card inner-card"><strong>Encerrado</strong><p className="muted">Encerramento manual antes do fim.</p></div>
          <div className="card inner-card"><strong>Cancelado</strong><p className="muted">Pode ocorrer em qualquer etapa.</p></div>
        </div>
      </div>
    </section>
  )
}

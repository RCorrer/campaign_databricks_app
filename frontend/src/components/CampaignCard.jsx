import { Link } from 'react-router-dom'

export default function CampaignCard({ campanha, onDelete, onStatusChange }) {
  return (
    <article className="card campaign-card">
      <div className="card-header">
        <div>
          <h3>{campanha.nome}</h3>
          <p>{campanha.descricao || campanha.objetivo || 'Sem descrição'}</p>
        </div>
        <span className="status-pill">{campanha.rotulo_status}</span>
      </div>
      <div className="meta-grid">
        <span><strong>ID</strong>{campanha.id_campanha}</span>
        <span><strong>Tema</strong>{campanha.tema || '-'}</span>
        <span><strong>Vigência</strong>{campanha.data_inicio || '-'} a {campanha.data_fim || '-'}</span>
        <span><strong>Versão</strong>{campanha.versao}</span>
      </div>
      <div className="actions">
        <Link className="btn primary" to={`/campanhas/${campanha.id_campanha}`}>Abrir fluxo</Link>
        {(campanha.transicoes_permitidas || []).map((status) => (
          <button key={status} className="btn" onClick={() => onStatusChange(campanha, status)}>{status}</button>
        ))}
        <button className="btn danger" onClick={() => onDelete(campanha)}>Excluir</button>
      </div>
    </article>
  )
}

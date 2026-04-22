import { Link } from "react-router-dom";
import CampaignStatusBadge from "./CampaignStatusBadge";
import { formatDate } from "../utils/formatters";

export default function CampaignCard({ campaign, onDelete, onStatusChange }) {
  return (
    <article className="card campaign-card">
      <div className="card-top">
        <div>
          <h3>{campaign.campaign_name}</h3>
          <p className="muted">{campaign.theme} • {campaign.owner_team || "Sem owner"}</p>
        </div>
        <CampaignStatusBadge status={campaign.status} />
      </div>
      <div className="card-grid">
        <div><strong>Canal</strong><span>{campaign.primary_channel || "-"}</span></div>
        <div><strong>Prioridade</strong><span>{campaign.priority || "-"}</span></div>
        <div><strong>Início</strong><span>{formatDate(campaign.start_date)}</span></div>
        <div><strong>Fim</strong><span>{formatDate(campaign.end_date)}</span></div>
        <div><strong>Regras nativas</strong><span>{campaign.native_rule_count ?? 0}</span></div>
        <div><strong>Regras temáticas</strong><span>{campaign.thematic_rule_count ?? 0}</span></div>
      </div>
      <div className="card-actions">
        <Link className="btn" to={`/campaigns/${campaign.campaign_id}/preparation`}>Abrir</Link>
        <button className="btn btn-secondary" onClick={() => onStatusChange(campaign, "PAUSADO")}>Pausar</button>
        <button className="btn btn-secondary" onClick={() => onStatusChange(campaign, "CANCELADO")}>Cancelar</button>
        <button className="btn btn-danger" onClick={() => onDelete(campaign)}>Excluir</button>
      </div>
    </article>
  );
}

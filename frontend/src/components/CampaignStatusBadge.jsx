export default function CampaignStatusBadge({ status }) {
  return <span className={`status-badge status-${(status || "").toLowerCase()}`}>{status}</span>;
}

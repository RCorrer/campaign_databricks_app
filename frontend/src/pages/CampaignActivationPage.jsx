import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Layout from "../components/Layout";
import Toast from "../components/Toast";
import { useToast } from "../hooks/useToast";
import { api } from "../api/client";

export default function CampaignActivationPage() {
  const { campaignId } = useParams();
  const { toast, show } = useToast();
  const [campaign, setCampaign] = useState(null);
  const [activation, setActivation] = useState({
    segmentation_version_no: 1,
    activation_mode: "SNAPSHOT",
    start_date: "",
    end_date: "",
  });

  useEffect(() => {
    api.get(`/api/campaigns/${campaignId}`)
      .then((data) => {
        setCampaign(data);
        setActivation((prev) => ({
          ...prev,
          segmentation_version_no: data.segmentation_version_no || 1,
          start_date: (data.start_date || "").slice(0, 10),
          end_date: (data.end_date || "").slice(0, 10),
        }));
      })
      .catch((error) => show(error.message, "error"));
  }, [campaignId]);

  async function handleActivate() {
    try {
      const result = await api.post(`/api/campaigns/${campaignId}/activation`, activation);
      show(`Campanha ativada com ${result.row_count} clientes`);
      const detail = await api.get(`/api/campaigns/${campaignId}`);
      setCampaign(detail);
    } catch (error) {
      show(error.message, "error");
    }
  }

  if (!campaign) {
    return <Layout title="Ativação"><div className="card">Carregando...</div></Layout>;
  }

  return (
    <Layout title={`Ativação - ${campaign.campaign_name}`}>
      <Toast toast={toast} />
      <div className="card">
        <h3>Resumo</h3>
        <p><strong>Campanha:</strong> {campaign.campaign_name}</p>
        <p><strong>Status:</strong> {campaign.status}</p>
        <p><strong>Segmentação atual:</strong> versão {campaign.segmentation_version_no || "-"}</p>
        <p><strong>Estimativa:</strong> {campaign.estimated_count || 0}</p>
      </div>

      <div className="card form-grid">
        <label className="form-field">
          <span>Modo de ativação</span>
          <select value={activation.activation_mode} onChange={(e) => setActivation({ ...activation, activation_mode: e.target.value })}>
            <option value="SNAPSHOT">SNAPSHOT</option>
            <option value="REFRESH">REFRESH</option>
          </select>
        </label>
        <label className="form-field">
          <span>Data início</span>
          <input type="date" value={activation.start_date} onChange={(e) => setActivation({ ...activation, start_date: e.target.value })} />
        </label>
        <label className="form-field">
          <span>Data fim</span>
          <input type="date" value={activation.end_date} onChange={(e) => setActivation({ ...activation, end_date: e.target.value })} />
        </label>
        <div className="full-width form-actions">
          <button className="btn" onClick={handleActivate}>Ativar campanha</button>
        </div>
      </div>
    </Layout>
  );
}

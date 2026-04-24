import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import Layout from "../components/Layout";
import Toast from "../components/Toast";
import { useToast } from "../hooks/useToast";
import { api } from "../api/client";

export default function CampaignActivationPage() {
  const { campaignId } = useParams();
  const { toast, show } = useToast();

  const [campaign, setCampaign] = useState(null);
  const [activating, setActivating] = useState(false);
  const [activationResult, setActivationResult] = useState(null);
  const [activation, setActivation] = useState({
    segmentation_version_no: 1,
    activation_mode: "SNAPSHOT",
    start_date: "",
    end_date: "",
  });

  async function loadCampaign() {
    const data = await api.get(`/api/campaigns/${campaignId}`);
    setCampaign(data);
    setActivation((prev) => ({
      ...prev,
      segmentation_version_no: data.segmentation_version_no || 1,
      start_date: (data.activation_start_date || data.start_date || "").slice(0, 10),
      end_date: (data.activation_end_date || data.end_date || "").slice(0, 10),
    }));
  }

  useEffect(() => {
    loadCampaign().catch((error) => show(error.message, "error"));
  }, [campaignId]);

  async function handleActivate() {
    try {
      setActivating(true);
      const result = await api.post(`/api/campaigns/${campaignId}/activation`, activation);
      setActivationResult(result);
      await loadCampaign();
      show(
        `Campanha ativada com ${result.row_count} clientes. Run ${result.run_id.slice(0, 8)}...`
      );
    } catch (error) {
      show(error.message, "error");
    } finally {
      setActivating(false);
    }
  }

  if (!campaign) {
    return <div>Carregando...</div>;
  }

  return (
    <Layout>
      <Toast toast={toast} />

      <div className="page-header">
        <div>
          <h1>Activation</h1>
          <p>{campaign.campaign_name}</p>
        </div>
        <div className="page-actions">
          <Link className="btn btn-secondary" to={`/campaigns/${campaignId}/segmentation`}>
            Voltar para segmentation
          </Link>
        </div>
      </div>

      <div className="card">
        <h3>Resumo atual</h3>
        <p>Status: {campaign.status}</p>
        <p>Versão atual de segmentação: {campaign.segmentation_version_no || "-"}</p>
        <p>Versão atual de ativação: {campaign.activation_version_no || "-"}</p>
        <p>Estimativa disponível: {campaign.estimated_count || 0}</p>
        <p>Última execução: {campaign.last_run_at || "-"}</p>
      </div>

      <div className="card form-grid">
        <div>
          <label>Versão da segmentação</label>
          <input
            type="number"
            min="1"
            value={activation.segmentation_version_no}
            onChange={(e) =>
              setActivation({
                ...activation,
                segmentation_version_no: Number(e.target.value),
              })
            }
          />
        </div>

        <div>
          <label>Modo de ativação</label>
          <select
            value={activation.activation_mode}
            onChange={(e) =>
              setActivation({
                ...activation,
                activation_mode: e.target.value,
              })
            }
          >
            <option value="SNAPSHOT">SNAPSHOT</option>
            <option value="REFRESH">REFRESH</option>
          </select>
        </div>

        <div>
          <label>Data início</label>
          <input
            type="date"
            value={activation.start_date}
            onChange={(e) =>
              setActivation({
                ...activation,
                start_date: e.target.value,
              })
            }
          />
        </div>

        <div>
          <label>Data fim</label>
          <input
            type="date"
            value={activation.end_date}
            onChange={(e) =>
              setActivation({
                ...activation,
                end_date: e.target.value,
              })
            }
          />
        </div>
      </div>

      <div className="form-actions">
        <button className="btn" onClick={handleActivate} disabled={activating}>
          {activating ? "Ativando..." : "Ativar campanha"}
        </button>
      </div>

      {activationResult && (
        <div className="card">
          <h3>Resultado da última ativação</h3>
          <p>Run id: {activationResult.run_id}</p>
          <p>Versão de segmentação usada: {activationResult.segmentation_version_no}</p>
          <p>Versão de ativação gerada: {activationResult.activation_version_no}</p>
          <p>Clientes materializados: {activationResult.row_count}</p>
        </div>
      )}
    </Layout>
  );
}

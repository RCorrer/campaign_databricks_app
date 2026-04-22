import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import Layout from "../components/Layout";
import FormField from "../components/FormField";
import Toast from "../components/Toast";
import ConfirmModal from "../components/ConfirmModal";
import { useToast } from "../hooks/useToast";
import { allowedTransitions } from "../utils/statusFlow";
import { api } from "../api/client";

export default function CampaignPreparationDetailPage() {
  const { campaignId } = useParams();
  const [campaign, setCampaign] = useState(null);
  const [editMode, setEditMode] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const { toast, show } = useToast();
  const navigate = useNavigate();

  async function load() {
    const data = await api.get(`/api/campaigns/${campaignId}`);
    setCampaign({
      ...data,
      channels: data.channels || ["Email"],
    });
  }

  useEffect(() => {
    load().catch((error) => show(error.message, "error"));
  }, [campaignId]);

  if (!campaign) {
    return <Layout title="Campanha"><div className="card">Carregando...</div></Layout>;
  }

  async function handleSave(event) {
    event.preventDefault();
    try {
      await api.put(`/api/campaigns/${campaignId}`, {
        name: campaign.campaign_name,
        theme: campaign.theme,
        objective: campaign.objective,
        strategy: campaign.strategy,
        description: campaign.description,
        primary_channel: campaign.primary_channel,
        priority: campaign.priority,
        owner_team: campaign.owner_team,
        goal_kpi: campaign.goal_kpi,
        goal_value: campaign.goal_value,
        start_date: campaign.start_date,
        end_date: campaign.end_date,
        periodicity: campaign.periodicity,
        max_impacts_month: campaign.max_impacts_month,
        control_group_enabled: campaign.control_group_enabled,
        status_reason: campaign.status_reason,
      });

      await api.put(`/api/campaigns/${campaignId}/briefing`, {
        challenge: campaign.challenge,
        target_business_outcome: campaign.target_business_outcome,
        channels: campaign.channels,
        constraints: campaign.constraints,
        business_rules: campaign.business_rules,
        notes: campaign.notes,
      });

      show("Campanha atualizada com sucesso");
      setEditMode(false);
      load();
    } catch (error) {
      show(error.message, "error");
    }
  }

  async function handleDelete() {
    try {
      await api.del(`/api/campaigns/${campaignId}`);
      show("Campanha excluída");
      setTimeout(() => navigate("/"), 500);
    } catch (error) {
      show(error.message, "error");
    }
  }

  async function handleStatus(newStatus) {
    try {
      await api.post(`/api/campaigns/${campaignId}/status`, {
        new_status: newStatus,
        reason: `Alteração para ${newStatus}`,
      });
      show(`Status alterado para ${newStatus}`);
      load();
    } catch (error) {
      show(error.message, "error");
    }
  }

  return (
    <Layout title={`Preparation - ${campaign.campaign_name}`}>
      <Toast toast={toast} />
      <form className="card form-grid" onSubmit={handleSave}>
        <div className="full-width toolbar">
          <button type="button" className="btn btn-secondary" onClick={() => setEditMode(!editMode)}>
            {editMode ? "Cancelar edição" : "Editar"}
          </button>
          <Link className="btn" to={`/campaigns/${campaignId}/segmentation`}>Ir para segmentação</Link>
          <button type="button" className="btn btn-danger" onClick={() => setConfirmDelete(true)}>Excluir</button>
          {allowedTransitions(campaign.status).map((status) => (
            <button key={status} type="button" className="btn btn-secondary" onClick={() => handleStatus(status)}>
              {status}
            </button>
          ))}
        </div>

        <FormField label="Nome">
          <input disabled={!editMode} value={campaign.campaign_name || ""} onChange={(e) => setCampaign({ ...campaign, campaign_name: e.target.value })} />
        </FormField>
        <FormField label="Tema">
          <input disabled={!editMode} value={campaign.theme || ""} onChange={(e) => setCampaign({ ...campaign, theme: e.target.value })} />
        </FormField>
        <FormField label="Objetivo">
          <input disabled={!editMode} value={campaign.objective || ""} onChange={(e) => setCampaign({ ...campaign, objective: e.target.value })} />
        </FormField>
        <FormField label="Estratégia">
          <input disabled={!editMode} value={campaign.strategy || ""} onChange={(e) => setCampaign({ ...campaign, strategy: e.target.value })} />
        </FormField>
        <FormField label="Descrição">
          <textarea disabled={!editMode} value={campaign.description || ""} onChange={(e) => setCampaign({ ...campaign, description: e.target.value })} />
        </FormField>
        <FormField label="Canal principal">
          <input disabled={!editMode} value={campaign.primary_channel || ""} onChange={(e) => setCampaign({ ...campaign, primary_channel: e.target.value })} />
        </FormField>
        <FormField label="Prioridade">
          <input disabled={!editMode} value={campaign.priority || ""} onChange={(e) => setCampaign({ ...campaign, priority: e.target.value })} />
        </FormField>
        <FormField label="Time owner">
          <input disabled={!editMode} value={campaign.owner_team || ""} onChange={(e) => setCampaign({ ...campaign, owner_team: e.target.value })} />
        </FormField>
        <FormField label="KPI alvo">
          <input disabled={!editMode} value={campaign.goal_kpi || ""} onChange={(e) => setCampaign({ ...campaign, goal_kpi: e.target.value })} />
        </FormField>
        <FormField label="Meta">
          <input disabled={!editMode} type="number" value={campaign.goal_value || 0} onChange={(e) => setCampaign({ ...campaign, goal_value: Number(e.target.value) })} />
        </FormField>
        <FormField label="Data início">
          <input disabled={!editMode} type="date" value={(campaign.start_date || "").slice(0, 10)} onChange={(e) => setCampaign({ ...campaign, start_date: e.target.value })} />
        </FormField>
        <FormField label="Data fim">
          <input disabled={!editMode} type="date" value={(campaign.end_date || "").slice(0, 10)} onChange={(e) => setCampaign({ ...campaign, end_date: e.target.value })} />
        </FormField>

        <div className="full-width"><h3>Briefing</h3></div>
        <FormField label="Desafio">
          <textarea disabled={!editMode} value={campaign.challenge || ""} onChange={(e) => setCampaign({ ...campaign, challenge: e.target.value })} />
        </FormField>
        <FormField label="Resultado esperado">
          <textarea disabled={!editMode} value={campaign.target_business_outcome || ""} onChange={(e) => setCampaign({ ...campaign, target_business_outcome: e.target.value })} />
        </FormField>
        <FormField label="Restrições">
          <textarea disabled={!editMode} value={campaign.constraints || ""} onChange={(e) => setCampaign({ ...campaign, constraints: e.target.value })} />
        </FormField>
        <FormField label="Regras de negócio">
          <textarea disabled={!editMode} value={campaign.business_rules || ""} onChange={(e) => setCampaign({ ...campaign, business_rules: e.target.value })} />
        </FormField>
        <FormField label="Observações">
          <textarea disabled={!editMode} value={campaign.notes || ""} onChange={(e) => setCampaign({ ...campaign, notes: e.target.value })} />
        </FormField>

        {editMode && (
          <div className="full-width form-actions">
            <button type="submit" className="btn">Salvar alterações</button>
          </div>
        )}
      </form>

      <ConfirmModal
        open={confirmDelete}
        title="Excluir campanha"
        text="Deseja excluir a campanha?"
        onConfirm={handleDelete}
        onCancel={() => setConfirmDelete(false)}
      />
    </Layout>
  );
}

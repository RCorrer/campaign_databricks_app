import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Layout from "../components/Layout";
import FormField from "../components/FormField";
import Toast from "../components/Toast";
import { useToast } from "../hooks/useToast";
import { api } from "../api/client";

const initialCampaign = {
  name: "",
  theme: "CARTOES",
  objective: "",
  strategy: "",
  description: "",
  primary_channel: "Email",
  priority: "ALTA",
  owner_team: "CRM",
  goal_kpi: "CONVERSAO",
  goal_value: 100,
  start_date: "",
  end_date: "",
  periodicity: "MENSAL",
  max_impacts_month: 1,
  control_group_enabled: false,
};

const initialBriefing = {
  challenge: "",
  target_business_outcome: "",
  channels: ["Email"],
  constraints: "",
  business_rules: "",
  notes: "",
};

export default function CampaignPreparationCreatePage() {
  const [campaign, setCampaign] = useState(initialCampaign);
  const [briefing, setBriefing] = useState(initialBriefing);
  const navigate = useNavigate();
  const { toast, show } = useToast();

  async function handleSubmit(event) {
    event.preventDefault();
    try {
      const created = await api.post("/api/campaigns", campaign);
      await api.put(`/api/campaigns/${created.campaign_id}/briefing`, briefing);
      show("Campanha criada com sucesso");
      setTimeout(() => navigate(`/campaigns/${created.campaign_id}/preparation`), 700);
    } catch (error) {
      show(error.message, "error");
    }
  }

  return (
    <Layout title="Nova campanha - Preparation">
      <Toast toast={toast} />
      <form className="card form-grid" onSubmit={handleSubmit}>
        <FormField label="Nome">
          <input value={campaign.name} onChange={(e) => setCampaign({ ...campaign, name: e.target.value })} required />
        </FormField>
        <FormField label="Tema">
          <input value={campaign.theme} onChange={(e) => setCampaign({ ...campaign, theme: e.target.value })} required />
        </FormField>
        <FormField label="Objetivo">
          <input value={campaign.objective} onChange={(e) => setCampaign({ ...campaign, objective: e.target.value })} required />
        </FormField>
        <FormField label="Estratégia">
          <input value={campaign.strategy} onChange={(e) => setCampaign({ ...campaign, strategy: e.target.value })} required />
        </FormField>
        <FormField label="Descrição">
          <textarea value={campaign.description} onChange={(e) => setCampaign({ ...campaign, description: e.target.value })} />
        </FormField>
        <FormField label="Canal principal">
          <input value={campaign.primary_channel} onChange={(e) => setCampaign({ ...campaign, primary_channel: e.target.value })} required />
        </FormField>
        <FormField label="Prioridade">
          <input value={campaign.priority} onChange={(e) => setCampaign({ ...campaign, priority: e.target.value })} required />
        </FormField>
        <FormField label="Time owner">
          <input value={campaign.owner_team} onChange={(e) => setCampaign({ ...campaign, owner_team: e.target.value })} />
        </FormField>
        <FormField label="KPI alvo">
          <input value={campaign.goal_kpi} onChange={(e) => setCampaign({ ...campaign, goal_kpi: e.target.value })} />
        </FormField>
        <FormField label="Meta">
          <input type="number" value={campaign.goal_value} onChange={(e) => setCampaign({ ...campaign, goal_value: Number(e.target.value) })} />
        </FormField>
        <FormField label="Data início">
          <input type="date" value={campaign.start_date} onChange={(e) => setCampaign({ ...campaign, start_date: e.target.value })} required />
        </FormField>
        <FormField label="Data fim">
          <input type="date" value={campaign.end_date} onChange={(e) => setCampaign({ ...campaign, end_date: e.target.value })} required />
        </FormField>

        <div className="full-width"><h3>Briefing</h3></div>
        <FormField label="Desafio">
          <textarea value={briefing.challenge} onChange={(e) => setBriefing({ ...briefing, challenge: e.target.value })} required />
        </FormField>
        <FormField label="Resultado esperado">
          <textarea value={briefing.target_business_outcome} onChange={(e) => setBriefing({ ...briefing, target_business_outcome: e.target.value })} required />
        </FormField>
        <FormField label="Restrições">
          <textarea value={briefing.constraints} onChange={(e) => setBriefing({ ...briefing, constraints: e.target.value })} />
        </FormField>
        <FormField label="Regras de negócio">
          <textarea value={briefing.business_rules} onChange={(e) => setBriefing({ ...briefing, business_rules: e.target.value })} />
        </FormField>
        <FormField label="Observações">
          <textarea value={briefing.notes} onChange={(e) => setBriefing({ ...briefing, notes: e.target.value })} />
        </FormField>

        <div className="full-width form-actions">
          <button className="btn" type="submit">Salvar e seguir</button>
        </div>
      </form>
    </Layout>
  );
}

import { useEffect, useState } from "react";
import Layout from "../components/Layout";
import FilterBar from "../components/FilterBar";
import CampaignCard from "../components/CampaignCard";
import ConfirmModal from "../components/ConfirmModal";
import Toast from "../components/Toast";
import { api } from "../api/client";
import { useToast } from "../hooks/useToast";

export default function DashboardPage() {
  const [campaigns, setCampaigns] = useState([]);
  const [filters, setFilters] = useState({ search: "", status: "", theme: "" });
  const [campaignToDelete, setCampaignToDelete] = useState(null);
  const { toast, show } = useToast();

  async function loadCampaigns() {
    const params = new URLSearchParams();
    if (filters.search) params.set("search", filters.search);
    if (filters.status) params.set("status", filters.status);
    if (filters.theme) params.set("theme", filters.theme);
    const data = await api.get(`/api/dashboard/campaigns?${params.toString()}`);
    setCampaigns(data);
  }

  useEffect(() => {
    loadCampaigns().catch((error) => show(error.message, "error"));
  }, []);

  async function handleDelete() {
    if (!campaignToDelete) return;
    await api.del(`/api/campaigns/${campaignToDelete.campaign_id}`);
    show("Campanha excluída com sucesso");
    setCampaignToDelete(null);
    loadCampaigns().catch((error) => show(error.message, "error"));
  }

  async function handleStatusChange(campaign, newStatus) {
    try {
      await api.post(`/api/campaigns/${campaign.campaign_id}/status`, {
        new_status: newStatus,
        reason: `Mudança rápida via dashboard para ${newStatus}`,
      });
      show(`Status alterado para ${newStatus}`);
      loadCampaigns();
    } catch (error) {
      show(error.message, "error");
    }
  }

  return (
    <Layout title="Campanhas">
      <Toast toast={toast} />
      <FilterBar filters={filters} setFilters={setFilters} onReload={() => loadCampaigns().catch((error) => show(error.message, "error"))} />
      <div className="campaign-grid">
        {campaigns.map((campaign) => (
          <CampaignCard
            key={campaign.campaign_id}
            campaign={campaign}
            onDelete={setCampaignToDelete}
            onStatusChange={handleStatusChange}
          />
        ))}
      </div>
      <ConfirmModal
        open={Boolean(campaignToDelete)}
        title="Excluir campanha"
        text={`Deseja excluir a campanha "${campaignToDelete?.campaign_name}"?`}
        onConfirm={handleDelete}
        onCancel={() => setCampaignToDelete(null)}
      />
    </Layout>
  );
}

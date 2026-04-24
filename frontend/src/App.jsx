import { Routes, Route } from "react-router-dom";
import DashboardPage from "./pages/DashboardPage";
import CampaignPreparationCreatePage from "./pages/CampaignPreparationCreatePage";
import CampaignPreparationDetailPage from "./pages/CampaignPreparationDetailPage";
import CampaignSegmentationPage from "./pages/CampaignSegmentationPage";
import CampaignActivationPage from "./pages/CampaignActivationPage";

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<DashboardPage />} />
      <Route path="/campaigns/new/preparation" element={<CampaignPreparationCreatePage />} />
      <Route path="/campaigns/:campaignId/preparation" element={<CampaignPreparationDetailPage />} />
      <Route path="/campaigns/:campaignId/segmentation" element={<CampaignSegmentationPage />} />
      <Route path="/campaigns/:campaignId/activation" element={<CampaignActivationPage />} />
    </Routes>
  );
}

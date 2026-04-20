import { Navigate, Route, Routes, useParams } from 'react-router-dom'
import { useEffect, useState } from 'react'
import Layout from './components/Layout'
import DashboardPage from './pages/DashboardPage'
import PreparationPage from './pages/PreparationPage'
import SegmentationPage from './pages/SegmentationPage'
import ActivationPage from './pages/ActivationPage'
import FlowPage from './pages/FlowPage'
import { apiGet, apiSend } from './lib/api'

function CampaignRoute({ campaigns, topics, page }) {
  const { campaignId } = useParams()
  const campaign = campaigns.find((item) => item.campaign_id === campaignId)

  if (!campaign) {
    return <Navigate to="/" replace />
  }

  if (page === 'preparation') {
    return <PreparationPage campaign={campaign} />
  }

  if (page === 'segmentation') {
    return <SegmentationPage campaign={campaign} topics={topics} />
  }

  return <ActivationPage campaign={campaign} />
}

export default function App() {
  const [campaigns, setCampaigns] = useState([])
  const [topics, setTopics] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    bootstrap()
  }, [])

  async function bootstrap() {
    try {
      setLoading(true)
      let list = await apiGet('/api/campaigns')
      if (!list.length) {
        await apiSend('/api/demo/bootstrap', 'POST')
        list = await apiGet('/api/campaigns')
      }
      const topicData = await apiGet('/api/catalog/topics')
      setCampaigns(list)
      setTopics(topicData.topics || [])
    } catch (bootstrapError) {
      setError('Não foi possível carregar a aplicação.')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="loading-screen">Carregando aplicação...</div>
  }

  if (error) {
    return <div className="loading-screen">{error}</div>
  }

  return (
    <Layout>
      <Routes>
        <Route path="/" element={<DashboardPage campaigns={campaigns} />} />
        <Route path="/flow" element={<FlowPage />} />
        <Route path="/campaigns/:campaignId/preparation" element={<CampaignRoute campaigns={campaigns} topics={topics} page="preparation" />} />
        <Route path="/campaigns/:campaignId/segmentation" element={<CampaignRoute campaigns={campaigns} topics={topics} page="segmentation" />} />
        <Route path="/campaigns/:campaignId/activation" element={<CampaignRoute campaigns={campaigns} topics={topics} page="activation" />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  )
}

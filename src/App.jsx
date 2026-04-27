import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import CampaignForm from './pages/CampaignForm'
import Segmentation from './pages/Segmentation'
import Header from './components/Header'

export default function App() {
  return (
    <Router>
      <Header />
      <div style={{ display: 'flex' }}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/campaign/new" element={<CampaignForm />} />
          <Route path="/campaign/:id" element={<CampaignForm />} />
          <Route path="/segmentacao/:id" element={<Segmentation />} />
        </Routes>
      </div>
    </Router>
  )
}

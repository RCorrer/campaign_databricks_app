import { Route, Routes } from 'react-router-dom'
import PainelPage from './pages/PainelPage.jsx'
import FluxoPage from './pages/FluxoPage.jsx'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<PainelPage />} />
      <Route path="/campanhas/:idCampanha/*" element={<FluxoPage />} />
    </Routes>
  )
}

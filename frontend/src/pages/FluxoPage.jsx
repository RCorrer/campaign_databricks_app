import { useEffect, useState } from 'react'
import { Link, Route, Routes, useParams } from 'react-router-dom'
import Layout from '../components/Layout.jsx'
import Toast from '../components/Toast.jsx'
import PreparacaoPage from './PreparacaoPage.jsx'
import SegmentacaoPage from './SegmentacaoPage.jsx'
import AtivacaoPage from './AtivacaoPage.jsx'
import { api } from '../api/cliente.js'
import { useToast } from '../hooks/useToast.js'

export default function FluxoPage() {
  const { idCampanha } = useParams()
  const [campanha, setCampanha] = useState(null)
  const { toast, show } = useToast()

  async function carregar() {
    const dados = await api.get(`/api/campanhas/${idCampanha}`)
    setCampanha(dados)
  }

  useEffect(() => { carregar().catch((erro) => show(erro.message, 'error')) }, [idCampanha])

  if (!campanha) return <Layout><p>Carregando...</p></Layout>

  return (
    <Layout>
      <Toast toast={toast} />
      <section className="page-header compact">
        <div>
          <Link to="/" className="breadcrumb">Campanhas</Link>
          <h1>{campanha.nome}</h1>
          <p>{campanha.objetivo}</p>
        </div>
        <span className="status-pill">{campanha.rotulo_status}</span>
      </section>
      <nav className="flow-tabs">
        <Link to="preparacao">Preparação</Link>
        <Link to="segmentacao">Segmentação</Link>
        <Link to="ativacao">Ativação</Link>
      </nav>
      <Routes>
        <Route path="/" element={<PreparacaoPage campanha={campanha} aoSalvar={carregar} notificar={show} />} />
        <Route path="preparacao" element={<PreparacaoPage campanha={campanha} aoSalvar={carregar} notificar={show} />} />
        <Route path="segmentacao" element={<SegmentacaoPage campanha={campanha} aoSalvar={carregar} notificar={show} />} />
        <Route path="ativacao" element={<AtivacaoPage campanha={campanha} aoSalvar={carregar} notificar={show} />} />
      </Routes>
    </Layout>
  )
}

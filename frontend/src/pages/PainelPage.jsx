import { useEffect, useState } from 'react'
import Layout from '../components/Layout.jsx'
import CampaignCard from '../components/CampaignCard.jsx'
import Toast from '../components/Toast.jsx'
import { api } from '../api/cliente.js'
import { useToast } from '../hooks/useToast.js'

export default function PainelPage() {
  const [campanhas, setCampanhas] = useState([])
  const [nova, setNova] = useState({ nome: '', tema: '', objetivo: '', estrategia: '', descricao: '', data_inicio: '', data_fim: '' })
  const { toast, show } = useToast()

  async function carregar() {
    const dados = await api.get('/api/campanhas')
    setCampanhas(dados)
  }

  useEffect(() => { carregar().catch((erro) => show(erro.message, 'error')) }, [])

  async function criarCampanha(evento) {
    evento.preventDefault()
    await api.post('/api/campanhas', {
      nome: nova.nome,
      tema: nova.tema,
      objetivo: nova.objetivo,
      estrategia: nova.estrategia,
      descricao: nova.descricao,
      periodicidade: 'Pontual',
      data_inicio: nova.data_inicio || null,
      data_fim: nova.data_fim || null,
      maximo_impactos_mes: 1,
      grupo_controle_habilitado: false,
    })
    setNova({ nome: '', tema: '', objetivo: '', estrategia: '', descricao: '', data_inicio: '', data_fim: '' })
    show('Campanha criada com sucesso')
    carregar()
  }

  async function excluir(campanha) {
    if (!confirm(`Excluir a campanha ${campanha.nome}?`)) return
    await api.del(`/api/campanhas/${campanha.id_campanha}`)
    show('Campanha excluída com sucesso')
    carregar()
  }

  async function alterarStatus(campanha, novoStatus) {
    await api.post(`/api/campanhas/${campanha.id_campanha}/status`, { novo_status: novoStatus, motivo: `Mudança rápida para ${novoStatus}` })
    show(`Status alterado para ${novoStatus}`)
    carregar()
  }

  return (
    <Layout>
      <Toast toast={toast} />
      <section className="page-header">
        <div>
          <span className="eyebrow">Painel</span>
          <h1>Campanhas</h1>
          <p>Gerencie campanhas, briefing, segmentação e ativação no Databricks.</p>
        </div>
      </section>

      <form className="card form-grid" onSubmit={criarCampanha}>
        <input placeholder="Nome" value={nova.nome} onChange={(e) => setNova({ ...nova, nome: e.target.value })} required />
        <input placeholder="Tema" value={nova.tema} onChange={(e) => setNova({ ...nova, tema: e.target.value })} />
        <input placeholder="Objetivo" value={nova.objetivo} onChange={(e) => setNova({ ...nova, objetivo: e.target.value })} />
        <input placeholder="Estratégia" value={nova.estrategia} onChange={(e) => setNova({ ...nova, estrategia: e.target.value })} />
        <input placeholder="Data início" type="date" value={nova.data_inicio} onChange={(e) => setNova({ ...nova, data_inicio: e.target.value })} />
        <input placeholder="Data fim" type="date" value={nova.data_fim} onChange={(e) => setNova({ ...nova, data_fim: e.target.value })} />
        <textarea placeholder="Descrição" value={nova.descricao} onChange={(e) => setNova({ ...nova, descricao: e.target.value })} />
        <button className="btn primary" type="submit">Criar campanha</button>
      </form>

      <div className="cards-grid">
        {campanhas.map((campanha) => (
          <CampaignCard key={campanha.id_campanha} campanha={campanha} onDelete={excluir} onStatusChange={alterarStatus} />
        ))}
      </div>
    </Layout>
  )
}

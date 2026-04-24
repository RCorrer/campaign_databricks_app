import { useState } from 'react'
import { api } from '../api/cliente.js'

export default function AtivacaoPage({ campanha, aoSalvar, notificar }) {
  const ativacao = campanha.ativacao || {}
  const [form, setForm] = useState({
    modo_materializacao: ativacao.modo_materializacao || 'TABLE',
    modo_execucao: 'MANUAL',
    data_inicio_vigencia: ativacao.data_inicio_vigencia || campanha.data_inicio || '',
    data_fim_vigencia: ativacao.data_fim_vigencia || campanha.data_fim || '',
  })

  async function ativar(evento) {
    evento.preventDefault()
    await api.post(`/api/campanhas/${campanha.id_campanha}/ativacao`, form)
    notificar('Campanha ativada com sucesso')
    aoSalvar()
  }

  return (
    <section className="card detail-card">
      <span className="eyebrow">Etapa 3</span>
      <h2>Ativação</h2>
      <p>Materialize o público final da campanha no schema de execução.</p>
      <form className="stack" onSubmit={ativar}>
        <label>Modo de materialização
          <select value={form.modo_materializacao} onChange={(e) => setForm({ ...form, modo_materializacao: e.target.value })}>
            <option value="TABLE">Tabela</option>
            <option value="VIEW">View</option>
          </select>
        </label>
        <label>Data início vigência<input type="date" value={form.data_inicio_vigencia || ''} onChange={(e) => setForm({ ...form, data_inicio_vigencia: e.target.value })} /></label>
        <label>Data fim vigência<input type="date" value={form.data_fim_vigencia || ''} onChange={(e) => setForm({ ...form, data_fim_vigencia: e.target.value })} /></label>
        <button className="btn primary" type="submit">Ativar campanha</button>
      </form>
      {ativacao.objeto_ativacao && <p className="metric">Objeto gerado: {ativacao.objeto_ativacao}</p>}
    </section>
  )
}

import { useState } from 'react'
import { api } from '../api/cliente.js'

export default function PreparacaoPage({ campanha, aoSalvar, notificar }) {
  const briefing = campanha.briefing || {}
  const [form, setForm] = useState({
    desafio: briefing.desafio || '',
    resultado_negocio_esperado: briefing.resultado_negocio_esperado || '',
    canais: (briefing.canais || []).join(', '),
    restricoes: (briefing.restricoes || []).join(', '),
    regras_negocio: (briefing.regras_negocio || []).join(', '),
    observacoes: briefing.observacoes || '',
  })

  async function salvar(evento) {
    evento.preventDefault()
    await api.put(`/api/campanhas/${campanha.id_campanha}/briefing`, {
      desafio: form.desafio,
      resultado_negocio_esperado: form.resultado_negocio_esperado,
      canais: separar(form.canais),
      restricoes: separar(form.restricoes),
      regras_negocio: separar(form.regras_negocio),
      observacoes: form.observacoes,
    })
    notificar('Briefing salvo com sucesso')
    aoSalvar()
  }

  return (
    <section className="card detail-card">
      <span className="eyebrow">Etapa 1</span>
      <h2>Preparação</h2>
      <p>Fase inicial onde o briefing é definido e refinado com objetivos, restrições e canais.</p>
      <form className="stack" onSubmit={salvar}>
        <label>Desafio<textarea value={form.desafio} onChange={(e) => setForm({ ...form, desafio: e.target.value })} /></label>
        <label>Resultado esperado<textarea value={form.resultado_negocio_esperado} onChange={(e) => setForm({ ...form, resultado_negocio_esperado: e.target.value })} /></label>
        <label>Canais<input value={form.canais} onChange={(e) => setForm({ ...form, canais: e.target.value })} /></label>
        <label>Restrições<input value={form.restricoes} onChange={(e) => setForm({ ...form, restricoes: e.target.value })} /></label>
        <label>Regras de negócio<input value={form.regras_negocio} onChange={(e) => setForm({ ...form, regras_negocio: e.target.value })} /></label>
        <label>Observações<textarea value={form.observacoes} onChange={(e) => setForm({ ...form, observacoes: e.target.value })} /></label>
        <button className="btn primary" type="submit">Salvar briefing</button>
      </form>
    </section>
  )
}

function separar(texto) {
  return texto.split(',').map((item) => item.trim()).filter(Boolean)
}

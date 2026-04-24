import { useEffect, useState } from 'react'
import { api } from '../api/cliente.js'

export default function SegmentacaoPage({ campanha, aoSalvar, notificar }) {
  const segmentacao = campanha.segmentacao || {}
  const [catalogo, setCatalogo] = useState({ publicos_iniciais: [] })
  const [form, setForm] = useState({
    codigo_publico_inicial: segmentacao.codigo_publico_inicial || 'base_clientes',
    view_publico_inicial: segmentacao.view_publico_inicial || 'main.fontes_campanha.vw_publico_base_clientes',
    idade_minima: '',
    renda_minima: '',
  })

  useEffect(() => {
    api.get('/api/catalogo/construtor-segmentacao').then(setCatalogo).catch(() => {})
  }, [])

  function trocarPublico(codigo) {
    const item = (catalogo.publicos_iniciais || []).find((p) => p.codigo === codigo)
    setForm({ ...form, codigo_publico_inicial: codigo, view_publico_inicial: item?.view || form.view_publico_inicial })
  }

  async function salvar(evento) {
    evento.preventDefault()
    const condicoes = []
    if (form.idade_minima) condicoes.push({ campo: 'idade', operador: 'MAIOR_IGUAL', valor: Number(form.idade_minima), conector_logico: 'AND' })
    if (form.renda_minima) condicoes.push({ campo: 'renda_mensal', operador: 'MAIOR_IGUAL', valor: Number(form.renda_minima), conector_logico: 'AND' })
    await api.put(`/api/campanhas/${campanha.id_campanha}/segmentacao`, {
      codigo_publico_inicial: form.codigo_publico_inicial,
      view_publico_inicial: form.view_publico_inicial,
      grupos_inclusao_nativa: condicoes.length ? [{ nome: 'Filtros nativos', condicoes }] : [],
      grupos_exclusao_nativa: [],
      grupos_inclusao: [],
      grupos_exclusao: [],
      observacao_versao: 'Segmentação salva pelo app',
    })
    notificar('Segmentação salva com sucesso')
    aoSalvar()
  }

  return (
    <section className="card detail-card">
      <span className="eyebrow">Etapa 2</span>
      <h2>Segmentação</h2>
      <p>Escolha um público inicial e aplique filtros no-code para estimar a audiência.</p>
      <form className="stack" onSubmit={salvar}>
        <label>Público inicial
          <select value={form.codigo_publico_inicial} onChange={(e) => trocarPublico(e.target.value)}>
            {(catalogo.publicos_iniciais || []).map((p) => <option key={p.codigo} value={p.codigo}>{p.nome}</option>)}
          </select>
        </label>
        <label>Idade mínima<input type="number" value={form.idade_minima} onChange={(e) => setForm({ ...form, idade_minima: e.target.value })} /></label>
        <label>Renda mínima<input type="number" value={form.renda_minima} onChange={(e) => setForm({ ...form, renda_minima: e.target.value })} /></label>
        <button className="btn primary" type="submit">Salvar segmentação</button>
      </form>
      {segmentacao.sql_previa && <pre className="sql-box">{segmentacao.sql_previa}</pre>}
      {segmentacao.publico_estimado !== undefined && <p className="metric">Público estimado: {segmentacao.publico_estimado}</p>}
    </section>
  )
}

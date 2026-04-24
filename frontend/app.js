const state = {
  campaigns: [],
  builderCatalog: null,
  currentCampaign: null,
  preparationEditMode: false,
}

const statusClass = {
  PREPARACAO: 'tag-blue',
  SEGMENTACAO: 'tag-yellow',
  ATIVACAO: 'tag-yellow',
  ATIVO: 'tag-green',
  PAUSADO: 'tag-red',
  CONCLUIDO: 'tag-green',
  ENCERRADO: 'tag-red',
  CANCELADO: 'tag-red',
}

const statusLabel = {
  PREPARACAO: 'Preparação',
  SEGMENTACAO: 'Segmentação',
  ATIVACAO: 'Ativação',
  ATIVO: 'Ativo',
  PAUSADO: 'Pausado',
  CONCLUIDO: 'Concluído',
  ENCERRADO: 'Encerrado',
  CANCELADO: 'Cancelado',
}

const statusActionLabel = {
  PREPARACAO: 'Voltar para preparação',
  SEGMENTACAO: 'Mover para segmentação',
  ATIVACAO: 'Mover para ativação',
  ATIVO: 'Ativar',
  PAUSADO: 'Pausar',
  CONCLUIDO: 'Concluir',
  ENCERRADO: 'Encerrar',
  CANCELADO: 'Cancelar',
}

const app = document.getElementById('app')

function pathParts() {
  return window.location.pathname.split('/').filter(Boolean)
}

function setFlash(message, type = 'success') {
  sessionStorage.setItem('flash', JSON.stringify({ message, type }))
}

function consumeFlash() {
  const raw = sessionStorage.getItem('flash')
  if (!raw) return ''
  sessionStorage.removeItem('flash')
  try {
    const flash = JSON.parse(raw)
    return `<div class="toast toast-${flash.type}">${escapeHtml(flash.message)}</div>`
  } catch {
    return ''
  }
}

function navigate(path, flash = null) {
  if (flash) setFlash(flash.message, flash.type)
  history.pushState({}, '', path)
  render()
}

window.addEventListener('popstate', render)

document.addEventListener('click', (event) => {
  const link = event.target.closest('[data-link]')
  if (!link) return
  event.preventDefault()
  navigate(link.getAttribute('href'))
})

async function api(url, options = {}) {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  })
  if (!response.ok) {
    let message = 'Erro na requisição'
    try {
      const json = await response.json()
      message = json.detail || json.message || message
    } catch {
      const text = await response.text()
      message = text || message
    }
    throw new Error(message)
  }
  if (response.status === 204) return null
  return response.json()
}

function shell(content, active = '') {
  const flash = consumeFlash()
  return `
    <div class="layout">
      <aside class="sidebar">
        <div class="brand">Campaign Orchestrator</div>
        <div class="brand-sub">CRM no-code em Databricks Apps</div>
        <nav class="nav">
          <a href="/" data-link class="${active === 'dashboard' ? 'active' : ''}">Campanhas</a>
          <a href="/campaigns/new/preparation" data-link class="${active === 'new' ? 'active' : ''}">Nova campanha</a>
        </nav>
      </aside>
      <main class="main">${flash}${content}</main>
    </div>
  `
}

function metricCard(label, value) {
  return `<div class="card kpi"><strong>${value}</strong><div>${label}</div></div>`
}

function campaignSteps(campaignId, current) {
  if (!campaignId || campaignId === 'new') return ''
  const items = [
    ['Preparação', `/campaigns/${campaignId}/preparation`],
    ['Segmentação', `/campaigns/${campaignId}/segmentation`],
    ['Ativação', `/campaigns/${campaignId}/activation`],
  ]
  return `<div class="steps">${items.map(([label, href]) => `<a class="step ${current === label ? 'active' : ''}" href="${href}" data-link>${label}</a>`).join('')}</div>`
}

async function ensureBootstrap() {
  state.campaigns = await api('/api/campaigns')
}

function campaignCard(campaign) {
  const transitions = (campaign.allowed_transitions || []).slice(0, 2)
  return `
    <article class="card campaign-card">
      <div class="campaign-card-top">
        <div>
          <div class="campaign-card-title">${escapeHtml(campaign.name)}</div>
          <div class="small">${escapeHtml(campaign.theme || 'Sem tema')} · versão ${campaign.version}</div>
        </div>
        <span class="tag ${statusClass[campaign.status] || 'tag-blue'}">${escapeHtml(campaign.status_label || campaign.status)}</span>
      </div>
      <p class="campaign-card-text">${escapeHtml(campaign.objective || campaign.description || 'Sem objetivo informado')}</p>
      <div class="campaign-card-meta">
        <span><strong>Início:</strong> ${escapeHtml(campaign.start_date || '-')}</span>
        <span><strong>Fim:</strong> ${escapeHtml(campaign.end_date || '-')}</span>
      </div>
      <div class="campaign-card-actions">
        <a href="/campaigns/${campaign.campaign_id}/preparation" data-link><button class="primary">Abrir</button></a>
        ${transitions.map(status => `<button class="ghost" data-status-action="${campaign.campaign_id}|${status}">${escapeHtml(statusActionLabel[status] || statusLabel[status] || status)}</button>`).join('')}
        <button class="danger" data-delete-campaign="${campaign.campaign_id}">Excluir</button>
      </div>
    </article>
  `
}

async function dashboardPage() {
  await ensureBootstrap()
  const q = new URLSearchParams(window.location.search)
  const term = (q.get('q') || '').toLowerCase()
  const status = q.get('status') || ''
  const filtered = state.campaigns.filter((campaign) => {
    const matchesText = !term || campaign.name.toLowerCase().includes(term) || (campaign.objective || '').toLowerCase().includes(term)
    const matchesStatus = !status || campaign.status === status
    return matchesText && matchesStatus
  })
  const counts = {
    total: state.campaigns.length,
    active: state.campaigns.filter((c) => c.status === 'ATIVO').length,
    building: state.campaigns.filter((c) => ['PREPARACAO', 'SEGMENTACAO', 'ATIVACAO'].includes(c.status)).length,
  }
  app.innerHTML = shell(`
    <div class="header">
      <div>
        <h1 class="title">Campanhas</h1>
        <p class="subtitle">Resumo em cards, ações rápidas e navegação direta por campanha.</p>
      </div>
      <div><a href="/campaigns/new/preparation" data-link><button class="primary">Nova campanha</button></a></div>
    </div>
    <div class="grid grid-3">
      ${metricCard('Total de campanhas', counts.total)}
      ${metricCard('Campanhas ativas', counts.active)}
      ${metricCard('Em construção', counts.building)}
    </div>
    <div class="card" style="margin-top:16px;">
      <form class="toolbar" id="filter-form">
        <input class="input" style="max-width:260px;" name="q" placeholder="Buscar campanha" value="${escapeHtml(q.get('q') || '')}" />
        <select class="select" style="max-width:220px;" name="status">
          <option value="">Todos os status</option>
          ${['PREPARACAO','SEGMENTACAO','ATIVACAO','ATIVO','PAUSADO','CONCLUIDO','ENCERRADO','CANCELADO'].map(s => `<option value="${s}" ${status===s?'selected':''}>${statusLabel[s]}</option>`).join('')}
        </select>
        <button class="primary" type="submit">Filtrar</button>
      </form>
      <div class="campaign-cards">
        ${filtered.length ? filtered.map(campaignCard).join('') : '<div class="empty">Nenhuma campanha encontrada.</div>'}
      </div>
    </div>
  `, 'dashboard')
  document.getElementById('filter-form').onsubmit = (e) => {
    e.preventDefault()
    const form = new FormData(e.target)
    const params = new URLSearchParams()
    if (form.get('q')) params.set('q', form.get('q'))
    if (form.get('status')) params.set('status', form.get('status'))
    navigate(`/?${params.toString()}`)
  }
  bindCampaignActions()
}

function getPreparationStatusActions(campaign) {
  return (campaign.allowed_transitions || []).map(status => ({ status, label: statusActionLabel[status] || statusLabel[status] || status }))
}

async function preparationPage(campaignId) {
  state.preparationEditMode = campaignId === 'new'
  if (campaignId !== 'new') {
    state.currentCampaign = await api(`/api/campaigns/${campaignId}`)
  } else {
    state.currentCampaign = null
  }
  const campaign = state.currentCampaign
  const readOnly = campaignId !== 'new' && !state.preparationEditMode
  app.innerHTML = shell(`
    ${campaignSteps(campaignId, 'Preparação')}
    <div class="header">
      <div>
        <h1 class="title">Preparação</h1>
        <p class="subtitle">Defina briefing, estratégia e metadados da campanha. Depois avance para segmentação.</p>
      </div>
      ${campaign ? `<div class="header-badges"><span class="tag ${statusClass[campaign.status] || 'tag-blue'}">${escapeHtml(campaign.status_label)}</span></div>` : ''}
    </div>
    ${campaign ? `<div class="card" style="margin-bottom:16px;"><div class="toolbar compact"><a href="/campaigns/${campaignId}/segmentation" data-link><button type="button" class="primary">Ir para segmentação</button></a><button type="button" id="toggle-edit">${readOnly ? 'Editar' : 'Bloquear edição'}</button>${getPreparationStatusActions(campaign).map(action => `<button type="button" class="ghost" data-status-action="${campaignId}|${action.status}">${escapeHtml(action.label)}</button>`).join('')}<button type="button" class="danger" data-delete-campaign="${campaignId}">Excluir</button></div><div class="small">Fluxo recomendado: Preparação → Segmentação → Ativação → Ativo. Ajustes de regra podem retornar para Preparação ou Segmentação conforme o estágio.</div></div>` : ''}
    <div class="card">
      <form id="campaign-form" class="form-grid">
        <div><label>Nome</label><input class="input" name="name" value="${escapeHtml(campaign?.name || '')}" ${readOnly ? 'disabled' : ''} required /></div>
        <div><label>Tema</label><input class="input" name="theme" value="${escapeHtml(campaign?.theme || '')}" ${readOnly ? 'disabled' : ''} required /></div>
        <div class="full"><label>Objetivo</label><input class="input" name="objective" value="${escapeHtml(campaign?.objective || '')}" ${readOnly ? 'disabled' : ''} required /></div>
        <div><label>Estratégia</label><input class="input" name="strategy" value="${escapeHtml(campaign?.campaign?.strategy || '')}" ${readOnly ? 'disabled' : ''} /></div>
        <div><label>Descrição</label><input class="input" name="description" value="${escapeHtml(campaign?.campaign?.description || '')}" ${readOnly ? 'disabled' : ''} /></div>
        <div><label>Data início</label><input class="input" type="date" name="start_date" value="${escapeHtml(campaign?.start_date || '')}" ${readOnly ? 'disabled' : ''} /></div>
        <div><label>Data fim</label><input class="input" type="date" name="end_date" value="${escapeHtml(campaign?.end_date || '')}" ${readOnly ? 'disabled' : ''} /></div>
        <div class="full"><label>Desafio</label><textarea class="textarea" name="challenge" ${readOnly ? 'disabled' : ''}>${escapeHtml(campaign?.briefing?.challenge || '')}</textarea></div>
        <div class="full"><label>Resultado esperado</label><textarea class="textarea" name="target_business_outcome" ${readOnly ? 'disabled' : ''}>${escapeHtml(campaign?.briefing?.target_business_outcome || '')}</textarea></div>
        <div class="full"><label>Regras de negócio (uma por linha)</label><textarea class="textarea" name="business_rules" ${readOnly ? 'disabled' : ''}>${escapeHtml((campaign?.briefing?.business_rules || []).join('\n'))}</textarea></div>
        <div class="full"><label>Restrições (uma por linha)</label><textarea class="textarea" name="constraints" ${readOnly ? 'disabled' : ''}>${escapeHtml((campaign?.briefing?.constraints || []).join('\n'))}</textarea></div>
        <div class="full"><label>Observações</label><textarea class="textarea" name="notes" ${readOnly ? 'disabled' : ''}>${escapeHtml(campaign?.briefing?.notes || '')}</textarea></div>
        <div class="footer-actions full">
          <a href="/" data-link><button type="button" class="ghost">Voltar</button></a>
          ${readOnly ? '' : '<button type="submit" class="primary">Salvar e seguir</button>'}
        </div>
      </form>
    </div>
  `, campaignId === 'new' ? 'new' : '')

  if (campaign) {
    const toggleBtn = document.getElementById('toggle-edit')
    if (toggleBtn) {
      toggleBtn.onclick = () => {
        state.preparationEditMode = !state.preparationEditMode
        preparationPage(campaignId)
      }
    }
    bindCampaignActions()
  }

  const form = document.getElementById('campaign-form')
  if (!form || readOnly) return
  form.onsubmit = async (e) => {
    e.preventDefault()
    const formData = new FormData(e.target)
    let id = campaignId
    const campaignPayload = {
      name: formData.get('name'),
      theme: formData.get('theme'),
      objective: formData.get('objective'),
      strategy: formData.get('strategy') || 'Relacionamento',
      start_date: formData.get('start_date') || null,
      end_date: formData.get('end_date') || null,
      periodicity: 'MENSAL',
      max_impacts_month: 1,
      control_group_enabled: false,
      description: formData.get('description') || '',
    }
    if (campaignId === 'new') {
      const created = await api('/api/campaigns', {
        method: 'POST',
        body: JSON.stringify(campaignPayload),
      })
      id = created.campaign_id
    } else {
      await api(`/api/campaigns/${campaignId}`, {
        method: 'PUT',
        body: JSON.stringify(campaignPayload),
      })
    }
    await api(`/api/campaigns/${id}/briefing`, {
      method: 'PUT',
      body: JSON.stringify({
        challenge: formData.get('challenge') || '',
        target_business_outcome: formData.get('target_business_outcome') || '',
        channels: ['Email'],
        constraints: splitLines(formData.get('constraints')),
        business_rules: splitLines(formData.get('business_rules')),
        notes: formData.get('notes') || '',
      }),
    })
    state.preparationEditMode = false
    navigate(`/campaigns/${id}/preparation`, { message: campaignId === 'new' ? 'Campanha criada com sucesso.' : 'Campanha atualizada com sucesso.', type: 'success' })
  }
}

function splitLines(value) {
  return String(value || '').split('\n').map(v => v.trim()).filter(Boolean)
}

function ruleRowHtml({ native, index, themes, nativeFields, rule = {} }) {
  if (native) {
    return `<div class="rule-row native">
      <select class="select" name="field-${index}">${nativeFields.map(f => `<option value="${f.field}" ${rule.field===f.field?'selected':''}>${f.label}</option>`).join('')}</select>
      <select class="select" name="operator-${index}">${operatorOptions(rule.operator)}</select>
      <input class="input" name="value-${index}" value="${escapeHtml(formatValue(rule.value))}" placeholder="Valor" />
      <button type="button" data-remove-row="${index}">Remover</button>
    </div>`
  }
  const selectedTheme = themes.find(t => t.code === rule.theme) || themes[0] || { fields: [] }
  const themeFields = selectedTheme.fields || []
  return `<div class="rule-row">
    <select class="select" name="theme-${index}" onchange="window.__campaignThemeChange && window.__campaignThemeChange('${index}', this.value)">${themes.map(t => `<option value="${t.code}" ${rule.theme===t.code?'selected':''}>${t.label}</option>`).join('')}</select>
    <select class="select" name="field-${index}">${themeFields.map(f => `<option value="${f.field}" ${rule.field===f.field?'selected':''}>${f.label}</option>`).join('')}</select>
    <select class="select" name="operator-${index}">${operatorOptions(rule.operator)}</select>
    <input class="input" name="value-${index}" value="${escapeHtml(formatValue(rule.value))}" placeholder="Valor" />
    <button type="button" data-remove-row="${index}">Remover</button>
  </div>`
}

function operatorOptions(selected) {
  const ops = ['EQUALS','GT','GTE','LT','LTE','IN','LIKE']
  return ops.map(op => `<option value="${op}" ${selected===op?'selected':''}>${op}</option>`).join('')
}

function formatValue(value) {
  if (Array.isArray(value)) return value.join(',')
  if (value == null) return ''
  return String(value)
}

async function segmentationPage(campaignId) {
  state.currentCampaign = await api(`/api/campaigns/${campaignId}`)
  state.builderCatalog = await api('/api/catalog/segmentation-builder')
  const campaign = state.currentCampaign
  const audiences = state.builderCatalog.initial_audiences || []
  const nativeFields = state.builderCatalog.native_fields || []
  const themes = state.builderCatalog.themes || []

  app.innerHTML = shell(`
    ${campaignSteps(campaignId, 'Segmentação')}
    <div class="header"><div><h1 class="title">Segmentação</h1><p class="subtitle">Escolha o público inicial, aplique filtros nativos e cruzamentos temáticos por cpf_cnpj.</p></div></div>
    <div class="grid grid-2">
      <div class="card">
        <label>Público inicial</label>
        <select id="initial-audience" class="select">${audiences.map(a => `<option value="${a.code}" ${campaign.segmentation?.initial_audience_code===a.code?'selected':''}>${a.label}</option>`).join('')}</select>
        <div class="small" id="audience-view-label" style="margin-top:8px;"></div>
      </div>
      <div class="card">
        <strong>Resumo do modelo</strong>
        <div class="small" style="margin-top:8px;">1. Público inicial em <code>main.campaign_sources</code><br>2. Filtros nativos na própria view<br>3. Inclusões e exclusões por temas em <code>main.customer_360</code><br>4. Resultado materializado em <code>main.campaign_execution</code></div>
      </div>
    </div>
    <div class="grid" style="margin-top:16px;">
      <div class="card"><h3>Filtros nativos de inclusão</h3><div id="native-include-box" class="rule-box"></div><button id="add-native-include">Adicionar regra nativa</button></div>
      <div class="card"><h3>Filtros nativos de exclusão</h3><div id="native-exclude-box" class="rule-box"></div><button id="add-native-exclude">Adicionar regra nativa</button></div>
      <div class="card"><h3>Inclusões por tema</h3><div id="include-box" class="rule-box"></div><button id="add-include">Adicionar cruzamento temático</button></div>
      <div class="card"><h3>Exclusões por tema</h3><div id="exclude-box" class="rule-box"></div><button id="add-exclude">Adicionar cruzamento temático</button></div>
      <div class="card"><h3>Preview SQL</h3><div id="preview-sql" class="code">Salve a segmentação para gerar a prévia.</div></div>
    </div>
    <div class="footer-actions"><a href="/campaigns/${campaignId}/preparation" data-link><button type="button" class="ghost">Voltar</button></a><button id="save-segmentation" class="primary">Salvar e seguir</button></div>
  `)

  const groupsState = {
    nativeInclude: normalizeRules(campaign.segmentation?.native_include_groups, true),
    nativeExclude: normalizeRules(campaign.segmentation?.native_exclude_groups, true),
    include: normalizeRules(campaign.segmentation?.include_groups, false),
    exclude: normalizeRules(campaign.segmentation?.exclude_groups, false),
  }

  function rerenderRules() {
    renderRuleList('native-include-box', groupsState.nativeInclude, true)
    renderRuleList('native-exclude-box', groupsState.nativeExclude, true)
    renderRuleList('include-box', groupsState.include, false)
    renderRuleList('exclude-box', groupsState.exclude, false)
    const selectedAudience = audiences.find(a => a.code === document.getElementById('initial-audience').value)
    document.getElementById('audience-view-label').textContent = selectedAudience ? `View inicial: ${selectedAudience.source_view}` : ''
    document.getElementById('preview-sql').textContent = campaign.segmentation?.preview_sql || 'Salve a segmentação para gerar a prévia.'
  }

  window.__campaignThemeChange = (index, themeCode) => {
    const ruleMap = [groupsState.include, groupsState.exclude]
    ruleMap.forEach(arr => arr.forEach(rule => {
      if (String(rule.__idx) === String(index)) {
        const theme = themes.find(t => t.code === themeCode)
        rule.theme = themeCode
        rule.field = theme?.fields?.[0]?.field || ''
      }
    }))
    rerenderRules()
  }

  function renderRuleList(containerId, arr, native) {
    const container = document.getElementById(containerId)
    if (!arr.length) {
      container.innerHTML = '<div class="empty">Nenhuma regra configurada.</div>'
      return
    }
    container.innerHTML = arr.map((rule, index) => {
      rule.__idx = `${containerId}-${index}`
      return ruleRowHtml({ native, index: `${containerId}-${index}`, themes, nativeFields, rule })
    }).join('')
    container.querySelectorAll('[data-remove-row]').forEach(btn => btn.onclick = () => {
      const idx = Number(btn.getAttribute('data-remove-row').split('-').pop())
      arr.splice(idx, 1)
      rerenderRules()
    })
  }

  document.getElementById('add-native-include').onclick = () => { groupsState.nativeInclude.push({ field: nativeFields[0]?.field || 'state', operator: 'EQUALS', value: '' }); rerenderRules() }
  document.getElementById('add-native-exclude').onclick = () => { groupsState.nativeExclude.push({ field: nativeFields[0]?.field || 'state', operator: 'EQUALS', value: '' }); rerenderRules() }
  document.getElementById('add-include').onclick = () => { groupsState.include.push({ theme: themes[0]?.code || 'cartoes', field: themes[0]?.fields?.[0]?.field || '', operator: 'EQUALS', value: '' }); rerenderRules() }
  document.getElementById('add-exclude').onclick = () => { groupsState.exclude.push({ theme: themes[0]?.code || 'cartoes', field: themes[0]?.fields?.[0]?.field || '', operator: 'EQUALS', value: '' }); rerenderRules() }

  document.getElementById('save-segmentation').onclick = async () => {
    const initialAudience = document.getElementById('initial-audience').value
    const selectedAudience = audiences.find(a => a.code === initialAudience)
    const payload = {
      initial_audience_code: initialAudience,
      universe_view: selectedAudience?.source_view,
      native_include_groups: serializeRules('native-include-box', true),
      native_exclude_groups: serializeRules('native-exclude-box', true),
      include_groups: serializeRules('include-box', false),
      exclude_groups: serializeRules('exclude-box', false),
      save_as_version_note: 'versao-ui',
    }
    const result = await api(`/api/campaigns/${campaignId}/segmentation`, {
      method: 'PUT',
      body: JSON.stringify(payload),
    })
    campaign.segmentation = result.segmentation
    rerenderRules()
    navigate(`/campaigns/${campaignId}/activation`, { message: 'Segmentação salva com sucesso.', type: 'success' })
  }

  function serializeRules(containerId, native) {
    const box = document.getElementById(containerId)
    const rows = Array.from(box.querySelectorAll('.rule-row'))
    if (!rows.length) return []
    return [{
      name: native ? 'Grupo nativo' : 'Grupo temático',
      conditions: rows.map((row) => {
        const condition = {
          field: row.querySelector('[name^="field-"]').value,
          operator: row.querySelector('[name^="operator-"]').value,
          value: parseValue(row.querySelector('[name^="value-"]').value),
          source_scope: native ? 'NATIVE' : 'THEMATIC',
        }
        if (!native) {
          const themeCode = row.querySelector('[name^="theme-"]').value
          const theme = themes.find(t => t.code === themeCode)
          condition.theme = themeCode
          condition.entity = theme?.table || ''
        }
        return condition
      })
    }]
  }

  function parseValue(value) {
    if (value.includes(',')) return value.split(',').map(v => v.trim()).filter(Boolean)
    if (value === 'true') return true
    if (value === 'false') return false
    if (value !== '' && !isNaN(Number(value))) return Number(value)
    return value
  }

  rerenderRules()
}

function normalizeRules(groups) {
  return (groups || []).flatMap(g => g.conditions || [])
}

async function activationPage(campaignId) {
  const campaign = await api(`/api/campaigns/${campaignId}`)
  const activation = campaign.activation || {}
  app.innerHTML = shell(`
    ${campaignSteps(campaignId, 'Ativação')}
    <div class="header"><div><h1 class="title">Ativação</h1><p class="subtitle">Materialização da audiência final em <code>main.campaign_execution</code>.</p></div></div>
    <div class="grid grid-2">
      <div class="card">
        <form id="activation-form" class="form-grid">
          <div><label>Modo de materialização</label>
            <select class="select" name="materialization_mode">
              ${['TABLE','VIEW'].map(v => `<option value="${v}" ${activation.materialization_mode===v?'selected':''}>${v}</option>`).join('')}
            </select>
          </div>
          <div><label>Modo de execução</label>
            <select class="select" name="execution_mode">
              ${['RUN','PREVIEW'].map(v => `<option value="${v}" ${activation.execution_mode===v?'selected':''}>${v}</option>`).join('')}
            </select>
          </div>
          <div><label>Data início</label><input class="input" type="date" name="effective_start_date" value="${escapeHtml(activation.effective_start_date || campaign.start_date || '')}" /></div>
          <div><label>Data fim</label><input class="input" type="date" name="effective_end_date" value="${escapeHtml(activation.effective_end_date || campaign.end_date || '')}" /></div>
          <div class="footer-actions full"><a href="/campaigns/${campaignId}/segmentation" data-link><button type="button" class="ghost">Voltar</button></a><button class="primary" type="submit">Ativar campanha</button></div>
        </form>
      </div>
      <div class="card">
        <strong>Preview de ativação</strong>
        <div class="small" style="margin:8px 0 12px;">A audiência final contém somente os cpf_cnpj elegíveis e os metadados da execução.</div>
        <div class="code">${escapeHtml(activation.activation_sql || 'Ative a campanha para gerar o SQL final.')}</div>
      </div>
    </div>
  `)
  document.getElementById('activation-form').onsubmit = async (e) => {
    e.preventDefault()
    const form = new FormData(e.target)
    await api(`/api/campaigns/${campaignId}/activation`, {
      method: 'POST',
      body: JSON.stringify({
        materialization_mode: form.get('materialization_mode'),
        execution_mode: form.get('execution_mode'),
        effective_start_date: form.get('effective_start_date'),
        effective_end_date: form.get('effective_end_date'),
      }),
    })
    navigate(`/campaigns/${campaignId}/preparation`, { message: 'Campanha ativada com sucesso.', type: 'success' })
  }
}

function bindCampaignActions() {
  document.querySelectorAll('[data-delete-campaign]').forEach((button) => {
    button.onclick = async () => {
      const campaignId = button.getAttribute('data-delete-campaign')
      if (!window.confirm('Deseja realmente excluir a campanha? Essa ação remove metadados, histórico e audiência materializada.')) return
      await api(`/api/campaigns/${campaignId}`, { method: 'DELETE' })
      navigate('/', { message: 'Campanha excluída com sucesso.', type: 'success' })
    }
  })

  document.querySelectorAll('[data-status-action]').forEach((button) => {
    button.onclick = async () => {
      const [campaignId, newStatus] = button.getAttribute('data-status-action').split('|')
      const reason = window.prompt(`Informe o motivo para alterar o status para ${statusLabel[newStatus] || newStatus}:`, '') || ''
      await api(`/api/campaigns/${campaignId}/status`, {
        method: 'POST',
        body: JSON.stringify({ new_status: newStatus, reason }),
      })
      if (window.location.pathname.includes(`/campaigns/${campaignId}/`)) {
        navigate(`/campaigns/${campaignId}/preparation`, { message: `Status alterado para ${statusLabel[newStatus] || newStatus}.`, type: 'success' })
      } else {
        navigate('/', { message: `Status alterado para ${statusLabel[newStatus] || newStatus}.`, type: 'success' })
      }
    }
  })
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
}

async function render() {
  try {
    const parts = pathParts()
    if (parts.length === 0) return dashboardPage()
    if (parts[0] === 'campaigns' && parts[1] && parts[2] === 'preparation') return preparationPage(parts[1])
    if (parts[0] === 'campaigns' && parts[1] && parts[2] === 'segmentation') return segmentationPage(parts[1])
    if (parts[0] === 'campaigns' && parts[1] && parts[2] === 'activation') return activationPage(parts[1])
    app.innerHTML = shell(`<div class="card"><h1 class="title">Página não encontrada</h1><a href="/" data-link><button class="primary">Voltar ao início</button></a></div>`)
  } catch (error) {
    app.innerHTML = shell(`<div class="card"><h1 class="title">Erro</h1><p>${escapeHtml(error.message)}</p><a href="/" data-link><button class="primary">Voltar</button></a></div>`)
  }
}

render()

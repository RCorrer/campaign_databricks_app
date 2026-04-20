import { useEffect, useMemo, useState } from 'react'
import { apiGet, apiSend } from './lib/api'
import StageCard from './components/StageCard'

const defaultCampaign = {
  name: 'Campanha Crédito Consignado',
  objective: 'Aumentar contratação de crédito em clientes elegíveis',
  theme: 'CRÉDITO',
  strategy: 'Ciclo de Vida',
  start_date: '2026-05-01',
  end_date: '2026-05-31',
  periodicity: 'MENSAL',
  max_impacts_month: 2,
  control_group_enabled: true,
  description: 'Campanha exemplo criada a partir da arquitetura alvo'
}

const defaultBriefing = {
  challenge: 'Converter clientes já elegíveis com melhor propensão',
  target_business_outcome: 'Elevar taxa de contratação em 12%',
  channels: ['Push', 'Email'],
  constraints: ['Não impactar clientes com conta inativa'],
  business_rules: ['Aplicar elegibilidade por produto'],
  notes: 'Briefing refinado na etapa de preparação'
}

const defaultSegmentation = {
  universe_view: 'vw_universo_clientes_varejo',
  include_groups: [
    {
      name: 'Clientes elegíveis a crédito pessoal',
      conditions: [
        {
          topic: 'elegibilidade',
          entity: 'vw_elegibilidade_cliente',
          field: 'produto',
          operator: 'EQUALS',
          value: 'CREDITO_PESSOAL',
          logical_connector: 'AND'
        }
      ]
    }
  ],
  exclude_groups: [
    {
      name: 'Excluir contas inativas',
      conditions: [
        {
          topic: 'relacionamento',
          entity: 'vw_relacionamento_cliente',
          field: 'status_conta',
          operator: 'EQUALS',
          value: 'INATIVA',
          logical_connector: 'AND'
        }
      ]
    }
  ],
  save_as_version_note: 'Primeira versão de segmentação'
}

export default function App() {
  const [topics, setTopics] = useState([])
  const [campaign, setCampaign] = useState(null)
  const [selectedTab, setSelectedTab] = useState('universo')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    bootstrap()
  }, [])

  async function bootstrap() {
    try {
      setLoading(true)
      const topicData = await apiGet('/api/catalog/topics')
      setTopics(topicData.topics ?? [])

      const created = await apiSend('/api/campaigns', 'POST', defaultCampaign)
      await apiSend(`/api/campaigns/${created.campaign_id}/briefing`, 'PUT', defaultBriefing)
      await apiSend(`/api/campaigns/${created.campaign_id}/segmentation`, 'PUT', defaultSegmentation)
      const activated = await apiSend(`/api/campaigns/${created.campaign_id}/activation`, 'POST', {
        materialization_mode: 'TABLE',
        execution_mode: 'RUN',
        effective_start_date: defaultCampaign.start_date,
        effective_end_date: defaultCampaign.end_date
      })
      setCampaign(activated)
    } catch (err) {
      setError('Não foi possível montar a demonstração da campanha.')
    } finally {
      setLoading(false)
    }
  }

  const previewSql = useMemo(() => campaign?.segmentation?.preview_sql ?? '', [campaign])

  if (loading) {
    return <div className="page"><div className="hero-card"><h1>Carregando arquitetura da campanha...</h1></div></div>
  }

  if (error) {
    return <div className="page"><div className="hero-card"><h1>{error}</h1></div></div>
  }

  return (
    <div className="page">
      <header className="hero-card">
        <div>
          <p className="eyebrow">Databricks App</p>
          <h1>Campaign Orchestrator</h1>
          <p className="muted">
            Arquitetura inspirada em Salesforce Workflow + Data Cloud para preparação,
            segmentação no-code, ativação e operação de campanhas.
          </p>
        </div>
        <div className="hero-metrics">
          <div><strong>Status</strong><span>{campaign?.status}</span></div>
          <div><strong>Versão</strong><span>{campaign?.version}</span></div>
          <div><strong>Vigência</strong><span>{campaign?.start_date} até {campaign?.end_date}</span></div>
        </div>
      </header>

      <main className="grid">
        <StageCard title="1. Preparação" status="PREPARACAO -> SEGMENTACAO">
          <p><strong>Campanha:</strong> {campaign?.campaign?.name}</p>
          <p><strong>Objetivo:</strong> {campaign?.campaign?.objective}</p>
          <p><strong>Estratégia:</strong> {campaign?.campaign?.strategy}</p>
          <p><strong>Briefing refinado:</strong> {campaign?.briefing?.challenge}</p>
          <p><strong>Resultado esperado:</strong> {campaign?.briefing?.target_business_outcome}</p>
        </StageCard>

        <StageCard title="2. Segmentação no-code" status="SEGMENTACAO -> ATIVACAO">
          <div className="tabs">
            <button className={selectedTab === 'universo' ? 'tab active' : 'tab'} onClick={() => setSelectedTab('universo')}>Universo inicial</button>
            <button className={selectedTab === 'inclusao' ? 'tab active' : 'tab'} onClick={() => setSelectedTab('inclusao')}>Inclusão</button>
            <button className={selectedTab === 'exclusao' ? 'tab active' : 'tab'} onClick={() => setSelectedTab('exclusao')}>Exclusão</button>
          </div>

          {selectedTab === 'universo' && (
            <div className="panel">
              <p><strong>View base:</strong> {campaign?.segmentation?.universe_view}</p>
              <p>Essa aba representa o universo inicial da campanha, lido de um schema específico de views prontas.</p>
            </div>
          )}

          {selectedTab === 'inclusao' && (
            <div className="panel">
              {campaign?.segmentation?.include_groups?.map((group) => (
                <div key={group.name} className="rule-box">
                  <strong>{group.name}</strong>
                  {group.conditions.map((condition, index) => (
                    <p key={index}>{condition.topic} -> {condition.entity}.{condition.field} {condition.operator} {String(condition.value)}</p>
                  ))}
                </div>
              ))}
            </div>
          )}

          {selectedTab === 'exclusao' && (
            <div className="panel">
              {campaign?.segmentation?.exclude_groups?.map((group) => (
                <div key={group.name} className="rule-box">
                  <strong>{group.name}</strong>
                  {group.conditions.map((condition, index) => (
                    <p key={index}>{condition.topic} -> {condition.entity}.{condition.field} {condition.operator} {String(condition.value)}</p>
                  ))}
                </div>
              ))}
            </div>
          )}
        </StageCard>

        <StageCard title="3. Catálogo semântico" status="DE/PARA">
          <p>O sistema usa um arquivo de/para para exibir nomes amigáveis ao usuário.</p>
          <div className="topic-list">
            {topics.map((topic) => (
              <div key={topic.key} className="topic-item">
                <strong>{topic.label}</strong>
                <span>{topic.description}</span>
              </div>
            ))}
          </div>
        </StageCard>

        <StageCard title="4. Ativação" status="ATIVACAO -> ATIVO">
          <p>Na ativação, o sistema materializa a audiência final com `cpf_cnpj`, timestamp de segmentação e vigência.</p>
          <pre>{campaign?.activation?.activation_sql}</pre>
        </StageCard>

        <StageCard title="5. Preview SQL" status="AUDITÁVEL">
          <pre>{previewSql}</pre>
        </StageCard>

        <StageCard title="6. Timeline" status="LIFECYCLE">
          <div className="timeline">
            {campaign?.timeline?.map((item, index) => (
              <div key={index} className="timeline-item">
                <strong>{item.event}</strong>
                <span>{item.status}</span>
                <small>{item.timestamp}</small>
              </div>
            ))}
          </div>
        </StageCard>
      </main>
    </div>
  )
}

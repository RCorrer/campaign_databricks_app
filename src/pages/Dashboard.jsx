import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Box, Grid, Typography, CircularProgress } from '@mui/material'
import apiClient from '../api/client'
import Sidebar from '../components/Sidebar'
import CampaignCard from '../components/CampaignCard'

export default function Dashboard() {
  const [campaigns, setCampaigns] = useState([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState({
    nome: '',
    tema: '',
    segmento: '',
    canal: '',
    status: '',
    data_inicio: '',
    data_fim: '',
  })
  const navigate = useNavigate()

  useEffect(() => {
    apiClient.get('/api/campaigns')
      .then(res => setCampaigns(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const handleCardClick = (id) => navigate(`/campaign/${id}`)
  const handleNewCampaign = () => navigate('/campaign/new')

  const clearFilters = () => {
    setFilters({
      nome: '', tema: '', segmento: '', canal: '', status: '', data_inicio: '', data_fim: ''
    })
  }

  const filteredCampaigns = campaigns.filter(c => {
    const match = (field, value) => !value || (c[field] && c[field].toLowerCase().includes(value.toLowerCase()))
    const matchDate = (field, value) => {
      if (!value) return true
      const campaignDate = c[field] ? c[field].substring(0, 10) : ''
      return campaignDate === value
    }
    return match('nome', filters.nome) &&
           match('tema', filters.tema) &&
           match('segmento', filters.segmento) &&
           match('canal', filters.canal) &&
           match('status', filters.status) &&
           matchDate('data_inicio', filters.data_inicio) &&
           matchDate('data_fim', filters.data_fim)
  })

  return (
    <>
      <Sidebar filters={filters} onFilterChange={setFilters} onClear={clearFilters} onNewCampaign={handleNewCampaign} />
      <Box sx={{ flexGrow: 1, p: 3, ml: '260px', mt: '64px' }}>
        <Typography variant="h4" gutterBottom>Dashboard de Campanhas</Typography>
        {loading ? (
          <CircularProgress />
        ) : (
          <Grid container spacing={2}>
            {filteredCampaigns.map(c => (
              <Grid item key={c.id_campanha}>
                <CampaignCard campaign={c} onClick={handleCardClick} />
              </Grid>
            ))}
            {filteredCampaigns.length === 0 && (
              <Typography color="text.secondary">Nenhuma campanha encontrada.</Typography>
            )}
          </Grid>
        )}
      </Box>
    </>
  )
}

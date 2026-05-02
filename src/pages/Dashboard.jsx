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
    name: '',
    theme: '',
    status: '',
    start_date: '',
    end_date: '',
  })
  const navigate = useNavigate()

  useEffect(() => {
    apiClient.get('/api/campaigns')
      .then(res => {
        const data = Array.isArray(res.data) ? res.data : []
        setCampaigns(data)
      })
      .catch(err => {
        console.error('Erro ao buscar campanhas:', err)
        setCampaigns([])
      })
      .finally(() => setLoading(false))
  }, [])

  const handleCardClick = (id) => navigate(`/campaign/${id}`)
  const handleNewCampaign = () => navigate('/campaign/new')

  const clearFilters = () => {
    setFilters({ name: '', theme: '', status: '', start_date: '', end_date: '' })
  }

  const filteredCampaigns = Array.isArray(campaigns)
    ? campaigns.filter(c => {
        const match = (field, value) =>
          !value || (c[field] && c[field].toLowerCase().includes(value.toLowerCase()))
        const matchDate = (field, value) => {
          if (!value) return true
          const campaignDate = c[field] ? c[field].substring(0, 10) : ''
          return campaignDate === value
        }
        return (
          match('name', filters.name) &&
          match('theme', filters.theme) &&
          match('status', filters.status) &&
          matchDate('start_date', filters.start_date) &&
          matchDate('end_date', filters.end_date)
        )
      })
    : []

  return (
    <Box sx={{ display: 'flex' }}>
      <Sidebar />
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Typography variant="h4" gutterBottom>
          Dashboard de Campanhas
        </Typography>
        {loading ? (
          <CircularProgress />
        ) : (
          <Grid container spacing={2}>
            {filteredCampaigns.map(c => (
              <Grid item xs={12} sm={6} md={4} key={c.campaign_id}>
                <CampaignCard campaign={c} onClick={handleCardClick} />
              </Grid>
            ))}
            {filteredCampaigns.length === 0 && (
              <Typography variant="body1" sx={{ mt: 2 }}>
                Nenhuma campanha encontrada.
              </Typography>
            )}
          </Grid>
        )}
      </Box>
    </Box>
  )
}

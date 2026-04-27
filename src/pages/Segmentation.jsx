import { useParams } from 'react-router-dom'
import { Box, Paper, Typography, Button } from '@mui/material'
import apiClient from '../api/client'

export default function Segmentation() {
  const { id } = useParams()

  const handleGenerate = async () => {
    try {
      const res = await apiClient.post(`/api/leads/generate/${id}`)
      alert(`View de leads criada: ${res.data.message}`)
    } catch (err) {
      alert('Erro ao gerar view de segmentação')
    }
  }

  return (
    <Box sx={{ p: 3, ml: '260px', mt: '64px', width: '100%' }}>
      <Paper sx={{ p: 4 }}>
        <Typography variant="h5">Segmentação da Campanha #{id}</Typography>
        <Typography sx={{ mt: 2 }}>Aqui você poderá configurar as regras de segmentação e gerar os leads.</Typography>
        <Button variant="contained" sx={{ mt: 3 }} onClick={handleGenerate}>
          Gerar View de Leads
        </Button>
      </Paper>
    </Box>
  )
}

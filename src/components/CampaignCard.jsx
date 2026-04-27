import { Card, CardContent, Typography, Chip, CardActionArea } from '@mui/material'
import { format } from 'date-fns' // não incluso, usar alternativa simples

function formatDate(dateStr) {
  if (!dateStr) return ''
  const dt = new Date(dateStr)
  return dt.toLocaleDateString('pt-BR')
}

const statusColors = {
  'planejada': '#1976d2',
  'aprovada': '#388e3c',
  'em execução': '#f57c00',
  'finalizada': '#7b1fa2',
  'cancelada': '#d32f2f',
}

export default function CampaignCard({ campaign, onClick }) {
  return (
    <Card variant="outlined" sx={{ minWidth: 280, maxWidth: 320, flex: 1 }}>
      <CardActionArea onClick={() => onClick(campaign.id_campanha)}>
        <CardContent>
          <Typography variant="h6" noWrap>{campaign.nome}</Typography>
          <Typography variant="body2" color="text.secondary">Tema: {campaign.tema}</Typography>
          <Typography variant="body2" color="text.secondary">Segmento: {campaign.segmento}</Typography>
          <Typography variant="body2" color="text.secondary">Canal: {campaign.canal}</Typography>
          <Chip
            label={campaign.status}
            size="small"
            sx={{ mt: 1, backgroundColor: statusColors[campaign.status] || '#999', color: 'white' }}
          />
          <Typography variant="caption" display="block" mt={1}>
            {formatDate(campaign.data_inicio)} - {formatDate(campaign.data_fim)}
          </Typography>
        </CardContent>
      </CardActionArea>
    </Card>
  )
}

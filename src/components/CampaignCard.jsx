import { Card, CardContent, Typography, Chip, CardActionArea } from '@mui/material'

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
    <Card>
      <CardActionArea onClick={() => onClick(campaign.campaign_id)}>
        <CardContent>
          <Typography variant="h6">{campaign.name}</Typography>
          <Typography color="text.secondary">
            Tema: {campaign.theme}
          </Typography>
          <Typography color="text.secondary">
            Objetivo: {campaign.objective}
          </Typography>
          <Typography color="text.secondary">
            Status:{' '}
            <Chip
              label={campaign.status_label}
              size="small"
              sx={{ backgroundColor: statusColors[campaign.status] || '#1976d2', color: '#fff' }}
            />
          </Typography>
          <Typography color="text.secondary">
            {formatDate(campaign.start_date)} - {formatDate(campaign.end_date)}
          </Typography>
        </CardContent>
      </CardActionArea>
    </Card>
  )
}

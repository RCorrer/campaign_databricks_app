import { Drawer, Box, TextField, MenuItem, Button, Typography, Divider } from '@mui/material'

const DRAWER_WIDTH = 260

export default function Sidebar({ filters, onFilterChange, onClear, onNewCampaign }) {
  const handleChange = (field) => (event) => {
    onFilterChange({ ...filters, [field]: event.target.value })
  }

  return (
    <Drawer
      variant="permanent"
      anchor="left"
      sx={{
        width: DRAWER_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: DRAWER_WIDTH,
          boxSizing: 'border-box',
          marginTop: '64px',
          backgroundColor: '#f5f7fa',
          borderRight: '1px solid #ddd',
        },
      }}
    >
      <Box sx={{ p: 2 }}>
        <Typography variant="h6" gutterBottom>Filtros</Typography>
        <TextField label="Nome" size="small" fullWidth sx={{ mb: 1.5 }} value={filters.nome || ''} onChange={handleChange('nome')} />
        <TextField label="Tema" size="small" fullWidth sx={{ mb: 1.5 }} value={filters.tema || ''} onChange={handleChange('tema')} />
        <TextField label="Segmento" size="small" fullWidth sx={{ mb: 1.5 }} value={filters.segmento || ''} onChange={handleChange('segmento')} />
        <TextField label="Canal" size="small" fullWidth sx={{ mb: 1.5 }} value={filters.canal || ''} onChange={handleChange('canal')} />
        <TextField label="Status" size="small" fullWidth select sx={{ mb: 1.5 }} value={filters.status || ''} onChange={handleChange('status')}>
          <MenuItem value="">Todos</MenuItem>
          <MenuItem value="planejada">Planejada</MenuItem>
          <MenuItem value="aprovada">Aprovada</MenuItem>
          <MenuItem value="em execução">Em Execução</MenuItem>
          <MenuItem value="finalizada">Finalizada</MenuItem>
          <MenuItem value="cancelada">Cancelada</MenuItem>
        </TextField>
        <TextField label="Data Início" type="date" size="small" fullWidth sx={{ mb: 1.5 }} InputLabelProps={{ shrink: true }} value={filters.data_inicio || ''} onChange={handleChange('data_inicio')} />
        <TextField label="Data Fim" type="date" size="small" fullWidth sx={{ mb: 1.5 }} InputLabelProps={{ shrink: true }} value={filters.data_fim || ''} onChange={handleChange('data_fim')} />
        <Divider sx={{ my: 1.5 }} />
        <Button variant="outlined" fullWidth onClick={onClear} sx={{ mb: 1 }}>
          Limpar Filtros
        </Button>
        <Button variant="contained" fullWidth onClick={onNewCampaign} color="primary">
          Criar Campanha
        </Button>
      </Box>
    </Drawer>
  )
}

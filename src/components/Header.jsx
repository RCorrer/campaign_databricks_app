import { AppBar, Toolbar, Typography, Button } from '@mui/material'
import { useNavigate } from 'react-router-dom'
import PieChartIcon from '@mui/icons-material/PieChart'

export default function Header() {
  const navigate = useNavigate()
  return (
    <AppBar position="static" sx={{ backgroundColor: '#1e3a5f' }}>
      <Toolbar>
        <PieChartIcon sx={{ mr: 1 }} />
        <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 'bold' }}>
          Customer Insights
        </Typography>
        <Button color="inherit" onClick={() => navigate('/')}>
          Dashboard
        </Button>
      </Toolbar>
    </AppBar>
  )
}

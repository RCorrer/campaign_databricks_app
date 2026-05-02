import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Box, TextField, Button, Typography, Paper, Grid, Alert } from '@mui/material'
import apiClient from '../api/client'

const initialForm = {
  name: '',
  theme: '',
  objective: '',
  strategy: '',
  start_date: '',
  end_date: '',
  status: 'planejada',
}

export default function CampaignForm() {
  const { id } = useParams()
  const isNew = !id
  const [form, setForm] = useState(initialForm)
  const [editMode, setEditMode] = useState(isNew)
  const [originalData, setOriginalData] = useState(null)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState(null)
  const navigate = useNavigate()

  useEffect(() => {
    if (!isNew) {
      apiClient.get(`/api/campaigns/${id}`)
        .then(res => {
          const data = res.data
          const formatted = {
            ...data,
            start_date: data.start_date ? data.start_date.substring(0, 10) : '',
            end_date: data.end_date ? data.end_date.substring(0, 10) : '',
          }
          setForm(formatted)
          setOriginalData(formatted)
          setEditMode(false)
        })
        .catch(err => {
          console.error(err)
          setMessage({ type: 'error', text: 'Erro ao carregar campanha' })
        })
    }
  }, [id, isNew])

  const handleChange = (e) => {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))
  }

  const isFormValid = () => {
    return form.name.trim() !== ''
  }

  const handleCreateAndGo = async () => {
    if (!isFormValid()) return
    setSaving(true)
    try {
      const res = await apiClient.post('/api/campaigns', form)
      const newId = res.data.campaign_id
      navigate(`/campaign/${newId}`)
    } catch (err) {
      setMessage({ type: 'error', text: 'Erro ao criar campanha' })
      setSaving(false)
    }
  }

  const handleUpdate = async () => {
    setSaving(true)
    try {
      await apiClient.put(`/api/campaigns/${id}`, form)
      setOriginalData({ ...form })
      setEditMode(false)
      setMessage({ type: 'success', text: 'Campanha atualizada com sucesso!' })
    } catch (err) {
      setMessage({ type: 'error', text: 'Erro ao atualizar campanha' })
    } finally {
      setSaving(false)
    }
  }

  return (
    <Box sx={{ maxWidth: 600, mx: 'auto', mt: 4 }}>
      <Paper sx={{ p: 3 }}>
        <Typography variant="h5" gutterBottom>
          {isNew ? 'Nova Campanha' : `Campanha #${id}`}
        </Typography>
        {message && (
          <Alert severity={message.type} sx={{ mb: 2 }}>
            {message.text}
          </Alert>
        )}
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Nome"
              name="name"
              value={form.name}
              onChange={handleChange}
              disabled={!editMode}
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Tema"
              name="theme"
              value={form.theme}
              onChange={handleChange}
              disabled={!editMode}
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Objetivo"
              name="objective"
              value={form.objective}
              onChange={handleChange}
              disabled={!editMode}
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Estratégia"
              name="strategy"
              value={form.strategy}
              onChange={handleChange}
              disabled={!editMode}
            />
          </Grid>
          <Grid item xs={6}>
            <TextField
              fullWidth
              type="date"
              label="Data Início"
              name="start_date"
              value={form.start_date}
              onChange={handleChange}
              disabled={!editMode}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={6}>
            <TextField
              fullWidth
              type="date"
              label="Data Fim"
              name="end_date"
              value={form.end_date}
              onChange={handleChange}
              disabled={!editMode}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              select
              label="Status"
              name="status"
              value={form.status}
              onChange={handleChange}
              disabled={!editMode}
              SelectProps={{ native: true }}
            >
              <option value="planejada">Planejada</option>
              <option value="aprovada">Aprovada</option>
              <option value="em execução">Em Execução</option>
              <option value="finalizada">Finalizada</option>
              <option value="cancelada">Cancelada</option>
            </TextField>
          </Grid>
        </Grid>
        <Box sx={{ mt: 2, display: 'flex', gap: 1 }}>
          {isNew ? (
            <Button variant="contained" onClick={handleCreateAndGo} disabled={saving}>
              Criar Campanha
            </Button>
          ) : (
            <>
              {editMode ? (
                <Button variant="contained" onClick={handleUpdate} disabled={saving}>
                  Salvar
                </Button>
              ) : (
                <Button variant="outlined" onClick={() => setEditMode(true)}>
                  Editar
                </Button>
              )}
            </>
          )}
        </Box>
      </Paper>
    </Box>
  )
}

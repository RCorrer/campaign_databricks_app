import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import {
  Box, TextField, Button, Typography, Paper, Grid, Alert
} from '@mui/material'
import apiClient from '../api/client'

const initialForm = {
  nome: '',
  tema: '',
  segmento: '',
  objetivo: '',
  estrategia: '',
  canal: '',
  data_inicio: '',
  data_fim: '',
  publico_alvo: '',
  regras_inclusao: '',
  regras_exclusao: '',
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
            data_inicio: data.data_inicio ? data.data_inicio.substring(0, 10) : '',
            data_fim: data.data_fim ? data.data_fim.substring(0, 10) : '',
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
    return form.nome.trim() !== ''
  }

  const handleCreateAndGo = async () => {
    if (!isFormValid()) return
    setSaving(true)
    try {
      const res = await apiClient.post('/api/campaigns', form)
      const newId = res.data.id_campanha
      navigate(`/segmentacao/${newId}`)
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

  const handleSegmentar = () => {
    navigate(`/segmentacao/${id}`)
  }

  const allFieldsFilled = () => {
    return form.nome && form.tema && form.segmento && form.canal && form.status
  }

  return (
    <Box sx={{ p: 3, ml: '260px', mt: '64px', width: '100%' }}>
      <Paper sx={{ p: 4, maxWidth: 800, mx: 'auto' }}>
        <Typography variant="h5" gutterBottom>
          {isNew ? 'Nova Campanha' : `Campanha #${id}`}
        </Typography>

        {message && <Alert severity={message.type} sx={{ mb: 2 }}>{message.text}</Alert>}

        <Grid container spacing={2}>
          <Grid item xs={12} sm={6}>
            <TextField name="nome" label="Nome" value={form.nome} onChange={handleChange} fullWidth disabled={!editMode} required />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="tema" label="Tema" value={form.tema} onChange={handleChange} fullWidth disabled={!editMode} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="segmento" label="Segmento" value={form.segmento} onChange={handleChange} fullWidth disabled={!editMode} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="objetivo" label="Objetivo" value={form.objetivo} onChange={handleChange} fullWidth disabled={!editMode} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="estrategia" label="Estratégia" value={form.estrategia} onChange={handleChange} fullWidth disabled={!editMode} multiline />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="canal" label="Canal" value={form.canal} onChange={handleChange} fullWidth disabled={!editMode} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="data_inicio" label="Data Início" type="date" value={form.data_inicio} onChange={handleChange} fullWidth disabled={!editMode} InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="data_fim" label="Data Fim" type="date" value={form.data_fim} onChange={handleChange} fullWidth disabled={!editMode} InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={12}>
            <TextField name="publico_alvo" label="Público Alvo" value={form.publico_alvo} onChange={handleChange} fullWidth disabled={!editMode} multiline />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="regras_inclusao" label="Regras Inclusão" value={form.regras_inclusao} onChange={handleChange} fullWidth disabled={!editMode} multiline />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="regras_exclusao" label="Regras Exclusão" value={form.regras_exclusao} onChange={handleChange} fullWidth disabled={!editMode} multiline />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField name="status" label="Status" value={form.status} onChange={handleChange} fullWidth disabled={!editMode} select SelectProps={{ native: true }}>
              <option value="planejada">Planejada</option>
              <option value="aprovada">Aprovada</option>
              <option value="em execução">Em Execução</option>
              <option value="finalizada">Finalizada</option>
              <option value="cancelada">Cancelada</option>
            </TextField>
          </Grid>
        </Grid>

        <Box sx={{ mt: 4, display: 'flex', gap: 2 }}>
          {isNew ? (
            <Button variant="contained" onClick={handleCreateAndGo} disabled={!allFieldsFilled() || saving} color="primary">
              Criar Campanha
            </Button>
          ) : (
            <>
              {editMode ? (
                <Button variant="contained" onClick={handleUpdate} disabled={saving} color="primary">
                  Salvar
                </Button>
              ) : (
                <Button variant="outlined" onClick={() => setEditMode(true)} color="secondary">
                  Editar
                </Button>
              )}
              {!editMode && (
                <Button variant="contained" onClick={handleSegmentar} color="success">
                  Segmentar
                </Button>
              )}
            </>
          )}
        </Box>
      </Paper>
    </Box>
  )
}

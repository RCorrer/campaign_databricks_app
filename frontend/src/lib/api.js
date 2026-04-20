export async function apiGet(path) {
  const response = await fetch(path)
  if (!response.ok) throw new Error('Erro ao carregar dados')
  return response.json()
}

export async function apiSend(path, method, body) {
  const response = await fetch(path, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  })
  if (!response.ok) throw new Error('Erro na requisição')
  return response.json()
}

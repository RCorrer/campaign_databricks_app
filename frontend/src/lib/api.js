export async function apiGet(path) {
  const response = await fetch(path)
  if (!response.ok) {
    throw new Error(`Erro ${response.status}`)
  }
  return response.json()
}

export async function apiSend(path, method = 'POST', payload) {
  const response = await fetch(path, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: payload ? JSON.stringify(payload) : undefined
  })
  if (!response.ok) {
    throw new Error(`Erro ${response.status}`)
  }
  return response.json()
}

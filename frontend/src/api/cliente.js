async function requisicao(caminho, opcoes = {}) {
  const resposta = await fetch(caminho, {
    headers: { 'Content-Type': 'application/json', ...(opcoes.headers || {}) },
    ...opcoes,
  })
  if (!resposta.ok) {
    let detalhe = 'Erro na requisição'
    try {
      const corpo = await resposta.json()
      detalhe = corpo.detail || detalhe
    } catch (_) {}
    throw new Error(detalhe)
  }
  if (resposta.status === 204) return null
  return resposta.json()
}

export const api = {
  get: (caminho) => requisicao(caminho),
  post: (caminho, corpo) => requisicao(caminho, { method: 'POST', body: JSON.stringify(corpo) }),
  put: (caminho, corpo) => requisicao(caminho, { method: 'PUT', body: JSON.stringify(corpo) }),
  del: (caminho) => requisicao(caminho, { method: 'DELETE' }),
}

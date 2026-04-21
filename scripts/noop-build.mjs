import { existsSync } from 'node:fs'

if (!existsSync('frontend/index.html')) {
  console.error('frontend/index.html não encontrado')
  process.exit(1)
}

console.log('No frontend build required. Static assets will be served directly by FastAPI.')

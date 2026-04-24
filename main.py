from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse
from backend.api.routes import api_router
from backend.core.config import settings

app = FastAPI(title=settings.app_name, version=settings.app_version)
app.include_router(api_router, prefix='/api')

FRONTEND_DIR = Path(settings.frontend_dir)


def _serve_frontend_file(relative_path: str):
    target = FRONTEND_DIR / relative_path
    if target.exists() and target.is_file():
        return FileResponse(target)
    return None


@app.get('/')
def root():
    index_file = FRONTEND_DIR / 'index.html'
    if index_file.exists():
        return FileResponse(index_file)
    return {'message': 'Frontend estático não encontrado.'}


@app.get('/app.js')
def app_js():
    file = _serve_frontend_file('app.js')
    return file or {'message': 'app.js não encontrado.'}


@app.get('/styles.css')
def styles_css():
    file = _serve_frontend_file('styles.css')
    return file or {'message': 'styles.css não encontrado.'}


@app.get('/{full_path:path}')
def spa_fallback(full_path: str):
    static_file = _serve_frontend_file(full_path)
    if static_file:
        return static_file
    index_file = FRONTEND_DIR / 'index.html'
    if index_file.exists():
        return FileResponse(index_file)
    return {'message': f'Rota {full_path} não encontrada e frontend indisponível.'}

from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from backend.api.routes import api_router
from backend.core.config import settings

app = FastAPI(title=settings.app_name, version=settings.app_version)
app.include_router(api_router, prefix='/api')

DIST_DIR = Path(settings.dist_dir)
if DIST_DIR.exists():
    assets_dir = DIST_DIR / 'assets'
    if assets_dir.exists():
        app.mount('/assets', StaticFiles(directory=str(assets_dir)), name='assets')


@app.get('/')
def root():
    index_file = DIST_DIR / 'index.html'
    if index_file.exists():
        return FileResponse(index_file)
    return {'message': 'Frontend ainda não foi buildado. Execute npm run build.'}


@app.get('/{full_path:path}')
def spa_fallback(full_path: str):
    target = DIST_DIR / full_path
    index_file = DIST_DIR / 'index.html'
    if target.exists() and target.is_file():
        return FileResponse(target)
    if index_file.exists():
        return FileResponse(index_file)
    return {'message': f'Rota {full_path} não encontrada e frontend indisponível.'}

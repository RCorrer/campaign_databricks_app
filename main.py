from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from backend.api.rotas import roteador_api

app = FastAPI(title="Orquestrador de Campanhas", version="4.0.0")
app.include_router(roteador_api, prefix="/api")

DIST_DIR = Path("frontend/dist")

if DIST_DIR.exists():
    assets_dir = DIST_DIR / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")

    @app.get("/{caminho:path}")
    def servir_frontend(caminho: str):
        arquivo = DIST_DIR / caminho
        if arquivo.is_file():
            return FileResponse(arquivo)
        return FileResponse(DIST_DIR / "index.html")

import logging
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from app.controllers.campaign_controller import router as campaign_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("crm-cdp")

app = FastAPI(
    title="Campaign Orchestrator",
    version="3.1.0",
    docs_url="/docs",
    redoc_url=None,
)

# Rotas da API
app.include_router(campaign_router, prefix="/api")

# Diretório do frontend React buildado
DIST_DIR = Path("dist")
if DIST_DIR.exists() and (DIST_DIR / "index.html").exists():
    logger.info("Servindo frontend React da pasta '%s'", DIST_DIR)
    assets_dir = DIST_DIR / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")

    @app.get("/")
    async def root():
        return FileResponse(DIST_DIR / "index.html")

    @app.get("/{full_path:path}")
    async def spa_fallback(full_path: str, request: Request):
        if request.url.path.startswith("/api"):
            return None
        static_file = DIST_DIR / full_path
        if static_file.exists() and static_file.is_file():
            return FileResponse(static_file)
        return FileResponse(DIST_DIR / "index.html")
else:
    logger.warning("Pasta 'dist' não encontrada – apenas API disponível.")

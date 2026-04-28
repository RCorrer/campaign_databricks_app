import logging
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

# Novas importações alinhadas com a estrutura do repositório
from app.controllers.campaign_controller import router as campaign_router
from app.config import AppConfig

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("crm-cdp")

app = FastAPI(title="Campaign Orchestrator", version="3.1.0")

# Monta as rotas da API ANTES de qualquer outra coisa
app.include_router(campaign_router, prefix="/api/campaigns")

# Determina qual diretório de frontend usar
FRONTEND_DIR = Path("frontend")   # para a versão vanilla (pasta frontend)
DIST_DIR = Path("dist")           # para build React/Vite

# Opção 1: Servindo o frontend vanilla (pasta frontend)
if FRONTEND_DIR.exists() and (FRONTEND_DIR / "index.html").exists():
    logger.info("Usando frontend vanilla da pasta '%s'", FRONTEND_DIR)

    @app.get("/")
    async def root():
        return FileResponse(FRONTEND_DIR / "index.html")

    @app.get("/app.js")
    async def app_js():
        return FileResponse(FRONTEND_DIR / "app.js")

    @app.get("/styles.css")
    async def styles_css():
        return FileResponse(FRONTEND_DIR / "styles.css")

    @app.get("/{full_path:path}")
    async def spa_fallback(full_path: str, request: Request):
        # Evita que o fallback capture as rotas da API
        if request.url.path.startswith("/api"):
            return None
        static_file = FRONTEND_DIR / full_path
        if static_file.exists() and static_file.is_file():
            return FileResponse(static_file)
        return FileResponse(FRONTEND_DIR / "index.html")

# Opção 2: Servindo a build do Vite/React (pasta dist)
elif DIST_DIR.exists() and (DIST_DIR / "index.html").exists():
    logger.info("Usando frontend React buildado da pasta '%s'", DIST_DIR)

    if (DIST_DIR / "assets").exists():
        app.mount("/assets", StaticFiles(directory=DIST_DIR / "assets"), name="assets")

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
    logger.warning("Nenhum diretório de frontend encontrado. Apenas a API estará disponível.")

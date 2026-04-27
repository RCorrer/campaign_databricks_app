import logging
from pathlib import Path
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles

# Configuração de logging – as mensagens aparecerão nos logs do Databricks App
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("crm-cdp")

app = FastAPI()

DIST_DIR = Path("dist")
logger.info(f"Dist directory exists: {DIST_DIR.exists()}")
if DIST_DIR.exists():
    logger.info(f"Dist contents: {list(DIST_DIR.iterdir())}")
    assets_dir = DIST_DIR / "assets"
    if assets_dir.exists():
        logger.info("Mounting /assets")
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")
else:
    logger.error("DIST_DIR not found! React build missing.")

# Incluir os routers
from app.controllers import campaign_controller, lead_controller
app.include_router(campaign_controller.router, prefix="/api/campaigns")
app.include_router(lead_controller.router, prefix="/api/leads")

@app.get("/health")
def health():
    """Endpoint de saúde para verificar se o servidor está respondendo."""
    return {"status": "ok", "dist_exists": DIST_DIR.exists()}

@app.get("/")
async def root(request: Request):
    logger.info(f"Serving index.html to {request.client.host}")
    index_file = DIST_DIR / "index.html"
    if index_file.exists():
        logger.info("index.html found")
        return FileResponse(index_file)
    else:
        logger.error("index.html not found!")
        return HTMLResponse("<h1>index.html missing</h1>", status_code=500)

@app.get("/{full_path:path}")
async def spa_fallback(request: Request, full_path: str):
    logger.info(f"SPA fallback for path: {full_path}")
    target = DIST_DIR / full_path
    if target.exists() and target.is_file():
        return FileResponse(target)
    # Fallback para index.html (importante para React Router)
    return FileResponse(DIST_DIR / "index.html")

@app.on_event("startup")
async def startup_event():
    logger.info("Application startup complete")

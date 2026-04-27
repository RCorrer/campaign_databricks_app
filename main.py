from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from app.controllers import customer_controller, campaign_controller, lead_controller

app = FastAPI()

DIST_DIR = Path("dist")
if DIST_DIR.exists():
    assets_dir = DIST_DIR / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")

app.include_router(customer_controller.router, prefix="/api/customers")
app.include_router(campaign_controller.router, prefix="/api/campaigns")
app.include_router(lead_controller.router, prefix="/api/leads")

@app.get("/")
def root():
    return FileResponse(DIST_DIR / "index.html")

@app.get("/{full_path:path}")
def spa_fallback(full_path: str):
    target = DIST_DIR / full_path
    if target.exists() and target.is_file():
        return FileResponse(target)
    return FileResponse(DIST_DIR / "index.html")

from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from backend.api.routes import router

app = FastAPI(title="Campaign Databricks App")
app.include_router(router, prefix="/api")

DIST_DIR = Path("frontend/dist")

if DIST_DIR.exists():
    assets_dir = DIST_DIR / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")


@app.get("/")
def root():
    index = DIST_DIR / "index.html"
    if index.exists():
        return FileResponse(index)
    return {"message": "Frontend não buildado ainda. Execute o build do Vite."}


@app.get("/{full_path:path}")
def spa_fallback(full_path: str):
    target = DIST_DIR / full_path
    if target.exists() and target.is_file():
        return FileResponse(target)
    index = DIST_DIR / "index.html"
    if index.exists():
        return FileResponse(index)
    return {"message": "Frontend não buildado ainda. Execute o build do Vite."}

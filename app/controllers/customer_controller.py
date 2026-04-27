from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def list_customers():
    return {"message": "Endpoint de clientes"}

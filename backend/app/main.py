import logging

from fastapi import Depends, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.database import DatabaseUnavailableError
from app.repository import MundialesRepository, get_repository
from app.schemas import MundialResponse, TitulosSeleccionResponse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="API de Mundiales", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://127.0.0.1"],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)


@app.exception_handler(DatabaseUnavailableError)
async def database_unavailable_handler(
    request: Request, exc: DatabaseUnavailableError
) -> JSONResponse:
    return JSONResponse(
        status_code=503,
        content={
            "detail": "No se pudo consultar MySQL. Verifica que el servidor esté "
            "activo y que las variables MYSQL_* sean correctas."
        },
    )


@app.get("/mundiales/", response_model=list[MundialResponse])
def listar_mundiales(
    repository: MundialesRepository = Depends(get_repository),
) -> list[MundialResponse]:
    return repository.listar_mundiales()


@app.get(
    "/graficas/titulos-por-seleccion/datos",
    response_model=list[TitulosSeleccionResponse],
)
def titulos_por_seleccion(
    repository: MundialesRepository = Depends(get_repository),
) -> list[TitulosSeleccionResponse]:
    return repository.listar_titulos()

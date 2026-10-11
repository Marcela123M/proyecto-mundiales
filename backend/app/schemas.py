from pydantic import BaseModel


class SeleccionNombreResponse(BaseModel):
    nombre: str


class MundialResponse(BaseModel):
    id: int
    anio: int
    sede: str
    campeon: SeleccionNombreResponse
    subcampeon: str
    marcador: str


class TitulosSeleccionResponse(BaseModel):
    nombre: str
    titulos: int

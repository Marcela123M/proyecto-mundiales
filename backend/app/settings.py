import os
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[1] / ".env")


@dataclass(frozen=True)
class Settings:
    mysql_host: str
    mysql_port: int
    mysql_database: str
    mysql_user: str
    mysql_password: str


@lru_cache
def get_settings() -> Settings:
    password = os.getenv("MYSQL_PASSWORD")
    if not password:
        raise RuntimeError(
            "MYSQL_PASSWORD no está configurada. Copia .env.example a .env "
            "y completa las variables de conexión."
        )

    try:
        port = int(os.getenv("MYSQL_PORT", "3306"))
    except ValueError as exc:
        raise RuntimeError("MYSQL_PORT debe ser un número entero.") from exc

    return Settings(
        mysql_host=os.getenv("MYSQL_HOST", "127.0.0.1"),
        mysql_port=port,
        mysql_database=os.getenv("MYSQL_DATABASE", "mundiales_db"),
        mysql_user=os.getenv("MYSQL_USER", "mundiales_user"),
        mysql_password=password,
    )

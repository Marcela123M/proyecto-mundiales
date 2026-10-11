import logging
from typing import Any

from fastapi import Depends
from mysql.connector import Error as MySQLError

from app.database import DatabaseUnavailableError, get_connection

logger = logging.getLogger(__name__)


class MundialesRepository:
    """Centraliza las consultas a las tablas de la aplicación."""

    def listar_mundiales(self) -> list[dict[str, Any]]:
        sql = """
            SELECT
                m.id,
                m.anio,
                m.sede,
                s.nombre AS campeon,
                m.subcampeon,
                m.marcador
            FROM mundiales AS m
            INNER JOIN selecciones AS s ON s.id = m.campeon_id
            ORDER BY m.anio
        """
        rows = self._query(sql)
        return [
            {
                "id": row["id"],
                "anio": row["anio"],
                "sede": row["sede"],
                "campeon": {"nombre": row["campeon"]},
                "subcampeon": row["subcampeon"],
                "marcador": row["marcador"],
            }
            for row in rows
        ]

    def listar_titulos(self) -> list[dict[str, Any]]:
        sql = """
            SELECT s.nombre, COUNT(m.id) AS titulos
            FROM selecciones AS s
            LEFT JOIN mundiales AS m ON m.campeon_id = s.id
            GROUP BY s.id, s.nombre
            ORDER BY titulos DESC, s.nombre
        """
        return [
            {"nombre": row["nombre"], "titulos": int(row["titulos"])}
            for row in self._query(sql)
        ]

    @staticmethod
    def _query(sql: str) -> list[dict[str, Any]]:
        try:
            with get_connection() as connection:
                cursor = connection.cursor(dictionary=True)
                try:
                    cursor.execute(sql)
                    return cursor.fetchall()
                finally:
                    cursor.close()
        except (MySQLError, DatabaseUnavailableError) as exc:
            logger.exception("Falló una consulta a MySQL")
            raise DatabaseUnavailableError from exc


def get_repository() -> MundialesRepository:
    """Dependency injection: permite sustituir el repositorio en las pruebas."""
    return MundialesRepository()

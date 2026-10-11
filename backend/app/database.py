from contextlib import contextmanager
from functools import lru_cache
from typing import Iterator

from mysql.connector import Error as MySQLError
from mysql.connector import MySQLConnection
from mysql.connector.pooling import MySQLConnectionPool

from app.settings import get_settings


class DatabaseUnavailableError(Exception):
    """Indica que la API no pudo establecer o usar una conexión MySQL."""


@lru_cache
def _get_pool() -> MySQLConnectionPool:
    settings = get_settings()
    return MySQLConnectionPool(
        pool_name="mundiales_pool",
        pool_size=5,
        pool_reset_session=True,
        host=settings.mysql_host,
        port=settings.mysql_port,
        database=settings.mysql_database,
        user=settings.mysql_user,
        password=settings.mysql_password,
        connection_timeout=5,
    )


@contextmanager
def get_connection() -> Iterator[MySQLConnection]:
    try:
        connection = _get_pool().get_connection()
    except (MySQLError, RuntimeError) as exc:
        raise DatabaseUnavailableError from exc

    try:
        yield connection
    except MySQLError as exc:
        raise DatabaseUnavailableError from exc
    finally:
        connection.close()

import unittest
from contextlib import contextmanager
from unittest.mock import Mock, patch

from app.repository import MundialesRepository


class MundialesRepositoryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.cursor = Mock()
        self.connection = Mock()
        self.connection.cursor.return_value = self.cursor
        self.repository = MundialesRepository()

    def _connection_context(self):
        @contextmanager
        def context():
            try:
                yield self.connection
            finally:
                self.connection.close()

        return context

    @patch("app.repository.get_connection")
    def test_listar_mundiales_da_formato_compatible_con_flutter(
        self, get_connection_mock: Mock
    ) -> None:
        get_connection_mock.side_effect = self._connection_context()
        self.cursor.fetchall.return_value = [
            {
                "id": 1,
                "anio": 1930,
                "sede": "Uruguay",
                "campeon": "Uruguay",
                "subcampeon": "Argentina",
                "marcador": "4-2",
            }
        ]

        result = self.repository.listar_mundiales()

        self.assertEqual(
            result,
            [
                {
                    "id": 1,
                    "anio": 1930,
                    "sede": "Uruguay",
                    "campeon": {"nombre": "Uruguay"},
                    "subcampeon": "Argentina",
                    "marcador": "4-2",
                }
            ],
        )
        self.cursor.close.assert_called_once()
        self.connection.close.assert_called_once()

    @patch("app.repository.get_connection")
    def test_listar_titulos_entrega_enteros(
        self, get_connection_mock: Mock
    ) -> None:
        get_connection_mock.side_effect = self._connection_context()
        self.cursor.fetchall.return_value = [{"nombre": "Brasil", "titulos": 5}]

        self.assertEqual(
            self.repository.listar_titulos(),
            [{"nombre": "Brasil", "titulos": 5}],
        )


if __name__ == "__main__":
    unittest.main()

"""
Configuración base de pytest para el proyecto.
Coloca este archivo en la raíz del directorio tests/ o en la raíz del proyecto.
"""

import pytest


# ── Fixtures de datos comunes ─────────────────────────────────────────────────

@pytest.fixture
def sample_user():
    """Usuario válido para tests que necesiten un usuario existente."""
    return {
        "id": 1,
        "nombre": "Ana García",
        "email": "ana@example.com",
        "activo": True,
    }


@pytest.fixture
def sample_users():
    """Lista de usuarios para tests de colecciones."""
    return [
        {"id": 1, "nombre": "Ana García", "email": "ana@example.com", "activo": True},
        {"id": 2, "nombre": "Carlos López", "email": "carlos@example.com", "activo": False},
        {"id": 3, "nombre": "María Torres", "email": "maria@example.com", "activo": True},
    ]


# ── Fixtures de infraestructura ───────────────────────────────────────────────

@pytest.fixture
def temp_dir(tmp_path):
    """Directorio temporal limpio para cada test."""
    return tmp_path


# Descomenta y adapta si el proyecto usa una base de datos:
# @pytest.fixture
# def db(tmp_path):
#     """Base de datos en memoria para tests de integración."""
#     from myapp.database import Database
#     database = Database(f"sqlite:///{tmp_path}/test.db")
#     database.create_tables()
#     yield database
#     database.drop_tables()


# Descomenta si el proyecto hace llamadas HTTP externas:
# @pytest.fixture
# def mock_http(requests_mock):
#     """Mock de llamadas HTTP para tests unitarios."""
#     return requests_mock


# ── Markers personalizados ────────────────────────────────────────────────────
# Registra markers para evitar warnings. Úsalos en tests con @pytest.mark.<nombre>

def pytest_configure(config):
    config.addinivalue_line("markers", "slow: tests que tardan más de 1 segundo")
    config.addinivalue_line("markers", "integration: tests que requieren servicios externos")
    config.addinivalue_line("markers", "unit: tests puramente unitarios")

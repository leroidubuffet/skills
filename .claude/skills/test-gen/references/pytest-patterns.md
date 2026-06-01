# Patrones de Testing — Python / pytest

## Estructura AAA (Arrange, Act, Assert)

Todo test debe seguir esta estructura. Nunca mezcles las tres fases.

```python
def test_calcular_descuento_aplicado_correctamente():
    # Arrange
    precio_original = 100.0
    porcentaje = 20

    # Act
    resultado = calcular_descuento(precio_original, porcentaje)

    # Assert
    assert resultado == 80.0
```

## Nomenclatura

Formato: `test_<funcion>_<condicion>_<resultado_esperado>`

```python
# Bien
def test_validar_email_con_formato_invalido_retorna_false():
def test_crear_usuario_sin_nombre_lanza_valor_error():
def test_calcular_total_lista_vacia_retorna_cero():

# Mal
def test_email():
def test_1():
def test_funciona():
```

## Fixtures

Usa fixtures para setup/teardown y datos reutilizables. Defínelos en `conftest.py`.

```python
# conftest.py
import pytest

@pytest.fixture
def usuario_valido():
    return {"nombre": "Ana", "email": "ana@example.com", "edad": 28}

@pytest.fixture
def cliente_db(tmp_path):
    db = Database(path=tmp_path / "test.db")
    db.initialize()
    yield db
    db.close()
```

```python
# test_usuarios.py
def test_crear_usuario_con_datos_validos(usuario_valido, cliente_db):
    resultado = cliente_db.crear_usuario(usuario_valido)
    assert resultado.id is not None
```

## Parametrize — múltiples casos de prueba

Cuando el mismo test debe correr con distintos inputs:

```python
import pytest

@pytest.mark.parametrize("entrada,esperado", [
    (0, "cero"),
    (1, "positivo"),
    (-1, "negativo"),
    (999, "positivo"),
])
def test_clasificar_numero(entrada, esperado):
    assert clasificar_numero(entrada) == esperado
```

## Mocks con pytest-mock / unittest.mock

### Mock de función externa

```python
from unittest.mock import patch, MagicMock

def test_enviar_email_llama_al_servicio(mock_email_service):
    with patch("modulo.email_service.send") as mock_send:
        mock_send.return_value = {"status": "ok"}
        resultado = enviar_confirmacion("user@example.com")
        mock_send.assert_called_once_with("user@example.com", subject="Confirmación")
        assert resultado is True
```

### Mock de dependencia inyectada (con pytest-mock)

```python
def test_procesar_pago_con_error_del_gateway(mocker):
    mock_gateway = mocker.patch("payments.gateway.charge")
    mock_gateway.side_effect = GatewayTimeoutError("timeout")

    with pytest.raises(PaymentFailedError):
        procesar_pago(monto=100, tarjeta="4111111111111111")
```

## Testing de excepciones

```python
def test_dividir_por_cero_lanza_excepcion():
    with pytest.raises(ZeroDivisionError):
        dividir(10, 0)

def test_crear_usuario_menor_de_edad_lanza_valor_error():
    with pytest.raises(ValueError, match="debe ser mayor de 18"):
        crear_usuario(nombre="Juan", edad=15)
```

## Testing de código async

```python
import pytest

@pytest.mark.asyncio
async def test_obtener_datos_async():
    resultado = await obtener_datos_usuario(user_id=42)
    assert resultado["id"] == 42
```

## Markers útiles

```python
@pytest.mark.skip(reason="pendiente de implementación")
def test_funcion_nueva():
    pass

@pytest.mark.skipif(sys.platform == "win32", reason="solo Unix")
def test_permisos_archivo():
    pass

@pytest.mark.slow
def test_procesamiento_batch():
    pass  # correr con: pytest -m slow
```

## Casos borde comunes que siempre hay que cubrir

| Tipo de entrada | Casos borde a testear |
|---|---|
| String | cadena vacía `""`, espacios `"   "`, caracteres especiales |
| Lista / colección | lista vacía `[]`, un solo elemento, lista muy grande |
| Número | `0`, negativo, `None`, float vs int |
| Objeto | `None`, objeto con campos opcionales vacíos |
| Fechas | hoy, fecha pasada, fecha futura, fin de mes, año bisiesto |

## Configuración recomendada (pyproject.toml)

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "-v --tb=short"
```

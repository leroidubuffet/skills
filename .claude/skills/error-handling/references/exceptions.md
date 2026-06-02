# Referencia: excepciones en Python y Java

## Python: jerarquia recomendada

```
ModuleBaseError(Exception)
├── ValidationError
├── NotFoundError
├── ExternalServiceError
│   ├── ServiceTimeoutError
│   └── ServiceUnavailableError
└── BusinessRuleError
```

## Python: excepciones built-in utiles

| Excepcion | Usar cuando |
|---|---|
| ValueError | Tipo correcto, valor invalido |
| TypeError | Tipo de argumento incorrecto |
| FileNotFoundError | Archivo esperado no existe |
| PermissionError | Sin permisos en I/O |
| NotImplementedError | Metodo abstracto sin implementar |

## Java: patron multi-catch

Agrupa solo excepciones con el mismo tratamiento:

```java
} catch (IOException | TimeoutException e) {
    throw new ExternalServiceException('Storage unavailable', e);
}
```

## Patron reintento en Python

```python
from functools import wraps
import time

def retry(max_attempts=3, delay=1.0, exceptions=(Exception,)):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as exc:
                    if attempt == max_attempts:
                        raise
                    time.sleep(delay * attempt)
        return wrapper
    return decorator
```

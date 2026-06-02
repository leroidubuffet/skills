---
name: error-handling
description: >
  Este skill proporciona patrones y convenciones profesionales para el manejo
  de errores en Python y Java. Debe activarse automaticamente cuando el usuario
  escribe bloques try/except o try/catch, define clases de excepcion personalizadas,
  pregunta como manejar o propagar un error, disenha la jerarquia de excepciones
  de un modulo, o escribe codigo que puede fallar con recursos externos (I/O, red,
  base de datos). No usar cuando el usuario esta auditando dependencias o
  generando tests.
---

# Error Handling - Patrones y Convenciones

Este skill proporciona el conocimiento que guia el codigo de manejo de errores.
El modelo lo aplica directamente al escribir o revisar codigo, sin pasos a ejecutar.

## Principio fundamental

**Falla rapido, falla con contexto.** Cada excepcion que cruce un limite de modulo
debe explicar que fallo, por que, y el estado relevante del sistema en ese momento.

## Taxonomia de errores

| Tipo | Cuando usarlo | Comportamiento esperado |
|---|---|---|
| **Programacion** | Precondicion violada, bug | No capturar - dejar que el proceso falle |
| **Recuperable** | Recurso no disponible temporalmente | Reintentar con backoff o degradar |
| **De negocio** | Regla de dominio violada | Capturar en capa de aplicacion, devolver error al cliente |
| **Fatal** | Corrupcion de estado, OOM | Log + exit controlado |

## Python

### Excepciones personalizadas

Hereda siempre de una base especifica del modulo, no directamente de Exception:

```python
class PaymentsError(Exception):
    pass  # base del modulo

class InsufficientFundsError(PaymentsError):
    def __init__(self, account_id: str, required, available):
        self.account_id = account_id
        self.required = required
        self.available = available
        super().__init__(
            f'Account {account_id}: required {required}, available {available}'
        )
```

### Captura

```python
# Correcto
try:
    result = gateway.charge(amount)
except GatewayTimeoutError as exc:
    logger.warning('Gateway timeout for payment %s', payment_id, exc_info=exc)
    raise PaymentRetryableError(payment_id) from exc

# Incorrecto
try:
    result = gateway.charge(amount)
except Exception:  # nunca
    pass           # nunca
```

Usa `raise NewError(...) from original` siempre que conviertas una excepcion de
libreria en una del dominio. Nunca pierdas el traceback original.

### Logging junto a errores

- `logger.exception(...)` - solo en el punto donde se decide no propagar mas
- `logger.warning(..., exc_info=exc)` - cuando se propaga transformada
- Nunca loguear y relanzar la misma excepcion: duplica el ruido en los logs

## Java

Usa **unchecked** (RuntimeException) para la mayoria de errores de dominio.
Las checked solo cuando el compilador aporta valor forzando el manejo.

```java
public class InsufficientFundsException extends RuntimeException {
    private final String accountId;
    private final BigDecimal required;
    private final BigDecimal available;

    public InsufficientFundsException(String accountId,
                                       BigDecimal required,
                                       BigDecimal available) {
        super("Account %s: required %s, available %s"
              .formatted(accountId, required, available));
        this.accountId = accountId;
        this.required = required;
        this.available = available;
    }
}
```

```java
// Correcto: preserva cause
try {
    gateway.charge(amount);
} catch (GatewayTimeoutException e) {
    log.warn('Gateway timeout for payment {}', paymentId, e);
    throw new PaymentRetryableException(paymentId, e);
}
```

## Errores en APIs REST

| Situacion | Codigo | Cuerpo |
|---|---|---|
| Validacion | 400 | `{"error": "VALIDATION_ERROR", "field": "amount"}` |
| No encontrado | 404 | `{"error": "NOT_FOUND", "resource": "payment"}` |
| Regla de negocio | 422 | `{"error": "INSUFFICIENT_FUNDS", "detail": "..."}` |
| Servicio externo caido | 503 | `{"error": "SERVICE_UNAVAILABLE", "retry_after": 30}` |
| Bug interno | 500 | `{"error": "INTERNAL_ERROR"}` - sin detalles internos |

## Anti-patterns a rechazar

- `except Exception: pass` - error silenciado
- Capturar y relanzar sin contexto
- Usar excepciones para control de flujo normal
- Mensajes genericos: 'Something went wrong'
- Loguear el mismo error en varias capas de la pila
- Exponer stack traces en respuestas de API de produccion

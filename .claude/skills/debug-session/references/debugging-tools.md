# Herramientas de debugging

## Python: pdb

```python
breakpoint()  # Python 3.7+ (equivale a import pdb; pdb.set_trace())
```

| Comando | Accion |
|---|---|
| n | siguiente linea (sin entrar en funciones) |
| s | siguiente linea (entrando en funciones) |
| c | continuar hasta el proximo breakpoint |
| p expr | mostrar valor de expresion |
| bt | backtrace completo |
| q | salir |

## Python: logging en lugar de print

```python
import logging
logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)
log.debug('valor=%r tipo=%s', valor, type(valor).__name__)
```

## Java: SLF4J

```java
private static final Logger log = LoggerFactory.getLogger(MiClase.class);
log.debug('valor={} tipo={}', valor, valor.getClass().getSimpleName());
```

## Leer un stack trace Java

```
Exception in thread 'main' java.lang.NullPointerException   <- tipo
    at com.example.PaymentService.charge(PaymentService.java:42)  <- causa raiz
    at com.example.OrderController.submit(OrderController.java:87)
Caused by: com.example.GatewayException: timeout            <- excepcion original
    at com.example.GatewayClient.send(GatewayClient.java:15)
```

Leer de abajo arriba para encontrar la causa raiz.

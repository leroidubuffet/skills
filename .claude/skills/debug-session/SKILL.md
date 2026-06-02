---
name: debug-session
description: >
  Este skill guia una sesion de debugging estructurada en Python o Java.
  Debe activarse automaticamente cuando el usuario reporta que algo no funciona,
  comparte un stack trace o mensaje de error, menciona un comportamiento inesperado,
  dice 'no entiendo por que falla', 'me da error', 'esto deberia funcionar pero...'
  o pega un traceback. No activar para revisiones de codigo sin error reportado
  ni para generacion de tests.
---

# Debug Session

Workflow estructurado para identificar y corregir la causa raiz de un bug.
Seguir los pasos en orden: saltarse pasos es la causa mas comun de perder tiempo.

## Paso 1 - Leer el error completo

Antes de tocar una linea de codigo, lee el traceback de arriba a abajo:

- Tipo de excepcion
- Mensaje exacto
- Linea y archivo donde se origina (ultima entrada del traceback, no la primera)
- Cadena `caused by` / `from` que apunte a la excepcion original

Si el usuario no compartio el error completo, pedirlo antes de continuar:
> 'Puedes pegar el traceback completo?'

## Paso 2 - Reproducir minimamente

El objetivo es el caso de reproduccion mas pequenho posible:

```bash
# Python
python -c 'from modulo import funcion; funcion(valor_que_falla)'

# Java (Maven)
mvn test -Dtest=ClaseTest#metodoQueFalla -pl modulo
```

Si no se puede reproducir en aislamiento, el bug depende de estado compartido
o de orden de ejecucion. Tomar nota: eso es informacion util.

## Paso 3 - Localizar el valor incorrecto

Lee el archivo y la linea del traceback. Comprueba el valor de cada variable:

```python
# Python: print temporal
print(f'DEBUG tipo={type(valor)!r} valor={valor!r}')
```

```java
// Java: log temporal
System.err.println('DEBUG valor=' + valor + ' tipo=' + valor.getClass());
```

Quitar los prints de debug antes de commitear.

## Paso 4 - Formular una hipotesis concreta

Con los datos del paso 3, formula una hipotesis especifica:

> 'El error ocurre porque X es None cuando funcion_Y espera un string.
> Eso pasa porque Z no inicializa correctamente cuando falta la config W.'

Una hipotesis vaga ('algo falla en la capa de servicio') no guia nada.

## Paso 5 - Verificar la hipotesis

Comprueba directamente antes de tocar codigo:

```python
assert valor is not None, f'valor no puede ser None, contexto={contexto!r}'
```

Si la hipotesis es correcta, el error cambia o desaparece. Si no cambia nada,
la hipotesis era erronea: volver al paso 3 con datos nuevos.

## Paso 6 - Aplicar el fix minimo

El fix debe ser especifico para la causa raiz. Evitar:

- Arreglar sintomas en lugar de la causa
- Guards genericos (`if valor is None: return`) sin entender por que es None
- Varios cambios a la vez (si hay otro bug, no sabras cual fix lo resolvio)

## Paso 7 - Verificar

```bash
# Python
python -m pytest tests/ -x -q

# Java (Maven)
mvn test -pl modulo
```

Reproduce ademas el caso del paso 2 manualmente para confirmar que ya no falla.

## Cuando el bug solo ocurre en produccion

1. Compara variables de entorno entre entornos
2. Compara versiones de dependencias (`pip freeze` / `mvn dependency:tree`)
3. Revisa los logs de produccion con el error completo
4. Comprueba diferencias de datos (IDs que no existen en dev, encoding diferente)

## Output al terminar

```
## Bug resuelto

**Causa raiz:** [una frase]
**Fix aplicado:** [que cambio y en que archivo]
**Como verificarlo:** [comando o paso concreto]
```

Si no se pudo resolver, documentar hasta donde se llego y que hipotesis quedan pendientes.

## Referencia adicional

Ver `references/debugging-tools.md` para comandos de pdb, logging y lectura de
stack traces Java.

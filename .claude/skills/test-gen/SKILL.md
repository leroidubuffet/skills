---
name: test-gen
description: Genera tests unitarios para código Python o Java existente. Úsalo cuando el usuario pida generar tests, cubrir funciones sin tests, escribir unit tests, crear suite de pruebas, o cuando haya código sin cobertura. Detecta automáticamente el lenguaje y genera tests con pytest o JUnit 5 siguiendo patrones profesionales.
argument-hint: "[ruta-archivo-o-directorio]"
disable-model-invocation: true
allowed-tools: Bash(python *) Bash(python3 *) Bash(python -m pytest *) Bash(mvn *) Bash(./gradlew *)
---

# Test Generator

Genera tests unitarios de calidad profesional para código Python o Java existente.

## Proceso

### 1. Identificar el contexto

Si el usuario no especificó archivos concretos, pregunta: "¿Qué archivo o módulo quieres cubrir?" Si ya lo indicó, ve directo al paso 2.

Detecta el lenguaje mirando extensiones (`.py` → Python, `.java` → Java). Si hay ambos, pregunta cuál priorizar.

### 2. Encontrar gaps de cobertura

Ejecuta el script para identificar funciones/métodos sin tests:

```bash
python ${CLAUDE_SKILL_DIR}/scripts/find-gaps.py $ARGUMENTS
```

El script imprime una lista de funciones o métodos que no tienen tests correspondientes. Usa esa lista como base — no inventes gaps, no ignores los que salgan.

### 3. Leer los patrones del lenguaje

Antes de escribir una sola línea de test, lee el archivo de referencia correspondiente:

- Python → `references/pytest-patterns.md`
- Java → `references/junit-patterns.md`

Estos archivos contienen los patrones concretos que debes seguir: estructura AAA, nombres de test, cómo hacer mocks, cuándo usar fixtures o parametrize.

### 4. Generar los tests

Para cada función/método identificado en el paso 2:

- Escribe al menos un test del happy path
- Escribe al menos un test del caso borde más obvio (valor nulo, lista vacía, número negativo, etc.)
- Sigue la estructura y convenciones del archivo de referencia

Coloca los tests en el lugar correcto:
- Python: `tests/test_<nombre_modulo>.py` (usa `assets/conftest_template.py` si no existe conftest.py)
- Java: `src/test/java/.../Test<NombreClase>.java` (usa `assets/TestBase.template.java` como base si aplica)

### 5. Verificar que los tests pasan

```bash
# Python
python -m pytest <archivo-de-tests> -v

# Java (Maven)
mvn test -pl . -Dtest=<NombreClase>Test

# Java (Gradle)
./gradlew test --tests "<paquete>.<NombreClase>Test"
```

Si algún test falla por un motivo distinto al código bajo prueba (import incorrecto, path, dependencia faltante), corrígelo antes de reportar.

## Output

Al terminar, muestra un resumen:

```
## Tests generados

**Archivo:** tests/test_pagos.py
**Funciones cubiertas:** calcular_total, aplicar_descuento, validar_monto (3)
**Tests escritos:** 8 (5 happy path, 3 casos borde)

**Cómo correrlos:**
python -m pytest tests/test_pagos.py -v
```

## Criterios de calidad

- Nombres descriptivos: `test_calcular_total_con_descuento_retorna_precio_reducido`, no `test_1`
- Un assert por concepto (no combinar 5 asserts no relacionados en un test)
- Tests independientes entre sí (ninguno depende del resultado de otro)
- Sin lógica de negocio en los tests (no calcules resultados esperados, ponlos fijos)

## Archivos de referencia

- `references/pytest-patterns.md` — patrones, fixtures, mocks, parametrize para Python
- `references/junit-patterns.md` — JUnit 5, Mockito, @ParameterizedTest para Java

## Assets disponibles

- `assets/conftest_template.py` — plantilla base de conftest.py para proyectos Python
- `assets/TestBase.template.java` — clase base con configuración común para JUnit

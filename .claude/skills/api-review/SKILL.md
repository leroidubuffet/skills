---
name: api-review
description: Revisa el diseño de una API REST contra estándares profesionales. Úsalo cuando el usuario pida revisar una API, auditar endpoints, verificar convenciones REST, evaluar el diseño de rutas, o cuando quiera saber si su API sigue buenas prácticas. Funciona con Flask, FastAPI, Django REST, Spring Boot y JAX-RS.
argument-hint: "[ruta-del-proyecto]"
disable-model-invocation: true
allowed-tools: Bash(python *) Bash(python3 *)
---

# API Review

Revisa el diseño de una API REST e identifica problemas concretos con recomendaciones accionables.

## Proceso

### 1. Descubrir los endpoints

Ejecuta el script extractor sobre el directorio del proyecto:

```bash
python ${CLAUDE_SKILL_DIR}/scripts/extract-endpoints.py $ARGUMENTS
```

El script detecta automáticamente el framework (Flask, FastAPI, Spring, JAX-RS) e imprime una tabla con todos los endpoints encontrados: método HTTP, ruta, función/método que lo maneja, y si devuelve algo documentado.

Si el script no puede detectar el framework o no encuentra endpoints, pide al usuario que indique el archivo principal o el framework que usa.

### 2. Cargar el checklist

Lee `references/rest-checklist.md` completo antes de evaluar. Contiene los criterios organizados por categoría: nomenclatura, verbos HTTP, códigos de respuesta, versionado, paginación y seguridad.

Para los códigos de estado específicos, consulta `references/http-status-codes.md`.

### 3. Evaluar cada categoría

Revisa los endpoints contra cada categoría del checklist. Para cada problema encontrado, anota:
- Qué endpoint lo tiene
- Qué criterio viola
- Por qué es un problema
- Cómo corregirlo (con ejemplo concreto)

No reportes como problema algo que no ves en el código — sólo lo que puedas evidenciar en los endpoints extraídos.

### 4. Producir el reporte

Usa la plantilla `assets/review-report.template.md` para estructurar el reporte. Rellena cada sección con los hallazgos reales del paso 3.

Crea el archivo en el proyecto: `api-review-report.md` (en la raíz del proyecto o donde el usuario indique).

## Niveles de severidad

- **Crítico** — Rompe contratos REST o causa comportamiento impredecible para clientes
- **Mayor** — Viola convenciones ampliamente adoptadas, dificulta el consumo de la API
- **Menor** — Inconsistencias de estilo o mejoras de legibilidad

Reporta todos los niveles, pero sé explícito sobre cuáles requieren acción inmediata.

## Output esperado

Al terminar:

```
## Revisión completada

**Endpoints analizados:** 12
**Hallazgos:** 2 críticos, 3 mayores, 4 menores

Los problemas críticos están en los endpoints de creación de recursos — 
los detalles están en api-review-report.md
```

## Archivos de referencia

- `references/rest-checklist.md` — criterios de evaluación organizados por categoría
- `references/http-status-codes.md` — guía de cuándo usar cada código de estado

## Assets disponibles

- `assets/review-report.template.md` — plantilla para el reporte de revisión

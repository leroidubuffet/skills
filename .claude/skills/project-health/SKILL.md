---
name: project-health
description: Analiza la salud técnica de un proyecto Python o Java. Úsalo cuando el usuario quiera saber el estado del proyecto, evaluar deuda técnica, ver métricas de calidad, hacer un health check, auditar el estado del código, o antes de una entrega o code review importante.
argument-hint: "[ruta-del-proyecto]"
disable-model-invocation: true
allowed-tools: Bash(bash *)
---

# Project Health

Produce un diagnóstico objetivo de la salud técnica del proyecto con métricas concretas y recomendaciones priorizadas.

## Proceso

### 1. Ejecutar el análisis

Corre el script desde la raíz del proyecto:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/health-check.sh $ARGUMENTS
```

El script recolecta y muestra:
- Líneas de código por tipo de archivo
- Cantidad de archivos de test vs archivos de producción
- TODOs, FIXMEs y HACKs en el código
- Archivos de gestión de dependencias presentes
- Funciones/métodos demasiado largos (>50 líneas)
- Archivos demasiado largos (>300 líneas)
- Presencia de configuración de linting/formato
- Commits en los últimos 30 días (actividad reciente)

### 2. Interpretar los resultados

Lee `references/quality-metrics.md` para entender qué significan los números y cuáles son los rangos saludables para cada métrica.

No reportes los números crudos sin contexto. Por ejemplo, "120 TODOs" sin más no es útil — lo útil es si eso es mucho para el tamaño del proyecto y qué sugiere sobre la deuda técnica acumulada.

### 3. Identificar los 3 problemas principales

De todos los hallazgos, selecciona los 3 que más impactan la mantenibilidad y el riesgo del proyecto. Para cada uno:
- Describe el problema con datos concretos
- Explica el riesgo real que representa
- Da una recomendación accionable con esfuerzo estimado (horas, no días)

### 4. Producir el reporte

Usa `assets/health-report.template.md` para estructurar el output. Guarda el reporte como `project-health-report.md` en la raíz del proyecto.

## Escala de salud

| Score | Descripción |
|---|---|
| 🟢 Saludable | Métricas dentro de rangos normales, pocos problemas aislados |
| 🟡 Atención | Algunas métricas fuera de rango, deuda técnica manejable |
| 🔴 Crítico | Múltiples métricas problemáticas, riesgo real de regresiones |

Asigna un score general al proyecto y justifícalo con los datos.

## Output al terminar

```
## Análisis completado

**Proyecto:** payments-service
**Score:** 🟡 Atención
**Métricas analizadas:** 8

El mayor riesgo está en la ausencia de tests para el módulo de facturación.
Detalles en project-health-report.md
```

## Archivos de referencia

- `references/quality-metrics.md` — qué mide cada métrica y rangos saludables

## Assets disponibles

- `assets/health-report.template.md` — plantilla del reporte de salud

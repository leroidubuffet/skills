# Métricas de Calidad de Proyecto

## Ratio test/producción

**Qué mide**: proporción de archivos de test respecto a archivos de producción.

| Rango | Interpretación |
|---|---|
| > 80% | Saludable — buena cobertura estructural |
| 40–80% | Atención — cobertura parcial, hay riesgo en áreas sin tests |
| < 40% | Crítico — cambios sin red de seguridad |

**Contexto importante**: 
- Un proyecto con 5 archivos y ratio del 20% puede estar bien si el código es muy simple.
- Un proyecto legacy con 200 archivos y 15% de tests es un riesgo real.
- Los tests de integración no aparecen en este conteo pero cuentan como cobertura real.

---

## Líneas de código (LOC)

**Qué mide**: tamaño y complejidad superficial del proyecto.

| Rango | Interpretación |
|---|---|
| < 5.000 LOC | Proyecto pequeño — una persona puede entenderlo todo |
| 5.000–30.000 | Proyecto mediano — necesita documentación y módulos bien separados |
| > 30.000 LOC | Proyecto grande — necesita arquitectura clara y ownership por módulos |

**No es una métrica de calidad en sí misma**. Un proyecto de 500 LOC con 80 TODOs es peor que uno de 15.000 LOC ordenado.

---

## TODOs, FIXMEs y HACKs

**Qué mide**: deuda técnica explícitamente reconocida en el código.

| Rango | Interpretación |
|---|---|
| 0–5 | Saludable |
| 6–20 | Normal — revisarlos en la próxima iteración |
| 21–50 | Atención — señal de velocidad priorizada sobre calidad |
| > 50 | Crítico — deuda técnica acumulada, riesgo de regresiones |

**Distinción importante**:
- `TODO`: feature o mejora pendiente
- `FIXME`: bug conocido no corregido → mayor riesgo
- `HACK`: solución temporal forzada → riesgo de comportamiento inesperado

Los `FIXME` y `HACK` pesan más que los `TODO`.

---

## Archivos largos (>300 líneas)

**Qué mide**: concentración de responsabilidades en un solo archivo.

| Cantidad | Interpretación |
|---|---|
| 0 | Saludable |
| 1–3 | Normal si son archivos de configuración o modelos |
| > 3 | Atención — posibles god objects o módulos sin dividir |

**Umbral**: 300 líneas es una guía, no una ley. Un archivo de 350 líneas con buena estructura es mejor que 3 archivos de 80 líneas que se llaman entre sí sin sentido.

Un archivo de >500 líneas casi siempre tiene múltiples responsabilidades.

---

## Presencia de archivos de gestión de dependencias

**Qué indica su presencia o ausencia**:

| Archivo | Significado si falta |
|---|---|
| `requirements.txt` / `pyproject.toml` | Las deps no están declaradas → el proyecto no es reproducible |
| `poetry.lock` / `requirements.lock` | Las versiones exactas no están fijadas → riesgo de "funciona en mi máquina" |
| `pom.xml` / `build.gradle` | Proyecto Java sin build tool → manual o incompleto |

---

## Configuración de linting y formato

**Qué mide**: si el equipo tiene estándares de código automatizados.

Señal positiva: presencia de `.flake8`, `mypy.ini`, `pylintrc`, `checkstyle.xml`, config en `pyproject.toml` con `[tool.ruff]` o `[tool.black]`.

Ausencia de configuración de linting en proyectos medianos/grandes sugiere:
- Inconsistencia de estilo entre contribuidores
- Sin detección estática de bugs comunes
- Dificultad para onboarding de nuevos devs

---

## Actividad reciente (commits últimos 30 días)

**Qué mide**: salud del proyecto desde la perspectiva de desarrollo activo.

| Commits/30d | Interpretación |
|---|---|
| > 20 | Proyecto activo |
| 5–20 | Actividad moderada — normal para proyectos en mantenimiento |
| 1–4 | Poca actividad — puede ser intencional (proyecto estable) o señal de abandono |
| 0 | Sin actividad — ¿proyecto abandonado? ¿monorepo donde este módulo no cambia? |

**No es una métrica de calidad directa** — un proyecto estable puede tener pocos commits porque está terminado.

---

## Cómo combinar las métricas

Un diagnóstico justo considera el **contexto del proyecto**:

- Proyecto nuevo (<3 meses): ratio de tests bajo es esperado, pero los TODOs no
- Proyecto legacy (>5 años): muchos archivos largos son esperados, pero CVEs no
- Librería pública: cobertura de tests y versionado de deps son críticos
- Script interno: menos rigor es razonable

El score final (🟢/🟡/🔴) debe reflejar si el estado actual representa un **riesgo real** para el equipo, no sólo si cumple métricas ideales.

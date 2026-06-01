---
name: dep-audit
description: Audita dependencias de un proyecto Python o Java buscando vulnerabilidades conocidas y versiones desactualizadas. Úsalo cuando el usuario quiera revisar dependencias, buscar CVEs, chequear vulnerabilidades de seguridad, actualizar paquetes, o prepararse para un security review. Detecta automáticamente pip/poetry/Maven/Gradle.
argument-hint: "[ruta-del-proyecto]"
disable-model-invocation: true
allowed-tools: Bash(bash *) Bash(pip-audit *) Bash(pip *) Bash(poetry *) Bash(mvn *) Bash(./gradlew *)
---

# Dependency Audit

Audita las dependencias del proyecto, identifica vulnerabilidades conocidas y versiones desactualizadas, y produce un plan de acción priorizado.

## Proceso

### 1. Ejecutar la auditoría

Corre el script desde la raíz del proyecto:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/audit.sh $ARGUMENTS
```

El script detecta automáticamente el tipo de proyecto:
- Python con `requirements.txt` → usa `pip-audit`
- Python con `pyproject.toml`/`poetry.lock` → usa `pip-audit` vía poetry
- Java con `pom.xml` → usa `mvn dependency:analyze` + OWASP Dependency Check
- Java con `build.gradle` → usa `gradle dependencies` + OWASP plugin

Si alguna herramienta no está instalada, el script lo indica con instrucciones de instalación.

### 2. Interpretar los resultados

Lee `references/cve-guide.md` para entender los niveles de severidad CVSS, cómo priorizar y qué tipos de vulnerabilidades requieren acción inmediata vs. cuáles pueden esperar.

Para cada vulnerabilidad encontrada, determina:
- Severidad real en este contexto (una vuln de CVSS 9 en una dep de dev-only es diferente a una de CVSS 7 en prod)
- Si hay versión corregida disponible
- Si la actualización puede causar breaking changes

### 3. Clasificar y priorizar

Agrupa los hallazgos en:

**Acción inmediata** — CVEs activamente explotados o CVSS ≥ 9.0 en dependencias de producción

**Planificar en próximo sprint** — CVSS 7.0–8.9, o dependencias desactualizadas con más de 2 versiones major de atraso

**Backlog técnico** — CVSS < 7.0, dependencias de desarrollo, deprecaciones sin fecha definida

### 4. Producir el reporte

Usa `assets/audit-report.template.md` para estructurar el reporte. Incluye para cada vulnerabilidad: CVE ID, descripción breve, dependencia afectada, versión actual, versión corregida, y comando exacto para actualizar.

Guarda como `dep-audit-report.md` en la raíz del proyecto.

## Cuando las herramientas no están disponibles

Si `pip-audit` no está instalado:
```bash
pip install pip-audit
```

Si el proyecto Java no tiene el plugin OWASP, el script sugiere cómo añadirlo al `pom.xml` o `build.gradle`.

Como fallback, revisa manualmente las dependencias principales contra https://osv.dev (base de datos de vulnerabilidades de código abierto).

## Output al terminar

```
## Auditoría completada

**Dependencias analizadas:** 47
**Vulnerabilidades encontradas:** 2 críticas, 5 mayores, 3 menores
**Dependencias desactualizadas:** 8

Requiere acción inmediata: requests 2.26.0 (CVE-2023-32681)
Detalles en dep-audit-report.md
```

## Archivos de referencia

- `references/cve-guide.md` — sistema CVSS, niveles de severidad, estrategias de remediación

## Assets disponibles

- `assets/audit-report.template.md` — plantilla del reporte de auditoría

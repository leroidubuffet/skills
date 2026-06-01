---
name: pr-summary
description: Genera una descripción completa y estructurada para un Pull Request a partir del diff y el historial de commits. Úsalo cuando el usuario quiera escribir la descripción de un PR, documentar un pull request, preparar un merge request, o cuando diga "genera el PR" o "escribe el PR description". Produce título, resumen, tipo de cambio, checklist y notas de testing.
disable-model-invocation: true
allowed-tools: Bash(bash *) Bash(git *)
---

# PR Summary

Genera una descripción de Pull Request clara, completa y lista para revisión a partir del estado actual del repositorio.

## Proceso

### 1. Recolectar información del repositorio

Ejecuta el script desde la raíz del repositorio:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/collect-git-info.sh
```

El script imprime:
- Commits incluidos en la rama (respecto a main/master/develop)
- Archivos modificados con tipo de cambio (added/modified/deleted)
- Estadísticas del diff (líneas añadidas/eliminadas por archivo)
- Referencias a tickets mencionadas en commits (JIRA, GitHub issues, etc.)
- Nombre de la rama actual

### 2. Determinar el tipo de PR

Lee `references/pr-conventions.md` para identificar el tipo correcto basándote en los commits y archivos cambiados:

- **feat** — nueva funcionalidad para el usuario
- **fix** — corrección de bug
- **refactor** — cambio de código que no añade features ni corrige bugs
- **chore** — mantenimiento, dependencias, CI/CD, configuración
- **docs** — sólo documentación
- **test** — añadir o corregir tests

Si los cambios mezclan tipos, elige el dominante y menciónalo.

### 3. Elegir y rellenar la plantilla

Según el tipo, usa la plantilla correspondiente de `assets/`:
- `feat` → `assets/feature.template.md`
- `fix` → `assets/fix.template.md`
- `refactor`, `chore`, `docs`, `test` → `assets/refactor.template.md`

Rellena cada sección con información real del diff — no dejes placeholders genéricos. Si una sección no aplica, elimínala en lugar de dejarla vacía.

### 4. Título del PR

Formato: `<tipo>(<scope>): <descripción imperativa corta>`

Ejemplos:
- `feat(auth): add OAuth2 login with Google`
- `fix(payments): handle null response from payment gateway`
- `refactor(users): extract UserRepository from UserService`

Máximo 72 caracteres. Sin punto al final.

### 5. Output

Muestra la descripción completa en el chat para que el usuario la revise antes de usarla. Si el usuario quiere ajustes, incorpóralos. Al confirmar, opcionalmente guarda como `PR_DESCRIPTION.md`.

No uses `gh pr create` ni interactúes con GitHub a menos que el usuario lo pida explícitamente.

## Criterios de calidad

- El título explica el QUÉ, el cuerpo explica el POR QUÉ
- La sección "Motivación" responde: ¿qué problema resuelve esto?
- El checklist de testing refleja lo que realmente hay que verificar, no pasos genéricos
- Sin frases vacías como "various improvements" o "misc fixes"

## Archivos de referencia

- `references/pr-conventions.md` — tipos de PR, convenciones de commits, estructura recomendada

## Assets disponibles

- `assets/feature.template.md` — template para PRs de nueva funcionalidad
- `assets/fix.template.md` — template para PRs de corrección de bugs
- `assets/refactor.template.md` — template para refactors, chores y mantenimiento

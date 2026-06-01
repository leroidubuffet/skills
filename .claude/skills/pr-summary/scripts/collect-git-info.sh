#!/usr/bin/env bash
# Recolecta información del repositorio git para generar la descripción del PR.
# Uso: bash collect-git-info.sh
# Ejecutar desde la raíz del repositorio.

set -euo pipefail

SEP="============================================================"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: este directorio no es un repositorio git."
  exit 1
fi

echo ""
echo "$SEP"
echo "  GIT INFO — PR Summary"
echo "$SEP"

# --- Rama actual y base ---
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)
echo ""
echo "Rama actual: $CURRENT_BRANCH"

# Determinar rama base (main, master o develop)
BASE_BRANCH=""
for candidate in main master develop; do
  if git show-ref --verify --quiet "refs/heads/$candidate" || \
     git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
    BASE_BRANCH="$candidate"
    break
  fi
done

if [ -z "$BASE_BRANCH" ]; then
  BASE_BRANCH="main"
  echo "Rama base (asumida): $BASE_BRANCH"
else
  echo "Rama base detectada: $BASE_BRANCH"
fi

# --- Commits incluidos ---
echo ""
echo "── Commits en esta rama ─────────────────────────────────"
COMMITS=$(git log "$BASE_BRANCH".."$CURRENT_BRANCH" --oneline 2>/dev/null)
if [ -z "$COMMITS" ]; then
  echo "  (sin commits nuevos respecto a $BASE_BRANCH)"
else
  echo "$COMMITS" | sed 's/^/  /'
  COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
  echo ""
  echo "  Total: $COMMIT_COUNT commit(s)"
fi

# --- Archivos modificados ---
echo ""
echo "── Archivos modificados ─────────────────────────────────"
git diff --name-status "$BASE_BRANCH".."$CURRENT_BRANCH" 2>/dev/null | \
  awk '{
    if ($1 == "A") status="[añadido] "
    else if ($1 == "M") status="[modificado]"
    else if ($1 == "D") status="[eliminado]"
    else if ($1 ~ /^R/) status="[renombrado]"
    else status="[" $1 "]"
    print "  " status " " $2
  }' | head -40

CHANGED_COUNT=$(git diff --name-only "$BASE_BRANCH".."$CURRENT_BRANCH" 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "  Total archivos: $CHANGED_COUNT"

# --- Estadísticas del diff ---
echo ""
echo "── Estadísticas ─────────────────────────────────────────"
git diff --stat "$BASE_BRANCH".."$CURRENT_BRANCH" 2>/dev/null | tail -1 | sed 's/^/  /'

# --- Referencias a tickets ---
echo ""
echo "── Referencias a tickets ────────────────────────────────"
TICKETS=$(git log "$BASE_BRANCH".."$CURRENT_BRANCH" --oneline 2>/dev/null | \
  grep -oE '([A-Z]{2,10}-[0-9]+|#[0-9]+)' | sort -u)

if [ -n "$TICKETS" ]; then
  echo "$TICKETS" | sed 's/^/  /'
else
  echo "  (no se detectaron referencias a tickets)"
fi

# --- Tipo de cambio sugerido ---
echo ""
echo "── Tipo sugerido (basado en commits) ────────────────────"
COMMIT_MSGS=$(git log "$BASE_BRANCH".."$CURRENT_BRANCH" --format="%s" 2>/dev/null | tr '[:upper:]' '[:lower:]')

if echo "$COMMIT_MSGS" | grep -qE "^(feat|add|new|implement|create)"; then
  echo "  → feat (nueva funcionalidad)"
elif echo "$COMMIT_MSGS" | grep -qE "^(fix|bug|hotfix|patch|resolve)"; then
  echo "  → fix (corrección de bug)"
elif echo "$COMMIT_MSGS" | grep -qE "^(refactor|clean|improve|move|rename|extract)"; then
  echo "  → refactor"
elif echo "$COMMIT_MSGS" | grep -qE "^(test|spec)"; then
  echo "  → test"
elif echo "$COMMIT_MSGS" | grep -qE "^(docs|doc|readme)"; then
  echo "  → docs"
elif echo "$COMMIT_MSGS" | grep -qE "^(chore|build|ci|deps|update)"; then
  echo "  → chore"
else
  echo "  → no determinado (revisar manualmente)"
fi

echo ""
echo "$SEP"
echo "  Información recolectada. El agente generará el PR description."
echo "$SEP"
echo ""

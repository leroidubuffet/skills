#!/usr/bin/env bash
# Analiza métricas de salud de un proyecto Python o Java.
# Uso: bash health-check.sh <ruta-del-proyecto>

set -euo pipefail

PROJECT="${1:-.}"
cd "$PROJECT" || { echo "Error: no se puede acceder a '$PROJECT'"; exit 1; }

SEP="============================================================"
echo ""
echo "$SEP"
echo "  PROJECT HEALTH CHECK"
echo "  $(pwd)"
echo "$SEP"

# --- Detectar lenguaje ---
PY_COUNT=$(find . -name "*.py" -not -path "*/\.*" -not -path "*/venv/*" -not -path "*/__pycache__/*" 2>/dev/null | wc -l | tr -d ' ')
JAVA_COUNT=$(find . -name "*.java" -not -path "*/\.*" 2>/dev/null | wc -l | tr -d ' ')

if [ "$PY_COUNT" -gt "$JAVA_COUNT" ]; then
  LANG="python"
  SRC_EXT="py"
else
  LANG="java"
  SRC_EXT="java"
fi

echo ""
echo "Lenguaje principal: $LANG ($PY_COUNT .py | $JAVA_COUNT .java)"

# --- Líneas de código ---
echo ""
echo "── Líneas de código ──────────────────────────────────────"
if [ "$LANG" = "python" ]; then
  PROD_FILES=$(find . -name "*.py" -not -path "*/test*" -not -path "*/venv/*" -not -path "*/__pycache__/*" -not -name "test_*" 2>/dev/null)
  TEST_FILES=$(find . -name "test_*.py" -o -name "*_test.py" 2>/dev/null)
else
  PROD_FILES=$(find . -name "*.java" -not -path "*/test/*" -not -name "*Test.java" 2>/dev/null)
  TEST_FILES=$(find . -name "*Test.java" -path "*/test/*" 2>/dev/null)
fi

PROD_LINES=0
PROD_FILE_COUNT=0
for f in $PROD_FILES; do
  [ -f "$f" ] || continue
  LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
  PROD_LINES=$((PROD_LINES + LINES))
  PROD_FILE_COUNT=$((PROD_FILE_COUNT + 1))
done

TEST_LINES=0
TEST_FILE_COUNT=0
for f in $TEST_FILES; do
  [ -f "$f" ] || continue
  LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
  TEST_LINES=$((TEST_LINES + LINES))
  TEST_FILE_COUNT=$((TEST_FILE_COUNT + 1))
done

echo "  Archivos producción : $PROD_FILE_COUNT archivos, $PROD_LINES líneas"
echo "  Archivos de test    : $TEST_FILE_COUNT archivos, $TEST_LINES líneas"
if [ "$PROD_FILE_COUNT" -gt 0 ]; then
  RATIO=$(echo "scale=1; $TEST_FILE_COUNT * 100 / $PROD_FILE_COUNT" | bc 2>/dev/null || echo "?")
  echo "  Ratio test/prod     : ${RATIO}%"
fi

# --- Deuda técnica en comentarios ---
echo ""
echo "── Deuda técnica en comentarios ─────────────────────────"
TODO_COUNT=$(grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.$SRC_EXT" . 2>/dev/null | grep -v "^\./\." | wc -l | tr -d ' ')
echo "  TODOs/FIXMEs/HACKs  : $TODO_COUNT"

if [ "$TODO_COUNT" -gt 0 ]; then
  echo ""
  echo "  Top 5 más recientes:"
  grep -rn "TODO\|FIXME\|HACK" --include="*.$SRC_EXT" . 2>/dev/null | \
    grep -v "^\./\." | head -5 | \
    sed 's/^/    /'
fi

# --- Archivos demasiado largos ---
echo ""
echo "── Archivos largos (>300 líneas) ────────────────────────"
LONG_FILES=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
  if [ "$LINES" -gt 300 ]; then
    LONG_FILES=$((LONG_FILES + 1))
    echo "  $LINES líneas  $f"
  fi
done < <(find . -name "*.$SRC_EXT" -not -path "*/\.*" -not -path "*/venv/*" 2>/dev/null)

[ "$LONG_FILES" -eq 0 ] && echo "  Ninguno — bien."

# --- Gestión de dependencias ---
echo ""
echo "── Gestión de dependencias ───────────────────────────────"
check_file() { [ -f "$1" ] && echo "  ✓ $1" || echo "  ✗ $1 (no encontrado)"; }

if [ "$LANG" = "python" ]; then
  check_file "requirements.txt"
  check_file "pyproject.toml"
  check_file "poetry.lock"
  check_file "setup.py"
else
  check_file "pom.xml"
  check_file "build.gradle"
  check_file "build.gradle.kts"
fi

# --- Configuración de calidad ---
echo ""
echo "── Configuración de calidad de código ───────────────────"
if [ "$LANG" = "python" ]; then
  check_file ".flake8"
  check_file "pyproject.toml"  # puede tener ruff/black config
  check_file ".pylintrc"
  check_file "mypy.ini"
  [ -f "pyproject.toml" ] && grep -q "\[tool.ruff\]\|\[tool.black\]\|\[tool.mypy\]" pyproject.toml 2>/dev/null && \
    echo "  ✓ linter/formatter configurado en pyproject.toml"
else
  check_file "checkstyle.xml"
  check_file ".editorconfig"
  [ -f "pom.xml" ] && grep -q "spotbugs\|checkstyle\|pmd" pom.xml 2>/dev/null && \
    echo "  ✓ análisis estático configurado en pom.xml"
fi

# --- Actividad reciente (git) ---
echo ""
echo "── Actividad reciente (git) ──────────────────────────────"
if git rev-parse --git-dir > /dev/null 2>&1; then
  COMMITS_30=$(git log --oneline --since="30 days ago" 2>/dev/null | wc -l | tr -d ' ')
  CONTRIBUTORS=$(git log --since="30 days ago" --format="%ae" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  LAST_COMMIT=$(git log -1 --format="%ar" 2>/dev/null || echo "desconocido")
  echo "  Commits últimos 30d : $COMMITS_30"
  echo "  Contribuidores      : $CONTRIBUTORS"
  echo "  Último commit       : $LAST_COMMIT"
else
  echo "  (no es un repositorio git)"
fi

# --- Resumen rápido ---
echo ""
echo "── Resumen ───────────────────────────────────────────────"
echo "  Lenguaje    : $LANG"
echo "  Prod LOC    : $PROD_LINES"
echo "  Test LOC    : $TEST_LINES"
echo "  TODOs       : $TODO_COUNT"
echo "  Archivos largos: $LONG_FILES"
echo ""
echo "$SEP"
echo "  Análisis completado. El agente interpretará estos resultados."
echo "$SEP"
echo ""

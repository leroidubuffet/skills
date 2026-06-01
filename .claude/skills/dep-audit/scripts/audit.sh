#!/usr/bin/env bash
# Audita dependencias de un proyecto Python o Java buscando vulnerabilidades.
# Uso: bash audit.sh <ruta-del-proyecto>

set -euo pipefail

PROJECT="${1:-.}"
cd "$PROJECT" || { echo "Error: no se puede acceder a '$PROJECT'"; exit 1; }

SEP="============================================================"
echo ""
echo "$SEP"
echo "  DEPENDENCY AUDIT"
echo "  $(pwd)"
echo "$SEP"

# --- Detectar tipo de proyecto ---
LANG=""
PKG_MANAGER=""

if [ -f "pyproject.toml" ] && grep -q "\[tool.poetry\]" pyproject.toml 2>/dev/null; then
  LANG="python"; PKG_MANAGER="poetry"
elif [ -f "requirements.txt" ]; then
  LANG="python"; PKG_MANAGER="pip"
elif [ -f "pom.xml" ]; then
  LANG="java"; PKG_MANAGER="maven"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  LANG="java"; PKG_MANAGER="gradle"
else
  echo "No se detectó un proyecto Python o Java conocido."
  echo "Archivos buscados: requirements.txt, pyproject.toml, pom.xml, build.gradle"
  exit 1
fi

echo ""
echo "Proyecto detectado: $LANG / $PKG_MANAGER"

# ─────────────────────────────────────────────
# PYTHON
# ─────────────────────────────────────────────
if [ "$LANG" = "python" ]; then

  echo ""
  echo "── Dependencias declaradas ──────────────────────────────"
  if [ "$PKG_MANAGER" = "poetry" ]; then
    poetry show 2>/dev/null | head -30 || echo "  (ejecutar con poetry activo)"
  else
    echo "  Leyendo requirements.txt..."
    cat requirements.txt | grep -v "^#" | grep -v "^$" | head -30
    TOTAL=$(cat requirements.txt | grep -v "^#" | grep -v "^$" | wc -l | tr -d ' ')
    echo "  Total: $TOTAL dependencias"
  fi

  echo ""
  echo "── Escaneo de vulnerabilidades (pip-audit) ──────────────"
  if command -v pip-audit &> /dev/null; then
    if [ "$PKG_MANAGER" = "poetry" ]; then
      pip-audit --requirement <(poetry export --without-hashes 2>/dev/null) 2>/dev/null || \
      pip-audit 2>/dev/null || echo "  Error al correr pip-audit con poetry."
    else
      pip-audit -r requirements.txt 2>/dev/null || pip-audit 2>/dev/null
    fi
  else
    echo "  pip-audit no está instalado."
    echo ""
    echo "  Para instalarlo:"
    echo "    pip install pip-audit"
    echo ""
    echo "  Alternativa — revisar manualmente en https://osv.dev"
    echo "  o correr: pip list --outdated"
  fi

  echo ""
  echo "── Dependencias desactualizadas ─────────────────────────"
  pip list --outdated 2>/dev/null | head -20 || echo "  (requiere entorno virtual activo)"

fi

# ─────────────────────────────────────────────
# JAVA
# ─────────────────────────────────────────────
if [ "$LANG" = "java" ]; then

  echo ""
  echo "── Dependencias declaradas ──────────────────────────────"
  if [ "$PKG_MANAGER" = "maven" ]; then
    mvn dependency:list -q 2>/dev/null | grep ":compile\|:runtime\|:test" | head -30 || \
      echo "  (mvn no disponible o error en el proyecto)"
    echo ""
    echo "  Analizando dependencias no usadas / faltantes..."
    mvn dependency:analyze -q 2>/dev/null | grep "WARNING\|Used undeclared\|Unused declared" | head -20 || true
  else
    ./gradlew dependencies --configuration compileClasspath 2>/dev/null | head -40 || \
      echo "  (gradlew no disponible)"
  fi

  echo ""
  echo "── Escaneo de vulnerabilidades (OWASP Dependency Check) ─"
  if command -v dependency-check &> /dev/null; then
    dependency-check --project "audit" --scan . --format TEXT --out /tmp/dep-check-report 2>/dev/null
    cat /tmp/dep-check-report/dependency-check-report.txt 2>/dev/null | grep -A3 "VULNERABLE\|CVE" | head -50
  elif [ "$PKG_MANAGER" = "maven" ]; then
    echo "  Intentando con plugin OWASP en Maven..."
    mvn org.owasp:dependency-check-maven:check -q 2>/dev/null || {
      echo "  Plugin OWASP no configurado."
      echo ""
      echo "  Para añadirlo al pom.xml:"
      echo "    <plugin>"
      echo "      <groupId>org.owasp</groupId>"
      echo "      <artifactId>dependency-check-maven</artifactId>"
      echo "      <version>9.0.9</version>"
      echo "    </plugin>"
      echo ""
      echo "  Alternativa: https://deps.dev — análisis gratuito de dependencias Java"
    }
  else
    echo "  OWASP Dependency Check no está instalado."
    echo ""
    echo "  Opciones:"
    echo "    1. Instalar CLI: https://jeremylong.github.io/DependencyCheck/dependency-check-cli/"
    echo "    2. Usar https://deps.dev para análisis manual"
    echo "    3. Configurar el plugin en build.gradle:"
    echo "       id 'org.owasp.dependencycheck' version '9.0.9'"
  fi

  echo ""
  echo "── Versiones desactualizadas ─────────────────────────────"
  if [ "$PKG_MANAGER" = "maven" ]; then
    mvn versions:display-dependency-updates -q 2>/dev/null | grep "\->" | head -20 || \
      echo "  (requiere mvn versions plugin)"
  else
    ./gradlew dependencyUpdates 2>/dev/null | grep "The following dependencies" -A 20 | head -25 || \
      echo "  (requiere plugin com.github.ben-manes.versions)"
  fi

fi

echo ""
echo "$SEP"
echo "  Auditoría completada. El agente interpretará los resultados."
echo "$SEP"
echo ""

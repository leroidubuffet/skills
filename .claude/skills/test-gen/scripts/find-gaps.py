#!/usr/bin/env python3
"""
Identifica funciones y métodos sin tests correspondientes.
Uso: python find-gaps.py <ruta-archivo-o-directorio>
"""

import ast
import sys
import os
from pathlib import Path


def find_python_functions(filepath: Path) -> list[dict]:
    """Extrae funciones y métodos de un archivo Python."""
    try:
        source = filepath.read_text(encoding="utf-8")
        tree = ast.parse(source)
    except (SyntaxError, UnicodeDecodeError) as e:
        print(f"  [!] No se pudo parsear {filepath}: {e}", file=sys.stderr)
        return []

    functions = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            if not node.name.startswith("_"):
                functions.append({
                    "name": node.name,
                    "line": node.lineno,
                    "file": str(filepath),
                })
        elif isinstance(node, ast.ClassDef):
            for item in node.body:
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    if not item.name.startswith("_") or item.name in ("__init__", "__call__"):
                        functions.append({
                            "name": f"{node.name}.{item.name}",
                            "line": item.lineno,
                            "file": str(filepath),
                        })
    return functions


def find_java_functions(filepath: Path) -> list[dict]:
    """Extrae métodos públicos de un archivo Java (parsing simple por texto)."""
    functions = []
    try:
        lines = filepath.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        return []

    import re
    method_pattern = re.compile(
        r'^\s*(public|protected)\s+(?:static\s+)?(?:\w+(?:<[^>]+>)?)\s+(\w+)\s*\('
    )
    class_pattern = re.compile(r'^\s*(?:public\s+)?class\s+(\w+)')
    current_class = "Unknown"

    for i, line in enumerate(lines, start=1):
        class_match = class_pattern.match(line)
        if class_match:
            current_class = class_match.group(1)
        method_match = method_pattern.match(line)
        if method_match:
            method_name = method_match.group(2)
            if method_name not in ("if", "while", "for", "switch", "catch"):
                functions.append({
                    "name": f"{current_class}.{method_name}",
                    "line": i,
                    "file": str(filepath),
                })
    return functions


def find_test_names(test_dir: Path, language: str) -> set[str]:
    """Recolecta nombres de tests existentes para detectar cobertura."""
    tested = set()
    if language == "python":
        pattern = "test_*.py"
        for test_file in test_dir.rglob(pattern):
            try:
                source = test_file.read_text(encoding="utf-8")
                tree = ast.parse(source)
                for node in ast.walk(tree):
                    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                        name = node.name.replace("test_", "").lower()
                        tested.add(name)
            except Exception:
                pass
    elif language == "java":
        import re
        for test_file in test_dir.rglob("*Test.java"):
            try:
                content = test_file.read_text(encoding="utf-8")
                for match in re.finditer(r'@Test.*?\s+(?:public\s+)?void\s+(\w+)', content, re.DOTALL):
                    tested.add(match.group(1).lower())
            except Exception:
                pass
    return tested


def analyze(target: str):
    path = Path(target)
    if not path.exists():
        print(f"Error: '{target}' no existe.", file=sys.stderr)
        sys.exit(1)

    py_files = list(path.rglob("*.py")) if path.is_dir() else ([path] if path.suffix == ".py" else [])
    java_files = list(path.rglob("*.java")) if path.is_dir() else ([path] if path.suffix == ".java" else [])

    # Excluir archivos de test del análisis de producción
    py_src = [f for f in py_files if "test" not in f.parts and not f.name.startswith("test_")]
    java_src = [f for f in java_files if "test" not in str(f) and not f.name.endswith("Test.java")]

    language = "python" if py_src else ("java" if java_src else None)
    if not language:
        print("No se encontraron archivos Python o Java de producción.", file=sys.stderr)
        sys.exit(1)

    test_dir = path if path.is_dir() else path.parent
    tested_names = find_test_names(test_dir, language)

    print(f"\n{'='*60}")
    print(f"  Análisis de cobertura — {language.upper()}")
    print(f"{'='*60}\n")

    all_functions = []
    source_files = py_src if language == "python" else java_src
    for src_file in source_files:
        if language == "python":
            all_functions.extend(find_python_functions(src_file))
        else:
            all_functions.extend(find_java_functions(src_file))

    untested = []
    for func in all_functions:
        simple_name = func["name"].split(".")[-1].lower()
        if simple_name not in tested_names and f"test_{simple_name}" not in tested_names:
            untested.append(func)

    if not untested:
        print("✓ Todas las funciones públicas encontradas tienen tests correspondientes.\n")
        return

    print(f"Funciones/métodos sin tests detectados: {len(untested)}\n")
    print(f"{'Función/Método':<40} {'Archivo':<35} {'Línea'}")
    print("-" * 85)
    for func in untested:
        rel_path = func["file"].replace(str(path), "").lstrip("/")
        print(f"{func['name']:<40} {rel_path:<35} {func['line']}")

    print(f"\nTotal analizado: {len(all_functions)} funciones | Sin tests: {len(untested)}")
    coverage = round((1 - len(untested) / max(len(all_functions), 1)) * 100)
    print(f"Cobertura estimada (por presencia de test): ~{coverage}%\n")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python find-gaps.py <ruta-archivo-o-directorio>")
        sys.exit(1)
    analyze(sys.argv[1])

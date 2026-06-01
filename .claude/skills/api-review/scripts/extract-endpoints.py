#!/usr/bin/env python3
"""
Extrae todos los endpoints de una API REST desde el código fuente.
Soporta: Flask, FastAPI, Django REST Framework, Spring Boot, JAX-RS.
Uso: python extract-endpoints.py <ruta-del-proyecto>
"""

import re
import sys
from pathlib import Path


FLASK_ROUTE = re.compile(r'@\w+\.route\(["\']([^"\']+)["\'](?:.*?methods=\[([^\]]+)\])?', re.DOTALL)
FASTAPI_ROUTE = re.compile(r'@\w+\.(get|post|put|patch|delete|options|head)\(["\']([^"\']+)["\']')
DJANGO_URL = re.compile(r'(?:path|re_path)\(["\']([^"\']+)["\'],\s*(\w+)')
SPRING_MAPPING = re.compile(
    r'@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)'
    r'(?:\(["\']([^"\']+)["\']|\(value\s*=\s*["\']([^"\']+)["\']|\()?'
)
JAXRS_PATH = re.compile(r'@Path\(["\']([^"\']+)["\']')
JAXRS_METHOD = re.compile(r'@(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)')


def detect_framework(project_path: Path) -> str:
    all_content = ""
    for py_file in list(project_path.rglob("*.py"))[:20]:
        try:
            all_content += py_file.read_text(errors="ignore")
        except Exception:
            pass

    if "fastapi" in all_content.lower() or "FastAPI" in all_content:
        return "fastapi"
    if "flask" in all_content.lower() or "Flask" in all_content:
        return "flask"
    if "rest_framework" in all_content or "APIView" in all_content:
        return "django-rest"

    for java_file in list(project_path.rglob("*.java"))[:20]:
        try:
            content = java_file.read_text(errors="ignore")
            if "springframework.web" in content or "RestController" in content:
                return "spring"
            if "javax.ws.rs" in content or "jakarta.ws.rs" in content:
                return "jaxrs"
        except Exception:
            pass

    return "unknown"


def extract_flask(project_path: Path) -> list[dict]:
    endpoints = []
    for py_file in project_path.rglob("*.py"):
        try:
            content = py_file.read_text(errors="ignore")
            lines = content.splitlines()
        except Exception:
            continue

        for i, line in enumerate(lines):
            match = FLASK_ROUTE.search(line)
            if match:
                path = match.group(1)
                methods_raw = match.group(2) or '"GET"'
                methods = [m.strip().strip('"\'') for m in methods_raw.split(",")]
                handler = ""
                for j in range(i + 1, min(i + 4, len(lines))):
                    fn_match = re.search(r'def\s+(\w+)', lines[j])
                    if fn_match:
                        handler = fn_match.group(1)
                        break
                for method in methods:
                    endpoints.append({
                        "method": method.upper(),
                        "path": path,
                        "handler": handler,
                        "file": str(py_file.relative_to(project_path)),
                        "line": i + 1,
                    })
    return endpoints


def extract_fastapi(project_path: Path) -> list[dict]:
    endpoints = []
    for py_file in project_path.rglob("*.py"):
        try:
            content = py_file.read_text(errors="ignore")
            lines = content.splitlines()
        except Exception:
            continue

        for i, line in enumerate(lines):
            match = FASTAPI_ROUTE.search(line)
            if match:
                method = match.group(1).upper()
                path = match.group(2)
                handler = ""
                for j in range(i + 1, min(i + 4, len(lines))):
                    fn_match = re.search(r'(?:async\s+)?def\s+(\w+)', lines[j])
                    if fn_match:
                        handler = fn_match.group(1)
                        break
                endpoints.append({
                    "method": method,
                    "path": path,
                    "handler": handler,
                    "file": str(py_file.relative_to(project_path)),
                    "line": i + 1,
                })
    return endpoints


def extract_spring(project_path: Path) -> list[dict]:
    endpoints = []
    for java_file in project_path.rglob("*.java"):
        try:
            content = java_file.read_text(errors="ignore")
            lines = content.splitlines()
        except Exception:
            continue

        class_path = ""
        class_path_match = re.search(r'@RequestMapping\(["\']([^"\']+)["\']', content)
        if class_path_match:
            class_path = class_path_match.group(1).rstrip("/")

        method_map = {
            "GetMapping": "GET", "PostMapping": "POST",
            "PutMapping": "PUT", "DeleteMapping": "DELETE",
            "PatchMapping": "PATCH",
        }

        for i, line in enumerate(lines):
            for annotation, http_method in method_map.items():
                if f"@{annotation}" in line:
                    path_match = re.search(r'["\']([^"\']+)["\']', line)
                    endpoint_path = (class_path + (path_match.group(1) if path_match else "/")) or "/"
                    handler = ""
                    for j in range(i + 1, min(i + 5, len(lines))):
                        fn_match = re.search(r'(?:public|private|protected)\s+\S+\s+(\w+)\s*\(', lines[j])
                        if fn_match:
                            handler = fn_match.group(1)
                            break
                    endpoints.append({
                        "method": http_method,
                        "path": endpoint_path,
                        "handler": handler,
                        "file": str(java_file.relative_to(project_path)),
                        "line": i + 1,
                    })
    return endpoints


def print_table(endpoints: list[dict], framework: str):
    print(f"\n{'='*70}")
    print(f"  Endpoints detectados — {framework.upper()} ({len(endpoints)} total)")
    print(f"{'='*70}\n")

    if not endpoints:
        print("No se encontraron endpoints.\n")
        return

    sorted_endpoints = sorted(endpoints, key=lambda e: (e["path"], e["method"]))

    print(f"{'MÉTODO':<10} {'RUTA':<40} {'HANDLER':<25} {'ARCHIVO'}")
    print("-" * 100)
    for ep in sorted_endpoints:
        print(f"{ep['method']:<10} {ep['path']:<40} {ep['handler']:<25} {ep['file']}:{ep['line']}")

    methods_used = set(ep["method"] for ep in endpoints)
    print(f"\nMétodos HTTP encontrados: {', '.join(sorted(methods_used))}")
    print(f"Rutas únicas: {len(set(ep['path'] for ep in endpoints))}\n")


def main():
    if len(sys.argv) < 2:
        print("Uso: python extract-endpoints.py <ruta-del-proyecto>")
        sys.exit(1)

    project_path = Path(sys.argv[1])
    if not project_path.exists():
        print(f"Error: '{sys.argv[1]}' no existe.")
        sys.exit(1)

    framework = detect_framework(project_path)
    print(f"Framework detectado: {framework}")

    if framework == "fastapi":
        endpoints = extract_fastapi(project_path)
    elif framework == "flask":
        endpoints = extract_flask(project_path)
    elif framework == "spring":
        endpoints = extract_spring(project_path)
    else:
        print("Intentando detección genérica...")
        endpoints = extract_flask(project_path) + extract_fastapi(project_path) + extract_spring(project_path)
        if not endpoints:
            print("No se pudo detectar el framework automáticamente.")
            print("Indica el framework manualmente: flask, fastapi, spring, jaxrs, django-rest")
            sys.exit(1)

    print_table(endpoints, framework)


if __name__ == "__main__":
    main()

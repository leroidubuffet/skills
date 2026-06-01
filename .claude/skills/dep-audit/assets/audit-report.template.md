# Dependency Audit Report

**Proyecto**: [nombre]  
**Fecha**: [fecha]  
**Lenguaje / Package manager**: [Python-pip / Python-poetry / Java-Maven / Java-Gradle]  
**Dependencias analizadas**: N  
**Generado por**: Claude (skill dep-audit)

---

## Resumen ejecutivo

[2-3 frases sobre el estado de seguridad. Menciona si hay algo que requiere acción urgente.]

| Categoría | Cantidad |
|---|---|
| 🔴 Vulnerabilidades críticas (CVSS ≥ 9.0) | N |
| 🟠 Vulnerabilidades altas (CVSS 7.0–8.9) | N |
| 🟡 Vulnerabilidades medias (CVSS 4.0–6.9) | N |
| 🔵 Vulnerabilidades bajas (CVSS < 4.0) | N |
| ⬆️ Dependencias desactualizadas | N |
| 🪦 Dependencias deprecadas/sin mantenimiento | N |

---

## Acción inmediata

> Vulnerabilidades que deben parchearse esta semana.

### [DEP-1] [nombre-libreria] [versión-actual] → CVE-XXXX-XXXXX

**Severidad**: Crítica / Alta (CVSS N.N)  
**Versión afectada**: < X.Y.Z  
**Versión con fix**: X.Y.Z  
**Descripción**: [qué permite hacer esta vulnerabilidad]  
**Impacto en este proyecto**: [si la funcionalidad vulnerable se usa, si es accesible desde internet, etc.]

**Comando de actualización**:
```bash
# Python
pip install nombre-libreria==X.Y.Z

# Maven — cambiar en pom.xml:
# <version>X.Y.Z</version>

# Gradle — cambiar en build.gradle:
# implementation 'grupo:nombre:X.Y.Z'
```

**¿Puede causar breaking changes?**: Sí / No  
**Notas**: [si hay consideraciones especiales para esta actualización]

---

## Planificar en próximo sprint

> CVSS 7.0–8.9 o dependencias con retraso significativo de versiones.

| Librería | Versión actual | Versión recomendada | CVE / Motivo | Esfuerzo |
|---|---|---|---|---|
| [nombre] | X.Y.Z | X.Y.W | CVE-XXXX-XXXXX | Bajo |
| [nombre] | X.Y.Z | X.Y.W | 3 versiones major de retraso | Medio |

---

## Backlog técnico

> Baja prioridad — incluir en mantenimiento regular.

| Librería | Versión actual | Versión recomendada | Motivo |
|---|---|---|---|
| [nombre] | X.Y.Z | X.Y.W | CVSS < 4.0 |
| [nombre] | X.Y.Z | X.Y.W | Deprecada, alternativa disponible |

---

## Dependencias sin vulnerabilidades conocidas

[N dependencias analizadas sin CVEs activos al momento de este reporte.]

---

## Notas

- Este reporte refleja el estado al [fecha]. Las bases de datos de CVE se actualizan diariamente.
- Las vulnerabilidades en dependencias transitivas pueden requerir actualizar la dependencia directa que las incluye.
- Verificar actualizaciones en: https://osv.dev

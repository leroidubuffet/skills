# API Review Report

**Proyecto**: [nombre del proyecto]  
**Fecha**: [fecha]  
**Framework**: [Flask / FastAPI / Spring Boot / JAX-RS]  
**Endpoints analizados**: [N]  
**Revisado por**: Claude (skill api-review)

---

## Resumen ejecutivo

[2-3 frases describiendo el estado general de la API. Menciona el punto más fuerte y el problema más importante.]

| Severidad | Cantidad |
|---|---|
| 🔴 Crítico | N |
| 🟡 Mayor | N |
| 🔵 Menor | N |

---

## Hallazgos críticos

> Problemas que rompen contratos REST o causan comportamiento impredecible.

### [C1] [Título del problema]

**Endpoint afectado**: `MÉTODO /ruta`  
**Criterio violado**: [qué principio REST se viola]

**Problema**:  
[Descripción del problema con contexto concreto]

**Ejemplo actual**:
```
[código o request/response actual]
```

**Corrección recomendada**:
```
[cómo debería ser]
```

---

## Hallazgos mayores

> Violaciones de convenciones ampliamente adoptadas que dificultan el consumo de la API.

### [M1] [Título del problema]

**Endpoint(s) afectados**: `MÉTODO /ruta`  
**Criterio violado**: [criterio]

**Problema**: [descripción breve]

**Recomendación**: [qué cambiar]

---

### [M2] [Título del problema]

**Endpoint(s) afectados**: `MÉTODO /ruta`

**Problema**: [descripción breve]

**Recomendación**: [qué cambiar]

---

## Hallazgos menores

> Inconsistencias de estilo o mejoras de legibilidad. Bajo impacto pero mejoran la DX.

| # | Endpoint | Problema | Recomendación |
|---|---|---|---|
| M1 | `GET /ruta` | [descripción breve] | [fix] |
| M2 | `POST /ruta` | [descripción breve] | [fix] |

---

## Lo que está bien

> Aspectos del diseño que siguen buenas prácticas y deben mantenerse.

- [punto positivo 1]
- [punto positivo 2]

---

## Plan de acción sugerido

### Esta semana (críticos)
- [ ] [acción concreta para C1]

### Próximo sprint (mayores)
- [ ] [acción para M1]
- [ ] [acción para M2]

### Backlog (menores)
- [ ] [acción para mejoras menores]

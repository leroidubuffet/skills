# Checklist de Revisión REST

## 1. Nomenclatura de rutas

### ✓ Criterios
- Recursos en **plural y sustantivos**: `/users`, `/orders`, `/products`
- Jerarquía clara para relaciones: `/users/{id}/orders`
- Minúsculas y guiones medios para múltiples palabras: `/payment-methods`
- Sin verbos en la ruta: `/users` no `/getUsers`, `/createUser`
- Sin extensiones de archivo: `/users` no `/users.json`

### Ejemplos
```
✓  GET  /users
✓  GET  /users/{id}
✓  GET  /users/{id}/orders
✗  GET  /getUsers
✗  POST /createUser
✗  GET  /user (singular)
✗  GET  /Users (mayúsculas)
```

---

## 2. Uso correcto de verbos HTTP

| Verbo | Uso correcto | Idempotente | Seguro |
|---|---|---|---|
| `GET` | Leer recurso(s) | Sí | Sí |
| `POST` | Crear recurso nuevo | No | No |
| `PUT` | Reemplazar recurso completo | Sí | No |
| `PATCH` | Actualizar campos parciales | No* | No |
| `DELETE` | Eliminar recurso | Sí | No |

### Señales de problema
- `GET` que modifica estado → crítico
- `POST` para operaciones de lectura → mayor
- `PUT` con actualización parcial → menor
- Sin `PATCH` cuando los updates suelen ser parciales → menor

---

## 3. Códigos de respuesta HTTP

### Reglas fundamentales
- `2xx` solo cuando la operación fue exitosa
- `4xx` para errores del cliente (datos inválidos, no autorizado, no encontrado)
- `5xx` solo para errores del servidor, nunca por errores del cliente
- No usar `200` para todo — esconde errores del cliente

### Los más importantes
```
200 OK           — GET exitoso, PUT/PATCH exitoso con body
201 Created      — POST que creó un recurso (incluir Location header)
204 No Content   — DELETE exitoso, PUT/PATCH sin body de respuesta
400 Bad Request  — Input inválido, validación fallida
401 Unauthorized — No autenticado
403 Forbidden    — Autenticado pero sin permiso
404 Not Found    — Recurso no existe
409 Conflict     — Conflicto de estado (email duplicado, etc.)
422 Unprocessable — Sintaxis válida pero semánticamente incorrecta
500 Internal     — Error inesperado del servidor
```

Ver `references/http-status-codes.md` para la guía completa.

---

## 4. Estructura del body de respuesta

### Respuesta de colección
```json
{
  "data": [...],
  "meta": {
    "total": 150,
    "page": 1,
    "per_page": 20
  }
}
```

### Respuesta de error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "El campo email es inválido",
    "details": [
      {"field": "email", "issue": "formato inválido"}
    ]
  }
}
```

### Señales de problema
- Estructura de error inconsistente entre endpoints → mayor
- Errores devueltos como `200 OK` con `{"success": false}` → crítico
- Body de error sin `message` legible → mayor

---

## 5. Paginación

Para cualquier colección que pueda crecer:

```
GET /users?page=2&per_page=20
GET /users?offset=40&limit=20   # alternativa
GET /users?cursor=eyJpZCI6NDB9  # cursor-based para grandes volúmenes
```

La respuesta debe incluir metadatos de paginación (total, página actual, si hay siguiente).

**Señal de problema**: colecciones sin paginación → crítico si el dataset puede crecer.

---

## 6. Versionado

Opciones (ordenadas por preferencia):
1. **URL path**: `/v1/users` — más explícito, fácil de probar
2. **Header**: `Accept: application/vnd.api+json;version=1`
3. **Query param**: `/users?version=1` — solo para debugging

**Señal de problema**: API sin ninguna estrategia de versionado → mayor si es API pública.

---

## 7. Filtrado, ordenamiento y búsqueda

```
GET /users?status=active&role=admin
GET /users?sort=created_at&order=desc
GET /users?q=ana&fields=nombre,email
```

Convenciones:
- Filtros como query params
- Ordenamiento: `sort=campo&order=asc|desc`
- Proyección de campos: `fields=campo1,campo2`
- Búsqueda de texto libre: `q=termino`

---

## 8. Seguridad básica (observable desde el diseño)

- Autenticación requerida en todos los endpoints privados
- IDs no predecibles (UUID preferido sobre auto-increment expuesto)
- Sin datos sensibles en la URL (tokens, passwords, tarjetas)
- HTTPS implícito (no responsabilidad de la API en sí, pero sí del diseño)

---

## 9. Headers importantes

```
# Request
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json

# Response
Content-Type: application/json
Location: /users/123         # en 201 Created
X-Request-Id: abc-123        # para trazabilidad
```

---

## Resumen de severidades

| Categoría | Crítico | Mayor | Menor |
|---|---|---|---|
| Verbos | GET que modifica | POST para leer | PUT parcial |
| Códigos | 200 para errores | 500 para errores cliente | Códigos incorrectos |
| Nomenclatura | — | Verbos en URL | Singular vs plural |
| Paginación | Colección grande sin paginar | Sin metadata | — |
| Errores | Sin estructura | Estructura inconsistente | Sin códigos de error |

# Guía de Códigos de Estado HTTP

## 2xx — Éxito

| Código | Nombre | Cuándo usarlo |
|---|---|---|
| `200` | OK | GET exitoso con body; PUT/PATCH con body de respuesta |
| `201` | Created | POST que crea un recurso. Incluir `Location: /recurso/{id}` |
| `202` | Accepted | Operación aceptada para procesamiento asíncrono |
| `204` | No Content | DELETE exitoso; PUT/PATCH sin body de respuesta |
| `206` | Partial Content | Respuesta parcial (Range requests, streaming) |

**Trampa común**: usar `200` para todo, incluyendo errores del cliente.

---

## 3xx — Redirección

| Código | Nombre | Cuándo usarlo |
|---|---|---|
| `301` | Moved Permanently | Recurso movido permanentemente (con `Location`) |
| `302` | Found | Redirección temporal |
| `304` | Not Modified | Caché válido (con `ETag`/`Last-Modified`) |

---

## 4xx — Error del cliente

| Código | Nombre | Cuándo usarlo |
|---|---|---|
| `400` | Bad Request | JSON malformado, parámetros inválidos, validación fallida |
| `401` | Unauthorized | Sin token de autenticación o token inválido |
| `403` | Forbidden | Autenticado pero sin permisos para este recurso |
| `404` | Not Found | El recurso no existe |
| `405` | Method Not Allowed | Verbo HTTP no soportado en esta ruta |
| `409` | Conflict | Estado conflictivo: email duplicado, versión obsoleta |
| `410` | Gone | Recurso eliminado permanentemente (era accesible antes) |
| `415` | Unsupported Media Type | Content-Type no soportado |
| `422` | Unprocessable Entity | Sintaxis válida pero semánticamente incorrecta |
| `429` | Too Many Requests | Rate limiting activado |

### 401 vs 403 — la distinción importante
- `401`: "No sé quién eres" → el cliente debe autenticarse
- `403`: "Sé quién eres, pero no puedes hacer eso" → no sirve reintentar con las mismas credenciales

### 400 vs 422 — cuándo elegir cada uno
- `400`: el request está mal formado (JSON inválido, falta campo obligatorio)
- `422`: el request está bien formado pero los datos no tienen sentido (fecha de fin antes que inicio, edad negativa)

---

## 5xx — Error del servidor

| Código | Nombre | Cuándo usarlo |
|---|---|---|
| `500` | Internal Server Error | Error inesperado del servidor (bug, excepción no manejada) |
| `501` | Not Implemented | Endpoint planificado pero no implementado aún |
| `502` | Bad Gateway | El servidor upstream devolvió respuesta inválida |
| `503` | Service Unavailable | Servicio en mantenimiento o sobrecargado |
| `504` | Gateway Timeout | El upstream tardó demasiado en responder |

**Regla crítica**: `5xx` son errores del servidor, nunca del cliente. Si el cliente envía datos inválidos, es `4xx`.

---

## Errores comunes en diseño de APIs

```
✗  POST /users → 200 {"success": false, "error": "email duplicado"}
✓  POST /users → 409 {"error": {"code": "EMAIL_DUPLICATE", "message": "..."}}

✗  GET /users/999 → 200 {"data": null}
✓  GET /users/999 → 404 {"error": {"code": "NOT_FOUND"}}

✗  DELETE /users/123 → 200 {"deleted": true}
✓  DELETE /users/123 → 204 (sin body)

✗  GET /users (query inválida) → 500
✓  GET /users (query inválida) → 400
```

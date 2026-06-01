# Convenciones para Pull Requests

## Tipos de PR (Conventional Commits)

| Tipo | Cuándo usarlo | Ejemplo |
|---|---|---|
| `feat` | Nueva funcionalidad para el usuario final | Login con OAuth2 |
| `fix` | Corrección de bug | Fix null pointer en checkout |
| `refactor` | Cambio interno sin nueva funcionalidad ni bug fix | Extraer servicio de pagos |
| `test` | Añadir o corregir tests | Tests para módulo de facturas |
| `docs` | Solo documentación | Actualizar README |
| `chore` | Mantenimiento, deps, CI/CD, config | Actualizar dependencias |
| `perf` | Mejora de rendimiento | Cachear consultas de usuarios |
| `style` | Formato, sin cambio de lógica | Aplicar black/checkstyle |

**Cuando hay mezcla**: elige el tipo dominante. Si un PR añade una feature y corrige un bug en el mismo módulo, es `feat`. Si una refactorización también corrige un comportamiento incorrecto, es `fix`.

---

## Estructura del título

```
<tipo>(<scope>): <descripción imperativa en presente>
```

### Reglas del título
- **Imperativo presente**: "add" no "added" ni "adds"
- **Sin mayúscula inicial**: `feat(auth): add OAuth login`
- **Sin punto al final**
- **Máximo 72 caracteres**
- **Scope opcional**: indica el módulo afectado entre paréntesis

### Ejemplos
```
✓ feat(auth): add Google OAuth2 login
✓ fix(payments): handle null response from gateway
✓ refactor(users): extract UserRepository from UserService
✓ chore(deps): upgrade Spring Boot to 3.2.1
✓ test(orders): add integration tests for checkout flow

✗ Fixed the login bug
✗ WIP: working on auth
✗ feat: added new feature for users to be able to login with Google
```

---

## Estructura del cuerpo del PR

### Secciones recomendadas

**Motivación** (obligatoria)  
El POR QUÉ de este cambio. Qué problema resuelve, qué necesidad cubre. No expliques el qué — eso ya está en el código.

```markdown
## Motivación
El módulo de pagos lanzaba NullPointerException cuando el gateway devolvía 
un timeout en lugar de un error estructurado. Esto causaba que las transacciones 
quedaran en estado pendiente indefinidamente.
```

**Cambios realizados** (recomendada)  
Bullets cortos de lo que cambia. Útil para reviewers que quieren saber dónde mirar.

```markdown
## Cambios
- Añade manejo de `GatewayTimeoutException` en `PaymentService`
- Devuelve `402 Payment Required` en lugar de `500` para timeouts
- Añade retry con backoff exponencial (máx. 3 intentos)
```

**Cómo testear** (obligatoria para feat y fix)  
Pasos concretos, no genéricos.

```markdown
## Cómo testear
1. Simular un timeout configurando `GATEWAY_TIMEOUT_MS=100` en `.env.test`
2. Hacer POST a `/api/payments` con cualquier payload válido
3. Verificar que la respuesta es `402` y el body contiene `"code": "GATEWAY_TIMEOUT"`
4. Verificar en logs que aparece el retry (debe aparecer 3 veces)
```

**Notas para el reviewer** (opcional)  
Decisiones de diseño que no son obvias, trade-offs asumidos, contexto extra.

```markdown
## Notas
El retry se hace a nivel de servicio y no en el gateway client 
para mantener el cliente más simple. Discutir si preferimos moverlo.
```

---

## Cuándo dividir un PR

Un PR debe dividirse si:
- Tiene más de ~400 líneas de cambio Y los cambios son independientes
- Mezcla tipos muy distintos (feat + refactor grande)
- Un reviewer tardaría >45 minutos en revisarlo bien

Un PR NO debe dividirse si:
- Los cambios son cohesivos y parte de la misma feature
- Dividirlo crearía estados intermedios que rompen tests o funcionalidad
- El "refactor" es necesario para hacer posible la "feature"

---

## Referencias a tickets

Formatos reconocidos por la mayoría de herramientas:

```
Closes #123          → cierra el issue de GitHub al mergear
Fixes #456           → equivalente a Closes
Refs #789            → menciona sin cerrar
Relates to JIRA-42   → referencia a JIRA
Part of #100         → PR parcial de una issue más grande
```

Coloca las referencias al final del cuerpo del PR, no en el título.

---

## Checklist estándar de PR

```markdown
## Checklist
- [ ] Tests añadidos o actualizados
- [ ] Documentación actualizada si cambia el comportamiento público
- [ ] Sin secrets ni credenciales en el código
- [ ] El CI pasa
- [ ] Breaking changes documentados en CHANGELOG
```

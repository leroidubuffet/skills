## Motivación

<!-- Por qué se hace este cambio ahora. Qué problema de diseño, mantenibilidad
     o deuda técnica resuelve. Sin esta sección el reviewer no sabe si vale el riesgo. -->

## Qué cambia

<!-- Descripción técnica de la transformación: qué se mueve, extrae, renombra o elimina.
     No es necesario listar cada archivo — solo los cambios estructurales importantes. -->

## Qué NO cambia

<!-- Comportamiento externo preservado. Ayuda al reviewer a saber qué testear
     y reduce la ansiedad de que "algo se rompió". -->

- El comportamiento observable desde fuera no cambia
- [otros invariantes preservados]

## Riesgo

<!-- Honesto sobre el riesgo de regresión. Qué áreas son más sensibles,
     qué casos de borde hay que verificar. -->

**Bajo / Medio / Alto** — [justificación breve]

## Cómo verificar

<!-- Qué hay que correr para confirmar que nada se rompió. -->

```bash
# Tests existentes — todos deben seguir pasando:
[comando]

# Smoke test manual si aplica:
[pasos]
```

## Checklist

- [ ] Todos los tests existentes pasan
- [ ] Sin cambios en el comportamiento público
- [ ] CI pasa

<!-- Referencias: Part of #N, Relates to #N -->

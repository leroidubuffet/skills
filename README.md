# skills

Skills de Claude Code para automatizar tareas repetitivas de revisión, documentación y desarrollo en proyectos Python y Java.

Siete skills que cubren: revisión de APIs REST, auditoría de dependencias, generación de descripciones de Pull Request, diagnóstico de salud técnica, generación de tests unitarios, patrones de manejo de errores y sesiones de debugging estructuradas.

Cinco son de **invocación explícita** (slash command) y dos se **activan automáticamente** cuando Claude detecta que el contexto lo requiere.

---

## Instalación

Copia `.claude/skills/` en tu proyecto o en tu directorio home:

```bash
# A nivel de proyecto (compartido con el equipo via git)
git clone https://github.com/leroidubuffet/skills /tmp/skills
cp -r /tmp/skills/.claude/skills/<nombre-del-skill> .claude/skills/

# O instala los siete de una vez
cp -r /tmp/skills/.claude/skills .claude/
```

Instalación global (disponible en todos los proyectos):

```bash
cp -r /tmp/skills/.claude/skills/* ~/.claude/skills/
```

Verifica que están registrados:

```
/skills
```

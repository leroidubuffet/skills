# skills

Skills de Claude Code para automatizar tareas repetitivas de revisión y documentación en proyectos Python y Java.

Cinco skills invocables mediante slash command que cubren: revisión de APIs REST, auditoría de dependencias, generación de descripciones de Pull Request, diagnóstico de salud técnica y generación de tests unitarios. Todos son **solo de invocación explícita** (`disable-model-invocation: true`) — Claude nunca los activa de forma automática.

---

## Instalación

Copia `.claude/skills/` en tu proyecto o en tu directorio home:

```bash
# A nivel de proyecto (compartido con el equipo via git)
git clone https://github.com/leroidubuffet/skills /tmp/skills
cp -r /tmp/skills/.claude/skills/<nombre-del-skill> .claude/skills/

# O instala los cinco de una vez
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


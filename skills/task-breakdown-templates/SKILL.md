---
name: task-breakdown-templates
description: Plantillas exactas y heurísticas para descomponer requerimientos en tareas atómicas bajo .claude/tasks/<feature>/. Incluye convenciones de slug, reglas de atomicidad, orden topológico, marcado de riesgos. Invocar al planificar un nuevo requerimiento.
---

# Task Breakdown Templates

## Convenciones de slug del feature

- Kebab-case, ≤ 3 palabras, verbo + objeto.
- Ejemplos: `publish-properties`, `api-versioning`, `email-notifications`.

## Plantilla `README.md` del feature

```markdown
# <Título del requerimiento>

**Fecha:** <ISO, ej. 2026-04-17>
**Estado:** planned

## Resumen
<2-3 líneas con el requerimiento original y su motivación>.

## Asunciones hechas durante la planificación
- <asunción 1>

## Índice de tareas
1. [TASK-01 — <título>](./TASK-01-<slug>.md) — <resumen 1 línea>

## Fuera de alcance global
- <lo que se descartó del requerimiento original y por qué>
```

## Plantilla `TASK-<nn>-<slug>.md`

```markdown
---
id: TASK-<nn>
title: <título corto>
status: pending
feature: <feature-slug>
apps: [<app1>, <app2>]
depends_on: [TASK-<xx>, ...]
risks: [migration, multi-app, breaking-change]
---

## Descripción
<2-4 líneas explicando qué hay que hacer y por qué>.

## Criterios de aceptación
- [ ] <criterio observable 1>

## Notas técnicas (opcional)
- Referencias: `apps/<app>/<archivo>.py::<función>`.

## Fuera de alcance
- <lo que explícitamente NO se hace en esta tarea>
```

## Heurísticas de atomicidad

Una tarea es **atómica** si el Backend Engineer puede completarla en **una pasada**:
- Un endpoint con su service + selector + tests.
- Un nuevo modelo con su service básico y admin.
- Una refactorización localizada en una sola app.

## Marcado de riesgos

| Riesgo | Cuándo marcar |
|---|---|
| `migration` | Requiere `makemigrations`. |
| `multi-app` | Cruza fronteras de bounded context. |
| `breaking-change` | Rompe clientes externos. |
| `performance` | Riesgo de N+1 o queries pesadas. |
| `data-migration` | Requiere migración de datos. |

## MVP-first

- **TASK-01 a 03: MVP** — mínimo funcional de punta a punta.
- **TASK-04+: Mejoras** — validación extra, admin, reportes.

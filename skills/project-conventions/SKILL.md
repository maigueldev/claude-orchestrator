---
name: project-conventions
description: Source of truth de {{PROJECT_NAME}} — stack, arquitectura Nivel 2, convenciones DRF, política de migraciones, estado de seguridad. Invocar al inicio de cualquier tarea para validar decisiones contra las reglas canónicas del proyecto.
---

# Project Conventions — {{PROJECT_NAME}}

Referencia maestra. Cuando otra skill o un agente cite "las convenciones del proyecto", es este documento.

## Stack

<!-- TODO: define el stack de tu proyecto aquí -->
- {{STACK_DESCRIPTION}}

## Arquitectura

**Nivel 2 estilo HackSoft.** Una app Django por bounded context. Archivos por app:

- `models.py` — ORM + invariantes (`clean()`, `constraints`).
- `services.py` — escritura. **Toda mutación bajo `@transaction.atomic`.**
- `selectors.py` — lectura. `select_related`/`prefetch_related` donde haya relaciones.
- `validators.py`, `exceptions.py`, `admin.py`, `tasks.py` (opcional).
- `api/{serializers,views,permissions,urls}.py`.
- `tests/`.

`core/` app para shared kernel (base classes, VOs comunes, excepciones base).

Detalle completo en la skill **`hacksoft-layered-architecture`**.

## DRF

- Serializer por acción (List/Detail/Create/Update).
- Validación dentro del serializer (`validate_<field>`, `validate()`).
- `permission_classes` **explícitos** por vista.
- Versionado por URL: `/api/v1/...`.
- Paginación global (clase por confirmar — default provisional: `CursorPagination`).

Detalle en **`drf-conventions`**.

## Otras reglas

- Imports **siempre al tope**. Única excepción: circular imports con justificación explícita.
- Comunicación entre apps **por ID, nunca importando modelos ajenos**. Usar el selector público de la otra app.
- **Las migraciones las ejecuta el desarrollador**, no los agentes. Si una tarea requiere migración, el agente declara qué campos cambian y se detiene.
- Type hints en funciones públicas.
- Sin comentarios obvios. Solo **WHY**, nunca **WHAT**.

## Seguridad

**Pendiente de definir.** Mass assignment, `SECURITY_*` settings, rate limit — diferidos.

Checklist mínimo mientras tanto:
- Sin secretos hardcodeados.
- `permission_classes` nunca `AllowAny` sin justificación.
- Validación en toda entrada externa (serializers + validators).

## Comandos canónicos

<!-- TODO: ajusta según el stack de tu proyecto -->
```bash
# Ejemplo para uv + Django:
uv run python manage.py runserver
uv run pytest
uv run ruff check --fix .
uv run ruff format .
uv run mypy .
```

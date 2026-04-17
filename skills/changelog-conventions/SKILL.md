---
name: changelog-conventions
description: Formato Conventional Commits para líneas de changelog y estructura de CHANGELOG.md con sección [Unreleased]. Invocar al generar entradas de changelog (backend-engineer) o al actualizar CHANGELOG.md (documentador).
---

# Changelog Conventions

## Formato de línea

```
<type>(<scope>): <short description>
```

### Types válidos

- `feat` — nueva funcionalidad visible al usuario final o a la API.
- `fix` — corrección de bug.
- `refactor` — reestructuración sin cambio de comportamiento.
- `perf` — mejora de rendimiento.
- `docs` — solo documentación.
- `test` — solo tests.
- `chore` — tareas de mantenimiento, deps, tooling.

### Ejemplos

- `feat(properties): add publish endpoint`
- `fix(users): prevent duplicate email on signup`
- `refactor(listings): extract price calculation into selector`

## Estructura de `CHANGELOG.md`

```markdown
# Changelog

Todos los cambios relevantes se documentan aquí.

## [Unreleased]

### Added
- `feat(properties): add publish endpoint` — nuevo `POST /api/v1/properties/{id}/publish/`.

### Fixed
- `fix(users): prevent duplicate email on signup` — validación en `UserCreateSerializer`.

### Changed
- `refactor(listings): extract price calculation into selector`.

## [0.1.0] — 2026-04-17

### Added
- Setup inicial del proyecto.
```

## Agrupación por sección

| `type` | Sección |
|---|---|
| `feat` | `Added` |
| `fix` | `Fixed` |
| `refactor`, `perf` | `Changed` |

## Reglas

- `[Unreleased]` siempre arriba.
- Fechas en ISO (`2026-04-17`).
- Al hacer release, se promueve a una versión nueva y se abre un nuevo `[Unreleased]` vacío.

## Breaking changes

```markdown
### Breaking
- `feat(api)!: change pagination to CursorPagination` — clientes deben usar `next`/`previous` URLs.
```

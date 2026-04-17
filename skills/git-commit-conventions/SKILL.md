---
name: git-commit-conventions
description: Reglas para mensajes de commit — Conventional Commits, inglés obligatorio, subject imperativo ≤72 chars, cuándo añadir body/footer, commits atómicos. Invocar antes de cualquier `git commit` (agente `git-committer`).
---

# Git Commit Conventions

> **Idioma:** todos los mensajes de commit **en inglés**, sin excepciones.

## Formato

```
<type>(<scope>): <subject>

<body (opcional)>

<footer (opcional)>
```

### Subject line

- **En inglés**, imperativo presente: `add`, `fix`, `remove`.
- **≤ 72 caracteres** incluyendo `type(scope):`.
- Minúscula tras los dos puntos.
- **Sin punto final.**

### Types válidos

| Type | Uso |
|------|-----|
| `feat` | Nueva funcionalidad visible al usuario/API. |
| `fix` | Corrección de bug. |
| `refactor` | Reestructuración sin cambio de comportamiento. |
| `perf` | Mejora de rendimiento. |
| `docs` | Solo documentación. |
| `test` | Solo tests. |
| `chore` | Mantenimiento, deps, tooling. |
| `build` | Cambios en build o deps de compilación. |
| `ci` | Cambios en CI/CD. |

### Scope

- Nombre de la app: `properties`, `users`, `contracts`.
- `core` para shared kernel.
- `api` para cambios transversales en `config/` o routing global.

## Breaking changes

```
feat(api)!: switch pagination to CursorPagination

BREAKING CHANGE: clients must now use `next`/`previous` URLs.
```

## Commits atómicos

- **Un commit = un cambio lógico.**
- Tests e implementación de la misma feature → **mismo commit**.
- Migraciones → **mismo commit** que el cambio de modelo.

## Ejemplos correctos

```
feat(users): add custom User model with email as USERNAME_FIELD
fix(properties): prevent negative price on publish
refactor(listings): extract price calculation into selector
chore(deps): bump django to 6.0.2
```

## Reglas del proyecto

- **Nunca** `--no-verify`.
- **Nunca** `git add -A`.
- **Nunca** `git commit --amend` sobre commits ya pusheados.
- Mensajes multi-línea vía HEREDOC.

## Checklist

- [ ] Mensaje en **inglés**.
- [ ] `type(scope): subject` presente, imperativo, ≤72 chars.
- [ ] Sin mayúscula tras `:`, sin punto final.
- [ ] Body explica el *porqué*, wrapped a 72.
- [ ] Un solo cambio lógico en el commit.
- [ ] Archivos añadidos por nombre, sin secretos.

# Changelog

All notable changes to this project are documented here.
Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

## [1.0.0] — 2026-04-18

### Added
- `feat(agents): add project-scout agent` — read-only repo explorer using `haiku` model, dispatched first in the orchestrator flow to reduce main context consumption.
- `feat(agents): add task-planner agent` — decomposes requirements into atomic tasks persisted in `.claude/tasks/<slug>/`.
- `feat(agents): add backend-engineer agent` — 3-phase implementation (mini-plan → green → delivery with ruff/mypy/pytest).
- `feat(agents): add test-engineer agent` — TDD red phase, writes only in `apps/*/tests/`.
- `feat(agents): add code-reviewer agent` — fixed checklist reviewer, read-only, produces `approve | request-changes` verdict.
- `feat(agents): add documentador agent` — updates CHANGELOG.md and README.md after approval, only writes `.md`.
- `feat(agents): add git-committer agent` — atomic Conventional Commits in English, never pushes without explicit order.
- `feat(skills): add project-conventions skill` — source of truth template with `{{PROJECT_NAME}}` placeholder.
- `feat(skills): add hacksoft-layered-architecture skill` — HackSoft Level 2 rules with code examples.
- `feat(skills): add drf-conventions skill` — serializer-per-action, explicit permissions, URL versioning.
- `feat(skills): add service-selector-patterns skill` — templates for `services.py` and `selectors.py`.
- `feat(skills): add drf-viewset-wiring skill` — ViewSet templates with router registration.
- `feat(skills): add performance-patterns skill` — N+1, select_related, update_fields, select_for_update.
- `feat(skills): add pytest-django-patterns skill` — markers, conftest layout, --reuse-db.
- `feat(skills): add factory-boy-patterns skill` — factory templates, Trait, SubFactory string path.
- `feat(skills): add drf-api-testing-patterns skill` — APIClient patterns, status assertions.
- `feat(skills): add django-app-scaffold skill` — complete app directory structure templates.
- `feat(skills): add task-breakdown-templates skill` — README and TASK-nn templates, risk flags.
- `feat(skills): add git-commit-conventions skill` — Conventional Commits rules and checklist.
- `feat(skills): add changelog-conventions skill` — CHANGELOG.md structure and entry format.
- `feat(installer): add install.sh` — `--install-global`, `--link-project` (interactive), `--update-global`, `--unlink`, `--status`.
- `feat(installer): symlink-based project linking` — updates to global `~/.claude/` propagate to all linked projects instantly.
- `feat(installer): project-conventions local copy` — only project-specific skill is copied (not symlinked) with `{{PROJECT_NAME}}` substituted.
- `feat(docs): add CLAUDE.md.template` — generic orchestrator CLAUDE.md with TODO sections for project-specific content.
- `feat(docs): add settings.local.json template` — Claude Code permissions for Engram + git + uv.

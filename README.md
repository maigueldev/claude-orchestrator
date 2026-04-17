# Claude Code Orchestrator

A multi-agent orchestrator for Claude Code, designed for Django + DRF projects following the **HackSoft Level 2** layered architecture. Includes 7 specialized agents, 13 skill libraries, and an installer that manages global installation and per-project symlinks.

## What is this?

This repo gives you a complete AI-assisted development workflow where Claude Code orchestrates specialized sub-agents for every phase of the development cycle:

```
User → project-scout (read-only context)
     → task-planner  → backend-engineer (mini-plan)
                     → test-engineer    (TDD red phase)
                     → backend-engineer (green + refactor)
                     → code-reviewer
                     → documentador
                     → git-committer
```

Each agent has a specific role, strict scope, and loads only the skills it needs — keeping context lean and responses focused.

---

## Agents

| Agent | Model | Role | Tools |
|---|---|---|---|
| `project-scout` | haiku | Read-only repo explorer. Invoked first to map the codebase before any planning. | Read, Glob, Grep, Bash |
| `task-planner` | sonnet | Decomposes requirements into atomic tasks, persisted in `.claude/tasks/<slug>/`. | Read, Glob, Grep, Bash, Write |
| `backend-engineer` | sonnet | Implements features in 3 phases: mini-plan → implementation → delivery (ruff/mypy/pytest). | Read, Write, Edit, Glob, Grep, Bash |
| `test-engineer` | sonnet | Writes failing tests (TDD red phase) before implementation exists. Only touches `tests/`. | Read, Write, Edit, Glob, Grep, Bash |
| `code-reviewer` | sonnet | Reviews diffs against a fixed checklist (architecture, N+1, security, types). Read-only. | Read, Glob, Grep, Bash |
| `documentador` | sonnet | Updates CHANGELOG.md, README.md after reviewer approval. Only writes `.md` files. | Read, Write, Edit, Glob, Grep, Bash |
| `git-committer` | sonnet | Creates atomic commits following Conventional Commits in English. Never pushes without explicit order. | Read, Bash, Glob, Grep |

---

## Skills

Skills are reference documents loaded by agents at task start. They encode architecture rules, patterns, and templates.

| Skill | Purpose | Used by |
|---|---|---|
| `project-conventions` | **Source of truth** — stack, architecture, DRF rules, migration policy, security. Project-specific (name substituted on install). | All agents |
| `hacksoft-layered-architecture` | HackSoft Level 2 rules with code examples. What goes where, anti-patterns to reject. | backend-engineer, code-reviewer |
| `drf-conventions` | Serializer-per-action, explicit permission_classes, URL versioning `/api/v1/`, global pagination. | backend-engineer, test-engineer, code-reviewer |
| `service-selector-patterns` | Templates for `services.py` (write, `@transaction.atomic`, kwargs-only) and `selectors.py` (read, QuerySet). | backend-engineer |
| `drf-viewset-wiring` | ViewSet templates, `get_serializer_class` per action, `@action` for custom endpoints, router registration. | backend-engineer |
| `performance-patterns` | N+1 detection, `select_related`, `prefetch_related`, `update_fields`, `select_for_update`, `only`/`defer`. | backend-engineer, code-reviewer |
| `pytest-django-patterns` | pytest-django markers, conftest layout, `--reuse-db`, test naming conventions. | test-engineer |
| `factory-boy-patterns` | Factory templates, Sequence, SubFactory (string path), Trait, post_generation for M2M. | test-engineer |
| `drf-api-testing-patterns` | APIClient patterns, auth, status assertions, pagination, validation errors, permission tests. | test-engineer |
| `django-app-scaffold` | Complete app directory structure + minimal templates for every file. | backend-engineer |
| `task-breakdown-templates` | Task README and TASK-nn.md templates, atomicity heuristics, risk flags, topological ordering. | task-planner |
| `git-commit-conventions` | Conventional Commits rules, English mandatory, subject ≤72 chars, atomic commits, checklist. | git-committer |
| `changelog-conventions` | Changelog entry format, CHANGELOG.md structure with `[Unreleased]`, grouping by type. | backend-engineer, documentador |

### Key rule: `project-conventions` is the source of truth
If any other skill conflicts with `project-conventions`, the skill wins. This allows project-specific overrides without touching the shared skill files.

---

## Installation

### Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- macOS or Linux (bash 3.2+)

### Step 1 — Clone and install globally

```bash
git clone https://github.com/YOUR_USERNAME/claude-orchestrator.git
cd claude-orchestrator
chmod +x install.sh
./install.sh --install-global
```

This copies all agents and skills to `~/.claude/agents/` and `~/.claude/skills/`. Agents in `~/.claude/agents/` are available globally to all Claude Code projects.

### Step 2 — Link a project

```bash
cd /path/to/your-django-project
/path/to/claude-orchestrator/install.sh --link-project \
  --project-name "my-project" \
  --write-claude-md
```

You'll see an interactive menu to select which agents to link:

```
  Seleccioná los agentes a linkear en el proyecto
  ──────────────────────────────────────────────────────────────────
  [x] 1. project-scout          — explorador read-only (haiku)
  [x] 2. task-planner           — descomposición de requerimientos
  [x] 3. backend-engineer       — implementación HackSoft Nivel 2
  [x] 4. test-engineer          — fase roja TDD
  [x] 5. code-reviewer          — revisión de diff (read-only)
  [x] 6. documentador           — CHANGELOG + README
  [x] 7. git-committer          — commits Conventional Commits

  Número para toggle | 'a' todos | 'n' ninguno | 'q' confirmar:
```

After confirming, the installer:
- Creates `.claude/agents/<agent>.md` → symlinks to `~/.claude/agents/<agent>.md`
- Creates `.claude/skills/<skill>/SKILL.md` → symlinks to `~/.claude/skills/<skill>/SKILL.md`
- Copies `.claude/settings.local.json` (project-specific permissions)
- Copies `.claude/skills/project-conventions/SKILL.md` as a **local file** with your project name substituted (not a symlink — this one you'll customize)
- Optionally generates `CLAUDE.md` from the template

### What gets created in your project

```
your-project/
├── CLAUDE.md                              # orchestrator guide (if --write-claude-md)
└── .claude/
    ├── settings.local.json                # Claude Code permissions
    ├── agents/
    │   ├── project-scout.md               # symlink → ~/.claude/agents/
    │   ├── task-planner.md                # symlink → ~/.claude/agents/
    │   ├── backend-engineer.md            # symlink → ~/.claude/agents/
    │   ├── test-engineer.md               # symlink → ~/.claude/agents/
    │   ├── code-reviewer.md               # symlink → ~/.claude/agents/
    │   ├── documentador.md                # symlink → ~/.claude/agents/
    │   └── git-committer.md               # symlink → ~/.claude/agents/
    └── skills/
        ├── project-conventions/
        │   └── SKILL.md                   # LOCAL COPY — customize this one
        ├── hacksoft-layered-architecture/
        │   └── SKILL.md                   # symlink → ~/.claude/skills/
        ├── drf-conventions/
        │   └── SKILL.md                   # symlink → ~/.claude/skills/
        └── ...                            # 10 more skills as symlinks
```

**Why symlinks?** Updating agents or skills in `~/.claude/` instantly propagates to all linked projects — no need to re-run the installer per project.

**Why a local copy for `project-conventions`?** This skill is project-specific (stack, conventions, security policy). It's the only one you're expected to edit per project.

---

## Usage

### All commands

```bash
# Install agents + skills to ~/.claude/ (run once)
./install.sh --install-global

# Link a project (interactive agent selection)
./install.sh --link-project --project-name "my-api" --write-claude-md
./install.sh --link-project --target-dir /path/to/project --project-name "my-api"

# Skip the interactive menu — link all agents
./install.sh --link-project --no-interactive --write-claude-md

# Check what's linked in current project
./install.sh --status
./install.sh --status --target-dir /path/to/project

# Update ~/.claude/ after a git pull
./install.sh --update-global

# Remove orchestrator symlinks from a project
./install.sh --unlink
./install.sh --unlink --target-dir /path/to/project

# Overwrite existing files
./install.sh --link-project --force
```

---

## After installation — customizing for your project

### 1. Edit `project-conventions/SKILL.md`

This is the **only file you must edit** per project. Open `.claude/skills/project-conventions/SKILL.md` and fill in:

```markdown
## Stack

- Python 3.13 · Django 6 · DRF
- `uv` · `ruff` · `mypy`
- `pytest` + `pytest-django` + `factory-boy`
```

Replace `{{STACK_DESCRIPTION}}` with your actual stack.

### 2. Complete `CLAUDE.md` (if generated)

If you used `--write-claude-md`, open `CLAUDE.md` and fill in:
- The **Stack** section
- The **Comandos de desarrollo** section with your actual commands

Search for `TODO` to find all sections that need customization.

### 3. That's it

All other skills (architecture rules, DRF conventions, testing patterns, etc.) work out of the box for Django + DRF projects.

---

## Using the orchestrator

### Typical workflow

In Claude Code, you can invoke agents with the `/agent` command or naturally in conversation:

```
# Explore first (always)
@project-scout what services exist related to user authentication?

# Plan the feature
@task-planner I need to add a publish endpoint for properties

# Test-first
@test-engineer implement the tests for TASK-01 in .claude/tasks/publish-properties/

# Implement
@backend-engineer implement TASK-01 — make the tests pass

# Review
@code-reviewer review the diff from backend-engineer

# Document
@documentador update docs after the approved diff

# Commit
@git-committer commit the changes
```

### Always run agents in background

Per the CLAUDE.md policy, all agents should run with `run_in_background: true`. This keeps the main context free for questions while the agent works.

### `project-scout` always first

Before any non-trivial task, dispatch `project-scout` to map the relevant code. This prevents the main session from burning context on `Grep`/`Glob` exploration.

---

## Workflow diagram

```
┌─────────────────────────────────────────────────────────┐
│                       User request                       │
└─────────────────────┬───────────────────────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  project-scout  │  read-only, haiku
              │  (explore repo) │  returns: paths + findings
              └────────┬────────┘
                       │ scout report
                       ▼
              ┌─────────────────┐
              │  task-planner   │  produces TASK-nn.md files
              │  (decompose)    │  in .claude/tasks/<slug>/
              └────────┬────────┘
                       │ TASK-01
                       ▼
         ┌─────────────────────────┐
         │     test-engineer       │  writes failing tests
         │     (TDD red phase)     │  only in apps/*/tests/
         └────────────┬────────────┘
                      │ failing tests
                      ▼
         ┌─────────────────────────┐
         │    backend-engineer     │  makes tests pass
         │    (implementation)     │  ruff + mypy + pytest
         └────────────┬────────────┘
                      │ diff + changelog
                      ▼
         ┌─────────────────────────┐
         │     code-reviewer       │  approve | request-changes
         │     (fixed checklist)   │  read-only
         └────────────┬────────────┘
                      │ approve
                      ▼
         ┌─────────────────────────┐
         │      documentador       │  CHANGELOG.md + README.md
         │      (docs update)      │  only .md files
         └────────────┬────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │     git-committer       │  atomic commits
         │     (commit)            │  Conventional Commits, English
         └─────────────────────────┘
```

---

## Updating

When agents or skills are improved in this repo:

```bash
git pull
./install.sh --update-global
```

Projects with symlinks automatically see the updated agents and skills — no action needed per project. Only `project-conventions/SKILL.md` (local copy) is not affected.

---

## Adapting to a different stack

The agents and most skills assume Django + DRF. To adapt:

1. **`project-conventions/SKILL.md`** — update the stack, commands, architecture section for your framework.
2. **`hacksoft-layered-architecture/SKILL.md`** — if your architecture differs significantly, update the layer descriptions and anti-patterns.
3. **`drf-*` skills** — these are DRF-specific. For FastAPI or other frameworks, replace with equivalent skill files.
4. **`pytest-django-patterns`**, **`factory-boy-patterns`** — update test tooling references if needed.

Agents (`task-planner`, `code-reviewer`, `documentador`, `git-committer`, `project-scout`) are framework-agnostic and require no changes.

---

## Repository structure

```
claude-orchestrator/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── install.sh                       # installer script
├── agents/                          # agent definition files
│   ├── project-scout.md
│   ├── task-planner.md
│   ├── backend-engineer.md
│   ├── test-engineer.md
│   ├── code-reviewer.md
│   ├── documentador.md
│   └── git-committer.md
├── skills/                          # skill reference libraries
│   ├── project-conventions/
│   ├── hacksoft-layered-architecture/
│   ├── drf-conventions/
│   ├── drf-viewset-wiring/
│   ├── drf-api-testing-patterns/
│   ├── performance-patterns/
│   ├── service-selector-patterns/
│   ├── pytest-django-patterns/
│   ├── factory-boy-patterns/
│   ├── django-app-scaffold/
│   ├── task-breakdown-templates/
│   ├── git-commit-conventions/
│   └── changelog-conventions/
└── docs/
    ├── CLAUDE.md.template           # project CLAUDE.md template
    └── settings.local.json          # Claude Code permissions template
```

---

## License

MIT — see [LICENSE](LICENSE).

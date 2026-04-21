#!/usr/bin/env bash
# =============================================================================
# install.sh — Claude Code Orchestrator Installer
# https://github.com/YOUR_USERNAME/claude-orchestrator
#
# Usage:
#   ./install.sh --install-global [--force]
#   ./install.sh --link-project  [--target-dir PATH] [--project-name NAME]
#                                [--write-claude-md] [--no-interactive] [--force]
#   ./install.sh --update-global [--force]
#   ./install.sh --unlink        [--target-dir PATH]
#   ./install.sh --status        [--target-dir PATH]
# =============================================================================
set -euo pipefail

ORCHESTRATOR_VERSION="1.0.0"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_DIR="${HOME}/.claude"
AGENTS_DIR="${GLOBAL_DIR}/agents"
SKILLS_DIR="${GLOBAL_DIR}/skills"
VERSION_FILE="${GLOBAL_DIR}/.orchestrator-version"

ALL_AGENTS=(
  "product-manager"
  "project-scout"
  "task-planner"
  "backend-engineer"
  "test-engineer"
  "code-reviewer"
  "documentador"
  "git-committer"
  "designer"
  "frontend-engineer"
  "ux-ui-reviewer"
)
AGENT_DESCRIPTIONS=(
  "sub-orquestador (opus) — gestiona el pipeline completo de una feature"
  "explorador read-only (haiku) — se invoca primero"
  "descomposición de requerimientos en tareas atómicas"
  "implementación HackSoft Nivel 2 (ruff + mypy + pytest)"
  "fase roja TDD — solo escribe tests"
  "revisión de diff (read-only, no modifica código)"
  "CHANGELOG + README — solo escribe .md"
  "commits Conventional Commits en inglés"
  "diseña interfaces (Pencil/Design System) — propone UI, tokens, atomic design"
  "implementación Vue 4 + Nuxt por capas (ESLint + TS + Vitest)"
  "revisión WCAG/UX (read-only) — aprueba o pide cambios"
)

ALL_SKILLS=(
  "project-conventions"
  "hacksoft-layered-architecture"
  "drf-conventions"
  "drf-viewset-wiring"
  "drf-api-testing-patterns"
  "performance-patterns"
  "service-selector-patterns"
  "pytest-django-patterns"
  "factory-boy-patterns"
  "django-app-scaffold"
  "task-breakdown-templates"
  "git-commit-conventions"
  "changelog-conventions"
  "vue-nuxt-architecture"
  "vue-component-conventions"
  "frontend-testing-patterns"
  "design-system-conventions"
  "pencil-design-workflow"
  "accessibility-checklist"
)

# ─── Colors ──────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BLUE='\033[0;34m';  BOLD='\033[1m';      NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓${NC} $*"; }
warn() { echo -e "${YELLOW}  ⚠${NC} $*"; }
err()  { echo -e "${RED}  ✗${NC} $*" >&2; }
info() { echo -e "${BLUE}  →${NC} $*"; }
hdr()  { echo -e "\n${BOLD}$*${NC}"; }

# ─── Usage ───────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'

  install.sh — Claude Code Orchestrator

  COMANDOS

    --install-global          Instala agentes + skills en ~/.claude/ (primer uso)
    --link-project            Crea symlinks en un proyecto destino (interactivo)
    --update-global           Actualiza ~/.claude/ desde este repo
    --unlink                  Elimina los symlinks del orquestador de un proyecto
    --status                  Muestra qué agentes/skills están linkeados

  FLAGS

    --target-dir PATH         Proyecto destino (default: directorio actual)
    --project-name NAME       Nombre para project-conventions/SKILL.md
                              (default: basename del --target-dir)
    --write-claude-md         Generar CLAUDE.md en el proyecto
    --no-interactive          Linkear todos los agentes sin menú
    --force                   Sobreescribir archivos existentes sin preguntar

  FLUJO TÍPICO

    # 1. Una sola vez — instala los archivos canónicos globalmente
    ./install.sh --install-global

    # 2. Por proyecto — linkea en el proyecto nuevo
    cd /path/to/new-project
    /path/to/install.sh --link-project --project-name "mi-proyecto" --write-claude-md

    # 3. Actualizar después de un git pull
    ./install.sh --update-global

EOF
  exit 0
}

# ─── Argument parsing ────────────────────────────────────────────────────────

CMD=""
TARGET_DIR="$(pwd)"
PROJECT_NAME=""
FORCE=false
NO_INTERACTIVE=false
WRITE_CLAUDE_MD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-global)  CMD="install_global"; shift ;;
    --link-project)    CMD="link_project";   shift ;;
    --update-global)   CMD="update_global";  shift ;;
    --unlink)          CMD="unlink_project"; shift ;;
    --status)          CMD="show_status";    shift ;;
    --target-dir)      TARGET_DIR="$2";      shift 2 ;;
    --project-name)    PROJECT_NAME="$2";    shift 2 ;;
    --write-claude-md) WRITE_CLAUDE_MD=true; shift ;;
    --no-interactive)  NO_INTERACTIVE=true;  shift ;;
    --force)           FORCE=true;           shift ;;
    --help|-h)         usage ;;
    *) err "Opción desconocida: $1"; usage ;;
  esac
done

[[ -z "$CMD" ]] && usage
[[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$(basename "$TARGET_DIR")"

# ─── Helpers ─────────────────────────────────────────────────────────────────

copy_file() {
  local src="$1" dest="$2" label="$3"
  if [[ ! -f "$src" ]]; then
    err "Archivo fuente no encontrado: ${src}"
    return 1
  fi
  if [[ -f "$dest" && "$FORCE" != "true" ]]; then
    warn "Ya existe: ${dest} (usá --force para sobreescribir)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  ok "${label}: ${dest}"
}

write_project_conventions() {
  local dest="$1"
  local project_name="$2"
  # Read the template and substitute {{PROJECT_NAME}}
  local src="${REPO_DIR}/skills/project-conventions/SKILL.md"
  if [[ ! -f "$src" ]]; then
    err "No se encontró: ${src}"
    return 1
  fi
  if [[ -f "$dest" && "$FORCE" != "true" ]]; then
    warn "Ya existe: ${dest} (usá --force para sobreescribir)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  sed "s/{{PROJECT_NAME}}/${project_name}/g" "$src" > "$dest"
  ok "Copia (con nombre sustituido): ${dest}"
}

write_claude_md_file() {
  local dest="$1"
  local project_name="$2"
  local template="${REPO_DIR}/docs/CLAUDE.md.template"
  if [[ ! -f "$template" ]]; then
    err "No se encontró el template: ${template}"
    return 1
  fi
  sed "s/{{PROJECT_NAME}}/${project_name}/g" "$template" > "$dest"
  ok "Generado: ${dest}"
}

write_version_file() {
  local git_hash=""
  if command -v git &>/dev/null && git -C "$REPO_DIR" rev-parse --short HEAD &>/dev/null; then
    git_hash="$(git -C "$REPO_DIR" rev-parse --short HEAD)"
  fi
  cat > "$VERSION_FILE" <<EOF
version: ${ORCHESTRATOR_VERSION}
installed_at: $(date +%Y-%m-%d)
source_repo: ${REPO_DIR}
source_commit: ${git_hash:-unknown}
agents: ${#ALL_AGENTS[@]}
skills: ${#ALL_SKILLS[@]}
EOF
  ok "Versión: ${VERSION_FILE}"
}

# ─── Interactive agent selection ─────────────────────────────────────────────

_ISEL_SELECTED=()
_ISEL_CURSOR=0

_isel_draw() {
  local n="${#ALL_AGENTS[@]}"
  local count=0
  for (( i=0; i<n; i++ )); do [[ "${_ISEL_SELECTED[$i]}" == "1" ]] && count=$(( count + 1 )) || true; done

  printf '\033[2J\033[H'
  printf "  Seleccioná los agentes a linkear en el proyecto\r\n"
  printf "  \033[2m↑↓ mover · ESPACIO seleccionar · a todos · n ninguno · ENTER confirmar\033[0m\r\n"
  printf "  ────────────────────────────────────────────────────────────────────────────\r\n"
  for (( i=0; i<n; i++ )); do
    local mark=" "
    [[ "${_ISEL_SELECTED[$i]}" == "1" ]] && mark="x"
    if (( i == _ISEL_CURSOR )); then
      printf "  \033[7m[%s] %-24s — %s\033[0m\r\n" "$mark" "${ALL_AGENTS[$i]}" "${AGENT_DESCRIPTIONS[$i]}"
    else
      printf "  [%s] %-24s — %s\r\n" "$mark" "${ALL_AGENTS[$i]}" "${AGENT_DESCRIPTIONS[$i]}"
    fi
  done
  printf "\r\n  \033[1mSeleccionados: %d / %d\033[0m\r\n" "$count" "$n"
}

interactive_agent_selection() {
  local n="${#ALL_AGENTS[@]}"
  _ISEL_SELECTED=()
  _ISEL_CURSOR=0
  local i
  for (( i=0; i<n; i++ )); do _ISEL_SELECTED+=("1"); done

  # ── Python3: entrada de terminal robusta ────────────────────────────────────
  # bash + stty tiene comportamiento inconsistente en macOS (bash 3.2, tmux,
  # terminales multiplexados). Python3 usa termios/tty de forma portable.
  if command -v python3 &>/dev/null; then
    local _py_result
    _py_result=$(python3 - "${ALL_AGENTS[@]}" "${AGENT_DESCRIPTIONS[@]}" <<'PYEOF'
import sys, tty, termios, select, os

argv   = sys.argv[1:]
half   = len(argv) // 2
agents = argv[:half]
descs  = argv[half:]
n      = len(agents)

if n == 0:
    sys.exit(0)

selected = [True] * n
cursor   = 0

try:
    tty_r = open('/dev/tty', 'rb', buffering=0)
    tty_w = open('/dev/tty', 'w',  buffering=1)
except OSError:
    for a in agents:
        print(a)
    sys.exit(0)

fd  = tty_r.fileno()
old = termios.tcgetattr(fd)

def restore():
    try:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    except Exception:
        pass
    tty_w.write('\033[2J\033[H')
    tty_w.flush()

def draw():
    out = ['\033[2J\033[H']
    out.append('  Seleccioná los agentes a linkear en el proyecto\r\n')
    out.append('  \033[2m↑↓ mover \xb7 ESPACIO seleccionar \xb7 a todos \xb7 n ninguno \xb7 ENTER confirmar\033[0m\r\n')
    out.append('  ' + '─' * 74 + '\r\n')
    for i, (agent, desc) in enumerate(zip(agents, descs)):
        mark = 'x' if selected[i] else ' '
        row  = '  [{m}] {a:<24} — {d}\r\n'.format(m=mark, a=agent, d=desc)
        if i == cursor:
            row = '\033[7m' + row.rstrip('\r\n') + '\033[0m\r\n'
        out.append(row)
    count = sum(1 for s in selected if s)
    out.append('\r\n  \033[1mSeleccionados: {c} / {n}\033[0m\r\n'.format(c=count, n=n))
    tty_w.write(''.join(out))
    tty_w.flush()

def getch():
    ch = tty_r.read(1)
    if ch == b'\x1b':
        r, _, _ = select.select([tty_r], [], [], 0.15)
        if r:
            ch2 = tty_r.read(1)
            if ch2 == b'[':
                r2, _, _ = select.select([tty_r], [], [], 0.15)
                if r2:
                    return b'\x1b[' + tty_r.read(1)
            return b'\x1b' + ch2
    return ch

try:
    tty.setraw(fd)
    draw()
    while True:
        key = getch()
        if   key == b'\x1b[A' or key == b'k': cursor = max(cursor - 1, 0)
        elif key == b'\x1b[B' or key == b'j': cursor = min(cursor + 1, n - 1)
        elif key == b' ':                      selected[cursor] = not selected[cursor]
        elif key.lower() == b'a':              selected = [True]  * n
        elif key.lower() == b'n':              selected = [False] * n
        elif key in (b'\r', b'\n', b'q', b'Q', b'\x03'):
            if key == b'\x03':
                restore()
                sys.exit(130)
            break
        draw()
except KeyboardInterrupt:
    pass
finally:
    restore()

for i, a in enumerate(agents):
    if selected[i]:
        print(a)
PYEOF
    ) || true

    SELECTED_AGENTS=()
    while IFS= read -r _line; do
      [[ -n "$_line" ]] && SELECTED_AGENTS+=("$_line")
    done <<< "$_py_result"
    return 0
  fi

  # ── Fallback sin python3: selección numerada ────────────────────────────────
  warn "python3 no encontrado — modo selección numérica."
  echo ""
  for (( i=0; i<n; i++ )); do
    printf "  %2d) %s\n" "$(( i+1 ))" "${ALL_AGENTS[$i]}"
  done
  echo ""
  printf "  Ingresá números separados por espacios (Enter = todos): "
  local _input
  IFS= read -r _input
  SELECTED_AGENTS=()
  if [[ -z "$_input" ]]; then
    SELECTED_AGENTS=("${ALL_AGENTS[@]}")
  else
    for _tok in $_input; do
      if [[ "$_tok" =~ ^[0-9]+$ ]] && [[ $_tok -ge 1 && $_tok -le $n ]]; then
        SELECTED_AGENTS+=("${ALL_AGENTS[$(( _tok - 1 ))]}")
      fi
    done
  fi
}

# ─── Commands ────────────────────────────────────────────────────────────────

cmd_install_global() {
  hdr "Instalando orquestador en ${GLOBAL_DIR}/"
  echo ""

  [[ ! -d "$GLOBAL_DIR" ]] && { err "~/.claude/ no existe. Instalá Claude Code primero."; exit 1; }

  hdr "Agentes..."
  for agent in "${ALL_AGENTS[@]}"; do
    copy_file "${REPO_DIR}/agents/${agent}.md" "${AGENTS_DIR}/${agent}.md" "Agente"
  done

  hdr "Skills..."
  for skill in "${ALL_SKILLS[@]}"; do
    copy_file \
      "${REPO_DIR}/skills/${skill}/SKILL.md" \
      "${SKILLS_DIR}/${skill}/SKILL.md" \
      "Skill"
  done

  write_version_file
  echo ""
  ok "Instalación global completa. Ahora podés linkear proyectos con --link-project."
}

cmd_update_global() {
  hdr "Actualizando orquestador en ${GLOBAL_DIR}/"
  echo ""
  FORCE=true
  cmd_install_global
}

cmd_link_project() {
  hdr "Linkeando orquestador en: ${TARGET_DIR}/"
  echo ""

  [[ ! -d "$TARGET_DIR" ]]  && { err "El directorio destino no existe: ${TARGET_DIR}"; exit 1; }
  [[ ! -d "$AGENTS_DIR" ]]  && { err "~/.claude/agents/ no encontrado. Ejecutá --install-global primero."; exit 1; }
  [[ ! -d "$SKILLS_DIR" ]]  && { err "~/.claude/skills/ no encontrado. Ejecutá --install-global primero."; exit 1; }

  local target_claude="${TARGET_DIR}/.claude"
  local target_agents="${target_claude}/agents"
  local target_skills="${target_claude}/skills"

  # Agent selection
  SELECTED_AGENTS=()
  if [[ "$NO_INTERACTIVE" == "true" ]]; then
    SELECTED_AGENTS=("${ALL_AGENTS[@]}")
    info "Modo no-interactivo: linkeando todos los agentes."
  else
    interactive_agent_selection
  fi

  [[ ${#SELECTED_AGENTS[@]} -eq 0 ]] && { warn "No se seleccionó ningún agente."; exit 0; }

  hdr "Symlinks de agentes..."
  mkdir -p "$target_agents"
  for agent in "${SELECTED_AGENTS[@]}"; do
    local src="${AGENTS_DIR}/${agent}.md"
    local lnk="${target_agents}/${agent}.md"
    [[ ! -f "$src" ]] && { warn "Agente no encontrado en global: ${src}"; continue; }
    if [[ -L "$lnk" && "$FORCE" != "true" ]]; then
      warn "Symlink ya existe: ${lnk} (usá --force para recrear)"
      continue
    fi
    ln -sf "$src" "$lnk"
    ok "Symlink: $(basename "$lnk") → ${src}"
  done

  hdr "Symlinks de skills..."
  # project-conventions: copia con nombre sustituido (no symlink)
  local pc_dest="${target_skills}/project-conventions/SKILL.md"
  write_project_conventions "$pc_dest" "$PROJECT_NAME"

  # Resto: symlinks
  for skill in "${ALL_SKILLS[@]}"; do
    [[ "$skill" == "project-conventions" ]] && continue
    local src="${SKILLS_DIR}/${skill}/SKILL.md"
    local lnk="${target_skills}/${skill}/SKILL.md"
    [[ ! -f "$src" ]] && { warn "Skill no encontrada en global: ${src}"; continue; }
    if [[ -L "$lnk" && "$FORCE" != "true" ]]; then
      warn "Symlink ya existe: ${lnk} (usá --force para recrear)"
      continue
    fi
    mkdir -p "$(dirname "$lnk")"
    ln -sf "$src" "$lnk"
    ok "Symlink: ${skill}/SKILL.md"
  done

  hdr "Config..."
  local settings_dest="${target_claude}/settings.local.json"
  if [[ -f "$settings_dest" && "$FORCE" != "true" ]]; then
    warn "Ya existe: ${settings_dest} (usá --force para sobreescribir)"
  else
    cp "${REPO_DIR}/docs/settings.local.json" "$settings_dest"
    ok "Copiado: settings.local.json"
  fi

  if [[ "$WRITE_CLAUDE_MD" == "true" ]]; then
    hdr "Generando CLAUDE.md..."
    local claude_md_dest="${TARGET_DIR}/CLAUDE.md"
    if [[ -f "$claude_md_dest" && "$FORCE" != "true" ]]; then
      printf "\n  ${YELLOW}⚠${NC} Ya existe CLAUDE.md. ¿Sobreescribir? [s/N]: "
      read -r overwrite
      [[ "$overwrite" =~ ^[sS]$ ]] && write_claude_md_file "$claude_md_dest" "$PROJECT_NAME" || warn "CLAUDE.md no modificado."
    else
      write_claude_md_file "$claude_md_dest" "$PROJECT_NAME"
    fi
  fi

  hdr "Validando symlinks..."
  local broken=0
  for agent in "${SELECTED_AGENTS[@]}"; do
    local lnk="${target_agents}/${agent}.md"
    [[ -L "$lnk" && ! -e "$lnk" ]] && { err "Symlink roto: ${lnk}"; broken=$((broken+1)); }
  done
  for skill in "${ALL_SKILLS[@]}"; do
    [[ "$skill" == "project-conventions" ]] && continue
    local lnk="${target_skills}/${skill}/SKILL.md"
    [[ -L "$lnk" && ! -e "$lnk" ]] && { err "Symlink roto: ${lnk}"; broken=$((broken+1)); }
  done

  echo ""
  if [[ $broken -eq 0 ]]; then
    ok "Todos los symlinks son válidos."
    echo ""
    ok "Orquestador linkeado en ${TARGET_DIR}/"
    echo ""
    info "Próximos pasos:"
    info "  1. Editá .claude/skills/project-conventions/SKILL.md con tu stack."
    [[ "$WRITE_CLAUDE_MD" == "true" ]] && info "  2. Completá CLAUDE.md — buscá los TODO."
  else
    err "${broken} symlink(s) roto(s). Verificá que --install-global fue ejecutado."; exit 1
  fi
}

cmd_unlink_project() {
  hdr "Eliminando symlinks del orquestador en: ${TARGET_DIR}/"
  echo ""
  local removed=0
  for agent in "${ALL_AGENTS[@]}"; do
    local lnk="${TARGET_DIR}/.claude/agents/${agent}.md"
    [[ -L "$lnk" ]] && { rm "$lnk"; ok "Eliminado: ${lnk}"; removed=$((removed+1)); }
  done
  for skill in "${ALL_SKILLS[@]}"; do
    [[ "$skill" == "project-conventions" ]] && continue
    local lnk="${TARGET_DIR}/.claude/skills/${skill}/SKILL.md"
    [[ -L "$lnk" ]] && { rm "$lnk"; ok "Eliminado: ${lnk}"; removed=$((removed+1)); }
  done
  echo ""
  [[ $removed -eq 0 ]] && info "No se encontraron symlinks en ${TARGET_DIR}/" || ok "${removed} symlink(s) eliminado(s)."
}

cmd_show_status() {
  hdr "Estado del orquestador"
  echo ""

  echo -e "  ${BOLD}Instalación global (${GLOBAL_DIR}/)${NC}"
  if [[ -f "$VERSION_FILE" ]]; then
    while IFS= read -r line; do echo "    $line"; done < "$VERSION_FILE"
  else
    warn "  ~/.claude/.orchestrator-version no encontrado. Ejecutá --install-global."
  fi
  echo ""

  local target_agents="${TARGET_DIR}/.claude/agents"
  echo -e "  ${BOLD}Agentes en proyecto (${TARGET_DIR}/)${NC}"
  if [[ ! -d "$target_agents" ]]; then
    warn "  .claude/agents/ no existe en el proyecto."
  else
    for agent in "${ALL_AGENTS[@]}"; do
      local lnk="${target_agents}/${agent}.md"
      if [[ -L "$lnk" ]]; then
        [[ -e "$lnk" ]] && ok "  ${agent} (symlink válido)" || err "  ${agent} (symlink ROTO)"
      elif [[ -f "$lnk" ]]; then
        info "  ${agent} (copia local)"
      else
        echo "  [ ] ${agent}"
      fi
    done
  fi
  echo ""

  local target_skills="${TARGET_DIR}/.claude/skills"
  echo -e "  ${BOLD}Skills en proyecto${NC}"
  if [[ ! -d "$target_skills" ]]; then
    warn "  .claude/skills/ no existe en el proyecto."
  else
    for skill in "${ALL_SKILLS[@]}"; do
      local lnk="${target_skills}/${skill}/SKILL.md"
      if [[ -L "$lnk" ]]; then
        [[ -e "$lnk" ]] && ok "  ${skill} (symlink válido)" || err "  ${skill} (symlink ROTO)"
      elif [[ -f "$lnk" ]]; then
        info "  ${skill} (copia local)"
      else
        echo "  [ ] ${skill}"
      fi
    done
  fi
  echo ""

  echo -e "  ${BOLD}Config${NC}"
  local settings="${TARGET_DIR}/.claude/settings.local.json"
  [[ -f "$settings" ]] && ok "  settings.local.json presente" || warn "  settings.local.json no encontrado"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────

case "$CMD" in
  install_global) cmd_install_global ;;
  link_project)   cmd_link_project   ;;
  update_global)  cmd_update_global  ;;
  unlink_project) cmd_unlink_project ;;
  show_status)    cmd_show_status    ;;
esac

#!/usr/bin/env bash
# notebooklm-research · cross-host installer
# Symlinks the skill into every AI host that reads the SKILL.md format natively.
#
# Native SKILL.md hosts (auto-installed here):
#   - Claude Code CLI      (~/.claude/skills/)
#   - OpenAI Codex CLI     (~/.codex/skills/)   ← reads SKILL.md natively since Dec 2025
#   - Anthropic Agents SDK (~/.agents/skills/)
#   - Hermes               (~/.hermes/skills/)
#
# Rules-based agents (Cursor, Windsurf, Copilot, Gemini, Aider, Zed …) have no
# skill concept — they read an always-on instructions file. Install on those by
# pasting the pointer block from templates/agents-md-snippet.md into their
# AGENTS.md / GEMINI.md / rules file. Run with --print-agents-snippet to print it.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
#
# Flags:
#   --dry-run                Show what would happen, do not modify anything
#   --force                  Overwrite existing non-symlink target dirs
#   --hosts X,Y              Install only to specific hosts (e.g., "claude,codex")
#   --uninstall              Remove all installed symlinks
#   --print-agents-snippet   Print the AGENTS.md pointer block (for rules-based agents) and exit
#   --help                   Show this help

set -euo pipefail

SKILL_NAME="notebooklm-research"
REPO_URL="https://github.com/vincent-wen789/notebooklm-research"
INSTALL_ROOT="${NOTEBOOKLM_RESEARCH_HOME:-$HOME/.local/share/notebooklm-research}"

DRY_RUN=0
FORCE=0
UNINSTALL=0
PRINT_SNIPPET=0
SELECTED_HOSTS=""

# Host registry: <key>:<path>
HOSTS=(
  "claude:$HOME/.claude/skills"
  "agents:$HOME/.agents/skills"
  "codex:$HOME/.codex/skills"
  "hermes:$HOME/.hermes/skills"
)

print_help() {
  sed -n '/^# notebooklm-research/,/^# Flags:/p; /^#   --/p' "$0" | sed 's/^# \{0,1\}//'
}

log() { printf '%s\n' "$*"; }
ok()  { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m⚠\033[0m %s\n' "$*"; }
err() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }

# For rules-based agents (Cursor / Windsurf / Copilot / Gemini / Aider …): the
# pointer block to paste into their AGENTS.md / GEMINI.md / rules file.
print_agents_snippet() {
  cat <<'SNIPPET'
## Deep research (NotebookLM workflow)
When the user wants deep research, an industry/competitor mapping, narrative ammunition, a compliance scan, a user-persona profile, or "a write-up with sources I can trust" — read and follow `~/.local/share/notebooklm-research/SKILL.md` (the full 4-stage workflow). For a quick no-setup version, hand them `~/.local/share/notebooklm-research/templates/simple-prompt.md`. Emit all output in the user's language.
SNIPPET
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --print-agents-snippet) PRINT_SNIPPET=1 ;;
    --hosts)
      case "${2:-}" in
        ""|--*) err "--hosts needs a value (e.g. claude,codex)"; exit 1 ;;
      esac
      SELECTED_HOSTS="$2"; shift ;;
    --help|-h) print_help; exit 0 ;;
    *) err "Unknown flag: $1"; print_help; exit 1 ;;
  esac
  shift
done

# Step 1: Locate the source dir
# Priority:
#   (a) If $0 is inside a git checkout of this repo, use that.
#   (b) Otherwise, clone/update $INSTALL_ROOT.
locate_source() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || script_dir=""
  if [ -n "$script_dir" ] && [ -f "$script_dir/SKILL.md" ] && [ -f "$script_dir/PLAYBOOK.md" ]; then
    SOURCE_DIR="$script_dir"
    log "Using local source at $SOURCE_DIR"
    return
  fi
  # Curl-piped or installed outside the repo. Clone or pull.
  if [ -d "$INSTALL_ROOT/.git" ]; then
    log "Updating existing source at $INSTALL_ROOT"
    [ "$DRY_RUN" -eq 0 ] && git -C "$INSTALL_ROOT" pull --ff-only
  else
    if [ -d "$INSTALL_ROOT" ]; then
      warn "$INSTALL_ROOT exists but is not a git repo. Re-cloning."
      [ "$DRY_RUN" -eq 0 ] && rm -rf "$INSTALL_ROOT"
    fi
    log "Cloning $REPO_URL → $INSTALL_ROOT"
    [ "$DRY_RUN" -eq 0 ] && mkdir -p "$(dirname "$INSTALL_ROOT")" && git clone "$REPO_URL" "$INSTALL_ROOT"
  fi
  SOURCE_DIR="$INSTALL_ROOT"
}

# Step 2: Detect hosts
detect_hosts() {
  local found=()
  for entry in "${HOSTS[@]}"; do
    local key="${entry%%:*}"
    local path="${entry#*:}"
    if [ -n "$SELECTED_HOSTS" ]; then
      case ",$SELECTED_HOSTS," in
        *",$key,"*) ;;
        *) continue ;;
      esac
    fi
    if [ -d "$path" ]; then
      found+=("$key:$path")
    fi
  done
  if [ ${#found[@]} -eq 0 ]; then
    err "No AI host paths found on this machine."
    log ""
    log "Looked for:"
    for entry in "${HOSTS[@]}"; do log "  - ${entry#*:}"; done
    log ""
    log "Install at least one supported host first."
    exit 1
  fi
  HOSTS_FOUND=("${found[@]}")
}

# Step 3a: Install
install_to_hosts() {
  for entry in "${HOSTS_FOUND[@]}"; do
    local key="${entry%%:*}"
    local path="${entry#*:}"
    local target="$path/$SKILL_NAME"
    if [ -L "$target" ]; then
      [ "$DRY_RUN" -eq 0 ] && rm "$target"
    elif [ -e "$target" ]; then
      if [ "$FORCE" -eq 1 ]; then
        [ "$DRY_RUN" -eq 0 ] && rm -rf "$target"
      else
        warn "$target exists and is not a symlink. Pass --force to overwrite. Skipping."
        continue
      fi
    fi
    if [ "$DRY_RUN" -eq 0 ]; then
      ln -s "$SOURCE_DIR" "$target"
    fi
    ok "[$key] symlink: $target → $SOURCE_DIR"
  done
}

# Step 3b: Uninstall
uninstall_from_hosts() {
  local removed=0
  for entry in "${HOSTS_FOUND[@]}"; do
    local key="${entry%%:*}"
    local path="${entry#*:}"
    local target="$path/$SKILL_NAME"
    if [ -L "$target" ]; then
      [ "$DRY_RUN" -eq 0 ] && rm "$target"
      ok "[$key] removed symlink: $target"
      removed=$((removed + 1))
    elif [ -e "$target" ]; then
      warn "[$key] $target exists but is not a symlink. Skipping (manual cleanup)."
    fi
  done
  log ""
  log "Removed $removed symlink(s). Source remains at $SOURCE_DIR (delete manually if you want)."
}

# Main
if [ "$PRINT_SNIPPET" -eq 1 ]; then
  print_agents_snippet
  exit 0
fi
[ "$DRY_RUN" -eq 1 ] && log "DRY RUN — no changes will be made."
locate_source
detect_hosts

if [ "$UNINSTALL" -eq 1 ]; then
  uninstall_from_hosts
  exit 0
fi

install_to_hosts

log ""
ok "Done. Installed to ${#HOSTS_FOUND[@]} host(s)."
log ""
log "Try it (any host that supports skills):"
log "  /notebooklm-research \"I want a deep research on <topic>\""
log ""
log "Using a rules-based agent (Cursor / Windsurf / Copilot / Gemini / Aider …)?"
log "  Those don't auto-load skills. Paste the pointer into their AGENTS.md / GEMINI.md:"
log "    $0 --print-agents-snippet"
log "  Details: $SOURCE_DIR/templates/agents-md-snippet.md"
log ""
log "Update later:    git -C $SOURCE_DIR pull"
log "Uninstall:       $0 --uninstall"

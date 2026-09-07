#!/usr/bin/env bash
# Shared helpers for Kapp's Dev Planner Bundle scripts. Source this file; do not execute it.
# Environment overrides:
#   RTA_BRAIN_HOME  install root of Rta-Smriti Brain   (default ~/.local/share/rta-smriti)
#   RTA_BRAIN_DIR   directory holding <slug>.sqlite     (default $RTA_BRAIN_HOME/brains)
#   KDP_MCP_PROFILE MCP gateway tool profile core|full  (default core)

KDP_HOME="${RTA_BRAIN_HOME:-$HOME/.local/share/rta-smriti}"
KDP_VENV="$KDP_HOME/.venv"
KDP_BRAINS="${RTA_BRAIN_DIR:-$KDP_HOME/brains}"
KDP_RTA="$KDP_VENV/bin/rta-brain"
KDP_RTA_MCP="$KDP_VENV/bin/rta-brain-mcp"
KDP_PLANNING_DIR="docs/planning"
KDP_CONFIG_NAME=".brain.json"

# Mirror rta_brain.project._slug: lowercase, every non-alphanumeric char becomes '-', trim '-'.
kdp_slug() {
  local s
  s="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]/-/g; s/^-+//; s/-+$//')"
  printf '%s' "${s:-default}"
}

kdp_db_for() { printf '%s/%s.sqlite' "$KDP_BRAINS" "$(kdp_slug "$1")"; }

# Canonical project root: git toplevel of the given dir (or cwd), else the dir itself.
kdp_project_root() {
  local d="${1:-$PWD}"
  git -C "$d" rev-parse --show-toplevel 2>/dev/null || (cd "$d" && pwd -P)
}

kdp_require_brain() {
  if [ ! -x "$KDP_RTA" ]; then
    echo "rta-brain is not installed at $KDP_RTA. Run: install.sh --brain" >&2
    exit 3
  fi
}

# Read a key from docs/planning/.brain.json under a root. Prints nothing if missing.
kdp_config_get() {
  local root="$1" key="$2" f
  f="$root/$KDP_PLANNING_DIR/$KDP_CONFIG_NAME"
  [ -f "$f" ] || return 1
  python3 - "$f" "$key" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
v = d.get(sys.argv[2])
if v is None:
    sys.exit(1)
print(v)
PY
}

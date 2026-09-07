#!/usr/bin/env bash
# Create (or refresh) the Rta-Smriti brain for the current repo and record it for the planner.
#
#   bootstrap-project.sh [--project NAME] [--root DIR] [--no-agents]
#
# Defaults: root = git toplevel of cwd; project = basename of root.
# Writes docs/planning/.brain.json {project, stage: "bootstrapped"} and, with --write-agents,
# lets rta-brain write AGENTS.rta-smriti.md plus a marker block in AGENTS.md.
# If CLAUDE.md exists and does not import AGENTS.md, one "@AGENTS.md" line is appended.
set -euo pipefail
here="$(dirname "$(readlink -f "$0")")"
. "$here/lib.sh"
kdp_require_brain

project=""; root=""; write_agents="--write-agents"
while [ $# -gt 0 ]; do
  case "$1" in
    --project) project="$2"; shift 2 ;;
    --root) root="$2"; shift 2 ;;
    --no-agents) write_agents=""; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
root="$(kdp_project_root "${root:-$PWD}")"
project="${project:-$(basename "$root")}"
mkdir -p "$KDP_BRAINS" && chmod 700 "$KDP_BRAINS"
db="$(kdp_db_for "$project")"

if [ -f "$db" ]; then
  echo "brain exists: $db — refreshing index"
  "$KDP_RTA" --db "$db" ingest-repo "$root" --project "$project" --json >/dev/null
else
  # shellcheck disable=SC2086
  "$KDP_RTA" bootstrap-project "$root" --project "$project" --brain-dir "$KDP_BRAINS" $write_agents --json >/dev/null
fi

if [ -f "$root/CLAUDE.md" ] && [ -f "$root/AGENTS.md" ] && ! grep -q '^@AGENTS.md' "$root/CLAUDE.md"; then
  printf '\n@AGENTS.md\n' >> "$root/CLAUDE.md"
fi

mkdir -p "$root/$KDP_PLANNING_DIR"
( cd "$root" && "$here/project-config.sh" set project "$project" stage bootstrapped >/dev/null )
"$KDP_RTA" --db "$db" self-check --project "$project" --root "$root" --json | python3 -c '
import json,sys; d=json.load(sys.stdin)
print("project:", "'"$project"'")
print("db:", "'"$db"'")
print("database_ready:", d.get("database_ready"), "| continuation_ready:", d.get("continuation_ready"))
print("entities:", d.get("entities"))'

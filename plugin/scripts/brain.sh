#!/usr/bin/env bash
# Run an rta-brain command against the brain of one project.
#
#   brain.sh <project|.> <subcommand> [args...]
#   brain.sh raw [any rta-brain args...]
#
# "<project>" is the project name; "." resolves the name from docs/planning/.brain.json
# in the current repo. The script adds --db <brains>/<slug>.sqlite and --project <name>
# so callers only pass the subcommand-specific flags.
#
# Examples:
#   brain.sh . context-pack "write the PRD"
#   brain.sh . remember "Auth uses passkeys" --type decision --pramana sabda --priority 8
#   brain.sh . checkpoint --objective "..." --next-action "..."
#   brain.sh . ingest-repo
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/lib.sh"
kdp_require_brain

[ $# -ge 1 ] || { sed -n '2,16p' "$0"; exit 2; }

if [ "$1" = "raw" ]; then
  shift
  exec "$KDP_RTA" "$@"
fi

project="$1"; shift
[ $# -ge 1 ] || { echo "missing subcommand" >&2; exit 2; }
sub="$1"; shift

if [ "$project" = "." ]; then
  root="$(kdp_project_root)"
  project="$(kdp_config_get "$root" project || true)"
  if [ -z "$project" ]; then
    echo "no $KDP_PLANNING_DIR/$KDP_CONFIG_NAME under $root; run bootstrap-project.sh first" >&2
    exit 4
  fi
fi

db="$(kdp_db_for "$project")"
case "$sub" in
  ingest-repo)
    # ingest-repo takes the repo path as a positional argument
    root="$(kdp_project_root)"
    exec "$KDP_RTA" --db "$db" "$sub" "$root" --project "$project" "$@" ;;
  doctor|projects-list)
    exec "$KDP_RTA" --db "$db" "$sub" "$@" ;;
  *)
    exec "$KDP_RTA" --db "$db" "$sub" --project "$project" "$@" ;;
esac

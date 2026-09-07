#!/usr/bin/env bash
# SessionStart hook: if this repo has a Dev Planner brain, print the continuation prompt
# and the planning-stage status so the agent starts with the last checkpoint in context.
# Prints nothing (exit 0) when the repo is not managed, so it is safe everywhere.
set -uo pipefail
. "$(dirname "$(readlink -f "$0")")/lib.sh"

root="$(kdp_project_root "${CLAUDE_PROJECT_DIR:-${GROK_WORKSPACE_ROOT:-$PWD}}")"
project="$(kdp_config_get "$root" project 2>/dev/null || true)"
[ -n "$project" ] || exit 0
[ -x "$KDP_RTA" ] || { echo "Kapp's Dev Planner: project '$project' is configured but rta-brain is missing at $KDP_RTA."; exit 0; }
db="$(kdp_db_for "$project")"
[ -f "$db" ] || { echo "Kapp's Dev Planner: project '$project' has no brain at $db yet. Run /drill-me to bootstrap."; exit 0; }

echo "## Kapp's Dev Planner — project memory (Rta-Smriti)"
"$KDP_RTA" --db "$db" continue-prompt --project "$project" 2>/dev/null || echo "(continue-prompt unavailable)"
echo
echo "Planning artifacts under $KDP_PLANNING_DIR:"
"$(dirname "$(readlink -f "$0")")/project-config.sh" status 2>/dev/null | sed -n '3,$p'
echo
echo "Use /dev-planner to resume the workflow, or /drill-me, /prd, /tasks, /plan for one step."
exit 0

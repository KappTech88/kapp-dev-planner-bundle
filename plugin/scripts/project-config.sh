#!/usr/bin/env bash
# Read or write docs/planning/.brain.json for the current repo.
#
#   project-config.sh get [key]              print the whole file, or one key
#   project-config.sh set key value [...]    create/update keys
#   project-config.sh status                 which planning artifacts exist (00..03)
#
# The file holds only portable values (project name, stage, timestamps). Absolute paths
# are derived at run time from the git root and the brains directory, never stored.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/lib.sh"

root="$(kdp_project_root)"
dir="$root/$KDP_PLANNING_DIR"
file="$dir/$KDP_CONFIG_NAME"
cmd="${1:-get}"; shift || true

case "$cmd" in
  get)
    [ -f "$file" ] || { echo "no config: $file" >&2; exit 1; }
    if [ $# -eq 0 ]; then cat "$file"; echo; else kdp_config_get "$root" "$1"; fi ;;
  set)
    [ $# -ge 2 ] && [ $((  $# % 2 )) -eq 0 ] || { echo "usage: set key value [key value...]" >&2; exit 2; }
    mkdir -p "$dir"
    python3 - "$file" "$@" <<'PY'
import json, sys, datetime, os
path = sys.argv[1]; kv = sys.argv[2:]
d = {}
if os.path.exists(path):
    try: d = json.load(open(path))
    except Exception: d = {}
for k, v in zip(kv[::2], kv[1::2]):
    d[k] = v
d.setdefault("created_at", datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"))
d["updated_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
d.setdefault("bundle", "kapp-dev-planner")
tmp = path + ".tmp"
with open(tmp, "w") as f: json.dump(d, f, indent=2, sort_keys=True); f.write("\n")
os.replace(tmp, path)
print(json.dumps(d, indent=2, sort_keys=True))
PY
    ;;
  status)
    printf 'root: %s\n' "$root"
    printf 'project: %s\n' "$(kdp_config_get "$root" project 2>/dev/null || echo '(none)')"
    printf 'stage: %s\n' "$(kdp_config_get "$root" stage 2>/dev/null || echo '(none)')"
    for f in 00-brief.md 01-prd.md 02-tasks.md 03-plan.md; do
      if [ -f "$dir/$f" ]; then printf '  [x] %s\n' "$f"; else printf '  [ ] %s\n' "$f"; fi
    done ;;
  *) echo "unknown command: $cmd" >&2; exit 2 ;;
esac

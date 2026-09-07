#!/usr/bin/env bash
# Cursor sessionStart hook adapter: wraps session-start.sh output as {"additional_context": ...}.
set -uo pipefail
here="$(dirname "$(readlink -f "$0")")"
payload="$(cat 2>/dev/null || true)"
ws="$(printf '%s' "$payload" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin); print((d.get("workspace_roots") or [""])[0])
except Exception: print("")' 2>/dev/null)"
export CLAUDE_PROJECT_DIR="${ws:-$PWD}"
out="$(bash "$here/session-start.sh" 2>/dev/null || true)"
python3 -c 'import json,sys; t=sys.stdin.read().strip(); print(json.dumps({"additional_context": t} if t else {}))' <<<"$out"
exit 0

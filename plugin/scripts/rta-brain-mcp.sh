#!/usr/bin/env bash
# Launch the Rta-Smriti MCP stdio gateway over every project brain.
# Gateway mode (--brain-dir) is read-only by upstream design; writes go through brain.sh.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/lib.sh"
kdp_require_brain
mkdir -p "$KDP_BRAINS" && chmod 700 "$KDP_BRAINS"
exec "$KDP_RTA_MCP" --brain-dir "$KDP_BRAINS" --tool-profile "${KDP_MCP_PROFILE:-core}"

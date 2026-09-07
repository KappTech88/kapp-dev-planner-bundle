# rta-brain CLI cheatsheet (via brain.sh)

`brain.sh <project|.> <subcommand> [flags]` adds `--db <brains>/<slug>.sqlite` and
`--project <name>`. `brain.sh raw ...` passes arguments to `rta-brain` untouched.

| Purpose | Command |
|---|---|
| Health of one brain | `brain.sh . doctor` |
| Readiness incl. binding to this checkout | `brain.sh . self-check [--check-files]` |
| Context pack for a task | `brain.sh . context-pack "<task>" [--limit 8] [--max-tokens 4000]` |
| Search | `brain.sh . search "<query>" --json` |
| Remember one fact | `brain.sh . remember "<fact>" --type T --pramana P --priority N [--source-path F] [--verification-status verified] [--verification-command "<cmd>"]` |
| Checkpoint | `brain.sh . checkpoint --objective O [--verified-evidence E] [--remaining-gaps G] [--next-action A] [--prohibited-repetition R]` |
| Resume prompt | `brain.sh . continue-prompt` |
| Re-index repo | `brain.sh . ingest-repo [--force]` |
| Ingest a handoff or transcript | `brain.sh . ingest-thread <path> --title "<title>"` |
| Consolidate memories | `brain.sh . reflect --json` |
| Stale check | `brain.sh . stale-check [--details]` |
| Entity graph | `brain.sh . graph` / `brain.sh . graph-query ...` |
| Cognition snapshot (readiness, decision debt) | `brain.sh . cognition --json` |
| MCP config for another host | `brain.sh raw --db <db> --json mcp-config --project <name> --name rta-smriti` |
| Probe the MCP command | `brain.sh raw --db <db> mcp-doctor --project <name>` |

Memory types used by the planner: `decision`, `constraint`, `fact`, `procedure`, `bug`, `evidence`.

Install root: `~/.local/share/rta-smriti` (override with `RTA_BRAIN_HOME`); brains dir
`~/.local/share/rta-smriti/brains` (override with `RTA_BRAIN_DIR`).

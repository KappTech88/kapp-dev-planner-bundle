# Kapp's Dev Planner Bundle

Start dev projects the right way: **drill me → PRD → tasks → plan**, with every answer,
decision, and checkpoint kept in a local project memory ([Rta-Smriti Brain](https://github.com/kapptech88/rta-smriti-brain), a fork of [sulabhdubey/rta-smriti-brain](https://github.com/sulabhdubey/rta-smriti-brain))
so no session starts from zero. One plugin, three hosts: **Claude Code**, **Grok Build**, **Cursor**.

## Run it from a terminal

Run your coding agent from a **terminal CLI** (`claude`, `grok`, or Cursor's CLI agent) rather
than an IDE chat pane. A CLI host has shell access and therefore the best system vision: it can
inventory your machine, check versions, install toolchains, bootstrap the project brain, and run
verification commands itself. In a chat pane without a shell the machine-scan and install steps
of `/drill-me` are degraded and the skill will tell you the command to run from a CLI instead.

## Commands

| Command | What it does | Writes |
|---|---|---|
| `/dev-planner <idea or repo path>` | Runs the four steps in order with a gate between each; resumes from the first missing artifact | all of the below |
| `/drill-me <idea or repo path>` | Socratic requirements interview in rounds. The tech-stack round offers **Scan what's on this machine**: read-only inventory → fit assessment → recommendation → *install it for me / I'll install / skip* | `docs/planning/00-brief.md` |
| `/prd` | Drafts the PRD from the brief, has the `planning-critic` agent attack it, resolves open points with you | `docs/planning/01-prd.md` |
| `/tasks` | Milestones and sized tasks with acceptance criteria, dependencies, verification, evidence slots | `docs/planning/02-tasks.md` |
| `/plan` | Three architecture options with different biases (minimal, clean, pragmatic), you pick, plan written with sequencing and verification | `docs/planning/03-plan.md` |
| `brain` (model-invoked) | How to read memory (MCP `brain_*` tools) and write it (`scripts/brain.sh`) | — |

This bundle stops at planning. Implementation proceeds normally with the brain's checkpoint
as the handoff (`rta-brain continue-prompt` is injected at session start by the hook).

## Install

```bash
git clone https://github.com/kapptech88/kapp-dev-planner-bundle ~/Projects/kapp-dev-planner-bundle
cd ~/Projects/kapp-dev-planner-bundle
./install.sh --brain            # installs Rta-Smriti Brain into ~/.local/share/rta-smriti (Python 3.11+ venv)
./install.sh --host all         # Claude Code + Cursor + Grok Build (or --host claude|cursor|grok)
./install.sh --check
```

`--brain` uses `~/Downloads/rta-smriti-brain-main.zip` if present, a path you pass, or clones the fork `kapptech88/rta-smriti-brain` (override with `RTA_BRAIN_REPO`).
Tested here on Python 3.14.7 (upstream lists 3.11–3.13; all dependencies ship abi3/pure wheels).

| Host | How it loads | Notes |
|---|---|---|
| Claude Code | symlink `plugin/` → `~/.claude/skills/kapp-dev-planner` (loads as `kapp-dev-planner@skills-dir`) | `$ARGUMENTS`, hooks, bundled MCP all native |
| Grok Build | `grok plugin install plugin/ --trust && grok plugin enable kapp-dev-planner` | reads Claude-format plugins natively; MCP registered with `grok mcp add`; use `/kapp-dev-planner:plan` and `/kapp-dev-planner:tasks` (builtins win the bare names) |
| Cursor | symlink `hosts/cursor/` → `~/.cursor/plugins/local/kapp-dev-planner` | Cursor manifest + `mcp.json` + `hooks.json`; skills/agents symlinked to `plugin/` |

Restart the host after installing. In Claude Code check `/mcp` for `rta-smriti`; in Grok `grok mcp list`.

## Layout

```
plugin/                  Claude-format plugin: source of truth for all hosts
  .claude-plugin/        manifest
  .mcp.json              rta-smriti MCP gateway (read-only, over all project brains)
  hooks/hooks.json       SessionStart → continuation prompt + planning stage
  scripts/               brain.sh (writes), rta-brain-mcp.sh, bootstrap-project.sh,
                         project-config.sh, session-start.sh, machine-inventory.sh
  skills/                dev-planner, drill-me, prd, tasks, plan, brain
  agents/                planning-critic, codebase-scout
  templates/             brief.md, prd.md, tasks.md, plan.md
hosts/cursor/            Cursor plugin view (manifest, mcp.json, hooks.json, rule)
hosts/grok/              notes
install.sh
```

## Project memory

One SQLite brain per project at `~/.local/share/rta-smriti/brains/<slug>.sqlite`, created by
`scripts/bootstrap-project.sh` (also writes `AGENTS.md` instructions into the repo and
`docs/planning/.brain.json` with the project name and stage; no absolute paths are stored).

- **Reads** use the bundled MCP server `rta-smriti` (`brain_context_pack`, `brain_search`,
  `brain_continuation_prompt`, `brain_repo_map`, `brain_stale_check`, …). Gateway mode over
  many brains is read-only by upstream design.
- **Writes** use `scripts/brain.sh . remember|checkpoint|ingest-repo|reflect …`, visible commands
  with pramana evidence labels (`sabda` = you said it, `pratyaksha` = observed, `anumana` = inferred).
- Reset a project's memory: delete its `.sqlite` and `docs/planning/.brain.json`, then run
  `/drill-me` again. Nothing is sent anywhere; no telemetry.

## Customize

Edit `plugin/skills/*/SKILL.md` and `plugin/templates/*.md`; all hosts pick up the change on
their next session. Environment overrides: `RTA_BRAIN_HOME`, `RTA_BRAIN_DIR`, `KDP_MCP_PROFILE=full`.

## License

MIT. Rta-Smriti Brain is MIT, by Sulabh Dubey.

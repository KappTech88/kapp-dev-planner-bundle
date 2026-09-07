# Description for github.com/kapptech88/rta-smriti-brain

## GitHub "About" line (fits the 350-character limit)

Fork of Rta-Smriti Brain, the local-first project memory for AI coding agents, maintained as the memory layer for Kapp's Dev Planner Bundle. Adds a Claude Code / Grok Build / Cursor install path (Python 3.14 venv, read-only MCP gateway, CLI writes) so drill-me → PRD → tasks → plan runs with durable, evidence-labelled memory.

Topics: `ai-coding-agents` `agent-memory` `mcp` `claude-code` `cursor` `grok` `sqlite` `local-first` `prd` `planning`

## README section to add above the upstream README

### About this fork

This is [kapptech88](https://github.com/kapptech88)'s fork of
[sulabhdubey/rta-smriti-brain](https://github.com/sulabhdubey/rta-smriti-brain), kept so that
[Kapp's Dev Planner Bundle](https://github.com/kapptech88/kapp-dev-planner-bundle) has a pinned,
tested memory backend. Upstream does the hard part: a sovereign SQLite "brain" per project that
stores repository structure, decisions, checkpoints, and evidence with provenance labels
(`pratyaksha` observed, `sabda` stated, `anumana` inferred), plus a stdio MCP server so any agent
can read that memory without re-telling the project's story every session.

What this fork is for:

- **Planning workflow backend.** The Dev Planner Bundle runs a project through drill-me → PRD →
  tasks → plan. Every user answer, stack decision, and milestone becomes a `remember` entry, and
  each step ends with a `checkpoint` that the next session picks up through `continue-prompt`.
- **Three hosts, one install.** Verified on Claude Code and Grok Build, wired for Cursor: a
  `python3 -m venv` install under `~/.local/share/rta-smriti`, CLI wrappers in `~/.local/bin`, and
  a read-only MCP gateway (`rta-brain-mcp --brain-dir …`) over all project brains. Writes go
  through the CLI so they stay explicit and visible.
- **Python 3.14 tested.** Upstream lists 3.11 to 3.13; this fork records that 3.14.7 works on Linux
  with the current dependency set and keeps the install script honest about it.
- **Machine-aware planning.** The bundle's `/drill-me` step can inventory the machine, assess how
  the installed toolchain fits the build, recommend a better stack, and store the observed
  versions in the brain as direct evidence.

Nothing here changes upstream's privacy posture: local SQLite, no telemetry, no cloud database,
one brain per project. Bug fixes that are not specific to the bundle are sent upstream.

Quick start with the bundle:

```bash
git clone https://github.com/kapptech88/kapp-dev-planner-bundle ~/Projects/kapp-dev-planner-bundle
cd ~/Projects/kapp-dev-planner-bundle
./install.sh --brain        # clones this fork into ~/.local/share/rta-smriti/src and installs it
./install.sh --host all     # Claude Code, Grok Build, Cursor
```

Then open a repo in a terminal-hosted agent and run `/drill-me`.

Credit: Rta-Smriti was conceived and researched by Sulabh Dubey and built with OpenAI Codex.
MIT licensed, as is this fork.

## Apply it

```bash
gh repo edit kapptech88/rta-smriti-brain \
  --description "Fork of Rta-Smriti Brain, local-first project memory for AI coding agents, maintained as the memory layer for Kapp's Dev Planner Bundle (Claude Code / Grok Build / Cursor)." \
  --add-topic ai-coding-agents --add-topic agent-memory --add-topic mcp --add-topic claude-code \
  --add-topic cursor --add-topic sqlite --add-topic local-first --add-topic prd --add-topic planning
```

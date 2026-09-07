# Grok Build host notes

Grok Build reads the Claude-format plugin in `../../plugin` as-is: `.claude-plugin/plugin.json`,
`skills/`, `agents/`, `hooks/hooks.json`, `.mcp.json`. Install and enable:

```bash
grok plugin install "$HOME/Projects/kapp-dev-planner-bundle/plugin" --trust
grok plugin enable kapp-dev-planner
grok inspect --json | grep -o '"name": *"[a-z-]*"' | sort -u   # shows drill-me, prd, tasks, plan, dev-planner, brain
grok mcp list                                                   # should list rta-smriti
```

If `grok mcp list` does not show `rta-smriti` (plugin `.mcp.json` not expanded), register it
at user scope:

```bash
grok mcp add rta-smriti --scope user -- "$HOME/Projects/kapp-dev-planner-bundle/plugin/scripts/rta-brain-mcp.sh"
```

Naming in Grok: `plan` collides with Grok's builtin `/plan`, so this bundle's step is
`/kapp-dev-planner:plan` there, and `tasks` likewise becomes `/kapp-dev-planner:tasks` (the others keep their bare names). Grok also scans
`~/.claude/skills`, so `install.sh` adds `~/.claude/skills/kapp-dev-planner` to `[skills] ignore`
in `~/.grok/config.toml` to avoid duplicate `/user:...` entries.

Grok sets `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PROJECT_DIR` aliases for plugin hooks, so the shared
`scripts/session-start.sh` works unchanged. `$ARGUMENTS` and `argument-hint` are supported.

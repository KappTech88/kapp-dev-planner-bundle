#!/usr/bin/env bash
# Kapp's Dev Planner Bundle installer.
#
#   install.sh [--host claude|cursor|grok|all] [--brain [ZIP_OR_DIR]] [--uninstall] [--check]
#
# --brain      install Rta-Smriti Brain into ~/.local/share/rta-smriti (venv + CLI symlinks).
#              Source: the given zip/dir, else ~/Downloads/rta-smriti-brain-main.zip, else git clone.
# --host       register the plugin with one host or all (default: all).
# --uninstall  remove the host registrations (keeps the brain and this repo).
# --check      report what is installed and exit.
set -euo pipefail
BUNDLE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd -P)"
PLUGIN="$BUNDLE/plugin"
NAME="kapp-dev-planner"
KDP_HOME="${RTA_BRAIN_HOME:-$HOME/.local/share/rta-smriti}"
UPSTREAM="${RTA_BRAIN_REPO:-https://github.com/kapptech88/rta-smriti-brain.git}"   # fork of sulabhdubey/rta-smriti-brain

host="all"; do_brain=0; brain_src=""; uninstall=0; check=0
while [ $# -gt 0 ]; do
  case "$1" in
    --host) host="$2"; shift 2 ;;
    --brain) do_brain=1; shift; if [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; then brain_src="$1"; shift; fi ;;
    --uninstall) uninstall=1; shift ;;
    --check) check=1; shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

install_brain() {
  say "Installing Rta-Smriti Brain into $KDP_HOME"
  mkdir -p "$KDP_HOME/brains"; chmod 700 "$KDP_HOME/brains"
  if [ ! -d "$KDP_HOME/src" ]; then
    src="${brain_src:-$HOME/Downloads/rta-smriti-brain-main.zip}"
    if [ -d "$src" ]; then
      cp -r "$src" "$KDP_HOME/src"
    elif [ -f "$src" ]; then
      tmp="$KDP_HOME/src.tmp"; rm -rf "$tmp"; mkdir -p "$tmp"
      unzip -q -o "$src" -d "$tmp" -x '*/docs/media/*' '*/launch-assets/*' '*/launch-site/*' '*/launch-video/*' '*/dashboard-src/*' '*/operator-tests/*' >/dev/null 2>&1 || true
      inner="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
      mv "$inner" "$KDP_HOME/src"; rm -rf "$tmp"
    else
      say "No local source; cloning $UPSTREAM"
      git clone --depth 1 "$UPSTREAM" "$KDP_HOME/src"
    fi
  fi
  [ -x "$KDP_HOME/.venv/bin/python" ] || python3 -m venv "$KDP_HOME/.venv"
  "$KDP_HOME/.venv/bin/python" -m pip install --upgrade pip >/dev/null
  "$KDP_HOME/.venv/bin/python" -m pip install "$KDP_HOME/src" | tail -n1
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$KDP_HOME/.venv/bin/rta-brain" "$HOME/.local/bin/rta-brain"
  ln -sfn "$KDP_HOME/.venv/bin/rta-brain-mcp" "$HOME/.local/bin/rta-brain-mcp"
  "$KDP_HOME/.venv/bin/rta-brain" --json doctor | grep -q '"status": "ok"' && say "rta-brain doctor: ok ($("$KDP_HOME/.venv/bin/python" --version))"
}

install_claude() {
  say "Claude Code: linking $PLUGIN -> ~/.claude/skills/$NAME"
  mkdir -p "$HOME/.claude/skills"
  ln -sfn "$PLUGIN" "$HOME/.claude/skills/$NAME"
  have claude && claude plugin details "$NAME@skills-dir" 2>/dev/null | grep -v mise | head -n 12 || true
  say "Claude Code loads it next session as $NAME@skills-dir"
}

install_cursor() {
  say "Cursor: linking $BUNDLE/hosts/cursor -> ~/.cursor/plugins/local/$NAME"
  mkdir -p "$HOME/.cursor/plugins/local"
  ln -sfn "$BUNDLE/hosts/cursor" "$HOME/.cursor/plugins/local/$NAME"
  say "Cursor picks it up from Plugins on next launch; skills are also visible via ~/.claude/skills compat"
}

grok_ignore_claude_copy() {
  local cfg="$HOME/.grok/config.toml" path="~/.claude/skills/$NAME"
  [ -f "$cfg" ] || touch "$cfg"
  python3 - "$cfg" "$path" <<'PY2'
import sys, re, tomllib
cfg, path = sys.argv[1], sys.argv[2]
text = open(cfg).read()
try:
    data = tomllib.loads(text)
except Exception as e:
    print(f"config.toml not parseable ({e}); not editing", file=sys.stderr); sys.exit(0)
ignore = (data.get("skills") or {}).get("ignore") or []
if path in ignore:
    sys.exit(0)
if "skills" not in data:
    text = text.rstrip("\n") + f'\n\n[skills]\nignore = ["{path}"]\n'
elif "ignore" not in data["skills"]:
    text = re.sub(r'(?m)^\[skills\]\s*$', f'[skills]\nignore = ["{path}"]', text, count=1)
else:
    text = re.sub(r'(?m)^(ignore\s*=\s*\[)', rf'\g<1>"{path}", ', text, count=1)
tomllib.loads(text)
open(cfg, "w").write(text)
print(f"grok: added {path} to [skills] ignore")
PY2
}

install_grok() {
  if ! have grok; then say "grok not found; skipping"; return; fi
  say "Grok Build: installing plugin"
  if grok plugin list 2>/dev/null | grep -q "$NAME"; then
    say "already registered with grok; enabling"
    grok plugin enable "$NAME" >/dev/null 2>&1 || true
  elif grok plugin install "$PLUGIN" --trust >/dev/null 2>&1; then
    grok plugin enable "$NAME" >/dev/null 2>&1 || true
  else
    say "grok plugin install failed; falling back to ~/.grok/plugins/$NAME symlink"
    mkdir -p "$HOME/.grok/plugins"; ln -sfn "$PLUGIN" "$HOME/.grok/plugins/$NAME"
    grok plugin enable "$NAME" >/dev/null 2>&1 || true
  fi
  # Grok also scans ~/.claude/skills; hide the Claude symlink there so the plugin is the single source.
  grok_ignore_claude_copy
  if ! grok mcp list 2>/dev/null | grep -q 'rta-smriti'; then
    say "Registering rta-smriti MCP at user scope in ~/.grok/config.toml"
    grok mcp add rta-smriti --scope user -- "$PLUGIN/scripts/rta-brain-mcp.sh" >/dev/null 2>&1 || true
  fi
  grok plugin list 2>/dev/null | grep -A3 "$NAME" || true
}

uninstall_hosts() {
  say "Removing host registrations"
  rm -f "$HOME/.claude/skills/$NAME" "$HOME/.cursor/plugins/local/$NAME" "$HOME/.grok/plugins/$NAME"
  if have grok; then grok plugin uninstall "$NAME" >/dev/null 2>&1 || true; grok mcp remove rta-smriti --scope user >/dev/null 2>&1 || true; fi
  say "Done. Brain data in $KDP_HOME was left in place."
}

check_all() {
  printf 'brain:   %s\n' "$([ -x "$KDP_HOME/.venv/bin/rta-brain" ] && "$KDP_HOME/.venv/bin/rta-brain" --version 2>/dev/null || echo 'not installed')"
  printf 'brains:  %s\n' "$(ls "$KDP_HOME/brains"/*.sqlite 2>/dev/null | wc -l) project brain(s) in $KDP_HOME/brains"
  printf 'claude:  %s\n' "$([ -L "$HOME/.claude/skills/$NAME" ] && echo linked || echo 'not linked')"
  printf 'cursor:  %s\n' "$([ -L "$HOME/.cursor/plugins/local/$NAME" ] && echo linked || echo 'not linked')"
  printf 'grok:    %s\n' "$(have grok && (grok plugin list 2>/dev/null | grep -q "$NAME" && echo installed || echo 'not installed') || echo 'grok not found')"
}

if [ "$check" = 1 ]; then check_all; exit 0; fi
if [ "$uninstall" = 1 ]; then uninstall_hosts; exit 0; fi
[ "$do_brain" = 1 ] && install_brain
if [ ! -x "$KDP_HOME/.venv/bin/rta-brain" ]; then
  say "Rta-Smriti Brain is not installed; run: $0 --brain [zip-or-dir]"
fi
case "$host" in
  claude) install_claude ;;
  cursor) install_cursor ;;
  grok) install_grok ;;
  all) install_claude; install_cursor; install_grok ;;
  *) echo "unknown host: $host" >&2; exit 2 ;;
esac
say "Recommendation: run your coding agent from a terminal CLI (claude, grok) for full system vision."

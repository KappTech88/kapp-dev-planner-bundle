#!/usr/bin/env bash
# Read-only inventory of the development toolchain on this machine, as Markdown.
# Used by /drill-me when the user picks "scan what's on this machine". Makes no changes.
# Ends with the line KDP_INVENTORY_OK so callers can tell a complete run from a partial one.
set -uo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
ver() { # ver <label> <cmd> [args...] : print "- label: first line of output" or "- label: not installed"
  local label="$1"; shift
  if have "$1"; then
    local out; out="$("$@" 2>&1 | head -n1 | tr -d '\r')"
    printf -- '- %s: %s\n' "$label" "${out:-present}"
  else
    printf -- '- %s: not installed\n' "$label"
  fi
}

echo "# Machine inventory ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
echo
echo "## System"
echo "- host: $(hostname 2>/dev/null || echo '?')  user: ${USER:-?}"
if [ -r /etc/os-release ]; then . /etc/os-release; echo "- os: ${PRETTY_NAME:-$NAME}"; fi
echo "- kernel: $(uname -r)  arch: $(uname -m)"
echo "- cpu: $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //')  cores: $(nproc 2>/dev/null || echo '?')"
echo "- ram: $(free -h 2>/dev/null | awk '/Mem:/ {print $2 " total, " $7 " available"}')"
echo "- disk (home): $(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $4 " free of " $2}')"
if have lspci; then g="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | head -n2 | cut -d: -f3- | sed 's/^ //' | paste -sd ';')"; echo "- gpu: ${g:-none detected}"; fi
have nvidia-smi && echo "- nvidia driver: $(nvidia-smi --query-gpu=driver_version,name,memory.total --format=csv,noheader 2>/dev/null | head -n1)"
echo "- shell: ${SHELL:-?}  terminal: ${TERM_PROGRAM:-${TERM:-?}}"
echo "- package managers: $(for p in pacman yay paru apt dnf brew nix flatpak snap; do have $p && printf '%s ' $p; done)"
have mise && echo "- mise: $(mise --version 2>/dev/null | head -n1)"
echo
echo "## Languages and runtimes"
ver "python3" python3 --version
ver "pip (python3 -m pip)" python3 -m pip --version
ver "uv" uv --version
ver "pipx" pipx --version
ver "poetry" poetry --version
ver "node" node --version
ver "npm" npm --version
ver "pnpm" pnpm --version
ver "yarn" yarn --version
ver "bun" bun --version
ver "deno" deno --version
ver "go" go version
ver "rustc" rustc --version
ver "cargo" cargo --version
ver "java" java -version
ver "kotlin" kotlin -version
ver "dotnet" dotnet --version
ver "php" php --version
ver "composer" composer --version
ver "ruby" ruby --version
ver "elixir" elixir --version
ver "zig" zig version
ver "gcc" gcc --version
ver "clang" clang --version
ver "cmake" cmake --version
ver "make" make --version
if have mise; then echo; echo "### mise-managed tools"; mise ls 2>/dev/null | sed 's/^/    /'; fi
echo
echo "## Containers, virtualization, cloud"
ver "docker" docker --version
ver "docker compose" docker compose version
ver "podman" podman --version
ver "kubectl" kubectl version --client
ver "terraform" terraform version
ver "aws" aws --version
ver "gcloud" gcloud --version
ver "az" az version
ver "flyctl" flyctl version
ver "vercel" vercel --version
ver "wrangler" wrangler --version
echo
echo "## Databases and services"
ver "psql" psql --version
ver "postgres server" postgres --version
ver "mysql" mysql --version
ver "sqlite3" sqlite3 --version
ver "redis-server" redis-server --version
ver "mongod" mongod --version
ver "nginx" nginx -v
ver "caddy" caddy version
if have systemctl; then
  echo "- active services of interest: $(systemctl list-units --type=service --state=running --no-legend 2>/dev/null | grep -iE 'postgres|mysql|maria|redis|mongo|docker|podman|nginx|caddy|ollama' | awk '{print $1}' | paste -sd', ')"
fi
echo
echo "## Source control, editors, AI agents"
ver "git" git --version
ver "gh" gh --version
ver "glab" glab --version
ver "nvim" nvim --version
ver "code" code --version
ver "cursor" cursor --version
ver "zed" zed --version
echo "- AI coding CLIs: $(for p in claude grok codex gemini copilot opencode crush aider cursor-agent pi; do have $p && printf '%s ' $p; done)"
ver "ollama" ollama --version
echo
echo "## Notable installed packages"
if have pacman; then
  echo "- pacman: $(pacman -Qq 2>/dev/null | grep -xE 'python|nodejs|go|rust|jdk-openjdk|dotnet-sdk|php|ruby|docker|podman|postgresql|mariadb|redis|sqlite|nginx|caddy|ollama|cuda|rocm-hip-sdk|vulkan-icd-loader' | paste -sd', ')"
elif have dpkg; then
  echo "- dpkg: $(dpkg -l 2>/dev/null | awk '/^ii/ {print $2}' | grep -xE 'python3|nodejs|golang-go|rustc|default-jdk|dotnet-sdk-[0-9.]+|php|ruby|docker.io|podman|postgresql|mariadb-server|redis-server|sqlite3|nginx|caddy' | paste -sd', ')"
fi
echo
echo "KDP_INVENTORY_OK"

#!/usr/bin/env bash
# scripts/setup-mcps.sh — install the MCP servers bundled with sevaai-sdlc-toolkit.
#
# Reads .mcp.json as the source of truth so any MCPs you add there show up here.
#
# Usage:
#   ./scripts/setup-mcps.sh                # interactive: pick which to install
#   ./scripts/setup-mcps.sh --all          # install every non-template entry
#   ./scripts/setup-mcps.sh --minimal      # GitHub + Atlassian + Sentry
#   ./scripts/setup-mcps.sh --stage <N>    # only entries that benefit stage N (1-7)
#   ./scripts/setup-mcps.sh --list         # print catalog grouped by stage
#
# Requires: jq, and Claude Code CLI ('claude' command) authenticated.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MCP_FILE="$PLUGIN_ROOT/.mcp.json"

[[ -f "$MCP_FILE" ]] || { echo "error: $MCP_FILE not found" >&2; exit 1; }
command -v jq >/dev/null  || { echo "error: jq required (brew install jq)" >&2; exit 1; }

# Filter out the _custom_endpoint_template — it's an example, not a real MCP.
real_servers() {
  jq -r '.mcpServers | to_entries[] | select(.key | startswith("_") | not) | .key' "$MCP_FILE"
}

describe() {  # describe <server-name>
  jq -r --arg s "$1" '.mcpServers[$s]._purpose // ""' "$MCP_FILE"
}

stages_for() {  # stages_for <server-name>  -> "1, 2, 5"
  jq -r --arg s "$1" '.mcpServers[$s]._stages // [] | join(", ")' "$MCP_FILE"
}

free_for() {
  jq -r --arg s "$1" '.mcpServers[$s]._free_tier // "n/a"' "$MCP_FILE"
}

is_optional() {
  jq -e --arg s "$1" '.mcpServers[$s]._optional // false' "$MCP_FILE" >/dev/null
}

list_servers() {
  echo "MCP catalog (from $MCP_FILE):"
  echo
  for stage in 1 2 3 4 5 6 7; do
    matches=$(jq -r --argjson s "$stage" '.mcpServers | to_entries[] | select(.key | startswith("_") | not) | select((.value._stages // []) | index($s)) | .key' "$MCP_FILE")
    if [[ -n "$matches" ]]; then
      echo "Stage $stage:"
      while IFS= read -r srv; do
        printf "  %-35s  %s  (%s)\n" "$srv" "$(describe "$srv" | head -c 70)" "$(free_for "$srv" | head -c 40)"
      done <<<"$matches"
      echo
    fi
  done
}

MINIMAL=("atlassian-rovo" "github" "sentry")

mode="${1:-}"
arg2="${2:-}"

case "$mode" in
  --list)
    list_servers
    exit 0
    ;;
  --all)
    mapfile -t SELECTED < <(real_servers)
    ;;
  --minimal)
    SELECTED=("${MINIMAL[@]}")
    ;;
  --stage)
    [[ -n "$arg2" ]] || { echo "usage: --stage <1-7>" >&2; exit 1; }
    mapfile -t SELECTED < <(jq -r --argjson s "$arg2" '.mcpServers | to_entries[] | select(.key | startswith("_") | not) | select((.value._stages // []) | index($s)) | .key' "$MCP_FILE")
    ;;
  "")
    SELECTED=()
    echo "Pick which MCPs to install (Y/n for each). Defaults marked Y are the minimal set."
    echo
    while IFS= read -r srv; do
      default="N"
      for m in "${MINIMAL[@]}"; do [[ "$m" == "$srv" ]] && default="Y"; done
      read -r -p "  $srv  [stages $(stages_for "$srv") | $(free_for "$srv")] [$default]: " ans </dev/tty || true
      ans="${ans:-$default}"
      if [[ "$ans" =~ ^[Yy]$ ]]; then SELECTED+=("$srv"); fi
    done < <(real_servers)
    ;;
  --help|-h)
    grep '^#' "$0" | head -15
    exit 0
    ;;
  *)
    echo "unknown option: $mode" >&2
    grep '^#' "$0" | head -15 >&2
    exit 1
    ;;
esac

if ! command -v claude >/dev/null; then
  echo "warning: 'claude' CLI not found — printing manual install steps instead."
  for s in "${SELECTED[@]}"; do
    echo
    echo "=== $s ==="
    jq --arg s "$s" '.mcpServers[$s]' "$MCP_FILE"
  done
  exit 0
fi

echo
echo "Installing: ${SELECTED[*]}"
echo

for s in "${SELECTED[@]}"; do
  if claude mcp list 2>/dev/null | grep -q " $s$"; then
    echo "==> $s already installed, skipping"
    continue
  fi
  url=$(jq -r --arg s "$s" '.mcpServers[$s].url // empty' "$MCP_FILE")
  if [[ -n "$url" ]]; then
    echo "==> claude mcp add $s --transport http --url $url"
    claude mcp add "$s" --transport http --url "$url" || \
      echo "    (failed; add manually: $url)"
  else
    echo "==> $s is a local stdio server — see .mcp.json for command + env vars"
    jq --arg s "$s" '.mcpServers[$s] | {command, args, env}' "$MCP_FILE"
  fi
  echo
done

echo "Done. Run 'claude mcp list' to verify, then '/sdlc <feature>' to test."

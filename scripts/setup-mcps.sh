#!/usr/bin/env bash
# scripts/setup-mcps.sh — install the MCP servers bundled with sevaai-sdlc-toolkit.
#
# Usage:
#   ./scripts/setup-mcps.sh                # interactive: prompts which to install
#   ./scripts/setup-mcps.sh --all          # install all (will trigger OAuth for each)
#   ./scripts/setup-mcps.sh --minimal      # install minimum recommended (Atlassian + GitHub + Sentry)
#   ./scripts/setup-mcps.sh --list         # just print what's available
#
# Requires: Claude Code CLI (`claude` command) installed and authenticated.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MCP_FILE="$PLUGIN_ROOT/.mcp.json"

if [[ ! -f "$MCP_FILE" ]]; then
  echo "error: $MCP_FILE not found" >&2
  exit 1
fi

if ! command -v claude >/dev/null; then
  echo "error: 'claude' CLI not found. Install Claude Code first: https://docs.claude.com/claude-code" >&2
  exit 1
fi

# Map of server-name -> human description (kept in sync with .mcp.json)
declare -A DESCRIPTIONS=(
  [atlassian-rovo]="Jira + Confluence (stages 1, 2, 5)"
  [linear]="Linear issues (stage 1, alt to Jira)"
  [notion]="Notion docs (stages 1, 2)"
  [github]="GitHub repo, PRs, Actions (stages 2-6)"
  [sentry]="Sentry errors (stage 7)"
  [pagerduty]="PagerDuty on-call (stage 7)"
  [honeycomb]="Honeycomb SLOs (stage 7)"
  [incident-io]="incident.io incidents (stage 7, alt to PagerDuty)"
  [google-compute-engine]="GCP Compute Engine (stage 6, if on GCP)"
  [cloudflare-developer-platform]="Cloudflare Workers (stage 6, if on Cloudflare)"
  [figma]="Figma design context (stage 2, UI features)"
)

MINIMAL_SET="atlassian-rovo github sentry"

ALL_SERVERS=$(jq -r '.mcpServers | keys[]' "$MCP_FILE")

mode="${1:-}"

case "$mode" in
  --list)
    echo "Available MCP servers in this plugin:"
    for s in $ALL_SERVERS; do
      printf "  %-30s  %s\n" "$s" "${DESCRIPTIONS[$s]:-}"
    done
    exit 0
    ;;
  --all)
    SELECTED=$ALL_SERVERS
    ;;
  --minimal)
    SELECTED=$MINIMAL_SET
    ;;
  "")
    SELECTED=""
    echo "Pick which MCPs to install (Y/n for each). Press Enter to accept default."
    echo
    for s in $ALL_SERVERS; do
      default="N"
      [[ " $MINIMAL_SET " == *" $s "* ]] && default="Y"
      read -r -p "  install $s — ${DESCRIPTIONS[$s]:-} [$default]: " ans </dev/tty || true
      ans="${ans:-$default}"
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        SELECTED="$SELECTED $s"
      fi
    done
    ;;
  *)
    echo "usage: $0 [--list | --all | --minimal]" >&2
    exit 1
    ;;
esac

echo
echo "Installing: $SELECTED"
echo

for s in $SELECTED; do
  echo "==> claude mcp add-from-plugin sevaai-sdlc $s"
  # Each Claude Code version has a slightly different add command;
  # fall back to manual instructions if needed.
  if claude mcp list 2>/dev/null | grep -q " $s$"; then
    echo "    already installed, skipping"
    continue
  fi

  url=$(jq -r ".mcpServers[\"$s\"].url // empty" "$MCP_FILE")
  if [[ -n "$url" ]]; then
    claude mcp add "$s" --transport http --url "$url" || \
      echo "    (manual fallback) add this URL to your Claude config: $url"
  else
    cmd=$(jq -r ".mcpServers[\"$s\"].command // empty" "$MCP_FILE")
    args=$(jq -r ".mcpServers[\"$s\"].args | join(\" \") // empty" "$MCP_FILE")
    echo "    local server: $cmd $args  — set required env vars per .mcp.json"
  fi
  echo
done

echo "Done. Run 'claude mcp list' to verify, then '/sdlc <feature>' to test."

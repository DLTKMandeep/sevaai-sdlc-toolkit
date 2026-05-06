# MCP setup guide for sevaai-sdlc

If you've ever opened the `/mcp` menu in Claude Code, seen three options that don't include the tool you want, and given up — this guide is for you.

This document walks you through connecting every MCP server the SDLC toolkit can use, in the order you'll actually need them. Copy-paste the commands. Skip the theory unless you want it.

## TL;DR — the 60-second version

1. **MCPs are how Claude talks to your real tools** — Jira, GitHub, Notion, Mixpanel, etc. Each MCP is a small server that exposes one tool's API to Claude.
2. **Three ways to install an MCP**: in-app menu (`/mcp`), CLI (`claude mcp add`), or manual JSON edit. Use the CLI for anything not in the in-app list.
3. **`--scope user` makes the MCP available globally**; without it, it's only available in the current project.
4. **Restart `claude` after adding an MCP** — the running session won't see new MCPs until it re-scans.
5. **You only need the MCPs your project's `.sevaai-sdlc.yaml` enables.** Don't install all of them.

If that's all you needed, you're done. The rest of this doc is reference.

---

## Mental model — what MCPs actually are

An **MCP server** is a small process that exposes a tool's API to Claude using a standard protocol. Think of it like a USB port: Claude has the slot, the MCP server is the device.

When Claude Code starts in a project, it reads three places to find MCPs:

| Scope | Where it's stored | What it covers |
|---|---|---|
| `user` | `~/.claude/mcp.json` | Available in every project on your machine |
| `project` | `<project>/.mcp.json` | Available only in this project |
| `local` | the running session's memory | Available only in the current session |

**Most useful default: `user` scope.** Add the MCP once, use it everywhere. The toolkit's `.mcp.json` (project-scope) is a *menu* you can pick from — `scripts/setup-mcps.sh` reads it and helps you install the ones you actually want.

When Claude calls an MCP tool, it shows up like `mcp__github__get_file_contents` or `mcp__atlassian__createJiraIssue`. The names are deterministic: `mcp__<server-name>__<tool-name>`.

---

## The three install paths

### Path A — In-app menu (`/mcp`)

In a running Claude Code session, type `/mcp`. You'll see a curated list (Atlassian Rovo, Microsoft 365, sometimes a few others). Click **Add** next to one and follow the OAuth flow.

**Use when:** the MCP is in the curated list. Today this means: Atlassian Rovo, Microsoft 365.
**Don't use when:** you don't see what you want. The menu is short on purpose; most MCPs are not in it.

### Path B — CLI (`claude mcp add`)

The general-purpose path. Works for **any** MCP, including ones not in the in-app menu.

```bash
# Pattern
claude mcp add <name> --scope user [-e ENV_VAR=value ...] -- <command-to-run>

# Example: GitHub MCP
claude mcp add github --scope user \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=ghp_REPLACE \
  -- npx -y @modelcontextprotocol/server-github
```

After running this, **exit and relaunch `claude`** so it picks up the new MCP.

**Use when:** the MCP isn't in the in-app menu, or you want to script the setup.
**Don't use when:** the MCP is OAuth-only and the tool's docs say to use the in-app flow (Atlassian Rovo is the main example — token-based install works but OAuth is smoother).

### Path C — Manual JSON edit

For complete control or for batch setup, edit `~/.claude/mcp.json` directly. This is what `scripts/setup-mcps.sh` automates.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_REPLACE" }
    }
  }
}
```

After editing, restart `claude`.

**Use when:** you're scripting setup or migrating from another machine.
**Don't use when:** you're new to MCPs — use Path A or B until you're comfortable.

---

## MCPs you'll need, by SDLC stage

You don't need to install everything. Pick based on which stages your `.sevaai-sdlc.yaml` enables.

| Stage | Required MCPs | Optional MCPs | Free tier OK? |
|---|---|---|---|
| 0 — Bootstrap | GitHub | — | yes |
| 0.5 — Discovery | — | Productboard, Dovetail, Pendo, Mixpanel | mostly yes |
| 1 — Requirements | Jira (Atlassian Rovo) **or** GitHub | Notion | yes |
| 2 — Design | GitHub | Confluence (Atlassian Rovo) | yes |
| 3 — Development | GitHub | Sourcegraph, Linear (if not Jira) | yes |
| 4 — Testing | GitHub (Issues + Projects) | BrowserStack, Mabl, TestRail | mostly yes |
| 5 — Security | GitHub | Snyk, Semgrep, IriusRisk, Drata | partial — Snyk free tier limited |
| 6 — Deployment | GitHub | LaunchDarkly, Argo CD, Terraform Cloud | partial |
| 7 — Maintenance | — | PagerDuty, Datadog, Sentry, Honeycomb | mostly yes |
| 8 — Launch & Learn | — | Mixpanel, Amplitude, Intercom, HubSpot | mostly yes |

**Minimum viable setup for the toolkit:** GitHub + Atlassian Rovo. With those two, every existing skill works end-to-end. Everything else is upgrade.

---

## Per-MCP walkthroughs

Each section below shows: where to get credentials, the exact CLI command, and how to verify it works.

### 1. GitHub (essential)

**Get a token:**

1. Go to https://github.com/settings/tokens?type=beta
2. Click **Generate new token (fine-grained)**
3. Name: `claude-code-mcp`
4. Resource owner: your username or org
5. Repository access: pick the repos you want Claude to read/write
6. Permissions: **Contents: Read and write**, **Issues: Read and write**, **Pull requests: Read and write**, **Metadata: Read** (always required)
7. Generate and copy the token (starts with `github_pat_` or `ghp_`)

**Install:**

```bash
claude mcp add github --scope user \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=ghp_REPLACE_ME \
  -- npx -y @modelcontextprotocol/server-github
```

**Verify (in a new claude session):**

```
List the repos under <your-username> on GitHub.
```

You should see your repos listed. If you get an auth error, your token doesn't have `repo` scope (classic) or the right fine-grained permissions.

### 2. Atlassian Rovo (Jira + Confluence)

**The OAuth path (recommended):**

1. Open `claude` in any project.
2. Type `/mcp`.
3. Find **Atlassian Rovo** in the list and click **Add**.
4. A browser tab opens; log into Atlassian and approve.
5. Done — no token to manage.

**The CLI path (if OAuth fails):**

```bash
claude mcp add atlassian --scope user \
  -- npx -y @atlassian/mcp-server-atlassian
```

This will then prompt for OAuth on first use.

**Verify:**

```
List my Atlassian sites. Then list the Jira projects on <your-site>.
```

You should see your Atlassian Cloud site and projects listed. The toolkit's Jira hand-off uses tools like `createJiraIssue`, `searchJiraIssuesUsingJql`, `editJiraIssue`.

### 3. Notion (optional — for PRD pages)

**Get a token:**

1. Go to https://www.notion.so/profile/integrations
2. Click **+ New integration**, name it `Aurora SDLC` (or your project name), type **Internal**
3. Copy the **Internal Integration Secret** (starts with `ntn_` or `secret_`)
4. **Important:** share the database with the integration (`...` menu on the database → Connections → add your integration). Without this step, the integration sees nothing.

**Install:**

```bash
claude mcp add notion --scope user \
  -e NOTION_TOKEN=ntn_REPLACE_ME \
  -- npx -y @notionhq/notion-mcp-server
```

**Verify:**

```
List the Notion databases I have access to. Describe the schema of the "Aurora PRDs" database.
```

If it says "no databases found", you forgot the Connections step.

### 4. PagerDuty (Stage 7 — Maintenance)

**Get a token:**

1. PagerDuty → User profile → User settings → API access keys → Create
2. Choose **Read-only** or **Read/write** depending on whether you want Claude to create incidents

**Install:**

```bash
claude mcp add pagerduty --scope user \
  -e PAGERDUTY_API_KEY=u+REPLACE_ME \
  -- npx -y @pagerduty/mcp-server
```

**Verify:**

```
List my PagerDuty services and the on-call schedule for this week.
```

### 5. Datadog (Stage 7 — Maintenance)

**Get keys:**

Datadog → Organization Settings → API Keys → New Key. You also need an **Application Key** — Personal Settings → Application Keys → New Key.

**Install:**

```bash
claude mcp add datadog --scope user \
  -e DD_API_KEY=REPLACE_ME \
  -e DD_APP_KEY=REPLACE_ME \
  -e DD_SITE=datadoghq.com \
  -- npx -y @datadog/mcp-server
```

`DD_SITE` is `datadoghq.com` for US, `datadoghq.eu` for EU.

**Verify:**

```
Show me the SLOs in my Datadog account and the current burn rate for each.
```

### 6. Sentry (Stage 7)

**Get a token:**

Sentry → Settings → Account → API → Auth Tokens → Create New Token. Scopes needed: `event:read`, `project:read`, `org:read`.

**Install:**

```bash
claude mcp add sentry --scope user \
  -e SENTRY_AUTH_TOKEN=sntrys_REPLACE_ME \
  -- npx -y @getsentry/mcp-server
```

### 7. Snyk (Stage 5 — Security)

**Get a token:**

Snyk → Account settings → API token → copy.

**Install:**

```bash
claude mcp add snyk --scope user \
  -e SNYK_TOKEN=REPLACE_ME \
  -- npx -y @snyk/mcp-server
```

**Verify:**

```
List my Snyk projects and the count of open issues by severity.
```

### 8. LaunchDarkly (Stage 6)

**Get a token:**

LaunchDarkly → Account settings → Authorization → Create access token. Pick **Reader** unless you want Claude to flip flags.

**Install:**

```bash
claude mcp add launchdarkly --scope user \
  -e LD_API_KEY=api-REPLACE_ME \
  -- npx -y @launchdarkly/mcp-server
```

### 9. Mixpanel (Stage 8)

**Get a service account:**

Mixpanel → Project Settings → Service Accounts → Create. You need username + secret + project ID.

**Install:**

```bash
claude mcp add mixpanel --scope user \
  -e MIXPANEL_PROJECT_ID=REPLACE \
  -e MIXPANEL_SERVICE_ACCOUNT_USERNAME=REPLACE \
  -e MIXPANEL_SERVICE_ACCOUNT_SECRET=REPLACE \
  -- npx -y mixpanel-mcp-server
```

### 10. Productboard (Stage 0.5)

**Get a token:**

Productboard → Settings → Integrations → Public API → New token.

**Install:**

```bash
claude mcp add productboard --scope user \
  -e PRODUCTBOARD_API_TOKEN=REPLACE_ME \
  -- npx -y @productboard/mcp-server
```

### 11. Custom / self-hosted MCPs

For an MCP server you wrote or one not on npm, use the absolute path to the executable:

```bash
claude mcp add my-thing --scope user \
  -e MY_API_KEY=REPLACE \
  -- /usr/local/bin/my-mcp-server --port 0
```

The toolkit's `.mcp.json` includes a `_custom_endpoint_template` block as a starting point.

---

## Bulk install via `setup-mcps.sh`

If you want to install several at once, the toolkit ships a script that reads the bundled `.mcp.json` and installs them with the right env-var prompts:

```bash
cd ~/path/to/sevaai-sdlc-toolkit

# See what's available
./scripts/setup-mcps.sh --list

# Install just the essentials (GitHub + Atlassian + Sentry)
./scripts/setup-mcps.sh --minimal

# Install everything for a specific stage
./scripts/setup-mcps.sh --stage 5

# Install everything (you probably don't want this)
./scripts/setup-mcps.sh --all

# Interactive picker
./scripts/setup-mcps.sh
```

The script writes to `~/.claude/mcp.json` (user scope) and prompts for any required env vars.

---

## Wiring an MCP into the toolkit's hand-offs

Installing an MCP is half the job. The other half is telling the toolkit *which* MCP to push artifacts to. That's done in the project's `.sevaai-sdlc.yaml`:

```yaml
trackers:
  jira:
    enabled: true                     # Stage 1 will push stories here
    site: dltk-starpoint.atlassian.net
    project_key: SDLCTEST
    epic_issue_type: Workstream
    story_issue_type: Story
  github:
    enabled: true
    issues_repo: "DLTKMandeep/orion"
    mode: backlog                     # umbrella | backlog
    project_v2_number: 0
  notion:
    enabled: false
    prds_database_id: ""
```

Each skill reads this on every run and asks before pushing — opt-in per artifact, not auto-fire. If you set `enabled: true` but the MCP isn't installed, the skill will tell you and skip the push.

---

## Verification — the smoke-test pattern

Whatever MCP you just installed, the verification pattern is the same:

1. **Restart `claude`** in any project.
2. Run `/mcp` — your new MCP should appear in the list (or `claude mcp list` from the shell).
3. Ask Claude to call a *read-only* tool first: "list my X", "describe my Y". This catches auth errors before you trust it with writes.
4. Then try a *write* tool with something disposable: a dry-run, a test issue, a sandbox project.

If the read works and the write works, you're done.

---

## Troubleshooting

### "There's no `<skill>` skill available"

The skill files exist on disk but aren't symlinked into `~/.claude/skills/`. Fix:

```bash
ln -s ~/path/to/sevaai-sdlc-toolkit/skills/<skill-name> ~/.claude/skills/<skill-name>
```

Then restart `claude`. Confirm with `claude skill list | grep sdlc`.

### "I don't see option to add" in the `/mcp` menu

The in-app menu only shows curated MCPs. For everything else, use the CLI path:

```bash
claude mcp add <name> --scope user -e KEY=value -- npx -y <package>
```

### MCP installed but Claude says "I don't have access to that tool"

Three causes, in order of frequency:

1. **You haven't restarted `claude` since installing the MCP.** Exit and relaunch.
2. **The MCP failed silently on startup.** Run `claude mcp list` — if your MCP shows `error` or doesn't appear, check `~/Library/Logs/Claude/mcp-*.log` (Mac) for the cause. Usually a missing env var or a wrong package name.
3. **The MCP is installed but not at the right scope.** `--scope project` only works in that project's directory; check with `claude mcp list --scope all`.

### "Native package darwin-arm64 not found" on install

You're running x64 Node under Rosetta 2. Fix:

```bash
# Install nvm if you don't have it
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# In a new terminal
arch -arm64 zsh -ic 'nvm install --lts'
nvm use --lts

# Confirm
node --version
which node    # should be under ~/.nvm/versions/node/
```

Then reinstall claude code: `npm install -g @anthropic-ai/claude-code`.

### Token leaked into a repo / shell history

Rotate it immediately. Then store in a real secret manager (1Password, Bitwarden, macOS Keychain) and reference it via shell:

```bash
claude mcp add github --scope user \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$(security find-generic-password -s github-mcp -w)" \
  -- npx -y @modelcontextprotocol/server-github
```

This way the token doesn't sit in `~/.claude/mcp.json` in plaintext.

### Multiple MCPs with the same name conflict

You added GitHub at user scope and project scope. Project wins. Check with `claude mcp list --scope all` and remove the one you don't want with `claude mcp remove <name> --scope <scope>`.

---

## A practical sequence for a new team member

If someone joins your team and needs to get the toolkit running, here's the path that works in ~30 minutes:

1. **Install Claude Code:** `npm install -g @anthropic-ai/claude-code` (use `arch -arm64` if on Apple Silicon — see troubleshooting).
2. **Clone the toolkit:** `git clone https://github.com/DLTKMandeep/sevaai-sdlc-toolkit && cd sevaai-sdlc-toolkit`
3. **Symlink the skills:** `ln -s "$(pwd)/skills"/* ~/.claude/skills/`
4. **Install the two essentials:** Atlassian Rovo via `/mcp` (in-app), GitHub via the CLI command in §1 above.
5. **Verify:** in any project, `claude mcp list` should show both. Run a smoke-test prompt for each.
6. **Open the project they're working on**, check that `.sevaai-sdlc.yaml` has `trackers.jira.enabled: true` and the right `project_key`.
7. **Run `/sdlc <feature description>`** and follow the prompts.

If they hit anything unexpected, the troubleshooting section above covers ~90% of the real problems.

---

## What's next when stages 0.5 and 8 ship

Once `sdlc-discovery` and `sdlc-launch` are released (planned for v0.4.0), the MCPs that become useful but aren't yet:

- **Productboard** for discovery hand-off (or **Dovetail** for research notes)
- **Mixpanel** or **Amplitude** for outcome metrics in Launch & Learn
- **Intercom** or **Zendesk** for customer-feedback intake during Launch

This guide will update with their walkthroughs in the same format. The pattern is identical: get a token, run `claude mcp add`, restart, smoke-test.

---

## One-line summary

> If `/mcp` doesn't show what you need, use `claude mcp add <name> --scope user -e KEY=value -- npx -y <package>`, then restart `claude`. That solves 90% of MCP setup confusion.

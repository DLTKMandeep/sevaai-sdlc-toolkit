# MCP catalog

Every MCP server bundled with sevaai-sdlc-toolkit, grouped by SDLC stage. All entries live in [`/.mcp.json`](../.mcp.json) — install commands flow through `scripts/setup-mcps.sh` (interactive) or your Claude Code plugin install dialog.

For your own / commercial / on-prem endpoints, scroll to **[Adding a custom MCP](#adding-a-custom-mcp)** at the bottom.

## Stage 1 — Requirements

| MCP | Free? | Notes |
|---|---|---|
| **Atlassian Rovo** (Jira + Confluence) | ≤10 users free | most teams' default tracker + wiki |
| **Linear** | ≤10 users free | Jira alternative; popular with smaller teams |
| **Asana** | ≤15 users free | project management; cross-functional teams |
| **Notion** | personal free | long-form PRDs, knowledge base |
| **Slack** | small teams free | capture requirements from threads |

## Stage 2 — Design

| MCP | Free? | Notes |
|---|---|---|
| **Atlassian Rovo** (Confluence ADRs) | ≤10 users free | for ADR-as-Confluence shops |
| **Notion** | personal free | for ADR-as-Notion shops |
| **Miro** | free | whiteboarding + journey maps |
| **Lucid** | free | diagrams |
| **Figma** | starter free | UI design context |
| **Stoplight** | limited free | host OpenAPI spec |
| **Postman** | free | API contract design |
| **GitHub / GitLab / Azure DevOps** | free | read existing ADRs and code structure |

## Stage 3 — Development

| MCP | Free? | Notes |
|---|---|---|
| **GitHub** | free | the most common dev plane |
| **GitLab** | free | alternative |
| **Azure DevOps** | free ≤5 users | Microsoft stack |
| **Sourcegraph** | OSS free | code search across many repos |

## Stage 4 — Testing

| MCP | Free? | Notes |
|---|---|---|
| **GitHub Issues** | free | tracking failures and bugs |
| **Postman** | free | contract / API tests |
| **BrowserStack** | trial | cross-browser matrix |

## Stage 5 — Security

| MCP | Free? | Notes |
|---|---|---|
| **Atlassian Rovo** | ≤10 users free | compliance docs in Confluence |
| **GitHub** | free | Dependabot + security advisories |
| **Snyk** | free for individuals | vuln scanning, IaC misconfig |
| **Okta** | dev free | identity for auth-touching features |
| **Auth0** | ≤7,500 MAU free | identity (Okta-owned) |
| **Splunk** | indexed free | SOC integration |

## Stage 6 — Deployment

| MCP | Free? | Notes |
|---|---|---|
| **GitHub Actions** | free | the most common CI/CD |
| **GitLab CI** | free tier | alternative |
| **Azure DevOps** | free ≤5 users | Microsoft stack |
| **AWS** | free tier | ECS, Lambda, RDS, EKS, S3 |
| **Google Compute Engine** | free tier | GCE state |
| **Cloudflare Developer Platform** | Workers free | edge / Jamstack |
| **Vercel** | Hobby free | frontend deploys |
| **Netlify** | free | Jamstack alternative |
| **LaunchDarkly** | trial | feature flags |
| **Terraform Cloud** | ≤5 users free | IaC plan/run state |

## Stage 7 — Maintenance

| MCP | Free? | Notes |
|---|---|---|
| **Sentry** | 5K errors/mo free | error patterns for runbook |
| **PagerDuty** | dev free | on-call schedules |
| **Honeycomb** | 20M events/mo free | SLOs grounded in real telemetry |
| **Datadog** | trial | most common commercial APM |
| **New Relic** | 100GB/mo free | APM alternative |
| **Grafana Cloud** | free tier | dashboards + Loki + Tempo + OnCall |
| **Splunk** | indexed free | log search |
| **incident.io** | trial | incident management |
| **BetterStack** | free | uptime + status page |
| **Slack** | small teams free | alerts and incident comms |

## Adding a custom MCP

If your team has an internal or commercial MCP not listed here, drop it into `.mcp.json`. Both flavors are supported.

### Remote (HTTP) endpoint

```json
"my-internal-tool": {
  "_purpose": "stage X — what this unlocks for the SDLC",
  "_stages": [3, 6],
  "_free_tier": "internal / not applicable",
  "type": "http",
  "url": "https://mcp.your-internal-tool.example.com/mcp"
}
```

### Local stdio MCP server

```json
"my-cli-tool": {
  "_purpose": "stage X — local server we run via npm",
  "_stages": [4],
  "_free_tier": "n/a",
  "command": "npx",
  "args": ["-y", "@your-org/your-mcp-server"],
  "env": {
    "YOUR_API_KEY": "${env:YOUR_API_KEY}"
  }
}
```

After saving the file:

```bash
./scripts/setup-mcps.sh --list           # confirm it appears
./scripts/setup-mcps.sh --stage 4         # install only stage-4 MCPs (or use --all)
```

The interactive picker, `--list`, `--all`, and `--stage <N>` all read directly from `.mcp.json` — no script changes needed.

### Tips for finding a vendor's MCP endpoint

1. Check the vendor's docs site for "MCP" or "Model Context Protocol".
2. Look in the [Anthropic MCP registry](https://docs.claude.com/mcp) for the maintained list.
3. Search the awesome-mcp-servers repo on GitHub.
4. If a vendor only has a REST API, you can wrap it as an MCP using the official MCP SDK in Python or TypeScript — that's a 30-line adapter for most APIs.

### Don't see your tool's category?

The `_stages` field accepts any of `[1, 2, 3, 4, 5, 6, 7]`. If your tool spans multiple stages, list all of them — `--stage 7` will pick it up when you're working on the maintenance bundle and `--stage 5` when you're on security.

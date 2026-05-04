# MCP integration guide

**MCPs are bundled with this plugin.** The repo includes a [`.mcp.json`](../.mcp.json) declaring all the recommended servers per stage. Installing the plugin in Claude Code registers them; you pick which to authenticate. There's also a CLI installer at `scripts/setup-mcps.sh` for terminal users. The skills still work without any MCPs — they fall back to local file reads — but each stage gets noticeably better when paired with the right server, because the skill can pull live state instead of inferring it.

## Per-stage MCP map

| # | Stage | Primary MCPs | What it unlocks | Where to install |
|---|---|---|---|---|
| 1 | Requirements | **Atlassian Rovo** (Jira + Confluence), **Linear**, **Notion**, **Glean** | Pull related epics, prior PRDs, customer feedback. Write stories back to Jira/Linear. | Cowork registry (`/mcp` add) |
| 2 | Design | **Atlassian Rovo** (Confluence ADRs), **Notion**, **Figma**, **Lucid**, **Microsoft 365** (SharePoint), **GitHub** | Read existing ADRs, infer code conventions, pull UI design context. | Mostly Cowork registry; **GitHub MCP** via `github.com/github/github-mcp-server` |
| 3 | Development | **GitHub** (or **GitLab**), **Microsoft Learn** | Read repo structure, lint configs, prior PRs, related docs. | GitHub MCP via official server |
| 4 | Testing | **GitHub** (CI configs, existing tests), **Atlassian Rovo** (related bugs in Jira) | Cross-reference test coverage with related defects, infer test framework conventions. | Same as above |
| 5 | Security | **GitHub** (security advisories, Dependabot), **Atlassian Rovo** (compliance docs in Confluence), **Snyk** (if available) | Pull dependency CVE data, link to compliance evidence, audit secret-scanning state. | Snyk MCP via Snyk docs (emerging) |
| 6 | Deployment | **GitHub** (Actions), **Cloudflare Developer Platform**, **Google Compute Engine**, **AWS Marketplace**, **Datadog** (deploy markers), **LaunchDarkly** | Read CI workflow state, read IaC, check current flag config, set deploy markers. | Mix of registry + vendor docs |
| 7 | Maintenance | **PagerDuty**, **Sentry**, **incident.io**, **Honeycomb**, **Datadog**, **Mixpanel/Amplitude/PostHog** (product KPIs) | Pull incident history, error rates, SLO state, on-call schedules. Auto-populate runbooks from real telemetry. | All in Cowork registry except Datadog |

## Recommended phased rollout

You don't need everything on day one. Connect in three phases by impact:

### Phase 1 — Code & docs (week 1)
Connect these and the toolkit can ground every stage in your real project state:

- **GitHub MCP** — by far the highest leverage. Touches stages 2-6.
- **Atlassian Rovo** (Jira + Confluence) OR **Linear** — pick whichever your team uses for tickets and docs. Touches stages 1-2 and 5.

That's enough to run the whole pipeline with real grounding.

### Phase 2 — Operations (week 2)
Once you start running features through the pipeline, add ops MCPs to make the maintenance stage real:

- **Sentry** — error data for runbook generation.
- **PagerDuty** OR **incident.io** — on-call schedules, paste-able paging commands in runbooks.
- **Honeycomb** OR **Datadog** — SLI/SLO definitions and dashboards. Honeycomb is in the Cowork registry; Datadog has its own MCP.

### Phase 3 — Specialty (later)
Connect as needed for specific workflows:

- **Notion** if your team writes long-form docs there instead of Confluence.
- **Figma** / **Lucid** if a design system is the bottleneck for the design stage.
- **Mixpanel** / **Amplitude** / **PostHog** to feed product KPIs into Stage 1 (requirements grounded in real usage data).
- **Snyk** when its MCP stabilizes — meanwhile, the GitHub MCP gives you Dependabot alerts.
- **LaunchDarkly** when its MCP stabilizes — meanwhile, the deployment skill writes the flag plan as text.

## What the skill does when an MCP is missing

Every `SKILL.md` is written to fail gracefully. If a stage's preferred MCP isn't connected, the skill falls back to:

1. Local file reads (Glob/Read/Grep).
2. The `.sevaai-sdlc.yaml` config block.
3. The user's chat input.

The artifact still gets written — it just relies on what you've told the skill in prose instead of what the MCP could fetch.

## How to connect an MCP

In Claude Code or Cowork, type `/mcp` to open the MCP management UI. From there:
- **Cowork registry**: search by name and click Connect — Cowork handles OAuth.
- **External MCPs (GitHub, Datadog, AWS, Snyk)**: follow the vendor's MCP server install docs; they typically give you a JSON snippet to paste into your Claude config.

## Stage-by-stage trigger examples once MCPs are connected

```
"Run the full SDLC for adding bulk CSV import"
  -> Stage 1 reads Jira (via Atlassian Rovo) for related stories
  -> Stage 2 reads existing Confluence ADRs and your code via GitHub MCP
  -> Stage 5 cross-references Dependabot alerts via GitHub MCP
  -> Stage 7 pulls historical incidents via PagerDuty + error patterns via Sentry
```

```
"Write the runbook for the bulk-import feature."
  -> sdlc-maintenance triggers
  -> reads PagerDuty schedules + Sentry error patterns + Honeycomb SLOs
  -> writes a runbook with real on-call routing and real SLI thresholds
```

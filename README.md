# sevaai-sdlc

[![Validate plugin](https://github.com/DLTKMandeep/sevaai-sdlc-toolkit/actions/workflows/validate.yml/badge.svg)](https://github.com/DLTKMandeep/sevaai-sdlc-toolkit/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Automated, AI-powered Software Development Lifecycle for any codebase, in any AI tool.**

Drop this plugin into your AI assistant and get seven composable skills that walk a feature from idea to operations: Requirements -> Design -> Development -> Testing -> Security -> Deployment -> Maintenance. Each skill is self-contained, references the real-world tools you already use (Jira, Snyk, Datadog, Harness, etc.), and produces ship-ready markdown artifacts.

### Works with

| Claude Code / Cowork | Cursor | Aider | ChatGPT (custom GPT) | Gemini (Gem) | Anything else |
|---|---|---|---|---|---|
| `plugin.json` | `.cursor/rules/*.mdc` | `CONVENTIONS.md` | one GPT per stage | one Gem per stage | raw prompt files |

The skills are markdown — they work anywhere you can set custom instructions. See [`adapters/`](adapters/) for ready-to-paste configs per tool.

```
+-------------+   +--------+   +-------------+   +---------+   +----------+   +------------+   +-------------+
| Requirements |->| Design |->| Development |->| Testing |->| Security |->| Deployment |->| Maintenance |
+-------------+   +--------+   +-------------+   +---------+   +----------+   +------------+   +-------------+
        ^----------------------------- /sdlc orchestrator ------------------------------------^
```

> See [docs/reference-architecture.md](docs/reference-architecture.md) for the full reference architecture diagram showing flow, runtime tools (Glob / Read / Grep / LLM / MCP / Write), and per-stage hand-off to real-world products. See [docs/sdlc-stages-detail.md](docs/sdlc-stages-detail.md) for the elaborate per-stage breakdown — every sub-activity each stage's artifact must address (Planning, HLD/LLD, System/Manual/Automated Testing, STRIDE/OWASP/Compliance, Feedback Loop, etc.).

## Why a skill pack, not a service?

Skills are markdown bundles an AI agent loads on demand. There's no server to host, no API to maintain, no model to fine-tune. The plugin is just files. That makes it:

- **Releasable as a product.** Ship via the Claude Code plugin marketplace, internal git repo, or a tarball.
- **Editable by the team.** Change `SKILL.md` to encode your conventions, compliance needs, supported stacks.
- **Composable.** Run one stage, several, or the whole pipeline. Stages are independent.
- **Tool-agnostic where it counts.** Skills point at real released products (GitHub Copilot, Snyk, Mabl, Harness, PagerDuty, etc.) instead of reinventing them.

## Install

### Claude Code

```bash
# From a marketplace
/plugin marketplace add DLTKMandeep/sevaai-sdlc-toolkit
/plugin install sevaai-sdlc

# Or directly from a local clone
/plugin install ./sevaai-sdlc-toolkit
```

### Cowork

Drop the `sevaai-sdlc-toolkit/` folder into your Cowork plugins directory. Cowork auto-discovers skills via their `SKILL.md` frontmatter.

### Manual

Symlink the skills into your Claude config:

```bash
ln -s "$(pwd)/skills"/* ~/.claude/skills/
ln -s "$(pwd)/commands/sdlc.md" ~/.claude/commands/sdlc.md
```

### Cursor

```bash
# from your project root
cp -R /path/to/sevaai-sdlc-toolkit/adapters/cursor/.cursor .
```

Cursor auto-loads each `.mdc` rule when its trigger phrase fires.

### Aider

```bash
aider --read /path/to/sevaai-sdlc-toolkit/adapters/aider/CONVENTIONS.md
```

Or add to `.aider.conf.yml`:
```yaml
read:
  - /path/to/sevaai-sdlc-toolkit/adapters/aider/CONVENTIONS.md
```

### ChatGPT custom GPT / Gemini Gem

Open `adapters/openai-gpt/sdlc-<stage>.md` (or `adapters/gemini-gem/...`), paste the body as the GPT/Gem's Instructions. One per stage. Optional: upload your README + ADRs as Knowledge.

### Anything else

`adapters/raw/sdlc-<stage>.md` is a tool-agnostic prompt — works in Cline, Continue.dev, Roo Code, Ollama, LM Studio, raw API calls, anywhere you can set a system prompt.

## MCPs are bundled with the plugin

The plugin ships a [`.mcp.json`](.mcp.json) declaring **34+ MCP servers** mapped to SDLC stages. When you install the plugin in Claude Code, you'll be offered to register and authenticate each one. Pick what your team uses; skip the rest. The most-used picks at a glance:

| MCP | Stages | Free tier? |
|---|---|---|
| **GitHub** | 2-6 | yes |
| **GitLab** / **Azure DevOps** | 2-6 (alt) | yes |
| **Atlassian Rovo** (Jira + Confluence) | 1, 2, 5 | yes (≤10 users) |
| **Notion** | 1, 2 | personal yes; teams paid |
| **Linear** / **Asana** | 1 (alts to Jira) | yes (≤10/15 users) |
| **Slack** | 1, 7 | yes (small teams) |
| **Figma** / **Miro** / **Lucid** / **Stoplight** | 2 | yes |
| **Postman** / **BrowserStack** | 4 | free / trial |
| **Snyk** / **Okta** / **Auth0** | 5 | yes |
| **Vercel** / **Netlify** / **AWS** / **GCE** / **Cloudflare** / **LaunchDarkly** / **Terraform Cloud** | 6 | yes |
| **Sentry** | 7 | yes (5K errors/mo) |
| **PagerDuty** | 7 | yes (Developer plan) |
| **Honeycomb** | 7 | yes (20M events/mo) |
| **Datadog** / **New Relic** / **Grafana Cloud** / **Splunk** / **BetterStack** / **incident.io** | 7 | trial / free / paid |

Prefer the terminal? Run the bundled installer:

```bash
./scripts/setup-mcps.sh --minimal       # GitHub + Atlassian + Sentry
./scripts/setup-mcps.sh --all           # everything (will OAuth each)
./scripts/setup-mcps.sh --stage 7       # only the MCPs that benefit stage 7
./scripts/setup-mcps.sh                 # interactive, pick one by one
./scripts/setup-mcps.sh --list          # browse the catalog grouped by stage
```

See [docs/mcp-catalog.md](docs/mcp-catalog.md) for the full categorized list and [docs/mcp-integration.md](docs/mcp-integration.md) for which MCPs help which stages. The `.mcp.json` includes a `_custom_endpoint_template` so teams can plug in internal or on-prem MCPs by following the same shape.

If you skip MCP setup entirely, the toolkit still works — every skill falls back to local file reads, the `.sevaai-sdlc.yaml` config, and your chat input.

## Make it mandatory — enforcement bundle

If you want sevaai-sdlc to be a **precursor** for any code that lands in your repo, drop the enforcement bundle into your project. It adds three layers:

1. **CI gate** — GitHub Actions workflow that fails any PR without a complete dossier or with a `BLOCKING` security stage. Mark it required in branch protection and merges become impossible without the dossier.
2. **AI guardrail (`CLAUDE.md`)** — auto-loaded by Claude Code / Cline / any CLAUDE.md-aware assistant; instructs the AI to refuse code changes until the dossier exists.
3. **Local pre-commit nudge** — warns the developer at commit time before they push.

Install in 30 seconds:

```bash
cd ~/path/to/your-project
~/path/to/sevaai-sdlc-toolkit/enforcement/setup-enforcement.sh
```

See [`enforcement/README.md`](enforcement/README.md) for what's installed and [`enforcement/docs.md`](enforcement/docs.md) for the phased rollout playbook (Phase 0 nudge -> Phase 1 soft launch -> Phase 2 hard gate -> Phase 3 routing).

## Quick start

Once installed, just describe what you want to build:

> "I need to add SSO with SAML to our portal, can you run the SDLC?"

The orchestrator skill picks up the trigger, walks all seven stages, and writes artifacts to `.sevaai-sdlc/<feature-slug>/` in your project. You can also run individual stages by name:

> "Generate a threat model for the SSO feature."  -> triggers `sdlc-security` only
> "Write the deployment plan for the SSO feature." -> triggers `sdlc-deployment` only
> "/sdlc Add SSO with SAML"                         -> runs the whole pipeline

## What you get per stage

Each stage produces a structured markdown artifact under `.sevaai-sdlc/<feature-slug>/`. Every artifact addresses an explicit set of sub-activities — see [docs/sdlc-stages-detail.md](docs/sdlc-stages-detail.md) for the full breakdown.

| Stage | Sub-activities covered | Artifact | Real-world products it works alongside |
|---|---|---|---|
| **1. Requirements** | Planning (scope, objectives, resources, timeline, KPIs) + Functional & Non-functional requirements + Definition of Ready + Compliance flags | `01-requirements.md` | Jira / Linear / Notion / Productboard / Asana |
| **2. Design** | High-Level Design + Low-Level Design + ADR + first-pass STRIDE | `02-design.md` | Eraser / Backstage / IriusRisk / Stoplight / Figma |
| **3. Development** | PR breakdown + Coding standards + Scalable code patterns + Version control + Code review checklist | `03-development.md` | Cursor / Copilot / Claude Code / CodeRabbit / Greptile |
| **4. Testing** | Test pyramid + System / Manual / Automated testing + Test data + Flake budget | `04-testing.md` | Mabl / Diffblue / Applitools / Qodo / BrowserStack |
| **5. Security** | STRIDE + OWASP Top 10 / ASVS L2 + Auth/authz + Data classification + Supply chain + Secrets + GenAI threats + Compliance + Pen test | `05-security.md` | Snyk / Semgrep / IriusRisk / Lakera / Auth0 / Okta |
| **6. Deployment** | Release planning + Feature flags + Canary analysis + Deployment automation + Rollback runbook + Release notes + Comms + Cost/capacity | `06-deployment.md` | Harness / LaunchDarkly / Argo / Pulumi / Vercel / GitHub Actions |
| **7. Maintenance** | SLOs + Dashboards + Alerting + Runbook + On-call cheat sheet + Postmortem template + Tech-debt watchlist + Capacity trend + Feedback loop | `07-maintenance.md` | Datadog / PagerDuty / Honeycomb / Sentry / Grafana / New Relic |

## Folder layout

```
sevaai-sdlc-toolkit/
├── plugin.json                   # marketplace manifest (Claude Code)
├── .mcp.json                     # 34+ bundled MCP servers per stage
├── README.md                     # this file
├── skills/                       # 7 stage skills + orchestrator (source of truth)
│   └── sdlc-<stage>/
│       ├── SKILL.md              # frontmatter triggers + sub-activities + instructions
│       └── templates/artifact.md # structured template the skill fills in
├── commands/
│   └── sdlc.md                   # /sdlc slash command
├── adapters/                     # generated formats for non-Claude tools
│   ├── cursor/                   # .cursor/rules/*.mdc
│   ├── aider/                    # CONVENTIONS.md
│   ├── openai-gpt/               # paste-as-Instructions per stage
│   ├── gemini-gem/               # paste-as-instructions per stage
│   └── raw/                      # tool-agnostic prompts
├── enforcement/                  # CI gate + CLAUDE.md guardrail + pre-commit hook
│   ├── README.md
│   ├── setup-enforcement.sh
│   ├── docs.md                   # rollout playbook
│   └── templates/                # files copied into the target repo
├── scripts/
│   ├── setup-mcps.sh             # CLI installer for the bundled MCPs (jq + claude CLI)
│   └── build-adapters.py         # regenerate adapters from skills/
├── examples/
│   └── sample_feature.md
└── docs/
    ├── reference-architecture.md # high-level flow + runtime tools
    ├── reference-architecture.svg
    ├── sdlc-stages-detail.md     # elaborated sub-activities per stage
    ├── mcp-integration.md        # which MCPs help which stages
    ├── mcp-catalog.md            # full categorized MCP list + custom-endpoint guide
    └── customization.md          # tune for your stack
```

Each stage skill is a folder with a `SKILL.md` (instructions for the AI, including a `Sub-activities covered` block that scopes what the artifact must address) and a `templates/` directory of artifact templates that the skill fills in.

## Documentation

| Doc | What's inside |
|---|---|
| [docs/reference-architecture.md](docs/reference-architecture.md) | Flow + runtime tools (Glob/Read/Grep/LLM/MCP/Write) + hand-off products |
| [docs/sdlc-stages-detail.md](docs/sdlc-stages-detail.md) | Every sub-activity each stage's artifact must address |
| [docs/mcp-catalog.md](docs/mcp-catalog.md) | All 34+ bundled MCPs grouped by stage + how to add your own |
| [docs/mcp-integration.md](docs/mcp-integration.md) | Which MCPs help which stages and how to roll them out |
| [docs/customization.md](docs/customization.md) | Tune the skills for your stack and conventions |
| [adapters/README.md](adapters/README.md) | Per-tool install steps for Cursor, Aider, GPTs, Gems, raw |

## Customize for your stack

Open any `SKILL.md` and edit the `Project conventions` block. Common things teams change:

- **Compliance frameworks.** Add SOC 2 / FedRAMP / HIPAA / PCI requirements that the skill should always check.
- **Supported runtimes.** Tell the design skill it must produce designs that fit your stack (e.g., Node + Postgres + GKE).
- **Tooling.** Tell the security skill which scanners you use, the deployment skill which CD platform you run.
- **Output destinations.** Default writes to `.sevaai-sdlc/`; change to `docs/sdlc/` or wherever your team keeps specs.

## License

MIT.

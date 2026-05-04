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

> See [docs/reference-architecture.md](docs/reference-architecture.md) for the full reference architecture diagram showing flow, runtime tools (Glob / Read / Grep / LLM / MCP / Write), and per-stage hand-off to real-world products.

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

The plugin ships a [`.mcp.json`](.mcp.json) that declares the high-value MCP servers each SDLC stage benefits from. When you install the plugin in Claude Code, you'll be offered to register and authenticate each one. Pick what your team uses; skip the rest. They map to stages like this:

| MCP | Stages | Free tier? |
|---|---|---|
| **GitHub** | 2-6 | yes |
| **Atlassian Rovo** (Jira + Confluence) | 1, 2, 5 | yes (≤10 users) |
| **Notion** | 1, 2 | personal yes; teams paid |
| **Linear** (alt to Jira) | 1 | yes (≤10 users) |
| **Sentry** | 7 | yes (5K errors/mo) |
| **PagerDuty** | 7 | yes (Developer plan) |
| **Honeycomb** | 7 | yes (20M events/mo) |
| **Google Compute Engine** | 6 (GCP) | yes |
| **Cloudflare Developer Platform** | 6 (Cloudflare) | yes |
| **Figma** | 2 (UI features) | yes |

Prefer the terminal? Run the bundled installer:

```bash
./scripts/setup-mcps.sh --minimal       # GitHub + Atlassian + Sentry
./scripts/setup-mcps.sh --all           # everything (will OAuth each)
./scripts/setup-mcps.sh --stage 7       # only the MCPs that benefit stage 7
./scripts/setup-mcps.sh                 # interactive, pick one by one
./scripts/setup-mcps.sh --list          # browse the catalog grouped by stage
```

See [docs/mcp-catalog.md](docs/mcp-catalog.md) for the full list — 35+ servers across all 7 stages, including a template for adding your own custom or on-prem endpoints.

If you skip MCP setup entirely, the toolkit still works — every skill falls back to local file reads, the `.sevaai-sdlc.yaml` config, and your chat input.

## Quick start

Once installed, just describe what you want to build:

> "I need to add SSO with SAML to our portal, can you run the SDLC?"

The orchestrator skill picks up the trigger, walks all seven stages, and writes artifacts to `.sevaai-sdlc/<feature-slug>/` in your project. You can also run individual stages by name:

> "Generate a threat model for the SSO feature."  -> triggers `sdlc-security` only
> "Write the deployment plan for the SSO feature." -> triggers `sdlc-deployment` only
> "/sdlc Add SSO with SAML"                         -> runs the whole pipeline

## What you get per stage

| Stage | Real-world products it works alongside | Artifact written |
|---|---|---|
| Requirements | Jira / Linear / Notion / Productboard | `01-requirements.md` (user stories + acceptance criteria) |
| Design | Eraser / Excalidraw / Backstage / IriusRisk | `02-design.md` (component plan, API contracts, ADR) |
| Development | Cursor / Copilot / Claude Code / CodeRabbit | `03-development.md` (file plan, conventions, review checklist) |
| Testing | Mabl / Diffblue / Applitools / Qodo | `04-testing.md` (test plan, stubs, edge cases) |
| Security | Snyk / Semgrep / IriusRisk / Lakera | `05-security.md` (threat model, OWASP map, checklist) |
| Deployment | Harness / LaunchDarkly / Argo / Pulumi | `06-deployment.md` (rollout, flags, rollback) |
| Maintenance | Datadog Bits / PagerDuty AIOps / DevOps Guru | `07-maintenance.md` (runbook, SLOs, monitoring) |

## Folder layout

```
sevaai-sdlc-toolkit/
├── plugin.json                   # marketplace manifest (Claude Code)
├── .mcp.json                     # bundled MCP servers per stage
├── README.md                     # this file
├── skills/                       # 7 stage skills + orchestrator (source of truth)
├── commands/
│   └── sdlc.md                   # /sdlc slash command
├── adapters/                     # generated formats for non-Claude tools
│   ├── cursor/                   # .cursor/rules/*.mdc
│   ├── aider/                    # CONVENTIONS.md
│   ├── openai-gpt/               # paste-as-Instructions per stage
│   ├── gemini-gem/               # paste-as-instructions per stage
│   └── raw/                      # tool-agnostic prompts
├── scripts/
│   ├── setup-mcps.sh             # CLI installer for the bundled MCPs
│   └── build-adapters.py         # regenerate adapters from skills/
├── examples/
│   └── sample_feature.md
└── docs/
    ├── customization.md
    ├── mcp-integration.md
    └── reference-architecture.svg
```

Each stage skill is a folder with a `SKILL.md` (instructions for the AI) and a `templates/` directory of artifact templates that the skill fills in.

## Customize for your stack

Open any `SKILL.md` and edit the `Project conventions` block. Common things teams change:

- **Compliance frameworks.** Add SOC 2 / FedRAMP / HIPAA / PCI requirements that the skill should always check.
- **Supported runtimes.** Tell the design skill it must produce designs that fit your stack (e.g., Node + Postgres + GKE).
- **Tooling.** Tell the security skill which scanners you use, the deployment skill which CD platform you run.
- **Output destinations.** Default writes to `.sevaai-sdlc/`; change to `docs/sdlc/` or wherever your team keeps specs.

## License

MIT.

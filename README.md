# sevaai-sdlc

[![Validate plugin](https://github.com/DLTKMandeep/sevaai-sdlc-toolkit/actions/workflows/validate.yml/badge.svg)](https://github.com/DLTKMandeep/sevaai-sdlc-toolkit/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Automated, AI-powered Software Development Lifecycle for any codebase.**

Drop this plugin into Claude Code or Cowork and get seven composable skills that walk a feature from idea to operations: Requirements -> Design -> Development -> Testing -> Security -> Deployment -> Maintenance. Each skill is self-contained, references the real-world tools you already use (Jira, Snyk, Datadog, Harness, etc.), and produces ship-ready markdown artifacts.

```
+-------------+   +--------+   +-------------+   +---------+   +----------+   +------------+   +-------------+
| Requirements |->| Design |->| Development |->| Testing |->| Security |->| Deployment |->| Maintenance |
+-------------+   +--------+   +-------------+   +---------+   +----------+   +------------+   +-------------+
        ^----------------------------- /sdlc orchestrator ------------------------------------^
```

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
├── plugin.json                   # marketplace manifest
├── README.md                     # this file
├── skills/
│   ├── sdlc-orchestrator/        # top-level: runs all 7 stages
│   ├── sdlc-requirements/        # stage 1
│   ├── sdlc-design/              # stage 2
│   ├── sdlc-development/         # stage 3
│   ├── sdlc-testing/             # stage 4
│   ├── sdlc-security/            # stage 5
│   ├── sdlc-deployment/          # stage 6
│   └── sdlc-maintenance/         # stage 7
├── commands/
│   └── sdlc.md                   # /sdlc slash command
├── examples/
│   └── sample_feature.md         # example input
└── docs/
    └── customization.md          # how to tune for your stack
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

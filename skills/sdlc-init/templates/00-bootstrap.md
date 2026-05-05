# Bootstrap — {Product Name}

**Project slug:** `{project-slug}`
**Status:** Bootstrapped
**Author:** sevaai-sdlc / sdlc-init skill
**Date:** {YYYY-MM-DD}

This artifact records the load-bearing decisions made when the project was first scaffolded. Subsequent stages (Requirements, Design, Development, Testing, Security, Deployment, Maintenance) inherit context from here.

## 1. Vision

One paragraph: what we're building, who it's for, and why now.

## 2. Intake answers

| Question | Answer |
|---|---|
| Product (one-line pitch) | |
| Primary user | B2B / B2C / internal / dev-tools / regulated |
| Stack preference | |
| Deploy target | |
| Compliance | |
| Scale target | |
| Team | |

## 3. Stack decisions

Mirror of `.sevaai-sdlc.yaml -> stack`. Each row is a binding choice; alternatives that were rejected appear in the relevant ADR.

| Concern | Choice | ADR |
|---|---|---|
| Language + runtime | | [ADR-0001](../../adr/0001-language-and-runtime.md) |
| Web framework | | |
| Primary datastore | | [ADR-0002](../../adr/0002-database.md) |
| Cache / queue | | |
| Auth | | [ADR-0004](../../adr/0004-auth.md) |
| Deploy target | | [ADR-0003](../../adr/0003-deployment-target.md) |
| Observability | | |
| CI / CD | | |

## 4. MVP scope

### In scope for v1
- Bullet list of 3-7 capabilities the first release will deliver

### Out of scope for v1
- Bullet list of things explicitly deferred — naming them prevents scope creep arguments later

## 5. Compliance posture

| Framework | Required? | Initial controls scaffolded |
|---|---|---|
| SOC 2 Type II | yes/no/planned | |
| GDPR | yes/no/planned | |
| HIPAA | yes/no/planned | |
| PCI-DSS | yes/no/planned | |
| Other | | |

## 6. Repo skeleton

```
{project-slug}/
├── README.md
├── LICENSE
├── .gitignore
├── .sevaai-sdlc.yaml
├── package.json (or pyproject.toml / go.mod / etc.)
├── .github/
│   └── workflows/
│       └── ci.yaml
├── docs/
│   ├── architecture.md
│   ├── adr/
│   │   ├── README.md
│   │   ├── 0001-language-and-runtime.md
│   │   ├── 0002-database.md
│   │   ├── 0003-deployment-target.md
│   │   └── 0004-auth.md
│   └── sdlc/
│       └── _bootstrap/
│           └── 00-bootstrap.md   <-- this file
├── src/
├── tests/
└── migrations/   (if relational DB)
```

## 7. Foundational ADRs

Short summary of each ADR with the decision and the strongest rejected alternative. Read the full ADRs for the reasoning.

| ADR | Decision | Strongest rejected alternative | Why rejected |
|---|---|---|---|
| 0001 — Language & runtime | | | |
| 0002 — Database | | | |
| 0003 — Deployment target | | | |
| 0004 — Auth | | | |
| (additional) | | | |

## 8. Risks at the bootstrap stage

| # | Risk | Likely surface in stage | Mitigation idea |
|---|---|---|---|
| 1 | | Requirements / Design | |
| 2 | | Security | |
| 3 | | Deployment | |

## 9. Open questions

| # | Question | Block what? | Resolve by |
|---|---|---|---|
| 1 | | First feature design | |

## 10. Hand-off to Stage 1

The project is now ready for feature-level SDLC work. Next:

- `/sdlc <first feature description>` — runs the full pipeline for your first feature
- Or stage by stage starting with `sdlc-requirements`

The first feature should be the **smallest end-to-end slice that proves the architecture works** — sometimes called a "tracer bullet" or "walking skeleton". Don't pick the most user-valuable feature first; pick the one that exercises the most architectural seams.

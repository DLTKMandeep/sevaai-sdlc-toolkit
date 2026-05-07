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

## 10. Walking skeleton — the project baseline

The bootstrap is the *frame*, not the SDLC. The first feature run through Stages 1-7 establishes the **project baseline**: a complete dossier (Requirements + Design + Development + Testing + Security + Deployment + Maintenance) that subsequent features reference instead of re-deriving architecture each time.

The walking skeleton is the right vehicle for this. It's the smallest end-to-end slice that exercises every architectural seam.

**Proposed walking skeleton:** {one-line description that touches every component in §3 of `docs/architecture.md`}

**Why this slice:**
- Touches: {list of components from architecture, e.g., "edge → API → validator → DB → observability"}
- Defers: {what's explicitly NOT in v1 — query, search, multi-event, auth-server-issued tokens, etc.}
- Verifiable by: {how you'll know it works — e.g., "curl POST returns 202 with event_id; SELECT confirms row in events; Datadog shows the request span"}

**Drive it through the SDLC:**

```
/sdlc {walking skeleton description}
```

The resulting `docs/sdlc/walking-skeleton/` dossier becomes the project's foundational SDLC reference. Every subsequent feature should:
- Cite the walking-skeleton design as architectural precedent
- Inherit security controls established in `docs/sdlc/walking-skeleton/05-security.md`
- Use the deployment pattern locked in by `docs/sdlc/walking-skeleton/06-deployment.md`
- Match the test pyramid shape from `docs/sdlc/walking-skeleton/04-testing.md`

## 11. Subsequent features

Once the walking skeleton is shipped, every additional feature follows the standard per-feature SDLC: `/sdlc <feature>` → 7 stages → ship. The bootstrap dossier (this file) and the walking-skeleton dossier together form the project baseline that those features ground against.

# Progress — sevaai-sdlc-toolkit

State of the toolkit, separate from the version-by-version CHANGELOG. Updated continuously as the toolkit evolves.

**Last updated:** 2026-05-07
**Current version on disk:** v0.4.0 candidate (Stage 2.5 + arc42/C4 + auto-backlog)
**Last tagged release:** v0.1.0 (CHANGELOG behind disk by 3 minor versions — see "Outstanding push" below)

---

## At a glance

The toolkit produces a structured, audit-grade SDLC dossier for any feature, in any AI tool, with hand-offs to real engineering tools (Jira, GitHub, Notion, Atlassian Rovo, etc.). It's currently 9 skills (1 orchestrator + 1 init + 7 stages) plus a Stage 2.5 mapping skill = 10 skills total. Three of the seven feature stages have been validated end-to-end on a real test project (Aurora). Four stages and one new skill (Stage 2.5) are built but unvalidated. The biggest deliverables of the last development burst — Stage 0 greenfield bootstrap, GitHub Projects v2 auto-backlog, and arc42/C4 design standard — have not yet been tested by an actual user run.

---

## Skill inventory

| Skill | Purpose | Built | User-validated |
|---|---|:-:|:-:|
| `sdlc-orchestrator` | Run all stages end-to-end; greenfield-aware; brownfield-aware skipping | ✓ | partial — used during Aurora test for Stages 1-3 |
| `sdlc-init` | Stage 0 — project bootstrap (greenfield only) | ✓ | partial — produced ADRs on Orion, no full validation |
| `sdlc-requirements` | Stage 1 — user stories, AC, Jira/GitHub backlog hand-off | ✓ | ✓ Aurora — created Workstream + 6 Stories in real Jira |
| `sdlc-design` | Stage 2 — arc42 + C4 design doc (upgraded in v0.4.0) | ✓ | partial — pre-arc42 version validated on Aurora; arc42 version unvalidated |
| `sdlc-mapping` | Stage 2.5 — Functional-to-Technical traceability matrix (NEW) | ✓ | ✗ |
| `sdlc-development` | Stage 3 — PR plan + auto-create GitHub Projects v2 backlog (upgraded in v0.4.0) | ✓ | partial — pre-mapping version validated on Aurora; auto-backlog unvalidated |
| `sdlc-testing` | Stage 4 — test plan + GitHub Projects work items | ✓ | ✗ |
| `sdlc-security` | Stage 5 — STRIDE, OWASP, IriusRisk + GitHub Issues findings | ✓ | ✗ |
| `sdlc-deployment` | Stage 6 — rollout plan, no-deploy windows, runbooks | ✓ | ✗ |
| `sdlc-maintenance` | Stage 7 — runbook, SLOs, on-call, postmortem template | ✓ | ✗ |

### Validated end-to-end against a real test project

Three skills have produced artifacts that were graded against the toolkit's own rubrics (in `docs/validator-guide.md`):

| Skill | Test artifact | Grade |
|---|---|:-:|
| `sdlc-requirements` | `aurora-product/docs/sdlc/churn-slack-alerts/01-requirements.md` + Jira `SDLCTEST-1..7` | 5/5 (R-rubric) |
| `sdlc-design` (pre-arc42 version) | `aurora-product/docs/sdlc/churn-slack-alerts/02-design.md` | 5/5 (D-rubric) |
| `sdlc-development` (pre-mapping version) | `aurora-product/docs/sdlc/churn-slack-alerts/03-development.md` | passed V1-V5 (caught real ADR collision + missing toolchain) |

---

## Documentation inventory

| Doc | Purpose | Status |
|---|---|:-:|
| `README.md` | Product page, install, works-with, flow diagrams | up-to-date through v0.4.0 |
| `CHANGELOG.md` | Version-by-version notes | up-to-date through v0.4.0 |
| `PROGRESS.md` | This document — meta state, what's tested, what's next | up-to-date |
| `docs/run-by-stage.md` | Terminal-driven walkthrough for running stages one at a time | up-to-date through v0.3.0 |
| `docs/mcp-user-guide.md` | Practical MCP setup walkthrough with copy-paste commands | up-to-date through v0.3.0 |
| `docs/mcp-catalog.md` | Full categorized MCP list (34+ servers) | up-to-date |
| `docs/mcp-integration.md` | Which MCPs help which stages | up-to-date |
| `docs/sdlc-stages-detail.md` | Elaborate sub-activities reference per stage | needs Stage 0 + Stage 2.5 sections |
| `docs/validator-guide.md` | Rubrics for grading artifacts (R/D/V/T/S/P) | needs M-rubric for Stage 2.5 + B-rubric for Stage 0 |
| `docs/reference-architecture.md` + `.svg` | Reference architecture diagram | does not yet show Stage 0 or Stage 2.5 |
| `docs/customization.md` | Per-project customization guide | up-to-date |
| `enforcement/docs.md` | Phased-rollout playbook for the dossier-required CI gate | up-to-date |

---

## Infrastructure inventory

| Component | Status |
|---|---|
| `plugin.json` | Marketplace manifest |
| `.mcp.json` | 34+ bundled MCP server configs |
| `scripts/setup-mcps.sh` | CLI installer reading `.mcp.json` via jq |
| `scripts/build-adapters.py` | Regenerates Cursor/Aider/GPT/Gemini/raw adapters from SKILL.md |
| `adapters/` | Generated configs for non-Claude AI tools |
| `enforcement/templates/` | CI workflow + CLAUDE.md guardrail + pre-commit hook |
| `enforcement/setup-enforcement.sh` | Installer for the enforcement bundle |
| `.github/workflows/validate.yml` | Plugin self-validation CI |
| `LICENSE`, `CONTRIBUTING.md`, issue templates | Standard OSS hygiene |

---

## What's outstanding

### Outstanding push to GitHub

The disk is ahead of the GitHub repo. The following work has been built but not committed + pushed + tagged:

**v0.2.0 work** (committed in earlier sessions to local main; should be pushed if not already)
- Visible `docs/sdlc/` output dir
- Jira / Notion / GitHub umbrella hand-offs
- Multi-tool adapters
- Enforcement bundle
- 34+ MCP configs + setup script
- Reference architecture diagram
- Validator guide

**v0.3.0 work** (built in current session, may or may not be pushed)
- `sdlc-init` skill + template (Stage 0)
- Walking-skeleton hand-off in `sdlc-init`
- GitHub backlog mode in `sdlc-requirements`
- MCP user guide

**v0.4.0 work** (built in current session, definitely uncommitted as of writing)
- `sdlc-mapping` skill + template (Stage 2.5)
- arc42 + C4 upgrade to `sdlc-design`
- Mermaid lint rules baked into `sdlc-design`
- Auto-backlog (GitHub Projects v2) in `sdlc-development`
- Brownfield-aware orchestrator
- README per-feature flow diagram update
- This `PROGRESS.md` + the updated `CHANGELOG.md`

### Recommended push sequence

```bash
cd ~/claude_cowork/sevaai-sdlc-toolkit
git status   # see what's actually pending
git add -A
git commit -m "v0.4.0: Stage 0 + Stage 2.5 + arc42/C4 + auto-backlog + MCP guide

Three release-worthy bundles consolidated:

v0.2.0 — visible dossier dir, Jira/Notion/GitHub hand-offs, multi-tool
adapters (Cursor/Aider/GPT/Gemini), enforcement bundle (CI gate +
CLAUDE.md guardrail + pre-commit), 34+ MCP configs, validator guide.

v0.3.0 — Stage 0 sdlc-init for greenfield projects, walking-skeleton
hand-off pattern, GitHub backlog mode (1 umbrella + N child issues
with Project v2), MCP user guide with copy-paste commands.

v0.4.0 — Stage 2.5 sdlc-mapping (Functional-to-Technical traceability
matrix), sdlc-design upgraded to arc42 + C4, Mermaid lint rules baked
into the skill prose, sdlc-development auto-creates GitHub Projects v2
backlog from the mapping, brownfield-aware orchestrator."
git push origin main
git tag -a v0.4.0 -m "v0.4.0 — Stage 0 + Stage 2.5 + arc42/C4 + auto-backlog"
git push origin v0.4.0
```

### Outstanding tests / validations

1. **Run Stage 0 (`sdlc-init`) on a brand-new project end-to-end.** Validate that the bootstrap dossier is "indistinguishable from a manually-bootstrapped repo by a senior engineer" (the bar set by the skill prose).
2. **Run the walking-skeleton hand-off.** After Stage 0 produces `00-bootstrap.md`, drive the proposed walking-skeleton feature through Stages 1 → 2 → 2.5 → 3 → 4 → 5 → 6 → 7. The resulting dossier becomes the project baseline.
3. **Run Stage 2.5 (`sdlc-mapping`) on a real feature.** Validate the traceability matrix produces 4-6 rows for a small feature, not 15. Validate the dependency graph and cross-cutting `[infra]` rows.
4. **Run the auto-backlog in Stage 3.** Validate that `sdlc-development` creates GitHub Issues + Project v2 cards correctly, with labels, story points, risk, and `Blocked by #N` dependency comments.
5. **Validate Notion hand-off.** Built but not run.
6. **Validate GitHub backlog mode (umbrella + N stories).** Built but not run.
7. **Run Stages 4-7 against a real feature.** None have been user-driven yet on a real feature; only the auto-generated reference dossier (`bulk-csv-import`) covers them.
8. **Validate multi-tool adapters.** Generated from SKILL.md via `build-adapters.py`, but not personally tested in a Cursor / Aider / ChatGPT / Gemini session.
9. **Validate enforcement bundle in a real PR flow.** CI workflow + CLAUDE.md + pre-commit are shipped, but never actually blocked a PR via branch protection.

---

## What's designed but not built

These are explicit follow-ups, in priority order. Each one has a sketch in the conversation history that produced this toolkit; none have skill files yet.

### Stage 0.5 + Stage 8 — Product-management lens

Designed in the "expanded SDLC with PM-aware stages" conversation, then **explicitly de-scoped** by the user when they pivoted back to engineering-only. May come back later. The architecture diagram and rubric notes for these stages exist in the conversation but were not committed to the repo. Status: **deferred**.

### Stage 3b — Sprint cycle / Scrum Master agent

Designed during the brownfield-pivot conversation. The skill would be invoked at four points (`/sprint-plan`, `/sprint-groom`, `/sprint-status`, `/sprint-retro`) and would actively drive 2-week sprint cycles against the GitHub Projects v2 backlog created in Stage 3a. It's the biggest single capability jump still pending. Status: **planned for v0.5.0**.

### Diagram MCP — first custom-built MCP server

A small Node service shipping as `mcp-servers/sevaai-diagrams/` that exposes:

- `lint_mermaid(source)` — catches the failure modes already encoded in the design skill's lint rules
- `render_mermaid(source, format)` — produces SVG/PNG via mermaid-cli
- `lint_plantuml(source)` / `render_plantuml(source, format)` — same for PlantUML
- `lint_c4(source)` — validates C4 conventions (one System box, no Components in System Context, etc.)
- `validate_arc42(doc)` — checks the design doc has all 12 H2 sections
- `generate_erd_from_migrations(dir)` — runs tbls against `migrations/` to produce Mermaid `erDiagram`
- `generate_sequence_from_openapi(spec, flow)` — sequence-diagram skeleton from an OpenAPI spec

The skill would call these tools instead of asking the LLM to "be careful with syntax." The lint rules in `sdlc-design/SKILL.md` exist for the case where the MCP isn't connected. Status: **planned for v0.5.0**.

### Cross-feature dossier referencing

Stages 2-7 currently ground on `docs/architecture.md`, the bootstrap dossier, and the prior stage's artifact. They do NOT yet read the walking-skeleton dossier as project baseline. Once a project has a walking skeleton + 1-2 additional features, the design / security / deployment skills should cite the walking-skeleton's `02-design.md`, `05-security.md`, `06-deployment.md` rather than re-deriving. This is a one-paragraph addition to four skills. Status: **deferred until a real second feature exists on a real project**.

---

## Maturity assessment

| Dimension | State |
|---|---|
| Skill quality | Strong — proven by Aurora's 5/5 design and the dev plan that caught real issues |
| Tool integrations | Jira proven, GitHub proven, Notion ready (untested), 30+ others in catalog (mostly untested) |
| Greenfield support | Just added (v0.3.0); needs validation |
| Mapping → Backlog auto-creation | Just added (v0.4.0); needs validation |
| arc42 + C4 design standard | Just added (v0.4.0); needs validation |
| Brownfield-aware orchestration | Just added (v0.4.0); needs validation |
| Enforcement (CI gate + AI guardrail) | Shipped (v0.2.0); not battle-tested in a real PR-blocking scenario |
| Multi-tool support | Adapters exist; not personally validated |
| Documentation | Substantial — README, CHANGELOG, PROGRESS, run-by-stage, MCP user guide, validator guide, reference architecture, customization guide |
| Adoption beyond the author | None — author is currently customer zero |

**Honest position:** demo-ready, early-adopter ready, NOT yet enterprise-deployment-ready. The biggest gap to the latter is empirical — a real customer running it on a real codebase for a full feature lifecycle (8-12 weeks) and producing a "dossier prevented X production incident" datapoint.

---

## Test queue (what to run, in order)

1. **Run Helios (or any greenfield) end-to-end through Stages 0 → 1 → 2 → 2.5 → 3.** Validates Stage 0, walking-skeleton hand-off, arc42/C4 design, mapping, auto-backlog. Single biggest validation possible right now.
2. **Run Stages 4-7 against the resulting walking-skeleton dossier.** Validates the latter half of the pipeline, which has only ever been seen via the auto-generated reference dossier.
3. **Get one external user (a colleague) to run the orchestrator on a real feature.** First independent data point; the toolkit stops being "you-as-validator."
4. **Build the diagram MCP.** Removes the AI-syntax-correctness risk from every diagram-producing stage.
5. **Build Stage 3b (Scrum Master).** Biggest single capability jump still pending.
6. **Document a customer story.** Aurora walkthrough → `docs/case-study-aurora.md` showing the artifacts produced, the issues caught, what would have been different without the toolkit. The artifact that lands in conversations.

---

## Quick links

- GitHub repo: `https://github.com/DLTKMandeep/sevaai-sdlc-toolkit`
- Test project (existing-codebase): `https://github.com/DLTKMandeep/aurora-product`
- Real Jira project used in testing: `https://dltk-starpoint.atlassian.net/jira/core/projects/SDLCTEST/board`

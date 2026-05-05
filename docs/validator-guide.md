# Validator's guide — does sevaai-sdlc actually work?

This is for someone who wants to **prove the toolkit produces useful artifacts on their own machine**, not take anyone's word for it. Run each stage yourself; use the rubric below to grade the output.

## Setup checklist

Before you can validate anything, you need:

- [ ] An AI assistant that can read SKILL.md files and execute file operations: Claude Code CLI, Cursor, Cline, Aider, or Cowork in a fresh session.
- [ ] The skills installed in a way the assistant picks them up (one of the install paths from the main README, or the symlink fallback).
- [ ] A target project with at least a `README.md` and `docs/architecture.md` (Aurora at `~/claude_cowork/aurora-product/` is a ready-made one).
- [ ] A `.sevaai-sdlc.yaml` at the project root (Aurora has one).
- [ ] **Optional**: the reference dossier at `~/claude_cowork/aurora-product/.sevaai-sdlc/bulk-csv-import/` to compare your output against.

## Pick a validation feature

Use a **different** feature than the reference (`bulk-csv-import`) so you don't bias your judgment by reading mine first. Suggested options for Aurora:

- *"Add Slack notifications when an account's churn-risk score crosses 0.8"*
- *"Add a tenant admin invite-by-email flow"*
- *"Add CSV export of accounts (the inverse of the reference example)"*
- *"Add API rate-limiting per tenant tier"*

Pick one and remember the feature + your slug (e.g., `account-churn-slack-alerts`).

## How to drive each stage

Open your AI assistant in the project folder. For each stage, paste the trigger and watch what happens.

### Stage 1 — Requirements
```
Generate the requirements artifact for "<your feature description>".
Slug: <your-slug>
Write to .sevaai-sdlc/<your-slug>/01-requirements.md
```

### Stage 2 — Design
```
Generate the design artifact for the <your-slug> feature.
Read .sevaai-sdlc/<your-slug>/01-requirements.md as input.
Write to .sevaai-sdlc/<your-slug>/02-design.md
```

### Stage 3 — Development
```
Generate the development plan for the <your-slug> feature.
Read 02-design.md as input.
Write to .sevaai-sdlc/<your-slug>/03-development.md
```

### Stage 4 — Testing
```
Generate the test plan for the <your-slug> feature.
Read 02-design.md and 03-development.md as input.
Write to .sevaai-sdlc/<your-slug>/04-testing.md
```

### Stage 5 — Security
```
Generate the security review for the <your-slug> feature.
Read 02-design.md and 04-testing.md as input.
Write to .sevaai-sdlc/<your-slug>/05-security.md
Use the deepest model tier available.
```

### Stage 6 — Deployment
```
Generate the deployment plan for the <your-slug> feature.
Read 02-design.md, 03-development.md, and 05-security.md as input.
Stop if 05-security.md is BLOCKING.
Write to .sevaai-sdlc/<your-slug>/06-deployment.md
```

## Validation rubric — grade each artifact

After each stage runs, open the new file and check it against this rubric. Score each criterion **PASS** (clearly met) / **PARTIAL** (mostly there) / **FAIL** (missing or generic).

### Rubric for stage 1 — Requirements
| # | What to check | PASS looks like |
|---|---|---|
| R1 | Planning block exists | Sub-section with scope / objectives / resources / timeline / metrics filled in |
| R2 | 3-7 user stories with INVEST + Given-When-Then acceptance | Each story is independently shippable; acceptance is concrete |
| R3 | Edge cases beyond happy path | At least 3 non-obvious edge cases per story (locale, concurrency, malformed input, etc.) |
| R4 | Compliance flags | Specific to your project's frameworks from `.sevaai-sdlc.yaml` (SOC 2 / GDPR / HIPAA, not generic) |
| R5 | Hand-off pointer | Last section names stage 2 and the next artifact filename |

### Rubric for stage 2 — Design
| # | What to check | PASS looks like |
|---|---|---|
| D1 | HLD section with Mermaid diagram | Diagram references YOUR services (Fastify, BullMQ, etc.), not generic boxes |
| D2 | LLD with API contracts (OpenAPI), data model (SQL), sequence diagram, env vars | All four sub-sections present and feature-specific |
| D3 | ADR with at least 2 alternatives + rejection reasons | Alternatives are realistic, not strawmen |
| D4 | Migration plan: forward AND rollback | Both present, rollback is genuinely safe |
| D5 | First-pass STRIDE table | One row per component with feature-specific entries |

### Rubric for stage 3 — Development
| # | What to check | PASS looks like |
|---|---|---|
| V1 | 3-5 PRs of <=400 LOC each | Sized so each is independently reviewable + shippable behind a flag |
| V2 | Per-PR file plan matches your project's actual layout | File paths match `src/services/*` or whatever your repo uses |
| V3 | Coding standards reference YOUR existing conventions | Lint/format toolchain matches your `.eslintrc` / `pyproject.toml` |
| V4 | Self-review checklist | Project-specific items, not generic "did you write tests?" |
| V5 | Coding-agent prompt at the bottom | Specific enough to paste into Cursor / Copilot and start work |

### Rubric for stage 4 — Testing
| # | What to check | PASS looks like |
|---|---|---|
| T1 | Test pyramid with explicit counts | Real numbers, not "some unit tests" |
| T2 | Unit-test stubs in YOUR test framework | Jest / Vitest / Pytest matching your config, with `describe`/`it` syntax |
| T3 | Edge cases beyond what was in stage 1 | New ones the LLM finds, not just copy-paste from requirements |
| T4 | Performance plan (if any high-volume path) | Tool named (k6 / Gatling), thresholds set |
| T5 | Test data + flake budget | Concrete strategy, not "we'll figure it out" |

### Rubric for stage 5 — Security
| # | What to check | PASS looks like |
|---|---|---|
| S1 | STRIDE per component with feature-specific attacks | Not boilerplate "Spoofing: use auth"; mention specific endpoints/data |
| S2 | OWASP A01-A10 mapping with ASVS L2 control IDs | Each row marked applicable / mitigated / accepted; ASVS IDs cited |
| S3 | Auth & authz table with caller / role / scope / tenancy / audit per endpoint | All new endpoints listed |
| S4 | Data classification per new field | Public / Internal / Confidential / Restricted assigned, with retention |
| S5 | Compliance map specific to YOUR frameworks | SOC 2 / GDPR / etc. with concrete control IDs |
| S6 | Pen test plan with specific attack scenarios | At least 3 concrete attempts a red team would make |
| S7 | Sign-off table with severity counts + BLOCKING flag | Status `BLOCKING: yes` or `no` is unambiguous |

### Rubric for stage 6 — Deployment
| # | What to check | PASS looks like |
|---|---|---|
| P1 | Environment promotion path | Matches your project (e.g., dev -> staging -> canary -> prod) |
| P2 | Feature flag plan with rollout schedule | Concrete percentages + timing, names the flag |
| P3 | Canary SLI thresholds with baselines | Real numbers tied to your monitoring tool |
| P4 | Migration plan = expand-contract | Forward and backward compatible explicitly stated |
| P5 | Rollback runbook with copy-pasteable commands | <=2 min per step, names the actual CLI tools you use |
| P6 | Release notes + comms matrix + cost/capacity delta | All three present, all specific |

## Scoring

- **All PASS across all 6 stages** = the toolkit works end-to-end on your project.
- **Mostly PASS, occasional PARTIAL** = the toolkit works; tune `.sevaai-sdlc.yaml` and SKILL.md `Project conventions` blocks to lift the PARTIALs.
- **Several FAILs in one stage** = something's broken. Most common cause: the skill couldn't find your project files. Verify you ran from project root, README.md and docs/architecture.md exist.
- **Several FAILs across stages** = the assistant probably isn't loading the skills. Confirm with `~/.claude/skills/` listing or your tool's equivalent.

## Compare to the reference

If you ran on Aurora, your dossier should look broadly similar in shape and concreteness to the reference at `.sevaai-sdlc/bulk-csv-import/`. Differences that are FINE:

- Different feature -> different content. Obviously.
- Different LLM model picks slightly different phrasing.
- Some edge cases caught vs. missed.

Differences that are CONCERNING:

- Reference has 28 unit-test stubs, yours has none -> your assistant didn't follow the skill instructions about producing stubs.
- Reference's STRIDE rows mention specific endpoints, yours says "use authentication" -> not grounded in your design.
- Reference's PR file paths match Aurora's `src/services/*`, yours show generic `path/to/file.ts` -> assistant didn't read your project layout.

## After validation — tell the team

If validation passes:
- Commit the dossier (`git add .sevaai-sdlc/<your-slug>/ && git commit`).
- Roll the toolkit out to your team using the main README's install paths.
- Enable the enforcement bundle (see `enforcement/README.md`) when you're ready to make dossiers mandatory.

If validation fails:
- Share the specific FAILs with the toolkit maintainer (file an issue using `.github/ISSUE_TEMPLATE/bug.md`).
- Workaround: tighten the relevant SKILL.md's `Project conventions` block for your project, then re-run that stage.

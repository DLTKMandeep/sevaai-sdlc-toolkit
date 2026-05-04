# Run sevaai-sdlc stage-by-stage from your terminal

This is the manual driver path. Use it when you want to run stages one at a time, review each artifact, and decide whether to keep going. The orchestrator's "run all 7 in one shot" path is in the main README — this doc is for the deliberate, stage-at-a-time flow.

## Pre-flight (once)

```bash
# 1. install the plugin (skip if already done)
claude plugin marketplace add DLTKMandeep/sevaai-sdlc-toolkit
claude plugin install sevaai-sdlc

# 2. confirm it's registered
claude plugin list                    # expect to see "sevaai-sdlc"
claude skill list | grep sdlc         # expect 8 sdlc-* skills

# 3. (optional) install the MCPs you want — minimal set:
cd ~/path/to/sevaai-sdlc-toolkit
./scripts/setup-mcps.sh --minimal     # GitHub + Atlassian + Sentry

# 4. cd into the project you're running the SDLC against
cd ~/path/to/your-product
```

If you're driving from Cowork, the install step is the in-app `/plugin install` flow; everything else below is the same.

## The flow at a glance

```
project root
├── .sevaai-sdlc/
│   └── <feature-slug>/
│       ├── 00-index.md              # you maintain this manually OR orchestrator writes it
│       ├── 01-requirements.md
│       ├── 02-design.md
│       ├── 03-development.md
│       ├── 04-testing.md
│       ├── 05-security.md
│       └── 06-deployment.md
```

## Stage 1 — Requirements

**Trigger** — type one of these in `claude` (CLI) or your editor's chat:

```
Generate the requirements artifact for adding "<feature description in 1-2 sentences>".
Slug: <feature-slug>
Write it to .sevaai-sdlc/<feature-slug>/01-requirements.md
```

**Expected outputs**
- A new file `01-requirements.md` with: Summary, Planning block (scope, objectives, resources, timeline, KPIs), Personas, Business goal, 3-7 user stories with INVEST + Given-When-Then acceptance, Out of scope, Risks, Compliance flags, Hand-off pointer.

**Sanity checks (30 seconds)**
- [ ] Are personas concrete (named role + need) or generic ("the user")? Generic = re-prompt with persona detail.
- [ ] Is each story independently shippable, or do they daisy-chain? Daisy-chain = re-prompt with INVEST emphasis.
- [ ] Does the Compliance flags section reference your real frameworks (SOC 2 / GDPR / HIPAA)? If absent, add `--read .sevaai-sdlc.yaml` context next time.

**If the wrong skill fires**, type the trigger phrase from the SKILL.md frontmatter (look in `~/.claude/skills/sdlc-requirements/SKILL.md`).

---

## Stage 2 — Design

**Trigger**
```
Generate the design artifact for the <feature-slug> feature.
Read 01-requirements.md as input.
Write to .sevaai-sdlc/<feature-slug>/02-design.md
```

**Expected outputs**
- HLD (component diagram in Mermaid, service responsibilities table, tech stack, integration points)
- LLD (module structure, API contracts in OpenAPI, data model with migration plan, sequence diagrams, env vars)
- ADR (decision + alternatives considered + consequences)
- First-pass STRIDE table (full review in stage 5)

**Sanity checks**
- [ ] Does the diagram show **your** services, not generic boxes? If generic, the skill couldn't find your project — confirm `docs/architecture*` or `ARCHITECTURE*` exists at project root.
- [ ] Does the migration plan have BOTH forward and rollback? Critical.
- [ ] Are alternatives in the ADR realistic, or is the rejection reason hand-wavy?

---

## Stage 3 — Development

**Trigger**
```
Generate the development plan for the <feature-slug> feature.
Read 02-design.md as input.
Write to .sevaai-sdlc/<feature-slug>/03-development.md
```

**Expected outputs**
- 3-5 PRs of <=400 LOC with Conventional Commit titles
- Per-PR file plan (added / modified / deleted)
- Coding standards + scalable code patterns + version control + code review checklist
- A copy-pasteable prompt for Cursor / Copilot / Claude Code to actually write PR 1's code

**Sanity checks**
- [ ] Do the file paths match your project's actual layout (e.g., `src/services/...` not `app/services/...`)?
- [ ] Is each PR independently shippable behind a flag, or does PR 3 require PR 2's runtime path?
- [ ] Is the coding-agent prompt at the bottom specific enough to act on?

---

## Stage 4 — Testing

**Trigger**
```
Generate the test plan for the <feature-slug> feature.
Read 02-design.md and 03-development.md as input.
Write to .sevaai-sdlc/<feature-slug>/04-testing.md
```

**Expected outputs**
- Test pyramid with explicit unit / integration / e2e / exploratory counts
- Per-story coverage (happy path, negative, edge cases)
- Unit test stubs in your framework (Jest / Vitest / Pytest etc.)
- Test data strategy + flake budget

**Sanity checks**
- [ ] Are the edge cases non-obvious (concurrent writes, locale boundaries, malformed input)? If they're just "happy path again", re-prompt with "find edge cases a senior engineer would catch."
- [ ] Are the test stubs in your actual framework, not a default Jest example?

---

## Stage 5 — Security

This is the one stage that may BLOCK the pipeline.

**Trigger**
```
Generate the security review for the <feature-slug> feature.
Read 02-design.md and 04-testing.md as input.
Write to .sevaai-sdlc/<feature-slug>/05-security.md
Use the deepest model tier available — security reasoning rewards depth.
```

**Expected outputs**
- STRIDE per component
- OWASP Top 10 (2021) + ASVS L2 control IDs
- Auth & authz design per new endpoint
- Data classification per new field
- Dependency / supply chain / secrets sections
- GenAI threats (n/a if no LLM in feature)
- Compliance map for your frameworks
- Pen test plan
- **Sign-off table** with severity counts — if there's any unmitigated HIGH/CRITICAL, the artifact's status is `BLOCKING`

**Sanity checks**
- [ ] Did STRIDE rows have feature-specific attacks, or boilerplate? Boilerplate = re-prompt with "concrete attacks against THIS feature, not general SaaS threats."
- [ ] Is the compliance map specific to your frameworks (declared in `.sevaai-sdlc.yaml`)?
- [ ] If `BLOCKING`, fix or accept-with-signoff before stage 6.

---

## Stage 6 — Deployment

**Trigger**
```
Generate the deployment plan for the <feature-slug> feature.
Read 02-design.md, 03-development.md, and 05-security.md as input.
Stop if 05-security.md is BLOCKING.
Write to .sevaai-sdlc/<feature-slug>/06-deployment.md
```

**Expected outputs**
- Environment promotion path (dev -> staging -> canary -> prod)
- Feature flag plan with rollout schedule
- Canary analysis SLIs + auto-rollback thresholds
- Database migration plan (expand-contract)
- Step-by-step rollback runbook (<=2 min per step)
- Release notes + stakeholder comms matrix
- Cost / capacity delta

**Sanity checks**
- [ ] Does the rollout schedule match your project's `release.default_rollout` from `.sevaai-sdlc.yaml`?
- [ ] Is the rollback runbook actually <=2 min per step, with copy-pasteable commands?
- [ ] Are the SLI thresholds tied to current baselines, not arbitrary numbers?

---

## After all 6 stages

```bash
# review the dossier
ls -la .sevaai-sdlc/<feature-slug>/
cat .sevaai-sdlc/<feature-slug>/00-index.md

# if you want a single combined view
cat .sevaai-sdlc/<feature-slug>/0*.md > /tmp/dossier.md
less /tmp/dossier.md
```

**Next moves**
- File the user stories from stage 1 into Jira / Linear (manual or via Atlassian Rovo MCP if installed)
- Open PR 1 from stage 3 — paste the coding-agent prompt into Cursor / Copilot
- Schedule the security findings from stage 5 into the sprint
- Hand stage 6 to release management

## Troubleshooting cheat sheet

| Symptom | Fix |
|---|---|
| `claude plugin list` doesn't show sevaai-sdlc | re-run `claude plugin install sevaai-sdlc`; check `~/.claude/plugins/` |
| Wrong skill fires | use the explicit name: "Use the sdlc-design skill to generate ..." |
| Artifact is generic | confirm you ran from project root with README + `docs/` present |
| Stage 5 marks BLOCKING | open the artifact's "Sign-off" table; either mitigate or get sign-off, then re-run |
| Files written outside project | the `.sevaai-sdlc.yaml` `output_dir` may not be set; default is `.sevaai-sdlc/` |
| Skill ignores `.sevaai-sdlc.yaml` | confirm the file is at the project root, not buried in a subfolder |

## Recommended cadence

For a real feature, don't rush all six stages in one sitting. Realistic pace:

- **Day 1**: stage 1 -> review with PM. Iterate.
- **Day 2**: stage 2 -> review with tech lead + security. Iterate.
- **Day 3**: stage 3 + 4 -> review with engineers + QA.
- **Day 4**: stage 5 -> review with security. May iterate twice if BLOCKING.
- **Day 5**: stage 6 -> review with SRE + release management.

The toolkit's value is the **structured first draft + the conversation it forces**, not the artifact itself.

# sdlc-orchestrator

**Triggers when:** Use this skill when the user wants to run the full SDLC pipeline end-to-end against a feature, fix, or initiative — taking it from a free-text idea all the way through Requirements, Design, Development plan, Testing plan, Security review, Deployment plan, and Maintenance bundle. Triggers include "run the SDLC", "full SDLC", "end to end SDLC", "SDLC pipeline", "/sdlc", "all stages", "soup to nuts", "from idea to ops", "everything from requirements to runbook", or any time the user pastes a feature description and asks for the complete plan. If the user wants only one stage (e.g., "just the threat model"), defer to the individual stage skill instead.

# SDLC Orchestrator

Runs all seven SDLC stages in order against a single feature and consolidates the artifacts into a feature dossier.

## When to invoke

- User runs `/sdlc <feature description>`
- User says any of the trigger phrases above with a feature description
- User pastes a feature idea and asks for "the whole thing"

## What to do

1. **Slugify the feature.** Take the feature description, derive a slug like `add-saml-sso`. If the user provides one, use it.
2. **Create the dossier folder** `.sevaai-sdlc/{feature-slug}/` in the project root. If the project root has a `.sevaai-sdlc.yaml` config that overrides `output_dir`, honor it.
3. **Write the dossier index** `.sevaai-sdlc/{feature-slug}/00-index.md` with the feature description, target stages, and links to each stage's artifact (initially as `(pending)`).
4. **Run stages in order**, invoking each skill via its `name` and passing the prior artifact:
   - `sdlc-requirements`  ->  `01-requirements.md`
   - `sdlc-design`        ->  `02-design.md`
   - `sdlc-development`   ->  `03-development.md`
   - `sdlc-testing`       ->  `04-testing.md`
   - `sdlc-security`      ->  `05-security.md`
   - `sdlc-deployment`    ->  `06-deployment.md`
   - `sdlc-maintenance`   ->  `07-maintenance.md`
5. **Halt on blocking security findings.** If `sdlc-security` marks the artifact `BLOCKING: yes`, stop the pipeline, surface the findings to the user, and ask whether to override or remediate before continuing.
6. **Update the index** after each stage so the user sees progress.
7. **At the end**, summarize the dossier in chat: feature, 7 artifact links, top 3 risks called out across stages, top 3 follow-ups.

## Output: dossier structure

```
.sevaai-sdlc/{feature-slug}/
├── 00-index.md           # entry point with status of each stage
├── 01-requirements.md
├── 02-design.md
├── 03-development.md
├── 04-testing.md
├── 05-security.md
├── 06-deployment.md
└── 07-maintenance.md
```

## Behavior rules

- **One stage may rely on prior artifacts.** Always pass `01-...md` through `0N-...md` to stage N+1. Don't ask the user to repeat themselves.
- **Stay in chat between stages.** After each stage, post a one-line status update so the user can interrupt if they want to redirect.
- **Respect single-stage requests.** If the user only wants one stage, do NOT use this orchestrator — defer to the individual stage skill.
- **Editable along the way.** If the user edits a stage's artifact between stages, re-read it before running the next stage.

## Real-world parallel: what "running the SDLC" looks like

This orchestrator is the AI analog of a delivery lead walking a feature from intake to GA. The individual stages are the deliverables that delivery lead would produce or commission: PRD, design doc, dev brief, test plan, threat model, runbook, etc. The skill pack just makes the cycle compressible — instead of 6 weeks of human cycles for a small feature, the AI produces the first-pass artifacts in minutes, and humans review/refine/approve.

## Index template (write this at start)

```markdown
# Feature dossier — {Feature Name}

**Slug:** `{feature-slug}`
**Started:** {YYYY-MM-DD HH:MM TZ}
**Description:** {one-paragraph user input}

## Stages

| # | Stage | Status | Artifact |
|---|---|---|---|
| 1 | Requirements | pending | [01-requirements.md](01-requirements.md) |
| 2 | Design | pending | [02-design.md](02-design.md) |
| 3 | Development | pending | [03-development.md](03-development.md) |
| 4 | Testing | pending | [04-testing.md](04-testing.md) |
| 5 | Security | pending | [05-security.md](05-security.md) |
| 6 | Deployment | pending | [06-deployment.md](06-deployment.md) |
| 7 | Maintenance | pending | [07-maintenance.md](07-maintenance.md) |
```

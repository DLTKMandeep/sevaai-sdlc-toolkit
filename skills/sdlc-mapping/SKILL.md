---
name: sdlc-mapping
description: Use this skill when the user has a requirements doc and a design doc and needs the bridge between them — the Functional-to-Technical traceability matrix that maps every user story to the specific technical components, files, migrations, and config it requires. Triggers include "traceability matrix", "functional to technical", "mapping doc", "requirements traceability", "RTM", "bridge to development", "what files does this story touch", "stage 2.5", or any time the user wants to know "what concrete code work does this requirement translate into" before the development plan is written. Also trigger when the orchestrator runs the pipeline and stage 2 (`sdlc-design`) has just finished. Do NOT use when requirements or design don't yet exist (run those stages first) or when the user wants a sprint plan (that's stage 3 / `sdlc-development`).
license: MIT
---

# SDLC Stage 2.5 — Functional-to-Technical Mapping

The bridge between PM-speak (user stories) and Eng-speak (modules, files, migrations, config). Produces a **traceability matrix** where every requirement maps to specific technical artifacts and effort. This artifact becomes the input to backlog generation in Stage 3.

## Why this stage exists

Without a mapping artifact, "we'll figure out what files to touch in development" is a hand-wave. The hand-wave costs time during sprint planning when the team realizes a story has dependencies that weren't visible in the requirements doc, or that a "small" story actually requires a schema migration plus three new modules. Stage 2.5 surfaces those facts when changing them is cheap (in a doc) instead of expensive (mid-sprint).

It also gives auditors and PMs a single view: requirement → code artifact. SOC 2 control-implementation mapping uses this exact pattern.

## When to invoke

- After `sdlc-design` produces `02-design.md`
- User asks for "traceability", "RTM", "mapping", or "what does this story actually change"
- Orchestrator calls this skill as stage 2.5 (between Design and Development)
- Brownfield: user has stories and design but no mapping yet — running this skill produces the missing artifact

## Inputs

1. **`docs/sdlc/{feature-slug}/01-requirements.md`** — the user stories (or Jira / GitHub Issues if not local)
2. **`docs/sdlc/{feature-slug}/02-design.md`** — the design doc, especially §5 (Building Blocks) and §8.2 (Persistence)
3. **`.sevaai-sdlc.yaml`** — for stack and conventions
4. **The repo via GitHub MCP** — to confirm which files exist and which are new

If 01- or 02- don't exist, ask the user to run those stages first.

## What the mapping looks like

The artifact is `docs/sdlc/{feature-slug}/02b-mapping.md`. The center of gravity is one big table — the traceability matrix — where every row connects a story to its technical implementation.

For each user story (or Jira/GitHub issue):

| Field | Source | Example |
|---|---|---|
| **Req ID** | Jira / GitHub | `SDLCTEST-2` |
| **Story (one-liner)** | 01-requirements.md §4 | "Tenant admin connects Slack workspace" |
| **Components touched** | 02-design.md §5 building blocks | `slack/oauth` (new), `kms` (existing — new IAM policy) |
| **Files: NEW** | inferred from §5.3 module structure | `src/services/slack/oauth/handlers.ts`, `src/services/slack/oauth/exchange.ts`, `src/services/slack/oauth/tokens.ts` |
| **Files: EDIT** | inferred from existing repo + design | `src/lib/kms.ts`, `infra/iam/api.tf`, `package.json` |
| **Migrations** | 02-design.md §8.2 | `migrations/1714939300000_slack-connection.up.sql` (+ `.down.sql`) |
| **Config / env vars** | 02-design.md §8.6 | `SLACK_CLIENT_ID`, `SLACK_CLIENT_SECRET`, `SLACK_KMS_CMK_ID` |
| **Effort** | INVEST size + design complexity | M (3 SP) |
| **Dependencies** | other stories that must land first | none / SDLCTEST-X |
| **Risk** | design surprise, external dep, perf | M (KMS envelope encryption first time) |
| **Test type** | functional spec | unit + integration |
| **ADR refs** | design ADRs that govern this story | ADR-0004 |

## What to do

1. **Brownfield check.** If `02b-mapping.md` exists, read it; ask whether to augment, replace, or skip.
2. **Read the requirements artifact.** Pull every user story with its INVEST size and acceptance criteria.
3. **Read the design artifact.** Pay particular attention to:
   - §5.3 module structure (gives you the candidate file paths)
   - §8.2 data model + migrations (gives you the schema work)
   - §8.6 config / env vars (gives you the config work)
   - §9 ADRs (govern HOW the story implements)
4. **Read the actual repo via GitHub MCP** to determine which files in §5.3 already exist (= EDIT) vs. need to be created (= NEW). This is what makes the mapping honest.
5. **Build the matrix.** One row per story. Fill all columns. If a column is genuinely n/a, write `n/a` — never leave blank.
6. **Cross-check effort vs. content.** A row that lists 6 NEW files and a migration cannot be sized S. If size and content disagree, surface the conflict and propose a re-size.
7. **Identify dependency chains.** Some stories must land before others (e.g., a dispatcher needs the OAuth-stored token first). Express as a directed list; visualize as a Mermaid graph in §3 of the artifact.
8. **Flag cross-cutting work.** Sometimes a story implies infrastructure work that isn't in the design doc (a new IAM policy, a new LaunchDarkly flag, a new on-call runbook). Add these as separate rows with a label `[infra]` or `[ops]`.
9. **Write artifact** to `docs/sdlc/{feature-slug}/02b-mapping.md` using `templates/artifact.md`.

## Sizing calibration

The toolkit's default SP calibration is **1 SP ≈ 1 engineer-day**. Story sizes from Stage 1 use:

| Size | SP | LOC budget | New files | Migration? |
|---|---|---|---|---|
| S | 1 | < 100 | 0-1 | no |
| M | 3 | 100-400 | 2-5 | maybe |
| L | 5 | 400-800 | 5-10 | usually |
| XL | 8+ | > 800 | > 10 | yes | → split |

If a row would be XL, the mapping skill should propose splitting it into 2 stories before handing off to development.

## Hand-off rules

This skill writes ONLY to the local markdown. It does NOT push to Jira, GitHub Issues, or any tracker — that's Stage 3 (development) which uses this artifact as input.

After the mapping is written, surface the headline counts:
```
Stories: N
Total SP: X
NEW files: Y
EDIT files: Z
Migrations: M
Risk-H stories: K (consider sequencing first)
Dependency chains: 1 long chain (A → B → C), 2 islands
```

Then tell the user the next step:
> Mapping complete. Run `sdlc-development` next to generate the GitHub Projects v2 backlog from this matrix.

## Real-world products this skill complements

- **Jira Advanced Roadmaps** — has a similar concept (initiative → epic → story → task) but doesn't tie down to file paths
- **Linear** — story dependencies, but again no file-level mapping
- **Productboard / Aha!** — pure product side, no engineering depth
- **Sourcegraph batch changes** — the closest thing to "this PR touches these N files" but for already-written code, not yet-to-be-written

The mapping skill is the "yet-to-be-written" version of a Sourcegraph batch change description, used for sprint planning instead of bulk refactors.

## Project conventions (edit me per project)

- **File-path style:** `src/services/{domain}/{module}/...` for backend, `src/components/{Feature}/...` for frontend. Tweak per stack.
- **Migration naming:** `migrations/{timestamp}_{slug}.up.sql` + matching `.down.sql`
- **Config-source convention:** env vars named `SCREAMING_SNAKE_CASE`, secret vars sourced from Secrets Manager not environment

## Hand-off to next stage

Next: **Development** (`sdlc-development`). Artifact: `03-development.md`.

The development skill consumes:
- `01-requirements.md`
- `02-design.md`
- **`02b-mapping.md`** ← THIS artifact, the row-by-row plan
- The repo via GitHub MCP
- `.sevaai-sdlc.yaml` for tracker config

It produces the PR plan AND auto-creates the GitHub Projects v2 backlog (one Issue per row in the mapping table).

## Template

See `templates/artifact.md`.

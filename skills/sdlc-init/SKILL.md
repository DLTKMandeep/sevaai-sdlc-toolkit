---
name: sdlc-init
description: Use this skill when the user is starting a brand-new project with no existing codebase, README, or architecture doc — and needs the foundation scaffolded before any feature work begins. Triggers include "new project", "greenfield", "starting from scratch", "init a project", "bootstrap a repo", "I'm building X from zero", "what stack should I use", "set up the project skeleton", "Stage 0", or any time the user asks to plan a product before they have code. Also trigger when the orchestrator (`sdlc-orchestrator`) detects no `.sevaai-sdlc.yaml` and no `docs/architecture.md` in the project root and needs to bootstrap before running stage 1. Do NOT use when the project already has a README, architecture doc, or any committed source code — for those, jump straight to `sdlc-requirements`.
license: MIT
---

# SDLC Stage 0 — Project Bootstrap (Greenfield)

Turn a one-line product idea into a fully scaffolded repo: vision README, architecture doc, foundational ADRs, `.sevaai-sdlc.yaml` config, repo skeleton, and CI baseline. After this skill runs, the project is in the same shape Aurora was in when stage 1 started — ready for the requirements skill to ground against.

## Why Stage 0 exists

Stages 1-7 all assume a project already exists with a README, an architecture doc, a stack, and some compliance posture. For a greenfield project none of that exists yet. Without a Stage 0, the user has to write all of it by hand before the toolkit becomes useful — which is exactly the manual SDLC work the toolkit is supposed to replace.

This skill produces the load-bearing bootstrap dossier so every later stage has real grounding.

## When to invoke

- User is starting a new product or service with no committed code
- User runs `/sdlc init` or asks to "bootstrap" / "scaffold" / "kick off" a project
- The orchestrator detects the project has neither `.sevaai-sdlc.yaml` nor `docs/architecture.md`
- User has been writing prompts to "design my new SaaS" with no underlying repo

## What this skill is NOT for

- Adding a feature to an existing project — use `sdlc-requirements`
- Re-architecting an existing system — that's a stage-2 design exercise, not greenfield
- Generating boilerplate code (`create-react-app` style) — this skill produces *decisions and structure*, not application code
- Picking between two known stacks — this skill expects the user to commit to load-bearing choices, not maintain optionality

## Inputs you should ask for

If the user hasn't provided this information, ask **once** in a single concise message. Don't drip-feed questions across multiple turns.

1. **Product** — one-line pitch. "Aurora is a B2B customer-success analytics SaaS for SaaS companies."
2. **Primary user** — B2B / B2C / internal-only / dev-tools / regulated (healthcare, finance, gov)
3. **Stack preference** — "you pick" / specific runtime (TypeScript+Node, Python+FastAPI, Go, Java+Spring, Ruby+Rails, etc.)
4. **Deploy target** — AWS / GCP / Azure / Vercel / Fly.io / Render / self-hosted / unknown
5. **Compliance** — none / SOC 2 / GDPR / HIPAA / PCI / FedRAMP / multiple
6. **Scale** — pre-launch / <10K users / <1M users / enterprise (>1M)
7. **Team** — solo / small (≤5 eng) / mid (5-25) / enterprise

If the user says "you pick" for stack, infer from the product, primary user, and deploy target. Be opinionated — pick the boring, well-supported option for that combination, not the trendy one.

## Grounding before you write

If the project root already contains anything (a stray README, a `package.json`, an `.envrc`), **read it first** and use it as a starting point rather than overwriting. Bootstrap should be additive when possible.

Run these checks:

- `ls .sevaai-sdlc.yaml docs/architecture.md README.md package.json pyproject.toml go.mod Cargo.toml 2>/dev/null`
- If any exist, ask the user "this isn't quite greenfield — should I bootstrap on top of what's here, or is there an old project to delete first?"

## What to do

Produce the bootstrap dossier in these specific files. All paths are relative to project root.

### 1. `.sevaai-sdlc.yaml`

The toolkit's config. Use the inputs to fill in stack, auth, compliance, observability, security, release. Don't leave any field as `TBD` — pick a sensible default for the chosen stack and tell the user what you picked. This file is the source of truth for every subsequent stage.

### 2. `README.md`

The product page. Includes:
- Product name + one-line pitch
- "What it is" / "What it isn't" (3-5 bullets each)
- Target users (the personas)
- MVP scope (in / out)
- Stack overview (one paragraph, not exhaustive)
- Quickstart (`git clone` → `npm install` → `npm run dev` or equivalent)
- Status badge placeholder

### 3. `docs/architecture.md`

The system-level design. Includes:
- Context: who uses it, why, what's the value
- High-level component diagram (Mermaid flowchart, single-token IDs only — see lint rules below)
- Component responsibilities table
- Data flow walkthrough for the primary use case
- Trust boundaries (internet → edge → app → data)
- Technology stack table (mirrors `.sevaai-sdlc.yaml`)
- Pointer to ADR index

### 4. `docs/adr/` — at least 4 foundational ADRs

One ADR per **load-bearing decision**. Each ADR follows the standard format (Context, Decision, Alternatives Considered with rejection reasons, Consequences). Mandatory ADRs:

- `0001-language-and-runtime.md` — language + version + reasoning
- `0002-database.md` — primary datastore + reasoning + at least 2 rejected alternatives
- `0003-deployment-target.md` — cloud + container/serverless + IaC choice
- `0004-auth.md` — user auth approach (in-house vs Auth0/Clerk/Cognito vs WorkOS)

Add more if compliance demands them (e.g., `0005-data-isolation.md` for multi-tenant + SOC 2).

Each ADR must list **at least 2 rejected alternatives** with concrete rejection reasons that reference the user's constraints — not generic industry talking points.

### 5. `docs/adr/README.md`

Index of ADRs with status (Accepted/Proposed/Superseded) and one-line summary each. This becomes the canonical place to grep for prior decisions.

### 6. Repo skeleton

Create the empty directories future stages will write into:

```
src/                           # application code (one .gitkeep)
tests/                         # test code (one .gitkeep)
migrations/                    # DB migrations (one .gitkeep, only if a relational DB was chosen)
docs/                          # already has architecture.md + adr/
docs/sdlc/                     # future feature dossiers (one .gitkeep)
.github/workflows/             # CI workflows
```

### 7. `.github/workflows/ci.yaml`

Stack-aware baseline CI. For TypeScript+Node: install, lint, type-check, test. For Python: install, ruff, mypy, pytest. For Go: build, vet, test. Keep it minimal — stage 3 (development) will expand it per feature. Just make sure `git push` doesn't immediately go red on first commit.

### 8. `LICENSE`

Default to MIT unless the user is enterprise / regulated, in which case ask which license.

### 9. `.gitignore`

Stack-appropriate. Use the GitHub `.gitignore` template for the chosen language as a starting point.

### 10. Stack-specific manifest

- TypeScript+Node → `package.json` with `name`, `version: "0.1.0"`, `scripts` for build/lint/test, devDeps for typescript+eslint+prettier+vitest (or whatever testing framework is conventional)
- Python → `pyproject.toml` (PEP 621) with project metadata, deps, ruff/mypy/pytest config
- Go → `go.mod` + a stub `cmd/<name>/main.go`
- Rust → `Cargo.toml`
- Java → `pom.xml` or `build.gradle.kts`
- Ruby → `Gemfile` + `<name>.gemspec`

### 11. `00-bootstrap.md` (the dossier artifact)

Write to `docs/sdlc/_bootstrap/00-bootstrap.md` (note the underscore prefix so it sorts above feature dossiers). This is the *record* of what was bootstrapped, the questions asked, the decisions made, and the rejected alternatives at the project level. Use the template at `templates/00-bootstrap.md`.

This is the artifact stages 1-7 inherit from. Future stages should reference it the way they reference `01-requirements.md` for feature work.

## Mermaid lint rules (apply to every diagram you write)

To prevent the parser failures we've hit before:

1. **No spaces in subgraph or node IDs.** Use `subgraph WorkerService [Display Label]`, never `subgraph Worker Service`.
2. **No `;` in sequence-diagram messages.** Use `,` or split into two arrows.
3. **No `<` / `>` in messages or `alt` labels.** Use words: "above", "below", "at least", "at most".
4. **No `<tagname>` in messages.** Looks like HTML; use `[name]` placeholders instead.
5. **No raw URLs without backticks.** Wrap in `\`https://...\`` to avoid auto-linking inside diagrams.

## Hand-off and integration

### After writing the dossier

1. Print the file tree of what was created.
2. Ask: "Initialize git and create a GitHub repo? (y/N)"
3. If yes:
   - `git init`
   - `git add .`
   - `git commit -m "chore(init): bootstrap project via sevaai-sdlc Stage 0"`
   - If the GitHub MCP is connected, ask the user for a repo name (default: project slug) and create the repo via `mcp__github__create_repository`, then push.
   - If the GitHub MCP is not connected, print the commands the user should run manually.

### Hand-off — the walking skeleton

A greenfield project is **not done** at the end of Stage 0. The bootstrap dossier produces *decisions and structure*, not the SDLC discipline applied to those decisions. Without Stages 1-7, the project foundation is exempt from the very rigor the toolkit enforces for every feature built on top of it.

The pattern that closes this gap is the **walking skeleton**: identify the smallest end-to-end slice that exercises every architectural seam, run it through Stages 1-7 immediately, and treat the resulting dossier as the **project baseline**. Subsequent features reference this baseline instead of re-deriving architecture each time.

**What makes a good walking skeleton:**
- End-to-end (touches every component named in `docs/architecture.md` at least once)
- Trivially small in scope (one happy path, no edge cases)
- Real (not a hello-world; produces some persistent artifact a human can verify)
- Defensible as v1 (it's a feature you'd actually ship, not a throwaway demo)

For Orion (log-stream platform): "POST a single log line to /events, validate it, persist as a structured event, return 202 with the event id." That one feature touches API, validation, persistence, observability, auth — every component in the architecture is exercised.

For a B2B SaaS: "tenant admin signs in, sees an empty dashboard, can sign out." That touches auth, tenant routing, frontend, session management, observability.

For a payments platform: "create a $1 charge against a test card, persist the charge record, return success." Touches API, validation, external API integration, persistence, idempotency.

### Hand-off message

After writing the bootstrap dossier, tell the user:

```
Project bootstrapped. The bootstrap is *not* the SDLC — it's the frame
the SDLC sits in. Next, identify the walking skeleton (smallest
end-to-end slice that exercises every architectural seam) and drive it
through Stages 1-7. That dossier becomes the project's foundational
SDLC artifact; later features reference it instead of re-deriving
architecture.

Suggested walking skeleton for {project name}: {one-line proposal}

To proceed, run:

  /sdlc {walking skeleton description}

This will create docs/sdlc/walking-skeleton/01-requirements.md through
07-maintenance.md. Subsequent features reference this dossier as the
project baseline.
```

Always propose a concrete walking-skeleton description — don't make the user invent one cold. Base your proposal on `docs/architecture.md` and the MVP scope from the bootstrap intake. The user can refine or replace it, but they should never face a blank prompt.

## Behavioral rules

- **Be opinionated.** A good Stage 0 commits to choices. Listing 6 frameworks "for the user to pick" is failure mode #1.
- **Justify, don't lecture.** Each ADR explains the choice in 1-2 paragraphs, not 10.
- **Avoid hallucinated MCPs.** Reference only the real-world tools listed in `.sevaai-sdlc.yaml`. Don't invent SaaS products.
- **Compliance gates the stack.** If the user says HIPAA, certain choices are off the table (e.g., Vercel Hobby tier, free Heroku, MongoDB Atlas free tier without BAA). The skill must respect this.
- **Don't generate application code.** No business logic, no `app.get('/users', ...)` boilerplate. Stages 3+ produce code; Stage 0 produces the *frame* the code will live in.

## What good output looks like — the Aurora benchmark

If a user says "I'm building a B2B customer-success analytics SaaS, multi-tenant, SOC 2, AWS, TypeScript+Node, mid team", the skill should produce roughly the same set of files Aurora has today: README + architecture + 4-6 ADRs + `.sevaai-sdlc.yaml` filled in for Fastify+Postgres+BullMQ+Redis on ECS Fargate with Auth0 + Datadog + Sentry + IriusRisk + LaunchDarkly. The bar is "indistinguishable from a manually-bootstrapped repo by a senior engineer."

## Template

See `templates/00-bootstrap.md` for the dossier artifact format.

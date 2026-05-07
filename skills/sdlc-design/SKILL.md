---
name: sdlc-design
description: Use this skill when the user wants to design a feature's architecture, components, APIs, or data model — typically after requirements are clear and before code is written. Triggers include "design", "architecture", "ADR", "architecture decision record", "component design", "API contract", "API spec", "data model", "schema", "system design", "high-level design", "low-level design", "HLD", "LLD", "sequence diagram", "trade-off analysis", or stage-2 SDLC work. Also trigger when the user asks "how should we build X" or wants a first-pass threat model as part of design. Do NOT use for pure requirements (use sdlc-requirements) or for writing the actual code (use sdlc-development).
license: MIT
---

# SDLC Stage 2 — Design

Take the requirements artifact and produce a component design, API contracts, data model, and an ADR documenting the key decision. This is the deepest-reasoning stage; pair with the strongest model tier you have available.

## Standards we follow

Two industry-standard formats produce a design doc reviewers know how to read:

- **arc42** — text structure for the design doc. 12 canonical sections; widely used in regulated and mid-market engineering. The artifact's H2 sections in §1-§12 below map 1:1 onto arc42.
- **C4 model** — visual notation for the diagrams (Simon Brown). Four levels: System Context → Container → Component → Code. Most teams use levels 1-3.

Diagrams are **Mermaid** in markdown (renders natively on GitHub). The lint rules in the next section prevent the parser failures Mermaid is prone to.

## Mermaid lint rules — apply to every diagram

Mermaid's parser has five sharp edges that AI-generated content keeps hitting. These rules are not optional — they prevent the design doc from rendering as a red error on GitHub.

1. **No spaces in subgraph or node IDs.** Use `subgraph WorkerService [Display Label]`, not `subgraph Worker Service`. The bracketed label can have spaces; the ID cannot.
2. **No `;` in sequence-diagram messages.** Mermaid treats `;` as a statement terminator. Use `,` or split into two arrows.
3. **No `<` or `>` in messages or `alt`/`else`/`opt` labels.** Use words: "above", "below", "at least", "at most".
4. **No `<tagname>` in messages.** Looks like HTML to the renderer. Use `[name]` or `(name)` placeholders.
5. **Use single-token arrow labels.** Avoid quotes inside diagram messages where possible.

If `lint_mermaid` is available via the diagram MCP, call it before writing the artifact. Otherwise self-check against these rules before each `flowchart` or `sequenceDiagram` block.

## Sub-activities covered

The artifact must address these in `02-design.md`, structured per arc42:

**§1 Introduction & Goals** — what's being built, the requirements quoted, success criteria.
**§2 Constraints** — technical, organizational, regulatory constraints (from `.sevaai-sdlc.yaml`).
**§3 Context & Scope** — C4 Level 1 (System Context diagram) showing the system + external actors and systems.
**§4 Solution Strategy** — the core approach in 5-10 sentences. Why this shape, not another.
**§5 Building Blocks** — C4 Level 2 (Container diagram) + C4 Level 3 (Component diagram for the most complex container). Module/package structure.
**§6 Runtime View** — sequence diagrams for the 1-3 critical flows.
**§7 Deployment View** — where the containers run (ECS / EKS / serverless), env-by-env differences.
**§8 Cross-cutting Concepts** — auth, observability, caching, error handling, i18n.
**§9 Architecture Decisions (ADRs)** — one or more ADRs, each with rejected alternatives. Standalone copies in `docs/adr/NNNN-*.md`.
**§10 Quality Requirements** — non-functional requirements (perf, scale, availability) with measurable targets.
**§11 Risks & Technical Debt** — what could go wrong; what we're consciously punting.
**§12 Glossary** — domain terms used in the doc.

Plus a final §13 first-pass STRIDE threat model (full review happens in stage 5).

Plus §14 Hand-off to Stage 2.5 (Functional-to-Technical Mapping) — the next stage consumes this artifact + the requirements artifact to produce the traceability matrix.

If a section doesn't apply (e.g., no schema changes → no migration), write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-requirements` has produced `01-requirements.md`
- User explicitly asks for design / architecture / ADR / API contract
- Orchestrator calls this skill as stage 2

## Inputs

1. The requirements artifact (`01-requirements.md`) if it exists
2. Existing project architecture docs and ADRs (read with Glob `ADR*/**/*.md`, `ARCHITECTURE*`)
3. Existing source code structure (sample with Read; don't try to read everything)

If the requirements artifact is missing, ask the user to run `sdlc-requirements` first or provide the requirement summary inline.

## What to do

1. **Brownfield check.** If `docs/sdlc/{feature-slug}/02-design.md` already exists, read it and ask the user: "Existing design doc found. Augment, replace, or skip?" Default to augment.
2. **Read existing ADRs.** Read all `docs/adr/*.md`. Don't contradict prior decisions silently. If you must, surface the conflict and propose an ADR supersession with the next sequential number.
3. **Identify the design's center of gravity.** Is this primarily a data-model change, a new service, a new API surface, a UI change, or a cross-cutting concern (auth, observability)? The arc42 sections weighting depends on the answer.
4. **Produce all 12 arc42 sections** (plus §13 STRIDE, §14 hand-off) per the template. C4 Levels 1, 2, and (where the design has a complex container) 3. Mermaid for visual rendering on GitHub.
5. **Lint diagrams before writing.** Apply the 5 Mermaid lint rules. If the diagram MCP is connected, call `lint_mermaid` on every diagram block.
6. **First-pass threat model.** STRIDE one-liners per component. The full security review is `sdlc-security`'s job; here you just flag.
7. **Write each ADR twice.** Once embedded in §9 of the design doc, once as a standalone file `docs/adr/NNNN-{slug}.md` for grep-ability. Both copies stay in sync.
8. **Write artifact** to `docs/sdlc/{feature-slug}/02-design.md` using `templates/artifact.md`.

## Real-world products this skill complements

- **Eraser AI / Excalidraw / Whimsical** — for diagrams (you produce Mermaid; teams often paste into one of these)
- **Backstage** — register new services in the catalog after design lands
- **Stoplight / SwaggerHub / Postman** — host the OpenAPI spec
- **IriusRisk / ThreatModeler / Microsoft Threat Modeling Tool** — formal threat modeling beyond the STRIDE one-liners
- **dbdiagram.io / DbSchema** — for the data model visualization

## Project conventions (edit me per project)

- **Stack**: declare your default stack here (e.g., Node 20 / TypeScript / Postgres 16 / GKE / Cloud SQL).
- **Auth**: declare the standard auth pattern (e.g., OIDC via Auth0; service-to-service via mTLS).
- **API style**: REST + JSON, gRPC, GraphQL — pick one as default and call deviations out.
- **Naming**: snake_case for tables, camelCase for fields, kebab-case for URL paths.
- **ADR location**: `docs/adr/NNNN-title.md` with sequential numbering.

## Hand-off

The orchestrator should invoke `sdlc-mapping` (Stage 2.5) next, NOT `sdlc-development` directly. Stage 2.5 consumes both `01-requirements.md` and `02-design.md` to produce the Functional-to-Technical traceability matrix that drives backlog generation in Stage 3.

## Template

See `templates/artifact.md`.

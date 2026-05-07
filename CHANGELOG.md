# Changelog

All notable changes to sevaai-sdlc-toolkit. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] / v0.4.0 candidate

### Added
- **Stage 2.5 — Functional-to-Technical Mapping (`sdlc-mapping` skill).** New skill that produces a traceability matrix bridging user stories to specific technical components, files, migrations, and config. The mapping artifact (`02b-mapping.md`) becomes the input to backlog generation in Stage 3. One row per story, with NEW vs. EDIT files, dependencies, risk, and ADR refs.
- **Auto-create GitHub Projects v2 backlog in Stage 3.** `sdlc-development` now consumes `02b-mapping.md` and creates one GitHub Issue per row with labels (`story`/`infra`/`docs`/`comms`), story points, risk, and `Status: Backlog` placement on a configured Project v2 board. Dependencies expressed as `Blocked by #N` comments.
- **arc42 + C4 model** as the design standard. `sdlc-design/SKILL.md` and template rewritten to produce 12 arc42 sections (Introduction & Goals → Constraints → Context & Scope → Solution Strategy → Building Blocks → Runtime View → Deployment View → Cross-cutting Concepts → ADRs → Quality Requirements → Risks & Tech Debt → Glossary) plus first-pass STRIDE and hand-off. Diagrams use C4 levels 1-3 (System Context, Container, Component) in Mermaid.
- **Mermaid lint rules baked into `sdlc-design` skill.** Five rules to prevent the parser failures encountered during Aurora testing: no spaces in subgraph/node IDs, no `;` in sequence-diagram messages, no `<`/`>` in messages or `alt` labels, no `<tagname>` placeholders, single-token arrow labels.
- **Brownfield-aware orchestrator.** Each stage checks whether its output already exists and asks "augment / replace / skip?" before writing. Default behaviors per stage: skip for Stages 1-2, augment for Stages 2.5-3, skip for Stages 4-7.

### Changed
- `sdlc-orchestrator` now runs Stages 1 → 2 → 2.5 → 3 → 4 → 5 → 6 → 7 (Stage 2.5 inserted between Design and Development).
- `sdlc-development` hand-off updated: now mentions optional `sdlc-sprint` (Stage 3b — Scrum Master mode, planned for v0.5.0).
- README per-feature flow diagram updated to show 1 → 2 → 2.5 → 3 with auto-backlog callout.

## [0.3.0] — Stage 0 + walking skeleton + GitHub backlog + MCP user guide

### Added
- **Stage 0 — Project Bootstrap (`sdlc-init` skill).** New skill for greenfield projects. Produces vision README, `docs/architecture.md`, foundational ADRs (language, database, deploy target, auth), `.sevaai-sdlc.yaml`, repo skeleton (src/, tests/, migrations/, .github/workflows/), CI baseline, LICENSE, .gitignore, stack-specific manifest. Closes the gap where the toolkit only worked against existing codebases.
- **Walking skeleton concept.** Stage 0 explicitly hands off to the orchestrator with a proposed walking-skeleton feature — the smallest end-to-end slice that exercises every architectural seam. The walking-skeleton's dossier becomes the project baseline; subsequent features reference it instead of re-deriving architecture.
- **GitHub backlog mode for Stage 1.** `sdlc-requirements` now supports two GitHub modes via `trackers.github.mode`: `umbrella` (one tracking issue per feature, pairs with Jira) and `backlog` (one umbrella + one child issue per user story, with optional Project v2 board attachment). Configurable labels.
- **MCP user guide (`docs/mcp-user-guide.md`).** Practical, copy-paste setup walkthrough for the 11 most-common MCPs (GitHub, Atlassian Rovo, Notion, PagerDuty, Datadog, Sentry, Snyk, LaunchDarkly, Mixpanel, Productboard, custom). Covers in-app vs. CLI vs. JSON install paths, scope (user/project/local), the verification pattern, and troubleshooting for the issues actually encountered (Apple Silicon / Rosetta 2, missing in-app option, scope conflicts, token leaks).
- **Greenfield detection in orchestrator.** Detects absence of `.sevaai-sdlc.yaml` AND `docs/architecture.md` and offers to run Stage 0 first.

### Changed
- README promo block now distinguishes Stage 0 (greenfield, runs once) from Stages 1-7 (per-feature). New ASCII flow diagram showing both paths.
- `docs/run-by-stage.md` updated for 9 sdlc-* skills (orchestrator + init + 7 stages).
- `.sevaai-sdlc.yaml.example` documents new `github.mode` and `github.project_v2_number` fields.

### Notes
- Stage 0 is opt-in. Existing projects (with README + architecture + yaml) skip it entirely; greenfield projects get prompted.

## [0.2.0] — Visible docs, multi-tool adapters, enforcement, Jira hand-off

### Added
- **Multi-tool adapters.** Generated from SKILL.md sources via `scripts/build-adapters.py`. Output: `adapters/cursor/.cursor/rules/*.mdc`, `adapters/aider/CONVENTIONS.md`, `adapters/openai-gpt/*.md`, `adapters/gemini-gem/*.md`, `adapters/raw/*.md`. Skills work in Cursor, Aider, ChatGPT custom GPTs, Gemini Gems, and any tool that accepts custom instructions.
- **Enforcement bundle.** Three components that make the dossier a precondition for code merging:
  - `enforcement/templates/.github/workflows/require-sdlc-dossier.yml` — CI workflow that fails any PR missing a complete dossier (six stage artifacts + non-BLOCKING security stage)
  - `enforcement/templates/CLAUDE.md` — AI guardrail; auto-loaded by Claude Code in repos that adopt it. Refuses to generate code when the dossier is incomplete.
  - `enforcement/templates/.githooks/pre-commit` — local nudge for developers using non-Claude AI assistants
  - `enforcement/setup-enforcement.sh` — installer
  - `enforcement/docs.md` — phased-rollout playbook (Phase 0 baseline → Phase 1 soft launch → Phase 2 hard gate → Phase 3 routing)
- **Jira hand-off in `sdlc-requirements`.** Via Atlassian Rovo MCP. Asks before pushing, then creates one Workstream/Epic + N Stories with compliance labels (`pii`, `gdpr`, `soc2`, `hipaa`, `payment`, `accessibility`, `wcag`) and story-point hints. Validated end-to-end against a real Atlassian Cloud site.
- **Notion hand-off in `sdlc-requirements`.** Via Notion MCP. Creates a PRD page in a configured database. Built but not yet user-validated.
- **GitHub umbrella hand-off in `sdlc-requirements`.** Single tracking issue with SDLC-stage checklist; pairs with Jira when both are enabled.
- **Reference architecture diagram.** `docs/reference-architecture.svg` + `.md`. Light-mode, indigo/violet/emerald/amber/rose palette. Shows the 7-stage flow plus runtime tools (Glob/Read/Grep/LLM/MCP/Write) plus per-stage hand-offs to real-world products.
- **Sub-activities sections** in every SKILL.md, expanding what each stage's artifact must address.
- **34+ bundled MCPs in `.mcp.json`.** Covers Atlassian Rovo, Notion, Slack, GitHub, GitLab, Azure DevOps, Sourcegraph, BrowserStack, Snyk, Okta, Auth0, Vercel, Netlify, AWS, GCP, Cloudflare, LaunchDarkly, Terraform Cloud, Sentry, PagerDuty, Honeycomb, Datadog, New Relic, Grafana Cloud, Splunk, incident.io, BetterStack, plus a `_custom_endpoint_template` for internal MCPs.
- **`scripts/setup-mcps.sh`.** CLI installer that reads `.mcp.json` via jq. Supports `--list`, `--minimal` (GitHub + Atlassian + Sentry), `--all`, `--stage N`, and interactive picker.
- **`docs/mcp-catalog.md`.** Full categorized MCP list grouped by stage.
- **`docs/mcp-integration.md`.** Which MCPs help which stages.
- **`docs/sdlc-stages-detail.md`.** Elaborate sub-activities reference per stage.
- **`docs/run-by-stage.md`.** Terminal-driven walkthrough for running stages one at a time.
- **`docs/validator-guide.md`.** Rubrics R1-R5 (Requirements), D1-D5 (Design), V1-V5 (Development), T1-T5 (Testing), S1-S7 (Security), P1-P6 (Deployment) for grading skill outputs.
- **bulk-csv-import reference dossier.** All 6 stages auto-generated as a worked example, marked clearly as "REFERENCE OUTPUT — for studying the artifact format, not as a real implementation plan."

### Changed
- `output_dir` default moved from hidden `.sevaai-sdlc/` to visible `docs/sdlc/`. The dossier shows up in Finder, gets PR-reviewed, and lives next to the code.
- All seven stage SKILL.md files updated to reference the new `docs/sdlc/` location.
- All seven artifact templates expanded with the new sub-sections.

### Validated
- Stage 1 (Requirements) end-to-end against Aurora: created Jira Workstream `SDLCTEST-1` + Stories `SDLCTEST-2..7` with compliance labels (pii, gdpr, soc2, wcag, accessibility, auth, secrets, churn-slack-alerts, sdlc-requirements).
- Stage 2 (Design) end-to-end against Aurora: produced 5/5 design doc with HLD + LLD + ADR + STRIDE.
- Stage 3 (Development) end-to-end against Aurora: produced 9-PR breakdown summing to 30 SP. Caught two real issues via GitHub MCP grounding (ADR number collision + missing toolchain).

## [0.1.0] — 2026-05-04

Initial release.

- Seven stage skills: requirements, design, development, testing, security, deployment, maintenance
- Top-level orchestrator skill (`sdlc-orchestrator`)
- `/sdlc` slash command
- Reusable artifact templates per stage
- Plugin manifest (`plugin.json`) for Claude Code marketplace
- Customization guide (`docs/customization.md`)
- Example feature input

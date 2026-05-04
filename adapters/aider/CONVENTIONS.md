# sevaai-sdlc Conventions for Aider

Run aider with `aider --read CONVENTIONS.md` so these rules are loaded into every session.
Each section corresponds to one SDLC stage skill. Mention the stage name (or its trigger
phrases) in your prompt to invoke that section's behavior.

---

# sdlc-deployment

**Triggers when:** Use this skill when the user wants a deployment plan, rollout strategy, feature flag plan, canary plan, blue-green plan, rollback runbook, or release plan for a feature. Triggers include "deployment plan", "release plan", "rollout", "rollout plan", "canary", "blue-green", "feature flag", "feature flags", "progressive delivery", "rollback", "rollback plan", "release notes", "go-live", "production push", "CI/CD plan", "IaC change", "Terraform plan", "Kubernetes manifest", "helm chart change", or stage-6 SDLC work. Do NOT use for runtime monitoring after release (use sdlc-maintenance).

# SDLC Stage 6 — Deployment

Produce the rollout plan: environments, CI/CD wiring, feature-flag strategy, canary thresholds, rollback runbook, and release notes. This artifact is what release management approves before production push.

## Sub-activities covered

The artifact must address these in `06-deployment.md`:

**Release planning** — environment promotion path (dev -> staging -> canary -> prod), approver(s) per gate, release window + no-deploy windows, versioning + dependencies on other releases.

**Feature flag plan** — flag name, default state, rollout schedule (e.g. 1% / 1h -> 10% / 4h -> 50% / 8h -> 100%), kill-switch criteria.

**Canary analysis** — SLIs to watch (error rate, p95 latency, saturation, business KPI) and threshold that triggers auto rollback.

**Deployment automation** — CI workflow updates (Actions / GitLab / Jenkins), IaC changes (Terraform / Pulumi / Helm / Argo), DB migration plan (expand-contract).

**Rollback runbook** — copy-pasteable steps, <=2min each.

**Release notes** — user-facing / internal / API / deprecations.

**Stakeholder comms** — audience x channel x timing matrix.

**Cost & capacity check** — QPS / storage / inference-cost delta.

If a sub-activity doesn't apply, write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-security` produced `05-security.md` (and is non-blocking)
- User asks for a deployment / rollout / release plan
- Orchestrator calls this skill as stage 6

## Inputs

1. `02-design.md` (infra changes, scaling expectations)
2. `03-development.md` (PR sequence — drives release ordering)
3. `05-security.md` (any blocking issues halt this stage)
4. Existing CI/CD config — Glob `.github/workflows/**`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/**`
5. IaC — Glob `terraform/**`, `pulumi/**`, `helm/**`, `k8s/**`

## What to do

1. **Environment promotion path.** Dev -> staging -> canary -> prod with the gate at each (auto / human).
2. **Feature flag plan.** Flag name, default state, rollout schedule (`0% -> 1% -> 10% -> 50% -> 100%` over N hours/days), kill-switch criteria.
3. **Canary analysis.** Define the SLIs you'll watch during canary (latency p95, error rate, saturation, business KPI) and the threshold that triggers automatic rollback. If the team uses Harness CV / Argo Rollouts + Kayenta / Flagger, name the analysis template.
4. **Database migrations.** Confirm forward + backward compatible (expand-contract pattern). No long-running migrations during business hours.
5. **Rollback runbook.** Step-by-step what to do when canary fails. Each step <=2 min to execute. Name who has access to execute it.
6. **Release notes.** User-facing changes, internal-team changes, API changes, deprecations.
7. **Stakeholder comms.** Who's notified, when, in what channel (Slack #releases, email to support, status-page entry if customer-facing).
8. **Cost & capacity check.** Will this change peak QPS, storage, egress, model-inference cost? Note expected delta.
9. **Write artifact** to `.sevaai-sdlc/{feature-slug}/06-deployment.md` using `templates/artifact.md`.

## Real-world products this skill complements

- **CI/CD platforms**: GitHub Actions, GitLab CI, CircleCI, Jenkins, Buildkite
- **Progressive delivery**: Argo Rollouts + Kayenta, Flagger, Harness Continuous Verification
- **Feature flags**: LaunchDarkly, Unleash, Split, Statsig, Flagsmith, GrowthBook
- **IaC**: Terraform / Spacelift / env0, Pulumi (Pulumi AI), Crossplane, AWS CDK
- **Container orchestration**: Kubernetes, Argo CD, Flux, Helm
- **Cloud platforms**: AWS, GCP, Azure, OCI — match what your project uses
- **Status pages**: Statuspage, BetterStack, Instatus

## Project conventions (edit me per project)

- **Default rollout**: 1% / 1h -> 10% / 4h -> 50% / 8h -> 100%, with auto-rollback if error rate > baseline + 0.5%.
- **Database changes**: expand-contract; never combine schema change + code change in one PR.
- **No deploys**: Friday after 14:00, weekends, the day before a major holiday.
- **Approver**: at least one engineer from the owning team + one from platform / SRE.
- **Release calendar**: tracked in `docs/releases/calendar.md` or your equivalent.

## Hand-off

The orchestrator should invoke `sdlc-maintenance` with `06-deployment.md` as input.

## Template

See `templates/artifact.md`.

---

# sdlc-design

**Triggers when:** Use this skill when the user wants to design a feature's architecture, components, APIs, or data model — typically after requirements are clear and before code is written. Triggers include "design", "architecture", "ADR", "architecture decision record", "component design", "API contract", "API spec", "data model", "schema", "system design", "high-level design", "low-level design", "HLD", "LLD", "sequence diagram", "trade-off analysis", or stage-2 SDLC work. Also trigger when the user asks "how should we build X" or wants a first-pass threat model as part of design. Do NOT use for pure requirements (use sdlc-requirements) or for writing the actual code (use sdlc-development).

# SDLC Stage 2 — Design

Take the requirements artifact and produce a component design, API contracts, data model, and an ADR documenting the key decision. This is the deepest-reasoning stage; pair with the strongest model tier you have available.

## Sub-activities covered

The artifact must address these in `02-design.md`:

**High-Level Design (HLD)** — system architecture diagram (Mermaid), service boundaries and responsibilities, tech stack decisions, integration points with existing services, system-level data flow.

**Low-Level Design (LLD)** — module / class / package structure, API contracts (OpenAPI), data model (schema additions, indexes, migrations forward + rollback), sequence diagrams for non-trivial flows, configuration / env vars.

**Architecture Decision Record (ADR)** — context, decision, alternatives considered + why rejected, consequences, supersession of prior ADRs if any.

**First-pass threat model** — STRIDE one-liners per component (full review happens in stage 5).

If a sub-activity doesn't apply (e.g., no schema changes -> no migration), write "n/a" with a one-line reason.

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

1. **Read existing ADRs.** Don't contradict prior decisions silently. If you must, surface the conflict and propose an ADR supersession.
2. **Identify the design's center of gravity.** Is this primarily a data-model change, a new service, a new API surface, a UI change, or a cross-cutting concern (auth, observability)?
3. **Produce four sub-artifacts** inside the same output file:
   - **Component diagram (Mermaid)** showing services, data stores, external systems
   - **API contracts** — OpenAPI snippet or typed function signatures, with auth, errors, pagination
   - **Data model** — schema additions/changes (DDL or schema language) with indexes and migrations
   - **ADR** — context, decision, alternatives considered, consequences, supersedes (if any)
4. **First-pass threat model.** STRIDE one-liners per component. The full security review is `sdlc-security`'s job; here you just flag.
5. **Trade-offs.** Explicitly list two alternatives you considered and why you didn't pick them.
6. **Write artifact** to `.sevaai-sdlc/{feature-slug}/02-design.md` using `templates/artifact.md`.

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

The orchestrator should invoke `sdlc-development` with `02-design.md` as input.

## Template

See `templates/artifact.md`.

---

# sdlc-development

**Triggers when:** Use this skill when the user wants an implementation plan, file-by-file build plan, code skeleton, or coding conventions for a feature whose design is already done. Triggers include "implementation plan", "build plan", "file plan", "scaffold", "skeleton", "code structure", "how should I implement", "coding conventions", "PR plan", "split into PRs", "review checklist", "developer brief", or stage-3 SDLC work. This skill produces the brief a developer hands to Cursor / Copilot / Claude Code, NOT the actual code commits. Do NOT use for design (use sdlc-design) or for writing tests (use sdlc-testing).

# SDLC Stage 3 — Development Plan

Produce the developer brief: a file-by-file implementation plan, naming and style conventions, a PR breakdown, and a self-review checklist. The actual coding happens in an IDE assistant — this skill produces the plan that makes that assistant fast.

## Sub-activities covered

The artifact must address these in `03-development.md`:

**PR breakdown** — 3-5 PRs of <=400 LOC each, Conventional Commit titles, per-PR file plan (added / modified / deleted), behind-flag flag for user-facing PRs, reviewer suggestions.

**Coding standards** — naming conventions matched to existing codebase, lint / format toolchain (eslint / ruff / gofmt etc.), import ordering, comment / docstring expectations, forbidden patterns.

**Scalable code patterns** — pure functions where possible, dependency injection at boundaries, pagination / batching / idempotency keys for high-volume paths.

**Version control conventions** — branch strategy (trunk-based default), commit style (Conventional Commits), PR size budget.

**Code review checklist** — self-review steps before requesting review, what reviewers should look for in this feature, coding-agent prompt the developer can paste into Cursor / Copilot / Claude Code.

If a sub-activity doesn't apply, write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-design` has produced `02-design.md`
- User wants a file plan, scaffold, or PR breakdown
- Orchestrator calls this skill as stage 3

## Inputs

1. `02-design.md` (or design summary inline)
2. Existing source layout — sample with Glob `src/**/*` and Read a few representative files to learn conventions
3. Existing lint / format config (`.eslintrc`, `pyproject.toml`, `.prettierrc`) — read these so your plan matches

## What to do

1. **Match the codebase's style.** If files use snake_case, don't suggest camelCase. If imports are sorted by isort, your plan must respect that.
2. **Decompose into PRs.** Default to 3-5 PRs of <=400 lines diff each. Order them so each PR is independently reviewable and shippable behind a flag.
3. **Per-PR breakdown.** For each PR:
   - Title (`feat:` / `fix:` / `chore:` conventional commits)
   - Files added / modified / deleted
   - Test files alongside (defer test content to `sdlc-testing`)
   - Migration steps if data model changes
   - Feature flag wrapping if user-facing
4. **Author a self-review checklist** the developer runs before requesting human review.
5. **Hand-off to coding tools.** Produce a one-paragraph "Cursor/Claude Code prompt" the developer can paste to start the build.
6. **Write artifact** to `.sevaai-sdlc/{feature-slug}/03-development.md` using `templates/artifact.md`.

## Real-world products this skill complements

- **Cursor / Claude Code / Windsurf / Copilot Workspace** — the coding agents that consume this brief
- **GitHub Copilot / Tabnine / Codeium / Cody** — inline assistants
- **CodeRabbit / Greptile / Graphite Reviewer / Korbit** — AI code review on the resulting PR
- **Aider** — terminal-based agent if your team prefers CLI
- **Conventional Commits + commitlint** — for commit message standards

## Project conventions (edit me per project)

- **Branch strategy**: trunk-based with short-lived feature branches.
- **PR size**: target <=400 lines net diff.
- **Commit style**: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`).
- **Lint/format**: ruff + black for Python, eslint + prettier for TS, gofmt for Go.
- **Pre-commit hooks**: must pass before push.
- **Feature flags**: required for any user-facing change behind a flag system (LaunchDarkly, Unleash, internal).

## Hand-off

The orchestrator should invoke `sdlc-testing` with `03-development.md` as input.

## Template

See `templates/artifact.md`.

---

# sdlc-maintenance

**Triggers when:** Use this skill when the user wants a runbook, on-call cheat sheet, monitoring plan, alerting plan, SLO/SLI definition, dashboard plan, postmortem template, capacity plan, or technical-debt watchlist for a feature that's been deployed or is about to be. Triggers include "runbook", "on-call", "oncall", "playbook", "monitoring", "observability", "metrics", "dashboard", "alert", "alerting", "SLO", "SLI", "SLA", "error budget", "capacity plan", "anomaly detection", "incident response", "postmortem", "AIOps", "tech debt", "tech-debt", "deprecation plan", or stage-7 SDLC work. Do NOT use for pre-release deployment planning (use sdlc-deployment).

# SDLC Stage 7 — Maintenance & Optimization

Produce the operations bundle: SLOs/SLIs, dashboards, alerts, runbook, on-call cheat sheet, postmortem template, and tech-debt watchlist. This is what makes the feature operable, not just deployed.

## Sub-activities covered

The artifact must address these in `07-maintenance.md`:

**SLOs and SLIs** — availability, latency p95/p99, error rate, freshness over a 28-day rolling window. Burn-rate alerts (fast / slow).

**Dashboards** — four golden signals (latency / traffic / errors / saturation) plus the business KPI for the feature.

**Alerting** — P1 page / P2 ticket / P3 notify-only routing, alert noise budget (e.g. max 2 pages per shift).

**Runbook** — per failure mode: symptom -> diagnosis -> remediation, with copy-pasteable commands or links.

**On-call cheat sheet** — where logs live, how to roll back, how to kill the flag, escalation owner.

**Postmortem template** — pre-seeded with this feature's context.

**Tech debt watchlist** — items, owner, severity, review-by date.

**Capacity + cost trend** — what to watch, revisit cadence.

**Feedback loop** — user feedback channels (tickets / NPS / in-app surveys), cadence for reviewing feedback against the feature thesis, trigger for deprecation or major iteration.

If a sub-activity doesn't apply, write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-deployment` produced `06-deployment.md`
- User asks for a runbook, monitoring plan, SLOs, or on-call docs
- Orchestrator calls this skill as stage 7

## Inputs

1. `02-design.md` (architecture for SLI choice)
2. `06-deployment.md` (canary thresholds become starting SLI definitions)
3. Existing observability stack — search for Datadog / New Relic / Grafana / Prometheus / Sentry config

## What to do

1. **Pick SLIs that matter** — availability, latency p95/p99, error rate, freshness, correctness. Avoid vanity metrics.
2. **Define SLOs** with explicit numbers and a 28-day rolling window. State the error budget burn rate alerts (fast burn, slow burn).
3. **Dashboard plan.** What goes on the at-a-glance dashboard the on-call sees first. Use the four golden signals (latency, traffic, errors, saturation) plus business KPI for the feature.
4. **Alert routing.** Page (P1) vs ticket (P2) vs notify-only (P3). Alert noise budget: <=2 pages per on-call shift.
5. **Runbook.** For each likely failure mode: symptom -> diagnosis steps -> remediation. Steps must be copy-pasteable commands or links.
6. **On-call cheat sheet.** One-pager: where logs live, how to roll back, how to disable the feature flag, who owns escalations.
7. **Postmortem template** seeded with the feature context, so a future incident author has less blank-page friction.
8. **Tech-debt watchlist.** TODOs, hacks, deferred work, known limitations. With owner and review-by date.
9. **Capacity & cost trend** plan: what to watch for, when to revisit.
10. **Write artifact** to `.sevaai-sdlc/{feature-slug}/07-maintenance.md` using `templates/artifact.md`.

## Real-world products this skill complements

- **APM with AI**: Datadog Bits AI, New Relic AI, Dynatrace Davis AI, AppDynamics Cognition
- **Logs**: Splunk AI, Sumo Logic AI, Elastic AI Assistant, Coralogix
- **Tracing**: Honeycomb, Lightstep / ServiceNow Cloud Observability, Tempo
- **Metrics**: Prometheus + Grafana, CloudWatch, Stackdriver
- **Incident response**: PagerDuty AIOps, Incident.io, FireHydrant, Rootly, Grafana OnCall
- **Anomaly detection**: AWS DevOps Guru, Azure Anomaly Detector, GCP Active Assist
- **SLO platforms**: Nobl9, Sloth (open-source)
- **Tech debt / code health**: SonarQube AI, CodeScene, CAST Highlight, Sentry AI auto-fix
- **Status pages**: Statuspage, BetterStack, Instatus

This skill produces the *plan and runbook*. The products above provide the actual telemetry and alerting.

## Project conventions (edit me per project)

- **Observability stack**: declare it (e.g., Datadog for APM + logs, Grafana for dashboards, PagerDuty for paging).
- **Default SLOs**: 99.9% availability, p95 < 500ms, error rate < 0.1%.
- **Page budget**: 2 pages / on-call shift max; investigate alert tuning if over budget.
- **Postmortem norm**: blameless, written within 5 business days for any P1.
- **Tech-debt review**: monthly; debt items >90 days old escalate to staff eng.

## Hand-off

This is the last stage. The orchestrator (`sdlc-orchestrator`) consolidates all 7 artifacts into a feature dossier under `.sevaai-sdlc/{feature-slug}/`.

## Template

See `templates/artifact.md`.

---

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

---

# sdlc-requirements

**Triggers when:** Use this skill when the user wants to gather, clarify, or document software requirements for a new feature, fix, or initiative. Triggers include any mention of "user stories", "acceptance criteria", "PRD", "product requirements", "feature spec", "requirements doc", "what should we build", "feature request", "epic breakdown", "story refinement", "INVEST criteria", or stage-1 SDLC work. Also trigger when the user describes a fuzzy idea ("we want to add SSO") and needs it turned into structured stories before any design or coding starts. Do NOT use when the requirements are already written and the user wants design or implementation.

# SDLC Stage 1 — Requirements Gathering

Turn a fuzzy feature description into structured, testable user stories with acceptance criteria, ready to land in Jira / Linear / Notion.

## Sub-activities covered

The artifact must address these in `01-requirements.md`:

**Planning** — define project scope, set objectives + measurable goals, resource planning (people / time / dependencies), timeline + milestones, success metrics (KPIs / OKRs).

**Requirements** — functional requirements as user stories (INVEST + Given-When-Then acceptance), non-functional / technical requirements (performance, scalability, accessibility, i18n), stakeholder review and approval (Definition of Ready), edge cases, explicit out-of-scope, compliance flags (PII / payment / regulated data / WCAG).

If a sub-activity doesn't apply to this feature, write "n/a" in the relevant section with a one-line reason, rather than silently skipping it.

## When to invoke

- User describes a feature in prose ("we want to add X")
- User asks for a PRD, user stories, or acceptance criteria
- The orchestrator (`sdlc-orchestrator`) calls this skill as stage 1

## Inputs you should ask for (only if missing)

1. **One-line feature description** — what's being built
2. **Primary persona** — who's it for
3. **Business goal** — why now (revenue, retention, compliance, cost)
4. **Constraints** — deadline, must-fit-into systems, regulatory

If any of those are missing, ask once concisely. Don't ask again.

## What to do

1. **Ground in the codebase.** Read project files matching `README*`, `docs/**/*.md`, `ARCHITECTURE*`, `ADR*/**/*.md`. Use Grep/Glob/Read. Note the stack and existing conventions.
2. **Mine for context.** If `Atlassian`, `Jira`, `Linear`, `Notion`, or `Productboard` MCP connectors are available, search for related epics or feedback. Otherwise rely on the codebase context.
3. **Decompose** the feature into 3-7 user stories. Each story:
   - INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable)
   - "As a {persona}, I want {capability}, so that {benefit}"
   - 3-6 acceptance criteria in Given-When-Then form
   - Edge cases the LLM caught that a human likely missed
   - Dependencies (other stories, external systems, data migrations)
4. **Flag risks**: ambiguous scope, unstated assumptions, missing personas, conflicting goals.
5. **Write the artifact** to `.sevaai-sdlc/{feature-slug}/01-requirements.md` using `templates/artifact.md`.

## Real-world products this skill complements (not replaces)

- **Jira / Linear / Asana** — file the stories there as the source of truth
- **Atlassian Intelligence / Linear AI** — your destination, not a competitor
- **Notion AI / Confluence AI** — for the long-form PRD
- **Productboard / Dovetail / UserVoice** — feedback to mine for evidence
- **Storyteller / Userdoc** — auto-generation of acceptance criteria

If the user asks "should we use Productboard instead?", the answer is: this skill drafts the structured stories quickly; ship them to Jira/Linear and use Productboard for ongoing feedback aggregation. Skill + product, not skill vs. product.

## Project conventions (edit me per project)

- **Story format**: Given-When-Then for acceptance criteria.
- **Sizing**: stories should be completable in <=5 days by one engineer.
- **Compliance**: flag any story that touches PII, payment data, or auth — these need security stage review.
- **Definition of Ready**: a story is ready when it has acceptance criteria, dependencies, and a sized estimate.

## Hand-off

When done, the orchestrator should invoke `sdlc-design` with the artifact at `01-requirements.md` as input.

## Template

See `templates/artifact.md` for the output format.

---

# sdlc-security

**Triggers when:** Use this skill when the user wants a security review, threat model, OWASP mapping, security checklist, dependency or secrets scan plan, or compliance review for a feature. Triggers include "security review", "threat model", "STRIDE", "OWASP", "OWASP Top 10", "ASVS", "secure design", "auth review", "authn", "authz", "vulnerability assessment", "SAST", "DAST", "SCA", "dependency scan", "secrets scan", "pen test plan", "compliance check", "SOC 2", "PCI", "HIPAA", "FedRAMP", "GDPR", "GenAI security", "prompt injection", or stage-5 SDLC work. Also trigger automatically when prior stages flagged PII, payment, auth, or regulated-data exposure. Do NOT use for general code review (use sdlc-development) or for production incident response (use sdlc-maintenance).

# SDLC Stage 5 — Security

Produce a feature-specific threat model, OWASP Top 10 mapping, and a security checklist that gates merge. Pair with the strongest model tier you have — security reasoning rewards depth.

## Sub-activities covered

The artifact must address these in `05-security.md`:

**STRIDE threat model** — per-component table (Spoofing / Tampering / Repudiation / Info disclosure / DoS / Elevation), with attack scenarios specific to this feature.

**OWASP Top 10 + ASVS L2 mapping** — A01-A10 each marked applicable / mitigated / accepted, with ASVS L2 control IDs cited.

**Auth & authz design** — caller / role / scope / tenancy / audit event per new endpoint.

**Data classification + privacy** — Public / Internal / Confidential / Restricted per new field, encryption at rest + in transit, PII retention policies.

**Dependency + supply chain** — new deps, license review, SBOM update.

**Secrets handling** — secret name, vault path, rotation policy, owner.

**GenAI-specific threats** (when LLM in-feature) — prompt injection, training-data leakage, output handling, model availability.

**Compliance map** — SOC 2 / PCI / HIPAA / FedRAMP / GDPR controls touched + evidence required.

**Pen test plan** — what a red team should try after ship.

If a sub-activity doesn't apply (e.g., no LLM in feature -> no GenAI threats), write "n/a" with a one-line reason. Do NOT mark the artifact non-blocking just because some sub-activities were skipped — the gate is unmitigated HIGH/CRITICAL findings only.

## When to invoke

- After `sdlc-testing` produced `04-testing.md`
- Earlier stages flagged PII, payment, auth, or regulated-data
- User asks for a threat model, security review, or compliance check
- Orchestrator calls this skill as stage 5

## Inputs

1. `02-design.md` (the component diagram and data model are the security review's main targets)
2. `04-testing.md` (so security tests aren't duplicated)
3. Existing security policies if present — Glob `SECURITY*`, `docs/security/**`, `docs/compliance/**`
4. Existing scanner config — `.snyk`, `semgrep.yml`, `.gitleaks.toml`

## What to do

1. **Threat model with STRIDE** for every component in the design diagram. Per component, fill the six STRIDE categories with concrete attacks an attacker would attempt against THIS feature, not generic boilerplate.
2. **Map to OWASP Top 10 (2021)** — A01 Broken Access Control through A10 SSRF — and to OWASP ASVS L2 controls. Cite the control IDs.
3. **Auth & authz design** — explicitly state who can call each new API, in what tenancy / role / scope, with what audit trail.
4. **Data classification** — classify every new data field (Public / Internal / Confidential / Restricted) and define encryption-at-rest, encryption-in-transit, and PII-handling rules.
5. **Dependency & supply chain** — list new dependencies the design adds; flag any not yet in the SBOM allowlist.
6. **Secrets handling** — name every secret and its rotation policy; reject any plan that puts secrets in code or env vars without a vault.
7. **GenAI-specific threats** if the feature uses an LLM: prompt injection, training-data leakage, jailbreak, output-handling, model availability.
8. **Compliance map** — if the project's `.sevaai-sdlc.yaml` declares SOC 2 / PCI / HIPAA / FedRAMP / GDPR, walk the relevant controls and produce evidence requirements.
9. **Pen test plan** — what should a red team try once the feature ships.
10. **Write artifact** to `.sevaai-sdlc/{feature-slug}/05-security.md` using `templates/artifact.md`. Mark the artifact `BLOCKING` if any HIGH-severity threat is unmitigated.

## Real-world products this skill complements

- **SAST**: Snyk Code, Semgrep AI, Checkmarx, Veracode, GitHub Advanced Security, SonarQube
- **DAST**: Burp Suite, OWASP ZAP, StackHawk
- **SCA**: Snyk Open Source, Dependabot, Mend, Sonatype Lifecycle
- **Secrets**: GitGuardian, TruffleHog, GitHub secret scanning, Gitleaks
- **Container / cloud**: Trivy, Wiz, Prisma Cloud, Aqua, Lacework
- **Threat modeling tools**: IriusRisk, ThreatModeler, Microsoft Threat Modeling Tool, OWASP Threat Dragon
- **GenAI security**: Lakera Guard, Protect AI, Robust Intelligence, NeMo Guardrails (Nvidia), Guardrails AI
- **Compliance**: Vanta, Drata, Secureframe (evidence collection)

This skill produces the *threat-model + checklist*. Run the products above for actual scanning.

## Project conventions (edit me per project)

- **Compliance frameworks**: list active ones (e.g., SOC 2 Type II, PCI DSS Level 1, GDPR, FedRAMP Moderate).
- **Default auth**: OIDC + RBAC. Service-to-service: mTLS.
- **Crypto**: AES-256-GCM at rest, TLS 1.3 in transit, FIPS 140-3 modules in regulated envs.
- **Secret store**: Hashicorp Vault / AWS Secrets Manager / GCP Secret Manager — pick one.
- **PII handling**: tokenize at ingest, never log raw, retention max 90 days unless legal hold.
- **High-severity gate**: any HIGH/CRITICAL threat blocks merge until mitigated or accepted with sign-off.

## Hand-off

The orchestrator should invoke `sdlc-deployment` with `05-security.md` as input.

## Template

See `templates/artifact.md`.

---

# sdlc-testing

**Triggers when:** Use this skill when the user wants a test plan, test pyramid, unit test stubs, integration test plan, exploratory test charters, or wants to think through test coverage and edge cases for a feature. Triggers include "test plan", "test strategy", "test pyramid", "unit tests", "integration tests", "e2e tests", "test cases", "edge cases", "negative tests", "happy path", "exploratory testing", "test charters", "self-healing tests", "test data", "QA plan", or stage-4 SDLC work. Do NOT use for security testing alone (use sdlc-security) or for production monitoring (use sdlc-maintenance).

# SDLC Stage 4 — Testing

Produce a test plan and stubs that match the design and the development plan. Cover the pyramid (unit -> integration -> e2e -> exploratory) with explicit ratios, name the gaps, and list the edge cases the LLM thinks the design missed.

## Sub-activities covered

The artifact must address these in `04-testing.md`:

**Test pyramid** — counts and locations for unit / integration / e2e / exploratory tests, coverage target on changed code, test runner config alignment.

**System testing** — end-to-end happy paths, cross-system contract tests, migration applies cleanly to prod-schema copy.

**Manual testing** — exploratory test charters (30-60 min), accessibility / a11y manual sweep, cross-browser / cross-device matrix.

**Automated testing** — unit-test stubs in the project's framework, self-healing UI (Mabl / Testim), visual regression (Applitools / Percy), contract tests (Pact / Postman) for cross-team APIs, performance plan (k6 / Gatling) for high-volume paths.

**Test data + flake budget** — synthetic data strategy (Tonic.ai / Mockaroo + AI), recorded prod traffic (Keploy) where useful, flaky-test policy (triage SLA, quarantine rules).

If a sub-activity doesn't apply, write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-development` produced `03-development.md`
- User asks for a test plan, coverage strategy, or test stubs
- Orchestrator calls this skill as stage 4

## Inputs

1. `02-design.md` and `03-development.md` if they exist
2. Existing test directory structure — Glob `tests/**/*` or `**/*.test.*` and Read a sample
3. Existing test runner config (`jest.config.*`, `pytest.ini`, `vitest.config.*`)

## What to do

1. **Pick a coverage target** appropriate to the change risk: 90% for critical/auth/payment paths, 70-80% for normal product features, 50-60% for prototypes.
2. **Lay out the test pyramid** as a table of counts: how many unit / integration / e2e / exploratory tests, and what each covers.
3. **Per-story test cases.** For each story from requirements, write the Given-When-Then test cases (happy path, negative path, edge cases). LLM excels at finding edge cases — push hard here: empty inputs, max-size inputs, concurrent writes, partial failures, timezone boundaries, locale-specific bugs, accessibility paths.
4. **Generate unit-test stubs** in the project's test framework. Just stubs with descriptive names — let Diffblue / Qodo / Copilot fill in the bodies.
5. **Plan exploratory test charters** for areas hard to automate (UX, ambiguity, surprising states).
6. **Name the test data strategy.** Synthetic via Tonic.ai? Recorded production traffic via Keploy? Hand-crafted fixtures?
7. **Plan flaky-test budget.** What's acceptable, who triages, how long can a flake live before quarantine.
8. **Write artifact** to `.sevaai-sdlc/{feature-slug}/04-testing.md` using `templates/artifact.md`.

## Real-world products this skill complements

- **Test generation**: Diffblue Cover (Java), CodiumAI / Qodo, GitHub Copilot test commands
- **Self-healing UI tests**: Mabl, Testim, Functionize, Katalon
- **Visual regression**: Applitools, Percy, Chromatic
- **API testing**: Keploy, Postman, Bruno
- **Test data**: Tonic.ai, Mockaroo + AI, Synthesized
- **Performance**: k6, Gatling, JMeter
- **Frameworks**: Jest, Vitest, Pytest, JUnit, Playwright, Cypress

The skill writes the **plan and stubs**; the products above generate / maintain the test bodies.

## Project conventions (edit me per project)

- **Coverage gate**: PR fails CI if line coverage drops below baseline.
- **Test naming**: `describe("<unit>")` -> `it("does X when Y")`.
- **Fixture strategy**: factory functions over JSON fixtures.
- **No live network in unit tests.** Use fake clocks for time-dependent code.
- **e2e suite runs**: on every PR for changed flows, full sweep nightly.

## Hand-off

The orchestrator should invoke `sdlc-security` with `04-testing.md` as input.

## Template

See `templates/artifact.md`.

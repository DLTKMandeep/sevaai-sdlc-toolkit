# sevaai-sdlc — elaborate stage reference

The reference architecture diagram shows seven stages at high level. This doc breaks each stage into the sub-activities that the corresponding skill must cover, so you know exactly what the artifact at each stage contains.

Use this as the contract between you and the toolkit: when you run `/sdlc <feature>`, every box below should be addressed in the dossier somewhere.

---

## Stage 1 — Requirements

Combines **planning** and **requirement definition** from the classic SDLC. The artifact (`01-requirements.md`) covers:

### 1.1 Planning
- Define project scope (what's in / what's out)
- Set objectives and goals (measurable outcomes)
- Resource planning (people, time, dependencies)
- Timeline and milestones
- Success metrics (KPIs, OKRs)

### 1.2 Requirements
- Functional requirements (user stories with INVEST + Given-When-Then acceptance)
- Non-functional / technical requirements (performance, scalability, accessibility, internationalization)
- Stakeholder review and approval (Definition of Ready)
- Edge cases and out-of-scope explicitly listed
- Compliance flags (PII, payment, regulated data, accessibility)

---

## Stage 2 — Design

Two layers — system-level and component-level — plus a first-pass threat model. The artifact (`02-design.md`) covers:

### 2.1 High-Level Design (HLD)
- System architecture diagram (Mermaid)
- Service boundaries and responsibilities
- Tech stack decisions
- Integration points with existing services
- Data flow at the system level

### 2.2 Low-Level Design (LLD)
- Module / class / package structure
- API contracts (OpenAPI snippet)
- Data model — schema additions, indexes, migrations (forward + rollback)
- Sequence diagrams for non-trivial flows
- Configuration / environment variables

### 2.3 Architecture Decision Record (ADR)
- Context, decision, alternatives considered, consequences
- Supersession of prior ADRs if applicable

### 2.4 First-pass threat model
- One STRIDE row per component (full review happens in stage 5)

---

## Stage 3 — Development

Builds the developer-facing brief — a senior engineer's plan that an IDE assistant (Cursor / Copilot / Claude Code) can execute. The artifact (`03-development.md`) covers:

### 3.1 PR breakdown
- 3-5 PRs of <=400 LOC each
- Conventional Commit titles
- Per-PR file plan (added / modified / deleted)
- Behind-flag flag for each user-facing PR
- Reviewer suggestions

### 3.2 Coding standards
- Naming conventions (matched to existing codebase)
- Lint / format toolchain (eslint, ruff, gofmt, etc.)
- Import ordering
- Comment / docstring expectations
- Forbidden patterns (no `any`, no console.log in prod, etc.)

### 3.3 Scalable code patterns
- Pure functions where possible
- Dependency injection at boundaries
- Pagination, batching, idempotency keys for high-volume paths

### 3.4 Version control conventions
- Branch strategy (trunk-based default)
- Commit style (Conventional Commits)
- PR size budget

### 3.5 Code review checklist
- Self-review steps before requesting review
- What reviewers should explicitly look for in this feature
- Coding-agent prompt the developer can paste into their IDE assistant

---

## Stage 4 — Testing

Goes beyond "we'll write tests" to define the actual test pyramid + coverage targets + edge cases the LLM caught that humans usually miss. The artifact (`04-testing.md`) covers:

### 4.1 Test pyramid
- Unit / integration / e2e / exploratory counts and locations
- Coverage target on changed code
- Test runner config alignment

### 4.2 System testing
- End-to-end happy paths
- Cross-system contract tests
- Migration applies cleanly to a copy of prod schema

### 4.3 Manual testing
- Exploratory test charters (30-60 min sessions)
- Accessibility / a11y manual sweep
- Cross-browser / cross-device matrix (BrowserStack, Sauce Labs)

### 4.4 Automated testing
- Unit-test stubs in the project's test framework
- Self-healing UI tests (Mabl, Testim)
- Visual regression (Applitools, Percy)
- Contract tests (Pact, Postman) where APIs cross team boundaries
- Performance test plan (k6, Gatling) for high-volume paths

### 4.5 Test data + flake budget
- Synthetic data strategy (Tonic.ai, Mockaroo + AI)
- Recorded production traffic if applicable (Keploy)
- Flaky-test policy (triage SLA, quarantine rules)

---

## Stage 5 — Security

The most rigorous stage. Pair with the deepest model tier. The artifact (`05-security.md`) covers:

### 5.1 STRIDE threat model
- Per-component table — Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation
- Attack scenarios specific to this feature, not boilerplate

### 5.2 OWASP Top 10 + ASVS L2 mapping
- Each of A01-A10 with applicable / mitigated / accepted state
- ASVS L2 control IDs cited

### 5.3 Auth & authz design
- Caller / role / scope / tenancy / audit event per new endpoint

### 5.4 Data classification + privacy
- Classification per new field (Public / Internal / Confidential / Restricted)
- Encryption at rest, in transit
- PII handling and retention policies

### 5.5 Dependency + supply chain
- New deps added, license review, SBOM update

### 5.6 Secrets handling
- Secret name, vault path, rotation policy, owner

### 5.7 GenAI-specific threats (when applicable)
- Prompt injection, training data leakage, output handling, model availability

### 5.8 Compliance map
- SOC 2 / PCI / HIPAA / FedRAMP / GDPR controls touched + evidence required

### 5.9 Pen test plan
- What an internal red team should try after ship

---

## Stage 6 — Deployment

Combines release planning, deployment automation, and operational readiness. The artifact (`06-deployment.md`) covers:

### 6.1 Release planning
- Environment promotion path (dev -> staging -> canary -> prod)
- Approver(s) at each gate
- Release window + no-deploy windows
- Versioning + dependencies on other releases

### 6.2 Feature flag plan
- Flag name, default state
- Rollout schedule (1% -> 10% -> 50% -> 100% with timing)
- Kill-switch criteria

### 6.3 Canary analysis
- SLIs to watch (error rate, latency p95, saturation, business KPI)
- Threshold that triggers automatic rollback

### 6.4 Deployment automation
- CI workflow updates (GitHub Actions, GitLab, Jenkins)
- IaC changes (Terraform, Pulumi, Helm)
- Database migration plan (expand-contract pattern)

### 6.5 Rollback runbook
- Step-by-step, copy-pasteable commands, <=2min per step

### 6.6 Release notes
- User-facing, internal, API changes, deprecations

### 6.7 Stakeholder comms
- Audience x channel x timing matrix

### 6.8 Cost & capacity check
- QPS / storage / inference cost delta

---

## Stage 7 — Maintenance & Optimization

Operations bundle — what makes the feature operable, not just deployed. The artifact (`07-maintenance.md`) covers:

### 7.1 SLOs and SLIs
- Availability, latency p95/p99, error rate, freshness
- 28-day rolling window
- Burn-rate alerts (fast burn, slow burn)

### 7.2 Dashboards
- Four golden signals (latency, traffic, errors, saturation)
- Business KPI for the feature

### 7.3 Alerting
- P1 page / P2 ticket / P3 notify-only routing
- Alert noise budget (max pages / shift)

### 7.4 Runbook
- Per failure mode: symptom -> diagnosis -> remediation
- Each step copy-pasteable

### 7.5 On-call cheat sheet
- Where logs live, how to roll back, how to disable flag, escalation owner

### 7.6 Postmortem template
- Pre-seeded with feature context

### 7.7 Tech debt watchlist
- Items, owner, severity, review-by date

### 7.8 Capacity + cost trend
- What to watch, when to revisit

### 7.9 Feedback loop
- User feedback channels (support tickets, NPS, in-app surveys)
- Cadence for reviewing feedback against feature thesis
- Trigger for deprecation or major iteration

---

## How the elaborate scope shows up in your run

When the orchestrator runs the pipeline, the LLM produces an artifact for each stage that addresses the relevant boxes above. If a sub-activity doesn't apply to your feature (e.g., no UI -> no Figma; no LLM -> no GenAI threats), the artifact says "n/a" in that section and explains why, rather than skipping silently.

For single-stage runs (e.g., "just write the threat model"), only that stage's sub-activities are produced — you can compose them later by running other stages individually.

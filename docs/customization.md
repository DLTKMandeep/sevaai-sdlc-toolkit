# Customizing sevaai-sdlc for your stack

The skill pack ships with sensible defaults. Edit the SKILL.md files to match your team.

## Where to edit

Each `SKILL.md` has a **Project conventions** section near the bottom. That's the editable surface. Common changes:

### sdlc-requirements
- Story format (Given-When-Then vs. classic Acceptance Test syntax)
- Sizing convention (T-shirt sizes vs. story points)
- Definition of Ready bar

### sdlc-design
- Default stack (e.g., "Node 20 + TS + Postgres 16 + GKE")
- Auth pattern (OIDC, SAML, mTLS service-to-service)
- API style (REST + JSON / gRPC / GraphQL)
- ADR file location and naming

### sdlc-development
- Branch strategy (trunk-based, GitFlow, etc.)
- PR size budget
- Commit style (Conventional Commits, custom)
- Lint/format toolchain

### sdlc-testing
- Coverage thresholds
- Test framework (Jest / Vitest / Pytest / JUnit / Playwright)
- Fixture strategy
- e2e cadence

### sdlc-security
- Compliance frameworks (SOC 2, PCI, HIPAA, FedRAMP, GDPR)
- Default auth and crypto standards
- Secret store
- High-severity gate behavior

### sdlc-deployment
- Default rollout schedule
- No-deploy windows
- Approver list
- Feature-flag platform

### sdlc-maintenance
- Observability stack
- SLO defaults
- Page budget
- Postmortem norms

## A `.sevaai-sdlc.yaml` shortcut (optional)

If you'd rather override conventions in one place than edit each SKILL.md, drop a `.sevaai-sdlc.yaml` at your project root and the skills will read it on invocation.

```yaml
project_name: portal-api
stack: { lang: TypeScript, runtime: Node20, db: Postgres16, cd: ArgoCD, cloud: AWS }
auth: { user: OIDC-Auth0, service: mTLS-SPIFFE }
compliance: [SOC2, GDPR]
flag_provider: LaunchDarkly
observability: { apm: Datadog, paging: PagerDuty }
release: { window_no_deploy: ["Fri >=14:00", "Sat", "Sun"] }
```

The skills are written to read this when present — they fall back to their built-in defaults otherwise.

## Adding a stage

If your team has an extra stage (say "data review" between Design and Development), copy `skills/sdlc-design` to `skills/sdlc-data-review`, edit its frontmatter description so it triggers correctly, and add it to `plugin.json`'s `skills` array. Update the orchestrator's stage list in `skills/sdlc-orchestrator/SKILL.md`.

## Removing a stage

If your team's pipeline is shorter (no separate Maintenance stage, for example), remove the entry from `plugin.json` and `sdlc-orchestrator`. The other skills are independent and won't break.

## Forking for a new domain

Some teams need parallel pipelines for different domains (e.g., one for ML model changes, one for app changes). Copy the whole plugin folder, prefix the skill names (`mlsdlc-requirements`, etc.), and set distinct trigger phrases in their descriptions so they don't fight for the same prompt.

# Project guardrail — sevaai-sdlc dossier required before code

This file is auto-loaded by Claude Code into every session opened in this repo.
It applies to any AI assistant that reads CLAUDE.md (Claude Code, Cline, others).

## Rule: SDLC dossier comes before code

Before you write or modify ANY code in this repository:

1. Identify the feature slug. It usually matches the current git branch
   (e.g., branch `feature/add-saml-sso` -> slug `add-saml-sso`).
2. Check that `docs/sdlc/<slug>/` exists and contains all six stage artifacts:
   `01-requirements.md`, `02-design.md`, `03-development.md`, `04-testing.md`,
   `05-security.md`, `06-deployment.md`.
3. If the dossier is incomplete, **REFUSE to write or modify code**. Instead,
   offer to run the missing stages by invoking the `sdlc-orchestrator` skill
   or the individual `sdlc-<stage>` skills.
4. If `05-security.md` contains `BLOCKING: yes` and no `05-security-signoff.md`
   sits alongside it, **REFUSE to write or modify code**. Surface the
   unmitigated HIGH/CRITICAL findings and ask for either mitigation work or
   explicit security sign-off.
5. Once all checks pass, proceed. Cite the relevant dossier sections in your
   work — your PRs should reference the design's component IDs, the test
   plan's test IDs, etc.

## Exemptions

These changes do not require a full dossier:

- Documentation-only edits (`*.md`, `CHANGELOG`, `README` updates)
- Comment-only code edits
- Bot-driven dependency bumps (Dependabot, Renovate)
- Hot-fix branches prefixed `hotfix/` — but these still require a minimal
  dossier with at least `01-requirements.md` (impact + scope) and
  `05-security.md` (any auth or data changes). Document the abbreviation
  inside `00-index.md`.

If the user insists on coding without a dossier outside these exemptions,
explain that the CI gate will block the PR anyway, and offer the fastest
path: run `sdlc-orchestrator` now (~10 minutes for a small feature).

## Pointers

- Plugin source: https://github.com/DLTKMandeep/sevaai-sdlc-toolkit
- How to run a stage: see the plugin's `docs/run-by-stage.md`
- What each stage covers: see the plugin's `docs/sdlc-stages-detail.md`
- This guardrail's enforcement details: see the plugin's `docs/enforcement.md`

## Why this rule exists

The dossier is the structured first draft that makes design / security / SRE
review possible without huge ad-hoc meetings. Skipping it doesn't move faster
— it moves a different kind of work (debate, surprise, postmortem) into a
worse place. The toolkit makes the dossier cheap to produce; this rule makes
it the default.

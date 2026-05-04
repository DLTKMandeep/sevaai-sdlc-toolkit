# PR — {short title}

## Summary

What this PR does and why.

## SDLC dossier (mandatory)

This PR will be blocked by CI if the dossier is missing.

- [ ] `.sevaai-sdlc/<slug>/01-requirements.md` reviewed by PM
- [ ] `.sevaai-sdlc/<slug>/02-design.md` reviewed by tech lead
- [ ] `.sevaai-sdlc/<slug>/03-development.md` matches what's actually in this PR
- [ ] `.sevaai-sdlc/<slug>/04-testing.md` reflects the test changes in this PR
- [ ] `.sevaai-sdlc/<slug>/05-security.md` is `BLOCKING: no` (or has signed-off `05-security-signoff.md`)
- [ ] `.sevaai-sdlc/<slug>/06-deployment.md` reviewed by SRE / release lead

## Affected stages of the SDLC

- [ ] code (most PRs)
- [ ] DB migration (note expand-contract pattern)
- [ ] feature flag introduced / changed
- [ ] IaC change
- [ ] dashboards / alerts
- [ ] runbook updated

## Risk

- [ ] low (additive, behind flag, easy rollback)
- [ ] medium (touches existing code, has tests)
- [ ] high (auth / data / billing / migrations)

## Reviewers

- Tech lead: @
- Security (required if dossier flags PII/auth/regulated): @
- SRE (required for risk=high): @

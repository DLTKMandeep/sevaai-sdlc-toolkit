# Example feature input

Paste this into Claude Code or Cowork to try the pipeline:

> /sdlc Add SAML SSO with Okta and Azure AD as identity providers for the customer portal. Customers log in via their corporate IdP, get JIT-provisioned a tenant-scoped account, and have role mappings driven by IdP group claims. Must support SP-initiated and IdP-initiated flows. SOC 2 and a Fortune-500 deal depend on this. Target ship: end of next quarter.

What you'll get back:
- `.sevaai-sdlc/add-saml-sso/00-index.md` — dossier index
- `.sevaai-sdlc/add-saml-sso/01-requirements.md` — 5-7 user stories with acceptance criteria
- `.sevaai-sdlc/add-saml-sso/02-design.md` — auth flow diagrams, ADR on SP-init vs IdP-init, data model for IdP config + group mapping
- `.sevaai-sdlc/add-saml-sso/03-development.md` — 4-5 PR breakdown with file plan
- `.sevaai-sdlc/add-saml-sso/04-testing.md` — test pyramid + edge cases (replay, signature tampering, group claim missing)
- `.sevaai-sdlc/add-saml-sso/05-security.md` — STRIDE, OWASP, SOC 2 control mapping, pen-test plan
- `.sevaai-sdlc/add-saml-sso/06-deployment.md` — staged rollout, feature flag, rollback runbook
- `.sevaai-sdlc/add-saml-sso/07-maintenance.md` — auth-failure SLOs, on-call runbook, dashboards

## Single-stage examples

> "Just give me a threat model for that SAML SSO feature."  -> `sdlc-security` only

> "Write the runbook for the SAML SSO on-call rotation."  -> `sdlc-maintenance` only

> "Break the SAML SSO feature into 4 PRs."  -> `sdlc-development` only

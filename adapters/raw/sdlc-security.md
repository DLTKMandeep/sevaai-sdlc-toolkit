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
10. **Write artifact** to `docs/sdlc/{feature-slug}/05-security.md` using `templates/artifact.md`. Mark the artifact `BLOCKING` if any HIGH-severity threat is unmitigated.

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

# Security Review — {Feature Name}

**Feature slug:** `{feature-slug}`
**Date:** {YYYY-MM-DD}
**Status:** Draft  |  Blocking: yes/no

## 1. STRIDE per component

| Component | Spoofing | Tampering | Repudiation | Info disclosure | DoS | Elevation |
|---|---|---|---|---|---|---|
| API gateway | | | | | | |
| Service | | | | | | |
| Database | | | | | | |
| Queue | | | | | | |

## 2. OWASP Top 10 (2021) mapping

| ID | Risk | Applicable? | Mitigation |
|---|---|---|---|
| A01 | Broken Access Control | yes/no | RBAC + tenant scoping checks in middleware |
| A02 | Cryptographic Failures | | |
| A03 | Injection | | |
| A04 | Insecure Design | | |
| A05 | Security Misconfiguration | | |
| A06 | Vulnerable & Outdated Components | | |
| A07 | Identification & Authentication Failures | | |
| A08 | Software & Data Integrity Failures | | |
| A09 | Security Logging & Monitoring Failures | | |
| A10 | Server-Side Request Forgery | | |

## 3. Auth & authz

| API | Caller | Required role/scope | Tenancy | Audit event |
|---|---|---|---|---|
| `POST /v1/{resource}` | end-user | `resource:write` | tenant-scoped | `resource.created` |

## 4. Data classification

| Field | Classification | At rest | In transit | Retention | PII? |
|---|---|---|---|---|---|
| | | | | | |

## 5. Dependencies & supply chain

- New deps: `pkg-a@1.2`, `pkg-b@3.0`
- SBOM update required: yes
- License review: ...

## 6. Secrets

| Secret | Where stored | Rotation | Owner |
|---|---|---|---|
| | Vault path | quarterly | |

## 7. GenAI-specific threats (if applicable)

- Prompt injection: mitigated by ...
- Training data leakage: ...
- Output handling: ...
- Hallucination on safety-critical paths: ...

## 8. Compliance map

| Framework | Controls touched | Evidence required |
|---|---|---|
| SOC 2 | CC6.1, CC6.6, CC7.2 | access logs, change tickets |

## 9. Pen test plan

- Auth bypass attempts on the new endpoint
- Tenant isolation: try to read another tenant's data
- Replay attack: replay valid request after token rotation
- IDOR: increment / fuzz IDs

## 10. Sign-off

| Severity | Count | Mitigated | Accepted (with sign-off) |
|---|---|---|---|
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |

## 11. Hand-off

Next stage: **Deployment** (`sdlc-deployment`). Artifact: `06-deployment.md`.

# Deployment Plan — {Feature Name}

**Feature slug:** `{feature-slug}`
**Date:** {YYYY-MM-DD}
**Release window:** YYYY-MM-DD HH:MM TZ - HH:MM TZ
**Approver:** Eng lead + SRE on-call

## 1. Environment promotion

```
dev (auto on PR merge) -> staging (auto on main) -> canary 1% (manual gate) -> prod (auto on canary green)
```

## 2. Feature flag plan

- **Flag**: `feature.{name}`
- **Provider**: LaunchDarkly
- **Default**: `false` in prod
- **Rollout schedule**:
  - T+0h:    1% of users
  - T+4h:    10%
  - T+1d:    50%
  - T+3d:    100%
- **Kill switch**: flip to `false` globally if SLO violated for >5 min

## 3. Canary analysis

| SLI | Baseline | Threshold | Action |
|---|---|---|---|
| Error rate | 0.1% | +0.5pp | auto rollback |
| p95 latency | 250ms | +30% | auto rollback |
| Saturation | 60% | >85% | page on-call |
| Conversion | 14% | -2pp | hold rollout |

## 4. Database migrations

- Migration file: `2026_05_NN_add_{table}.sql`
- Forward: ALTER TABLE ADD COLUMN ... NULL DEFAULT NULL (additive, instant)
- Backward: code reads ignore the column if absent; schema can be reverted safely
- Backfill: deferred to async job after 100% rollout

## 5. Rollback runbook

1. Page on-call: `/pd trigger oncall release-team`
2. Disable flag: `lc launch-disable feature.{name} --env prod` (<=30s)
3. Verify error rate returns to baseline (<=2 min)
4. If still elevated: `kubectl rollout undo deployment/{service} -n prod`
5. Open postmortem ticket within 24h

## 6. Release notes

### User-facing
- New: ability to ...

### Internal
- New API endpoint: `POST /v1/{resource}`
- New DB column: `{table}.{column}`
- New env var required: `{NAME}` (default empty in prod, configured via vault)

### Deprecations
- None

## 7. Comms

| Audience | Channel | Timing |
|---|---|---|
| Customer support | #cx-releases | T-24h |
| Sales / CS | release-bulletin email | T-24h |
| Customers | status page entry | T+0 |
| Internal eng | #releases | T+0 |

## 8. Cost & capacity delta

- QPS expected: +5% peak
- Storage: +10GB / month at full rollout
- Inference cost: n/a (no LLM in feature)
- Action: capacity headroom is fine; no scaling change required

## 9. Hand-off

Next stage: **Maintenance** (`sdlc-maintenance`). Artifact: `07-maintenance.md`.

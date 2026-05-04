# Maintenance & Operations — {Feature Name}

**Feature slug:** `{feature-slug}`
**Date:** {YYYY-MM-DD}
**Owning team:** {team}
**On-call rotation:** {rotation name}

## 1. SLOs

| SLI | Definition | SLO (28d) | Error budget |
|---|---|---|---|
| Availability | successful_requests / total_requests | 99.9% | 0.1% (~43m / 28d) |
| Latency p95 | p95 time to respond | < 500ms | 5% of requests > 500ms |
| Error rate | 5xx / total | < 0.1% | 0.1% |
| Freshness | event-to-projection lag p95 | < 30s | n/a |

### Burn-rate alerts
- **Fast burn**: 14.4x burn over 1h -> P1 page
- **Slow burn**: 6x burn over 6h -> P2 ticket

## 2. Dashboard

Four-quadrant overview dashboard. Top row: business KPI for the feature + traffic. Bottom row: latency p95/p99 + error rate.

Saved as: `dashboards/{feature-slug}.json` (Grafana / Datadog).

## 3. Alerts

| Alert | Condition | Severity | Routing |
|---|---|---|---|
| Error rate spike | rate > 0.5% / 5m | P1 | PagerDuty -> oncall |
| Latency degradation | p95 > 800ms / 10m | P2 | PagerDuty ticket |
| Freshness lag | lag > 60s / 5m | P2 | Slack #ops-alerts |
| Capacity headroom | utilization > 85% / 15m | P3 | Slack notify-only |

## 4. Runbook

### Failure mode: error spike on `POST /v1/{resource}`
1. Open dashboard `dashboards/{feature-slug}.json`. Confirm error class (4xx auth? 5xx code? 5xx db?).
2. Check upstream dependency status page.
3. If db-related: `psql -c "SELECT * FROM pg_stat_activity WHERE state='active'"`.
4. If code-related: confirm recent deploy via `kubectl rollout history`. Roll back: `kubectl rollout undo deployment/{service}`.
5. If sustained: disable feature flag `feature.{name}` via LaunchDarkly.
6. Page DRI if not resolved in 15 min.

### Failure mode: freshness lag
1. ...

## 5. On-call cheat sheet

| Question | Answer |
|---|---|
| Where are logs? | Datadog index `service:{name} env:prod` |
| How do I roll back? | `kubectl rollout undo deployment/{service} -n prod` |
| How do I kill the feature? | LaunchDarkly: `feature.{name}` -> `false` |
| Who owns this? | {team}, ping `@{team}-oncall` |
| Where are the dashboards? | Datadog `Dashboards > {Feature Name}` |

## 6. Postmortem template

```
# Postmortem — {Feature Name} — {YYYY-MM-DD}

## Summary
## Impact (users affected, $ impact, SLO burn)
## Timeline
## Root cause
## What went well
## What went poorly
## Action items (each with owner + due date)
```

## 7. Tech-debt watchlist

| # | Item | Owner | Review by | Severity |
|---|---|---|---|---|
| 1 | Backfill job runs single-threaded | | | M |
| 2 | Hard-coded 30-day retention | | | L |

## 8. Capacity & cost trend

- **Watch**: storage growth rate, peak QPS at 14:00 UTC, model inference cost if applicable
- **Revisit**: monthly for 3 months, then quarterly

## 9. Sign-off

This artifact closes the SDLC for `{feature-slug}`. Feature dossier consolidated under `.sevaai-sdlc/{feature-slug}/`.

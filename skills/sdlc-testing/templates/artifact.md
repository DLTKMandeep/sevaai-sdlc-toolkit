# Test Plan — {Feature Name}

**Feature slug:** `{feature-slug}`
**Date:** {YYYY-MM-DD}
**Coverage target:** 80% line coverage on new code

## 1. Pyramid

| Level | Count | Lives in | Runs on |
|---|---|---|---|
| Unit | ~25 | `src/**/__tests__` | every commit |
| Integration | ~8 | `tests/integration` | every PR |
| End-to-end | ~3 | `tests/e2e` | every PR (changed flows), nightly full |
| Exploratory | 2 charters | manual | once before release |

## 2. Per-story coverage

### Story 1: {title}
- **Happy path**: Given X, when Y, then Z
- **Negative**: Given invalid X, when Y, then 400 with message Z
- **Edge cases**:
  - Empty input
  - Max-length input (255 / 4096 / 10MB)
  - Unicode / RTL / emoji
  - Concurrent writes (idempotency)
  - Partial failure (downstream timeout)
  - Locale / timezone edge (DST transition, leap year)

## 3. Unit test stubs

```ts
// src/services/{name}/__tests__/service.test.ts
describe('Service', () => {
  it('creates a resource with valid input');
  it('rejects empty input with ValidationError');
  it('is idempotent on retry with same idempotency key');
  it('emits a domain event on success');
});
```

## 4. Integration tests

- `POST /v1/{resource}` — full request through API to DB and back
- Worker consumes domain event and updates projection
- Migration applies cleanly to a copy of prod schema

## 5. E2E / UX tests

- User completes happy path on the new screen
- Screen is keyboard-navigable (a11y check)
- Error state shows correct message

## 6. Exploratory charters

- **Charter A**: explore the feature on slow 3G + screen reader for 30 min. Note any surprises.
- **Charter B**: try to break idempotency by sending parallel duplicate requests. Document outcome.

## 7. Test data strategy

- Synthetic fixtures via `factories/{resource}.factory.ts`
- For load: Tonic.ai-generated dataset of 10k rows
- For e2e: seeded Postgres snapshot per test run

## 8. Flaky test policy

- Triage SLA: within 2 business days of first flake report
- Quarantine after 2 flakes in 7 days; fix or delete within sprint

## 9. Hand-off

Next stage: **Security** (`sdlc-security`). Artifact: `05-security.md`.

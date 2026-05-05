# Development Plan — {Feature Name}

**Feature slug:** `{feature-slug}`
**Date:** {YYYY-MM-DD}

## 1. PR breakdown

| # | Title | Scope | Approx LOC | Behind flag? |
|---|---|---|---|---|
| 1 | feat: add {table/migration} | DB migration only | ~80 | No |
| 2 | feat: {service} core logic | Service module + unit tests | ~250 | Yes |
| 3 | feat: {api} endpoint | API handler + integration test | ~200 | Yes |
| 4 | feat: client integration | Frontend wiring | ~150 | Yes |
| 5 | chore: enable flag rollout | Flag config | ~30 | n/a |

## 2. Per-PR detail

### PR 1 — feat: add {table/migration}
- **Files added**: `migrations/2026_05_NN_add_{table}.sql`, `tests/test_migration.py`
- **Files modified**: `db/schema.py`
- **Reviewers**: 1 backend, 1 DBA
- **Risk**: low — additive migration, no backfill

### PR 2 — feat: {service} core logic
- **Files added**: `src/services/{name}/service.ts`, `src/services/{name}/types.ts`, `tests/services/{name}.test.ts`
- **Files modified**: `src/services/index.ts`
- **Notes**: pure module, no I/O at boundary; mock the repository in tests

### (continue for each PR...)

## 3. Naming & style

- File names: `kebab-case.ts`
- Class names: `PascalCase`
- Functions: `camelCase`
- Test files alongside module files, suffix `.test.ts`
- Match existing import ordering (run `eslint --fix` before commit)

## 4. Self-review checklist

- [ ] Each PR builds and passes lint independently
- [ ] No commented-out code or `console.log`
- [ ] All new functions have JSDoc / docstrings
- [ ] Migrations are reversible (down + up)
- [ ] Public interfaces have type definitions
- [ ] No secrets in code or fixtures
- [ ] Feature flag default is OFF for production
- [ ] CHANGELOG.md updated

## 5. Coding-agent prompt

Paste this into Cursor / Claude Code / Copilot Workspace to start the implementation:

> "Implement PR 2 from `docs/sdlc/{feature-slug}/03-development.md`. The design is in `02-design.md`. Create the listed files, follow the existing conventions in `src/services/`, and stop before writing tests — tests come from the testing stage."

## 6. Hand-off

Next stage: **Testing** (`sdlc-testing`). Artifact: `04-testing.md`.

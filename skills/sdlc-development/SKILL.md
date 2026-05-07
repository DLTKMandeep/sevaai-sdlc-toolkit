---
name: sdlc-development
description: Use this skill when the user wants an implementation plan, file-by-file build plan, code skeleton, or coding conventions for a feature whose design is already done. Triggers include "implementation plan", "build plan", "file plan", "scaffold", "skeleton", "code structure", "how should I implement", "coding conventions", "PR plan", "split into PRs", "review checklist", "developer brief", or stage-3 SDLC work. This skill produces the brief a developer hands to Cursor / Copilot / Claude Code, NOT the actual code commits. Do NOT use for design (use sdlc-design) or for writing tests (use sdlc-testing).
license: MIT
---

# SDLC Stage 3 — Development Plan

Produce the developer brief: a file-by-file implementation plan, naming and style conventions, a PR breakdown, and a self-review checklist. The actual coding happens in an IDE assistant — this skill produces the plan that makes that assistant fast.

## Sub-activities covered

The artifact must address these in `03-development.md`:

**PR breakdown** — 3-5 PRs of <=400 LOC each, Conventional Commit titles, per-PR file plan (added / modified / deleted), behind-flag flag for user-facing PRs, reviewer suggestions.

**Coding standards** — naming conventions matched to existing codebase, lint / format toolchain (eslint / ruff / gofmt etc.), import ordering, comment / docstring expectations, forbidden patterns.

**Scalable code patterns** — pure functions where possible, dependency injection at boundaries, pagination / batching / idempotency keys for high-volume paths.

**Version control conventions** — branch strategy (trunk-based default), commit style (Conventional Commits), PR size budget.

**Code review checklist** — self-review steps before requesting review, what reviewers should look for in this feature, coding-agent prompt the developer can paste into Cursor / Copilot / Claude Code.

If a sub-activity doesn't apply, write "n/a" with a one-line reason.

## When to invoke

- After `sdlc-design` has produced `02-design.md`
- User wants a file plan, scaffold, or PR breakdown
- Orchestrator calls this skill as stage 3

## Inputs

1. **`02b-mapping.md`** — the Functional-to-Technical traceability matrix (PRIMARY input)
2. `02-design.md` — for component IDs and ADR refs
3. `01-requirements.md` — for the original story text
4. Existing source layout — sample with Glob `src/**/*` and Read a few representative files to learn conventions
5. Existing lint / format config (`.eslintrc`, `pyproject.toml`, `.prettierrc`) — read these so your plan matches
6. The repo via GitHub MCP — to confirm file existence and read recent commit style

If `02b-mapping.md` doesn't exist, ask the user to run `sdlc-mapping` first. The development plan without a mapping is a guess; with a mapping it's a one-to-one transformation.

## What to do

1. **Brownfield check.** If `03-development.md` already exists OR if the GitHub Projects v2 board already has Issues for this feature, ask the user: "Existing dev plan / backlog found. Augment, replace, or skip?" Default to augment.
2. **Match the codebase's style.** If files use snake_case, don't suggest camelCase. If imports are sorted by isort, your plan must respect that. Read recent commits via GitHub MCP to learn the team's commit-message conventions.
3. **Transform mapping → PR plan.** Each row in `02b-mapping.md` becomes 1 or more PRs. Default to 3-5 PRs of <=400 lines diff each. Order them so each PR is independently reviewable and shippable behind a flag. Respect the dependency graph from §3 of the mapping doc.
4. **Per-PR breakdown.** For each PR:
   - Title (`feat:` / `fix:` / `chore:` conventional commits)
   - Files added / modified / deleted (drawn directly from mapping rows)
   - Test files alongside (defer test content to `sdlc-testing`)
   - Migration steps if data model changes
   - Feature flag wrapping if user-facing
   - **Linked Req IDs** — every PR cites the mapping rows it covers
5. **Author a self-review checklist** the developer runs before requesting human review.
6. **Hand-off to coding tools.** Produce a one-paragraph "Cursor/Claude Code prompt" the developer can paste to start the build.
7. **Auto-create the GitHub Projects v2 backlog (see next section).**
8. **Write artifact** to `docs/sdlc/{feature-slug}/03-development.md` using `templates/artifact.md`.

## Auto-creating the GitHub Projects v2 backlog

If `trackers.github.enabled: true` AND `trackers.github.project_v2_number > 0` in `.sevaai-sdlc.yaml`, this skill creates the backlog automatically as part of running. Procedure:

1. **Confirm before pushing.** Ask: "Create N GitHub Issues + add to Project v2 #{project_v2_number}? (Y/n)" where N = number of mapping rows + cross-cutting rows.
2. **For each row in `02b-mapping.md` §2 (and §4 cross-cutting):**
   - Create a GitHub Issue with:
     - **title:** `[{feature-slug}] {Story title}` (e.g., `[churn-slack-alerts] Tenant admin connects Slack workspace`)
     - **body:** quoted user story + Given-When-Then acceptance criteria from `01-requirements.md`, followed by the row's technical detail (Components, NEW/EDIT files, Migrations, Config), followed by ADR refs as links to the standalone ADR files
     - **labels:** `story` (or `infra`/`docs`/`comms` for cross-cutting), plus the feature slug, plus risk label (`risk-h`/`risk-m`/`risk-l`), plus compliance flags from §7 of `01-requirements.md`
     - **milestone:** the feature slug (create if missing)
3. **Set up dependency links.** For rows with `Deps`, add a comment on the dependent Issue: `Blocked by #N` referencing the dependency Issue numbers.
4. **Add every Issue to the Project v2 board** via the GraphQL `addProjectV2ItemById` mutation. Set the `Status` field to `Backlog`. Set the `Story Points` field to the SP value. Set `Risk` and `Story Type` fields if they exist.
5. **Print the umbrella roll-up** in chat:
   ```
   Created backlog for {feature-slug}:
   - Issues: #N1, #N2, ..., #NK (K total)
   - Project v2: https://github.com/users/{owner}/projects/{N}
   - Total story points: X
   - Risk-H: K, Risk-M: J, Risk-L: I
   - Dependency chains: A→B→C, D→E
   ```
6. **Append to `03-development.md`** a new section `## Tracker links` with the issue numbers + project URL, so subsequent stages can reference them.

If the GitHub MCP is not connected or `project_v2_number == 0`, skip steps 1-5; still write the markdown artifact, and tell the user how to wire up GitHub Projects v2 (point to `docs/mcp-user-guide.md`).

## Real-world products this skill complements

- **Cursor / Claude Code / Windsurf / Copilot Workspace** — the coding agents that consume this brief
- **GitHub Copilot / Tabnine / Codeium / Cody** — inline assistants
- **CodeRabbit / Greptile / Graphite Reviewer / Korbit** — AI code review on the resulting PR
- **Aider** — terminal-based agent if your team prefers CLI
- **Conventional Commits + commitlint** — for commit message standards

## Project conventions (edit me per project)

- **Branch strategy**: trunk-based with short-lived feature branches.
- **PR size**: target <=400 lines net diff.
- **Commit style**: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`).
- **Lint/format**: ruff + black for Python, eslint + prettier for TS, gofmt for Go.
- **Pre-commit hooks**: must pass before push.
- **Feature flags**: required for any user-facing change behind a flag system (LaunchDarkly, Unleash, internal).

## Hand-off

The orchestrator should invoke `sdlc-testing` with `03-development.md` as input.

If `sdlc-sprint` (Stage 3b — Scrum Master mode) is installed, the user can run `/sprint-plan` next to group the just-created Issues into 2-week sprints. Mention this option in the chat output.

## Template

See `templates/artifact.md`.

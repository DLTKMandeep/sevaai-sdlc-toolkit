# Rollout playbook — sevaai-sdlc enforcement

For engineering managers and platform teams introducing the dossier-required policy across teams.

## The change you're making

Before: anyone can open a PR and merge it.
After: every PR to `main` requires a complete `.sevaai-sdlc/<slug>/` dossier; the security stage must be non-BLOCKING; CI fails the PR if either is missing.

## Phased rollout (recommended)

### Phase 0 — Baseline (1 week)

Don't gate anything yet. Just install the **AI guardrail** (`CLAUDE.md`) and the **pre-commit hook**. Developers using Claude / Cursor / Cline get nudged toward the dossier; nothing is blocked. Goal: people see what the dossier is for without process anxiety.

Track: did anyone produce a dossier voluntarily? Did the prompts feel useful or annoying?

### Phase 1 — Soft launch (2-3 weeks)

Add the **CI workflow** (`require-sdlc-dossier.yml`) but **do NOT** mark it required in branch protection yet. The check appears on every PR, fails when missing, but doesn't block merge. Developers see the red X and the error message and learn what's expected. Some PRs go through despite a failed check; that's fine for now.

Track: % of PRs with a green dossier check. Aim for >70% before going hard.

### Phase 2 — Hard gate (ongoing)

Mark `check-dossier` **required** in branch protection. Now PRs cannot merge without a dossier. Communicate the change at least 1 sprint in advance.

Track: time-to-merge (it should not increase materially if Phase 1 went well), and dossier completeness (sample 5 random merged PRs/week and read their dossiers).

### Phase 3 — Routing (after Phase 2 stable)

Activate `CODEOWNERS` so design and security artifacts auto-route to the right reviewers. This shifts review load off generalists and onto the people who should actually be looking at threat models.

Track: review SLA for design and security artifacts. Should be <2 business days.

## Common objections and how to handle them

**"This will slow us down."**
Soft data point: the toolkit produces a first-draft dossier in <15 minutes for a small feature. Reviewing it adds maybe 30 minutes of human time. The slowdown is real; the alternative — surprise security findings, design rework after PR review, ops surprises post-launch — is much more expensive.

**"I'm just changing one line."**
That's why the workflow exempts `docs/*`, `dependabot/*`, and `renovate/*`. Add more exemptions if you have legitimate one-line categories — but keep the list short. Most "one line" changes turn out to be larger than expected.

**"What if the AI gets the dossier wrong?"**
The dossier is a first draft for humans to review — same as a first PR draft. The toolkit doesn't replace review; it gives reviewers a structured starting point so their feedback can be on the substance, not on filling in blanks. Wrong drafts are easy to fix; missing drafts are catastrophic.

**"My PR is for a hotfix at 2am."**
The CI workflow exempts `hotfix/*` from the dossier check. The CLAUDE.md still asks for an abbreviated dossier (requirements + security only) — that's reasonable even at 2am, since you want to know what you broke and whether the fix introduces new risk. Document the abbreviation in `00-index.md` and follow up post-mortem.

**"We use a different branching model."**
Edit the slug-derivation section of `require-sdlc-dossier.yml` to match your branch naming. The pattern is intentionally simple bash so you can adapt it.

## Metrics to watch

| Metric | Target | Why |
|---|---|---|
| % PRs with green `check-dossier` | >95% by Phase 2 end | Adoption signal |
| Median time from feature kickoff to first dossier | <1 day | If higher, the SDLC tools aren't being run early enough |
| Median dossier review cycle | <2 days | Routing through CODEOWNERS should make this fast |
| Security findings discovered POST-merge | should drop | The whole point |
| Production incidents caused by feature ship | should drop | Trailing indicator; expect 1-2 quarter lag |

## When to relax the rule

Don't. Once you've trained the muscle, removing the gate generally regresses fast. If the gate becomes a bottleneck, look at *why* — usually it's that the dossier is being produced too late in the cycle, not that the dossier is wrong.

## When NOT to roll this out

- Pre-Series-A startup with <5 engineers — too much process for the stage.
- Teams already drowning in process — fix the existing process before adding more.
- Teams that don't use AI assistants for coding at all — the toolkit's value is much lower without an AI to produce drafts.

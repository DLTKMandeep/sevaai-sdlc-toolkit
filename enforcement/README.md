# Enforcement bundle

Drop these templates into your repo to make the **sevaai-sdlc dossier mandatory** before any code merges.

There are three enforcement layers, from hardest to softest:

| Layer | What it does | Can it be bypassed? |
|---|---|---|
| **CI gate** (`.github/workflows/require-sdlc-dossier.yml`) | Fails the PR check if the dossier is missing or security is BLOCKING. With branch protection set to "require this status check," merge is blocked. | Only by an admin disabling branch protection. |
| **AI guardrail** (`CLAUDE.md`) | Tells Claude / Cline / any CLAUDE.md-aware assistant to refuse code changes until the dossier exists. | Yes — assistants are persuasive, not blocking. The CI gate is the real enforcer. |
| **Local nudge** (`.githooks/pre-commit`) | Warns the developer at commit time if the dossier is missing. | Yes (`--no-verify`). Just a heads-up. |

You'll typically want all three: the CI gate as your real teeth, the CLAUDE.md to keep AI assistants honest, and the pre-commit hook to surface the rule early.

## What's in here

```
enforcement/
├── README.md                              # this file
├── setup-enforcement.sh                   # one-shot installer (copies templates into your repo)
├── docs.md                                # rollout playbook for engineering leadership
└── templates/
    ├── CLAUDE.md                          # AI-assistant guardrail
    ├── .githooks/pre-commit                # local warning hook
    └── .github/
        ├── CODEOWNERS                      # design / security / SRE review routing
        ├── PULL_REQUEST_TEMPLATE.md        # PR checklist with SDLC items
        └── workflows/
            └── require-sdlc-dossier.yml    # CI gate
```

## Install in 30 seconds

From your project root:

```bash
# Replace ~/path/to/sevaai-sdlc-toolkit with your local clone path.
~/path/to/sevaai-sdlc-toolkit/enforcement/setup-enforcement.sh
```

That copies the templates into the right places, makes the pre-commit hook executable, and prints next-step instructions. Review the diff before committing.

## Manual install

If you'd rather copy by hand:

```bash
PROJECT=~/path/to/your-project
TOOLKIT=~/path/to/sevaai-sdlc-toolkit

cp -R "$TOOLKIT/enforcement/templates/.github"   "$PROJECT/"
cp    "$TOOLKIT/enforcement/templates/CLAUDE.md" "$PROJECT/"
cp -R "$TOOLKIT/enforcement/templates/.githooks" "$PROJECT/"

cd "$PROJECT"
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

## After install — wire up branch protection

The CI workflow is created but not yet **required**. To make it gate merges:

1. GitHub: **Settings -> Branches -> Branch protection rules -> Add rule** for `main` (and `develop` if you use it).
2. Check **Require status checks to pass before merging**.
3. Search for `check-dossier` and select it.
4. Save.

Now PRs without a dossier physically cannot merge.

## Edit before committing

Open each template and substitute placeholders for your team:

- `CODEOWNERS` — replace `@your-org/architecture-review` etc. with your real GitHub team names.
- `CLAUDE.md` — adjust the exemption list to match your team's policy on hotfixes / docs.
- `require-sdlc-dossier.yml` — adjust the branch list (`main`, `develop`) and the branch-prefix slug derivation to match your branching strategy.

## What developers see

- **At commit time** (with the hook): a yellow warning noting the dossier is missing.
- **At PR open**: the CI check `check-dossier` runs and either passes or fails.
- **At merge attempt**: GitHub blocks merge if `check-dossier` failed and branch protection requires it.
- **In their AI assistant**: Claude (or any tool reading CLAUDE.md) refuses to write code, prompts to run `/sdlc` first.

## Exemptions

The bundle exempts these branch patterns from the CI check:
- `docs/*` — docs-only edits
- `dependabot/*` and `renovate/*` — bot-driven dep bumps

Add more exemptions in `require-sdlc-dossier.yml` if your team has them. Hotfixes need an abbreviated dossier — see the rule in CLAUDE.md.

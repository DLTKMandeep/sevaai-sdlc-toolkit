#!/usr/bin/env bash
# enforcement/setup-enforcement.sh — install enforcement templates into a target repo.
#
# Usage:
#   cd ~/path/to/your-project
#   ~/path/to/sevaai-sdlc-toolkit/enforcement/setup-enforcement.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$SCRIPT_DIR/templates"
TARGET="$(pwd)"

if [[ ! -d "$TARGET/.git" ]]; then
  echo "error: $TARGET is not a git repo. cd into your project first." >&2
  exit 1
fi

confirm() {
  read -r -p "$1 [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

echo "Installing sevaai-sdlc enforcement templates into: $TARGET"
echo

# CI workflow + PR template + CODEOWNERS
mkdir -p "$TARGET/.github/workflows"
for f in "require-sdlc-dossier.yml"; do
  src="$TEMPLATES/.github/workflows/$f"
  dest="$TARGET/.github/workflows/$f"
  if [[ -f "$dest" ]]; then
    confirm "  $dest exists — overwrite?" && cp "$src" "$dest" && echo "    overwritten" || echo "    skipped"
  else
    cp "$src" "$dest" && echo "  + $dest"
  fi
done

for f in "CODEOWNERS" "PULL_REQUEST_TEMPLATE.md"; do
  src="$TEMPLATES/.github/$f"
  dest="$TARGET/.github/$f"
  if [[ -f "$dest" ]]; then
    confirm "  $dest exists — overwrite?" && cp "$src" "$dest" && echo "    overwritten" || echo "    skipped"
  else
    cp "$src" "$dest" && echo "  + $dest"
  fi
done

# CLAUDE.md
if [[ -f "$TARGET/CLAUDE.md" ]]; then
  confirm "  $TARGET/CLAUDE.md exists — append guardrail section?" && {
    echo "" >> "$TARGET/CLAUDE.md"
    cat "$TEMPLATES/CLAUDE.md" >> "$TARGET/CLAUDE.md"
    echo "    appended"
  } || echo "    skipped"
else
  cp "$TEMPLATES/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  + $TARGET/CLAUDE.md"
fi

# pre-commit hook
mkdir -p "$TARGET/.githooks"
cp "$TEMPLATES/.githooks/pre-commit" "$TARGET/.githooks/pre-commit"
chmod +x "$TARGET/.githooks/pre-commit"
echo "  + $TARGET/.githooks/pre-commit"

# Wire git to use it
( cd "$TARGET" && git config core.hooksPath .githooks )
echo "  ✓ git config core.hooksPath = .githooks"

echo
echo "Done. Next steps:"
echo "  1. Edit .github/CODEOWNERS — replace @your-org/* with your real teams."
echo "  2. Review CLAUDE.md and adjust exemptions to your policy."
echo "  3. Commit: git add .github CLAUDE.md .githooks && git commit -m 'chore: enable sevaai-sdlc enforcement'"
echo "  4. Open a PR; the new CI check will appear (not yet required)."
echo "  5. After 1-2 sprints of soft-launch, mark 'check-dossier' as REQUIRED in"
echo "     Settings -> Branches -> Branch protection."
echo
echo "Rollout playbook: $SCRIPT_DIR/docs.md"

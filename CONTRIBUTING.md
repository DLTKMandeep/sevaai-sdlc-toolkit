# Contributing to sevaai-sdlc

Thanks for your interest. The skill pack is intentionally simple — markdown bundles, a JSON manifest, no runtime to host. Most contributions are small, scoped edits to a single `SKILL.md` or template.

## Local dev loop

1. Clone the repo.
2. Symlink into your Claude config so you can iterate without reinstalling:
   ```bash
   ln -s "$(pwd)/skills"/* ~/.claude/skills/
   ln -s "$(pwd)/commands/sdlc.md" ~/.claude/commands/sdlc.md
   ```
3. Open a project and run `/sdlc <a feature description>` to exercise the orchestrator end-to-end, or paste a single-stage trigger phrase to exercise one skill.
4. Inspect the generated dossier under `.sevaai-sdlc/{feature-slug}/` and iterate on the SKILL.md instructions or templates.

## What good contributions look like

- **Sharper trigger descriptions.** If a skill is misfiring (triggering when it shouldn't, or missing when it should), tighten the `description:` in its frontmatter. Add the specific phrases users said when they meant to invoke it.
- **More realistic templates.** If a stage's template is producing weak or generic artifacts, edit `templates/artifact.md`. Move toward concrete examples over abstract placeholders.
- **Domain pre-sets.** If you've tuned the skills for a specific stack (Java + Spring + AWS, say), open a PR adding a `presets/` folder so others can copy your conventions.
- **New stages.** If your team has a stage that isn't covered (data review, ML model review, accessibility review), add a new skill folder, add it to `plugin.json`, and update the orchestrator's stage list.

## What doesn't fit

- Heavy runtime code. The point of the plugin is that it's just markdown — keep helper scripts small and optional.
- Vendor-specific lock-in. Skills should *complement* commercial tools (Snyk, Datadog, etc.) by name, not depend on them.
- Anything that requires the user to obtain a paid API key just to use a stage. Fail gracefully without external services.

## PR conventions

- Conventional Commits in commit messages (`feat:`, `fix:`, `chore:`, `docs:`).
- Update `CHANGELOG.md` under `[Unreleased]` for any user-visible change.
- The validate workflow must pass — it checks plugin.json validity, frontmatter completeness, and basic markdown lint.

## Releasing

Maintainers cut a release by:

1. Move `[Unreleased]` items in `CHANGELOG.md` under a new `## X.Y.Z — YYYY-MM-DD` heading.
2. Bump `version` in `plugin.json`.
3. `git tag vX.Y.Z && git push --tags`.
4. Create a GitHub Release using the tag, with the changelog section as the description.

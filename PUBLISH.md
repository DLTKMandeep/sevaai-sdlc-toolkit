# Publishing to GitHub

Local repo is initialized and tagged. Three steps to ship:

## 1. Create the empty GitHub repo

Go to https://github.com/new

- **Owner**: your account or org
- **Repository name**: `sevaai-sdlc-toolkit` (or whatever you prefer)
- **Description**: "Automated AI-powered SDLC. Drop into Claude Code or Cowork."
- **Visibility**: Public
- **DO NOT** initialize with README, .gitignore, or license (we already have them)

Click **Create repository**.

## 2. Push from your machine

GitHub will show you a "push an existing repository" snippet. Use this instead (it pushes the tag too):

```bash
cd ~/claude_cowork/sevaai-sdlc-toolkit

# Replace DLTKMandeep with your GitHub username or org
git remote add origin git@github.com:DLTKMandeep/sevaai-sdlc-toolkit.git

# Push the main branch
git push -u origin main

# Push the v0.1.0 tag
git push origin v0.1.0
```

If you prefer HTTPS over SSH:

```bash
git remote add origin https://github.com/DLTKMandeep/sevaai-sdlc-toolkit.git
git push -u origin main
git push origin v0.1.0
```

## 3. Cut a GitHub Release

After the tag is pushed:

```bash
# Using gh CLI (recommended)
gh release create v0.1.0 \
  --title "v0.1.0 — initial release" \
  --notes-from-tag

# Or do it in the web UI:
# https://github.com/DLTKMandeep/sevaai-sdlc-toolkit/releases/new?tag=v0.1.0
```

## 4. Tell users how to install

Once it's live, users install with:

```bash
/plugin install DLTKMandeep/sevaai-sdlc-toolkit
```

Or pin a version:

```bash
/plugin install DLTKMandeep/sevaai-sdlc-toolkit@v0.1.0
```

## 5. After-push checklist

- [ ] Update the badge URLs in `README.md` (search for `DLTKMandeep` and replace with your actual handle/org)
- [ ] Update `plugin.json` `homepage` and `author.url` fields
- [ ] Verify the `Validate plugin` GitHub Action ran green on the first push
- [ ] Test the install flow yourself: `/plugin install <handle>/sevaai-sdlc-toolkit` in a fresh Claude Code session
- [ ] Open one demo issue using the bug template so future contributors see what good issues look like

## Future releases

When you're ready to ship v0.2.0:

```bash
# 1. Update CHANGELOG.md and plugin.json version
# 2. Commit those changes
git commit -am "chore: bump version to 0.2.0"

# 3. Tag and push
git tag -a v0.2.0 -m "v0.2.0 — what changed"
git push origin main
git push origin v0.2.0

# 4. Cut the release
gh release create v0.2.0 --notes-from-tag
```

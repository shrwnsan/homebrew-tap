# AGENTS.MD

Homebrew tap repository guidelines and conventions.

## Project Context

- **Repository**: shrwnsan/homebrew-tap
- **Purpose**: Personal Homebrew tap for publishing custom formulae
- **Primary formula**: brew-change

## Homebrew Tap Conventions

### Commit Messages

This repository uses **Conventional Commits** format (not official Homebrew-core format).

**Formula version bumps:**
```
fix(formula-name): bump to version X.Y.Z

Brief description of what changed if applicable

Co-Authored-By: <Model> <attribution>
```

**Examples:**
- Bug fix release: `fix(brew-change): bump to version 1.5.5`
- Routine update: `chore(brew-change): bump to version 1.5.4`

**When to use `fix` vs `chore`:**
- `fix`: Upstream release includes bug fixes
- `chore`: Routine version bump, feature releases, or unclear changes

**Commit body guidance:**
- Keep it lightweight — one sentence max
- Highlight notable changes, but don't duplicate upstream changelog
- Reference upstream release with `gh release view` or GitHub releases page when unsure
- Use body when the change isn't obvious from version alone

### Reference: Official Homebrew-core Format

For comparison, official `Homebrew/homebrew-core` uses a simpler format:

**Simple version updates:**
```
<FORMULA_NAME> <NEW_VERSION>
```
Example: `source-highlight 3.1.8`

**Bug fixes:**
```
<FORMULA_NAME>: fix <description>
```
Example: `foobar: fix flibble matrix`

### Rationale

Conventional Commits over Homebrew-core format because:
- **Personal tap** — no upstream tooling compatibility needed
- **Workflow consistency** — matches other personal repos
- **Semantic clarity** — distinguishes `fix`/`chore`/`feat`

*Note: Use Homebrew-core format (`formula 1.2.3`) if contributing upstream*

## Formula Updates

### Automated Updates (brew-change)

The `brew-change` formula is automatically updated when releases are published upstream. The `scripts/release.sh` in `shrwnsan/brew-change` handles:

- Version bump detection
- SHA256 computation
- Formula file updates
- Conventional commit creation (`fix` vs `chore` detection)

No manual intervention required for `brew-change` updates.

### Manual Updates (Other Formulae)

For formulae without automated upstream integration:

- [ ] Verify new version exists upstream
- [ ] Update `url` to new version tarball
- [ ] Update `sha256` checksum (use `sha256sum` or `shasum -a 256`)
- [ ] Check for any formula-specific changes needed
- [ ] Fetch release notes for commit body context
- [ ] Commit with appropriate message
- [ ] Push to remote

### Fetching Release Notes

Before committing, fetch upstream release notes to craft a meaningful commit body:

```bash
# Using GitHub CLI
gh release view --repo owner/repo vX.Y.Z --json name,body

# For full changelog context, pipe to less
gh release view --repo owner/repo vX.Y.Z | less
```

Summarize notable changes in 1-2 lines for the commit body when the version alone doesn't tell the full story.

### Getting SHA256
```bash
# Download and checksum
curl -L https://github.com/user/repo/archive/refs/tags/vX.Y.Z.tar.gz | sha256sum
```

## Resources

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [How to Open a Homebrew Pull Request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request)
- [Homebrew-core Maintainer Guide](https://docs.brew.sh/Homebrew-homebrew-core-Maintainer-Guide)

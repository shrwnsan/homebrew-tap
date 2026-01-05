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

### Checklist
- [ ] Verify new version exists upstream
- [ ] Update `url` to new version tarball
- [ ] Update `sha256` checksum (use `sha256sum` or `shasum -a 256`)
- [ ] Check for any formula-specific changes needed
- [ ] Commit with appropriate message
- [ ] Push to remote

### Getting SHA256
```bash
# Download and checksum
curl -L https://github.com/user/repo/archive/refs/tags/vX.Y.Z.tar.gz | sha256sum
```

## Resources

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [How to Open a Homebrew Pull Request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request)
- [Homebrew-core Maintainer Guide](https://docs.brew.sh/Homebrew-homebrew-core-Maintainer-Guide)

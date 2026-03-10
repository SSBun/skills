---
name: release_new_version
description: Guide agents through releasing a new version of a project - update version, commit changes, create tags, and optionally publish to package managers.
user-invokable: true
args:
  - name: version
    description: The version to release (e.g., 1.2.3). If not provided, will prompt for version.
    required: false
  - name: skip_push
    description: If true, skip pushing to remote
    required: false
---

Guide developers through releasing a new version of the project correctly.

## Check Git Status

First, check the current git status to see if there are uncommitted changes:

```bash
git status
```

If there are uncommitted changes, ask the user what to do:
- **Commit them**: Proceed with versioning
- **Stash them**: Run `git stash`, complete the release, then `git stash pop`
- **Discard them**: Run `git checkout -- .` (only if user explicitly confirms)

Wait for user input before proceeding.

## Determine Project Type

Identify what type of project this is:

### Xcode Project

For iOS/macOS projects, update the version in:
- `*.xcodeproj/project.pbxproj` - Look for `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`
- Or use `agvtool` commands:
  ```bash
  # Set version
  agvtool new-marketing-version "1.2.3"
  # Set build number
  agvtool new-version -all "123"
  ```

### Package Managers

For projects using:
- **npm/Node.js**: Check `package.json` for `version` field
- **Python/pip**: Check `pyproject.toml` or `__version__` in `__init__.py`
- **Ruby/Gem**: Check `*.gemspec` for `version`
- **Rust/Cargo**: Check `Cargo.toml` for `version`
- **Go**: Check `version` variable in main code or goreleaser config
- **Homebrew**: Check the formula in the tap repository

### Scripts/Config Files

For scripts or configuration-based projects:
- Check for `VERSION` file
- Check for version strings in `setup.py`, `setup.cfg`, `conf.py`, etc.
- Check for version in README or CHANGELOG

### Other Projects

For other project types:
- Look for any version-related files or variables
- Check `CHANGELOG.md`, `CHANGELOG`, `HISTORY.md` for version patterns
- Check for version in `Makefile` or build scripts

Update the version appropriately based on project type.

## Commit Version Changes

After updating the version:

1. **Stage the changes**:
   ```bash
   git add -A
   ```

2. **Create a commit** with a descriptive message:
   ```bash
   git commit -m "Bump version to X.Y.Z"
   ```

## Create Version Tag

Before creating the tag, ask the user to confirm the version number. Show them:
- Current version (if detectable)
- Proposed new version

Use `AskUserQuestion` to confirm:
- Version number to use
- Whether to create a "v" prefix (e.g., `v1.2.3` vs `1.2.3`)

Once confirmed, create the tag:

```bash
git tag -a v1.2.3 -m "Release v1.2.3"
```

Or without "v" prefix:
```bash
git tag -a 1.2.3 -m "Release 1.2.3"
```

## Push to Remote

Ask the user whether to push the new version to remote:

- **Yes**: Push both the commit and tag:
  ```bash
  git push
  git push origin v1.2.3
  ```

- **No**: Don't push (user may want to review first)

Wait for user input before proceeding to publishing.

## Check Package Manager Publishing

After pushing (or if user opts not to push), check if the project should be published to package managers:

### npm (Node.js)
- Check if `package.json` has publish config
- Ask if user wants to publish to npm:
  ```bash
  npm publish
  ```

### PyPI (Python)
- Check if project has `pyproject.toml` or `setup.py`
- Ask if user wants to publish to PyPI:
  ```bash
  python -m build
  twine upload dist/*
  ```

### Homebrew
- Check if there's a Homebrew formula in the project
- If this is a Homebrew tap, ask about updating the formula
- Provide instructions for submitting to Homebrew core if applicable

### CocoaPods
- Check if `*.podspec` exists
- Ask if user wants to publish to CocoaPods:
  ```bash
  pod trunk push *.podspec
  ```

### Other Package Managers
- Check for other publishing configurations
- Ask user about any additional publishing needs

## Generate Release Summary

Once all tasks are complete, output a summary with:

### New Version Summary

| Item | Value |
|------|-------|
| **Version** | X.Y.Z |
| **Git Tag** | vX.Y.Z |
| **Commit** | [hash] |
| **Remote** | Pushed / Not pushed |
| **Published to** | npm / PyPI / CocoaPods / None |

### New Version Release Log

Provide a concise changelog for this release:
- List the key changes since last version
- Include bug fixes, new features, breaking changes
- Reference relevant commit messages if available

### Package Links (if published)

Provide relevant links:
- npm: `https://www.npmjs.com/package/[name]`
- PyPI: `https://pypi.org/project/[name]/`
- CocoaPods: `https://cocoapods.org/pods/[name]`
- GitHub Releases: `https://github.com/[owner]/[repo]/releases/tag/vX.Y.Z`

**NEVER**:
- Automatically push without user confirmation
- Publish to package managers without explicit user approval
- Assume version number without asking
- Skip checking for uncommitted changes

Remember: You're guiding a careful release process. Confirm each major step with the user before proceeding.

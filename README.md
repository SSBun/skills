# Personal Skills

A collection of custom Claude Code skills for enhancing development workflow.

## Overview

This repository stores custom skills that can be used with Claude Code to assist with various development tasks. Each skill is designed to provide specialized guidance for specific workflows.

## Skills

### release_new_version

Guide agents through releasing a new version of a project.

**Features:**
- Check git status and handle uncommitted changes
- Detect project type (Xcode, npm, Python, Ruby, Rust, Go, etc.)
- Update version in appropriate files
- Create version tags
- Push to remote
- Publish to package managers (npm, PyPI, Homebrew, CocoaPods)
- Generate release summary

**Usage:**
```
/release_new_version
/release_new_version 1.2.3
/release_new_version skip_push=true
```

## Adding New Skills

To add a new skill:

1. Create a folder in the project root with the skill name
2. Add a `SKILL.md` file with the skill definition
3. Commit and push to make it available

### Skill Format

```yaml
---
name: skill_name
description: Brief description of what the skill does
user-invokable: true
args:
  - name: arg_name
    description: Argument description
    required: false
---

## Skill Description

Detailed instructions for the skill...
```

## Installation

To use these skills in your Claude Code configuration, add them to your skills folder at `~/.claude/skills/`:

```bash
cp -r skills/* ~/.claude/skills/
```

Or reference this repository in your Claude settings.

## License

MIT

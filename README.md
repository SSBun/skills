# SSBun Skills

Agent skill collection for [Claude Code](https://docs.claude.com/en/docs/claude-code), published as a plugin.

## Skills

| Skill | Invokable | Description |
|-------|-----------|-------------|
| xcode-build | `/SSBun-skills:xcode-build` | Build, run, and test iOS/macOS apps. Auto-detects project type and platform, supports simulators and real devices. |
| app-icon-prompt | `/SSBun-skills:app-icon-prompt` | Analyze project and generate App icon prompts for AI image generators. Supports iOS, macOS, web, and CLI. |
| release-new-version | `/SSBun-skills:release-new-version [version]` | Release new version — version bump, commit, tag, push, and publish to package managers. |
| are-you-ready | Auto-loaded | Behavioral guidelines for session start: planning defaults, subagent strategy, verification standards. |
| analyze-project | `/SSBun-skills:analyze-project [path] [depth]` | Deep project analysis. Scans structure, deps, architecture, business logic, APIs, data model, security. Generates detailed MD reports in `docs/`. |

## Install

```bash
# Add marketplace
claude plugin marketplace add SSBun/skills

# Install plugin
claude plugin install SSBun-skills
```

## Develop

```bash
# Test locally
claude --plugin-dir /path/to/skills

# Reload after changes
/reload-plugins
```

## License

MIT

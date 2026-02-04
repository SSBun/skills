# Development Workflow Skills

A repository for custom AI skills designed to enhance development workflows.

## Structure

- `skills/`: Contains individual skill folders, each with a `SKILL.md` file.

## Skills

- [xcode-builder](./skills/xcode-builder/SKILL.md): A skill for building and running iOS/macOS projects on physical devices.
- [app-template](./skills/app-template/SKILL.md): Defines startup app UI styles and layout structures (landing, dashboard, onboarding, settings, feed, editor) for quickly scaffolding new apps.

## Integration Guides

<details>
<summary><b>Cursor Integration</b></summary>

To use these skills globally in Cursor, you can link or copy them to your Cursor skills directory.

### 1. Global Installation (Recommended)
Copy the skills to your local Cursor configuration:
```bash
mkdir -p ~/.cursor/skills
cp -r skills/* ~/.cursor/skills/
```

### 2. Live Development (Symlink)
If you want to develop skills in this repository and have them update in Cursor immediately:
```bash
mkdir -p ~/.cursor/skills
ln -s "$(pwd)/skills/xcode-builder" ~/.cursor/skills/xcode-builder
ln -s "$(pwd)/skills/app-template" ~/.cursor/skills/app-template
```

### 3. Usage in Cursor
Once installed, you can use these skills in Cursor by:
- **Direct Reference**: Use `@xcode-builder`, `@app-template`, or `@SKILL.md` in your prompt.
- **Agent Mode**: In Composer (Agent mode), the AI will automatically discover and follow the workflows defined in these skills when relevant to your task.
- **Project Rules**: Reference the skill in your `.cursorrules` to ensure the AI always follows its guidelines for specific project types.
</details>

<details>
<summary><b>OpenCode Integration</b></summary>

These skills are compatible with [OpenCode](https://opencode.ai/docs/skills/) and can be loaded on-demand via the native `skill` tool.

### 1. Global Installation
Copy the skills to your global OpenCode configuration directory:
```bash
mkdir -p ~/.config/opencode/skills
cp -r skills/* ~/.config/opencode/skills/
```

### 2. Project-Local Installation
For project-specific skills, place them in the `.opencode` directory:
```bash
mkdir -p .opencode/skills
cp -r skills/xcode-builder .opencode/skills/
```

### 3. Usage in OpenCode
OpenCode discovers skills automatically and lists them in the `skill` tool description.
- **Discovery**: Agents see available skills and their descriptions.
- **On-Demand Loading**: When the agent needs a skill, it will call `skill({ name: "xcode-builder" })` to load the full instructions.
- **Permissions**: You can control skill access in your `opencode.json`.

### 4. Skill Validation Rules
- `SKILL.md` must be in ALL CAPS.
- `name` in frontmatter must match the directory name.
- `name` must be lowercase alphanumeric with single hyphens.
</details>

<details>
<summary><b>Claude Code Integration</b></summary>

These skills follow the [Agent Skills](https://agentskills.io) open standard and are natively supported in [Claude Code](https://code.claude.com/docs/en/skills).

### 1. Global Installation
Copy the skills to your personal Claude skills folder:
```bash
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

### 2. Project-Local Installation
For project-specific workflows, place them in the `.claude` directory:
```bash
mkdir -p .claude/skills
cp -r skills/xcode-builder .claude/skills/
```

### 3. Usage in Claude Code
Claude Code automatically discovers skills and integrates them as slash commands.
- **Manual Invocation**: Run `/xcode-builder` to trigger the skill directly.
- **Automatic Discovery**: Claude will load the skill automatically if your request matches the `description`.
- **Arguments**: Pass arguments directly, e.g., `/xcode-builder [device-id]`.

### 4. Advanced Configuration
- `disable-model-invocation: true`: Prevents automatic triggering.
- `user-invocable: false`: Hides from the `/` menu.
- `context: fork`: Runs the skill in an isolated subagent.
</details>

---
name: analyze-project
description: Deep analysis of a software project. Scans structure, dependencies, architecture, business logic, APIs, data model, security, quality, build/deploy, and git history. Generates detailed MD reports in a docs folder.
user-invokable: true
args:
  - name: project_path
    description: Path to the project root (optional, defaults to current directory)
    required: false
  - name: depth
    description: "Analysis depth: quick (structure only), standard (+ architecture, deps, data flow), deep (all reports + security + quality)"
    required: false
---

Analyze a software project and generate detailed analysis reports.

## Usage

```
/analyze-project [project_path] [depth]
```

- `project_path`: defaults to current directory
- `depth`: `quick` | `standard` | `deep` (default: `standard`)

## Depth Levels

| Level | Phase 1 (Discovery) | Phase 2 (Deep Analysis) | Phase 3 (Synthesis) |
|-------|--------------------|-----------------------|--------------------|
| **quick** | structure + deps + build + git | - | SUMMARY.md |
| **standard** | all Phase 1 | architecture + data-flow + process-analysis + api-surface + data-model | SUMMARY.md |
| **deep** | all Phase 1 | all Phase 2 + security-review + quality-report | SUMMARY.md with cross-references |

## Output Structure

All reports go to `docs/` in the project root:

```
docs/
├── SUMMARY.md              # Executive summary + analysis index
├── project-structure.md    # Directory layout, entry points, module boundaries
├── dependencies.md         # Package graph, versions, licenses
├── development-history.md  # Contribution patterns, churn, release cadence
├── build-and-deploy.md     # CI/CD, build system, deployment
├── architecture.md         # Patterns, layer boundaries, module responsibilities
├── data-flow.md            # Tech stack inventory, data movement, storage backends
├── process-analysis.md     # Business logic step-by-step
├── api-surface.md          # Public endpoints, protocols, auth model
├── data-model.md           # Schemas, ORM models, migrations
├── security-review.md      # Auth flow, secret handling, attack surface (deep only)
└── quality-report.md       # Test strategy, coverage, linting, type safety (deep only)
```

## Execution Workflow

### Step 1: Setup

1. Determine `project_path` (default: current directory)
2. Determine `depth` (default: `standard`)
3. Create `docs/` directory if not exists
4. Auto-detect tech stack by scanning manifest/lockfiles:
   - `package.json` / `yarn.lock` / `pnpm-lock.yaml` → Node.js/JS
   - `Cargo.toml` / `Cargo.lock` → Rust
   - `go.mod` / `go.sum` → Go
   - `requirements.txt` / `pyproject.toml` / `Pipfile.lock` → Python
   - `Gemfile` / `Gemfile.lock` → Ruby
   - `pom.xml` / `build.gradle` → Java/Kotlin
   - `*.sln` / `*.csproj` → .NET
   - `Package.swift` → Swift
   - `composer.json` / `composer.lock` → PHP
   - `mix.exs` / `mix.lock` → Elixir

### Step 2: Phase 1 — Discovery (Parallel Subagents)

Spawn parallel subagents for each Phase 1 scan. Each subagent:
- Reads the corresponding prompt from `prompts/`
- Writes output using the corresponding template from `templates/`
- Saves to `docs/<report>.md`

All Phase 1 subagents run concurrently:

```
Agent 1: scan-structure     → docs/project-structure.md
Agent 2: scan-dependencies  → docs/dependencies.md
Agent 3: scan-build         → docs/build-and-deploy.md
Agent 4: scan-git-history   → docs/development-history.md
```

### Step 3: Phase 2 — Deep Analysis (Parallel Subagents)

Spawn parallel subagents for each Phase 2 analysis. Each subagent:
- Reads Phase 1 outputs for context
- Reads the corresponding prompt
- Writes output using the corresponding template
- Saves to `docs/<report>.md`

Standard depth subagents:

```
Agent 5: analyze-architecture     → docs/architecture.md
Agent 6: analyze-data-flow        → docs/data-flow.md
Agent 7: analyze-process          → docs/process-analysis.md
Agent 8: analyze-api-surface      → docs/api-surface.md
Agent 9: analyze-data-model       → docs/data-model.md
```

Deep-only additional subagents:

```
Agent 10: analyze-security        → docs/security-review.md
Agent 11: analyze-quality         → docs/quality-report.md
```

### Step 4: Phase 3 — Synthesis

After all Phase 2 subagents complete:
1. Read all generated reports
2. Extract key findings from each
3. Generate `docs/SUMMARY.md` with:
   - Executive summary section
   - Analysis index table linking to each report

### Step 5: Report

Tell user:
- How many reports generated
- Where they are (docs/ path)
- Top 3 findings across all reports

## Template Format

Each template defines the report structure. Prompts guide the subagent on what to scan and how to fill the template. Templates contain markdown sections with `<!-- FILL: description -->` placeholders.

## NEVER

- Modify any source code in the target project
- Run destructive commands (delete, drop, reset)
- Execute the project's code (only read it)
- Commit anything to the target project's git
- Include secrets or credentials in reports (redact with `***`)

## ALWAYS

- Use subagents for parallel execution
- Keep main context clean — offload scanning to subagents
- Respect the depth level — skip reports not in scope
- Use absolute paths when referencing target project files
- Redact any found secrets with `***REDACTED***`

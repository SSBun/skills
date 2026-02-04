---
name: app-template
description: Introduces and defines startup app UI styles and layout structures. Use when the user wants to create a new app from a template, scaffold an app UI, choose a startup app style, or quickly bootstrap an app with a specific layout (landing, dashboard, onboarding, settings, etc.).
---

# App Template

Defines reusable startup app UI styles and layout structures. Use this skill to scaffold a new app from a chosen style quickly.

## Core Principles

**Use the platform's default components, colors, and fonts.** Do not introduce custom UI kits or non-standard styling unless the user explicitly asks for it.

- **macOS** – Use SwiftUI or AppKit system components. Match the look and behavior of system apps (Finder, System Settings, Mail): standard buttons, list styles, sidebars, and system colors/fonts (e.g. SF Pro, dynamic type).
- **iOS** – Use SwiftUI or UIKit standard controls and navigation patterns. Align with system app style (Settings, Files, Mail).
- **Web** – Use the framework’s or design system’s default components (e.g. browser-native form controls, or the project’s chosen UI library). Prefer semantic HTML and platform-appropriate defaults.

Following these defaults keeps apps familiar, accessible, and maintainable.

## When to Use

- User wants to create a new app and needs a clear structure
- User asks for "app template", "starter layout", "UI scaffold", or "startup app style"
- User wants to pick a style (e.g. "dashboard app", "landing page app") and build from it

## Workflow

1. **Confirm stack** – Web, macOS (SwiftUI/AppKit), iOS, or other. Default to web if unspecified.
2. **Pick a style** – Choose a style from the files in `templates/` (one file per style). Read that file for layout and style; do not assume content type (list, grid, etc.) unless the template states it.
3. **Scaffold** – Create the layout structure, routes/pages, and placeholder sections per that style.
4. **Implement** – Fill in with real content and behavior; keep the layout structure.

## Styles

Styles are defined in the **`templates/`** folder, one file per style. Templates describe **main layout and style only** (chrome, regions, typography, colors)—not the detailed content type (e.g. whether the main area is a list, grid, form, or editor). When the user picks a style (or you infer it), read the corresponding file under `templates/`.

| Style | File |
|-------|------|
| macOS System App (Finder-like) | [templates/macos-system-app.md](templates/macos-system-app.md) |
| macOS System Settings (Finder Settings–like) | [templates/macos-system-settings.md](templates/macos-system-settings.md) |

Add new styles by creating new files in `templates/` and listing them in this table.

## Applying a Style

1. **Create structure** – Add the layout regions (e.g. sidebar, main, toolbar) as components or views per the style file.
2. **Add placeholders** – Use the style’s key components; use placeholder text or empty states.
3. **Wire navigation** – Routes or state so selection and navigation work.
4. **Refine** – Replace placeholders with real content; keep the structure and use platform defaults.

## Notes

- **Defaults first** – Use platform/system components, buttons, colors, and fonts; avoid custom UI unless requested.
- Keep layout structure consistent; avoid mixing unrelated patterns in one screen.
- Prefer responsive by default: sidebar collapses, list stacks, touch-friendly targets.
- Use semantic sections and headings so structure is clear in code and to assistive tech.

# macOS System App Style

Reference: Finder, System Settings, Mail. Clean, minimal window with sidebar navigation and toolbar.

**Platform:** macOS only. Use SwiftUI or AppKit; no custom UI kits.

**Scope:** This template defines **main layout and style only** (window chrome, toolbar, sidebar, content region). It does not prescribe the kind of content in the main area (e.g. list, grid, form, or editor)—that is up to the app.

---

## Window and Chrome

- **Window** – Standard rounded corners, system window background. Traffic-light controls (close, minimize, fullscreen) top-left.
- **Title bar** – Shows current context (e.g. window title or path). No custom title bar styling.

---

## Toolbar (below title bar)

- **Navigation** – Back/forward buttons (e.g. chevrons). System-style; colors follow system (dark gray on dark gray in dark mode).
- **Path / breadcrumb** – Optional. Segments like `Parent > Current` with caret separators; tappable for hierarchy.
- **View options** – Optional. Icons for layout modes if the app needs them.
- **Search** – Optional. Right-aligned search field: magnifying glass + placeholder "Search". System search field style.

Toolbar is a single bar; which items appear depends on the app. Style: system controls, consistent spacing.

---

## Sidebar (left pane)

- **Background** – Slightly darker than main content for separation.
- **Sections** – Grouped with section headers. Use bold or larger system font for headers.
- **Rows** – Each item: system icon (outline or filled) + label. Standard row height and padding. Text uses system label color.
- **Selection** – Selected item: rounded-rectangle background in system accent blue; text stays white. Single selection.
- **Scroll** – Sidebar scrolls independently if content exceeds height.

Use SwiftUI `List` with sidebar style, or AppKit `NSOutlineView` in source list style. Prefer `NavigationSplitView` (SwiftUI) for sidebar + content.

---

## Detail View (right pane)

The right pane is the **detail view**—the region that shows content for the current sidebar selection. In the template it **can be empty**; the app fills it as needed.

- **Background** – Slightly lighter than sidebar. Use system window/content background so light/dark mode is correct.
- **Layout** – One primary region. No prescribed content type (list, grid, form, editor, etc.)—the app decides. Optional status or info bar at bottom.
- **Style** – Consistent padding and alignment; content is the focus. Use system fonts and colors for any text in this region.

The template only defines the **region and its styling**; what goes inside (or leaving it empty until selection) is app-specific.

---

## Typography

- **Font** – San Francisco (system default). Use `.body`, `.headline`, `.caption` etc. in SwiftUI; `NSFont.systemFont(ofSize:weight:)` in AppKit.
- **Hierarchy** – Section headers larger or bolder; body text standard size.
- **Dynamic Type** – Respect system text size where applicable.

---

## Color Palette

- **Backgrounds** – Semantic system colors (e.g. `Color(NSColor.windowBackgroundColor)`, `controlBackgroundColor`) so light/dark mode follows system. Sidebar darker, detail view slightly lighter in typical system apps.
- **Text** – System label colors for primary text; secondary a step dimmer.
- **Accent** – System blue for selection, links, primary actions. Do not override.
- **Traffic lights** – System red, yellow, green; do not restyle.

---

## Key Components (SwiftUI / AppKit)

| Element | SwiftUI | AppKit |
|--------|---------|--------|
| Window + sidebar layout | `NavigationSplitView` | `NSSplitViewController` + sidebar list |
| Sidebar list | `List(.sidebar)` | `NSOutlineView` in source list style |
| Toolbar | `ToolbarItemGroup` / `.toolbar` | `NSToolbar` |
| Path bar | Custom with `Button` segments | `NSPathControl` |
| Search | `TextField` with search style | `NSSearchField` |
| Selection highlight | Default list row selection | `NSTableRowView` with selection highlight |

---

## Do Not

- Use custom window frames or title bars.
- Replace system buttons, list rows, or search with custom-drawn controls.
- Introduce non-system colors or fonts for standard UI.
- Prescribe specific content in the detail view (e.g. "always use a grid")—layout and style only; the detail view can be empty in the template.

---

## Applying This Style

1. Create a window with `NavigationSplitView` (SwiftUI) or equivalent split with sidebar (AppKit).
2. Build the sidebar: section headers + list of items with icons and labels; bind selection state.
3. Add toolbar: back/forward if needed; optional path bar, view toggles, search as appropriate for the app.
4. Add the detail view (right pane) with its background and spacing; it can be left empty in the template, or filled with the app’s content (type is app-specific).
5. Use only system colors and fonts; rely on dark/light mode from the environment.

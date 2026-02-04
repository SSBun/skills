# macOS System Settings Style

Reference: Finder Settings, System Settings panels. A single window with tab-based navigation at the top and a content area below for grouped settings.

**Platform:** macOS only. Use SwiftUI (preferred) or AppKit.

---

## Core Principle

**Use SwiftUI's built-in `Settings` scene.** This single decision gives you:
- Automatic **Cmd+,** keyboard shortcut
- Proper preferences window behavior (single instance, correct window level)
- Standard window chrome and title bar

Do not manually create a window for settings. Let the system handle it.

---

## Minimal Implementation (SwiftUI)

### 1. App Entry Point

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }
    }
}
```

### 2. Tab Definition (enum pattern)

Use an enum with `CaseIterable` for type-safe, extensible tabs:

```swift
enum SettingsTab: String, CaseIterable, Identifiable {
    case general, appearance, advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .advanced: return "Advanced"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintbrush"
        case .advanced: return "slider.horizontal.3"
        }
    }
}
```

### 3. Settings View Structure

```swift
struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(SettingsTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
        .frame(width: 500, minHeight: 300)
    }
}
```

### 4. Tab Content with Grouped Form

```swift
struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
            } header: {
                Text("Startup")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
```

---

## Key Patterns

| Pattern | Implementation | Why |
|---------|---------------|-----|
| Settings window | `Settings { }` scene | Auto Cmd+,, single instance, correct behavior |
| Tab navigation | `TabView` + `.tabItem { Label(...) }` | Native icon+label tabs |
| Form layout | `Form { }.formStyle(.grouped)` | Native grouped sections |
| Persistence | `@AppStorage("key")` | Auto UserDefaults sync |
| Sections | `Section { } header: { Text("...") }` | Native section headers |

---

## Common Controls

All controls use system styling automatically. No custom styling needed.

```swift
// Toggle (checkbox)
Toggle("Enable feature", isOn: $isEnabled)

// Picker (dropdown)
Picker("Option", selection: $selection) {
    Text("Choice A").tag(0)
    Text("Choice B").tag(1)
}

// Slider with label
VStack(alignment: .leading) {
    Text("Cache size: \(Int(cacheSize)) MB")
    Slider(value: $cacheSize, in: 50...500, step: 50)
}

// Description text (below a control)
Toggle("Debug logging", isOn: $debugLogging)
Text("Logs saved to ~/Library/Logs/")
    .font(.caption)
    .foregroundStyle(.secondary)

// Button
Button("Clear Cache") { clearCache() }
```

---

## Do Not

- Create a custom window for settings—use `Settings` scene
- Draw custom tabs or controls—use `TabView`, `Toggle`, `Picker`
- Override colors or fonts—system handles light/dark mode
- Use `Picker` with segmented style for top-level tabs—use `TabView`

---

## Checklist

- [ ] `Settings { }` scene in App struct
- [ ] Tab enum with `CaseIterable`, `Identifiable`
- [ ] `TabView` with `.tabItem { Label(...) }` for each tab
- [ ] `Form` with `.formStyle(.grouped)` for content
- [ ] `@AppStorage` for persisted settings
- [ ] `Section { } header: { }` for grouping
- [ ] `.frame(width:minHeight:)` on TabView for consistent sizing

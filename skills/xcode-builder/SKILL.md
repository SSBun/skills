---
name: xcode-builder
description: A skill for building and running iOS/macOS projects on physical devices for testing and debugging.
---

# xcode-builder Skill

A skill for building and running iOS/macOS projects on physical devices for testing and debugging.

## When to Use
Use this skill when users want to:
- Build iOS/macOS projects to test code
- Fix building errors
- Run apps on physical devices for debugging

## Prerequisites
- **MANDATORY**: Always ask the user for the project root path (the directory containing the `.xcworkspace` file) before performing any actions.
- **DO NOT** attempt to guess or search for the project root path automatically, as the current workspace might be a sub-component or library.
- Ensure the provided project path contains a `.xcworkspace` file.
- Physical iOS device connected and trusted.

## Functions

### 1. List Available Devices
Lists all connected iOS devices to help user select target device.

```bash
xcrun xctrace list devices
```

**Output**: Shows online/offline devices with their IDs and names.

### 2. Build Project (Debug Mode)
Builds the project for the selected device in debug configuration.

```bash
cd <project_path>
xcodebuild -workspace <workspace_name>.xcworkspace -scheme <scheme_name> -configuration Debug -destination 'platform=iOS,id=<device_id>' build
```

**Parameters**:
- `<project_path>`: Root directory containing the .xcworkspace file
- `<workspace_name>`: Name of the .xcworkspace file (without extension)
- `<scheme_name>`: Usually same as workspace name
- `<device_id>`: Device ID from step 1

**Success**: Build completes with "BUILD SUCCEEDED"
**Failure**: Shows compilation errors to fix

### 3. Install and Run App
Installs the built app on device and launches it.

**Install**:
```bash
cd <project_path>
xcrun devicectl device install app --device <device_id> /Users/<username>/Library/Developer/Xcode/DerivedData/<project>-*/Build/Products/Debug-iphoneos/<app_name>.app
```

**Launch**:
```bash
xcrun devicectl device process launch --device <device_id> <bundle_id>
```

**Parameters**:
- `<device_id>`: Target device ID
- `<bundle_id>`: App's bundle identifier (shown in install output)

## Workflow
1. **List devices** → Select online device ID
2. **Build project** → Fix any compilation errors if build fails
3. **Install and run** → App launches on physical device

## Notes
- Always use debug configuration for testing
- Requires physical device (not simulator) for real device testing
- Build must succeed before install/run
- App will appear on device home screen after installation

---
name: xcode-build
description: Use when the user wants to build, run, or test iOS/macOS/watchOS/tvOS apps with Xcode or xcodebuild. Auto-detects project type and platform, handles simulators and real devices, and resolves common build errors.
---

Guide agents through building, running, and testing iOS/macOS applications using Xcode and xcodebuild.

## Step 1: Identify Project Type

First, determine if the current directory contains an Xcode project or is a component within a larger project.

### Check for Xcode Project Files

Look for:
- `.xcodeproj` files (Xcode project)
- `.xcworkspace` files (Xcode workspace, often with CocoaPods)
- `Package.swift` files (Swift Package Manager)

Run:
```bash
ls -la
find . -maxdepth 2 -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null
```

### Determine Project Type

**Root Xcode Project**: The current directory contains the main `.xcodeproj` or `.xcworkspace` file.

**Component Project**: The current directory is a separate repository that integrates into a root project via SPM, CocoaPods, or submodules.

### If Component Project

If the current project is a component (not the root), ask the user:

> **Where is the root Xcode project located?**
>
> This project appears to be a component that integrates into a larger Xcode project. Please provide the path to the root `.xcodeproj` or `.xcworkspace` file.

Use `AskUserQuestion` to get the root project path.

### Detect Project Platform (iOS, macOS, etc.)

Automatically detect the platform from the project schemes:

```bash
# Get available schemes and their platforms
SCHEMES=$(xcodebuild -workspace Project.xcworkspace -list 2>/dev/null || xcodebuild -project Project.xcodeproj -list)

# Analyze schemes to determine platform
# iOS schemes typically include "iOS" app targets
# macOS schemes typically include "macOS" app targets
# watchOS, tvOS schemes follow similar patterns
```

From the scheme list, automatically determine:
- **iOS** - if schemes target iPhone/iPad apps
- **macOS** - if schemes target macOS apps
- **watchOS** - if schemes target Apple Watch apps
- **tvOS** - if schemes target Apple TV apps

Use this detected platform to filter available devices automatically.

## Step 2: Select Target Device

### Get Available Schemes

List all available schemes in the project:
```bash
xcodebuild -workspace Project.xcworkspace -list 2>/dev/null || xcodebuild -project Project.xcodeproj -list
```

### Get Available Devices

Use `xcrun xctrace list devices` to list both simulators and connected real devices:

```bash
# List all devices (simulators + real devices)
xcrun xctrace list devices
```

Filter based on the detected project platform:

```bash
# For iOS project
xcrun xctrace list devices | grep -i ios

# For macOS project
xcrun xctrace list devices | grep -i macos

# For watchOS project
xcrun xctrace list devices | grep -i watch

# For tvOS project
xcrun xctrace list devices | grep -i appletv
```

### Check for Connected Real Devices

After listing devices, check if any real devices are connected. Real devices typically appear in the output without a simulator runtime version (e.g., "iPhone" without "(iOS 17.0)").

### Ask About Real Devices First

If real devices are connected, ask the user first:

> **Real device detected!**
>
> A physical device is connected. Would you like to:
> - **Use real device**: Test on physical hardware (requires signing)
> - **Use simulator**: Run on iOS Simulator instead
>
> Note: Real devices require Apple Developer account and proper provisioning profiles.

Use `AskUserQuestion` to get their preference.

If no real devices are connected, skip this step and proceed to simulator selection.

### Ask User to Select Target

After determining the user's preference (real device vs simulator), present the available options filtered by the detected project platform:

> **Available devices:**
> - iPhone 15 Pro (iOS 17.0) - Simulator
> - iPhone 15 (iOS 17.0) - Simulator
> - iPhone SE (iOS 16.0) - Simulator
> - My iPhone (udid) - Real Device

Use `AskUserQuestion` to let user select their preferred device.

## Step 3: Build or Run Selection

After selecting the target device, ask the user what they want to do:

> **What would you like to do?**
> - **Build only**: Compile the project to check for errors
> - **Build and Run**: Compile and launch on the selected device/simulator
> - **Analyze**: Run static analysis without building

Use `AskUserQuestion` to get their choice.

## Step 4: Build or Run the Project

### Determine Build Command

**For Simulator:**
```bash
# Get simulator UDID using xctrace
SIMULATOR_UDID=$(xcrun xctrace list devices | grep "iPhone 15 Pro" | grep -oE "[0-9a-f-]{36}" | head -1)

xcodebuild build \
  -workspace Project.xcworkspace \
  -scheme SchemeName \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

**For Real Device:**
```bash
xcodebuild build \
  -workspace Project.xcworkspace \
  -scheme SchemeName \
  -destination 'platform=iOS,name=My iPhone' \
  CODE_SIGN_IDENTITY="Apple Development" \
  PROVISIONING_PROFILE_NAME="ProfileName"
```

**For macOS (clean build for testing):**

When building a macOS project for testing (build and run), always do a full clean build to avoid stale cache issues:

1. **Purge cached app from DerivedData:**
```bash
DERIVED_DATA=$(xcodebuild -workspace Project.xcworkspace -scheme SchemeName -showBuildSettings 2>/dev/null | grep -m1 BUILD_DIR | awk '{print $3}' | sed 's|/Build/Products||')
rm -rf "${DERIVED_DATA}/Build/Products/Debug/SchemeName.app"
```

2. **Clean build from source:**
```bash
xcodebuild clean build \
  -workspace Project.xcworkspace \
  -scheme SchemeName \
  -configuration Debug \
  -destination 'platform=macOS'
```

3. **Open the freshly built app:**
```bash
APP_PATH=$(xcodebuild -workspace Project.xcworkspace -scheme SchemeName -configuration Debug -destination 'platform=macOS' -showBuildSettings 2>/dev/null | grep -m1 BUILT_PRODUCTS_DIR | awk '{print $3}')
open "${APP_PATH}/SchemeName.app"
```

For build-only (no run), a regular `xcodebuild build` without clean is sufficient.

### Build Options

Common useful flags:
- `-configuration Debug|Release` - Build configuration
- `-derivedDataPath <path>` - Derived data location
- `-quiet` - Less verbose output
- `-showBuildSettings` - Display build settings

### For "Build and Run"

Use `xcrun simctl boot` to boot simulator first, then:
```bash
# Install and launch on simulator
xcrun simctl install booted /path/to/app.app
xcrun simctl launch booted com.bundle.id
```

Or use:
```bash
xcodebuild build \
  -workspace Project.xcworkspace \
  -scheme SchemeName \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  && xcrun simctl boot "iPhone 15 Pro"
```

### Handle Build Errors

If build fails:

1. **Parse errors carefully** - Look for actual errors vs warnings
2. **Check scheme/target** - Ensure correct scheme is selected
3. **Check Xcode version** - `xcodebuild -version`
4. **Clean and rebuild** - `xcodebuild clean`
5. **Check pods/Carthage** - If using CocoaPods, ensure workspace is used

Common error fixes:
- `error: no such module 'X'` → Check import, ensure dependency is linked
- `ld: symbol not found` → Check library linking
- `could not find developer disk image` → Update Xcode or simulators

## Output Summary

Provide the user with:
- Build status (success/failure)
- Build time
- Any warnings or errors found
- Location of build products (if successful)

---

**NEVER**:
- Assume the current folder is always the root project
- Skip asking about root project path for components
- Skip device/simulator selection
- Skip asking build vs run preference
- Hard-code bundle identifiers or signing identities

**ALWAYS**:
- Use `AskUserQuestion` for any user decisions
- Handle both `.xcodeproj` and `.xcworkspace`
- Support both simulators and real devices
- Provide clear error messages and solutions
- Automatically detect project platform from schemes
- Ask user first when real devices are connected

---
name: xcode_build
description: Guide agents to build, run, or test iOS/macOS apps using Xcode. Helps with building errors, running apps on simulators or devices, and testing features.
user-invokable: true
args:
  - name: project_path
    description: Path to the Xcode project (optional, defaults to current directory)
    required: false
---

Guide agents through building, running, and testing iOS/macOS applications using Xcode and xcodebuild.

## Step 1: Identify Project Type

First, determine if the current directory contains an Xcode project or is a component within a larger project.

### Check for Xcode Project Files

Look for:
- `.xcodeproj` files ( Xcode project)
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

## Step 2: Select Target Device

### Get Available Schemes

List all available schemes in the project:
```bash
xcodebuild -workspace Project.xcworkspace -list 2>/dev/null || xcodebuild -project Project.xcodeproj -list
```

### Get Available Destinations

First, ask the user about their preferences to filter the list:

**i. Platform Selection**
Ask: "Which platform do you want to build for?"
- iOS
- macOS
- watchOS
- tvOS

**ii. Device Type (if iOS)**
Ask: "What type of device?"
- iPhone
- iPad

**iii. Simulator Version**
Ask: "Which iOS version?" or "Which macOS version?"
- Latest stable
- Specific version (e.g., iOS 17.0, macOS 14.0)

### Get Filtered Simulators

After getting preferences, list matching simulators:

```bash
# For iOS
xcrun simctl list devices available | grep -E "iPhone|iPad" | grep "iOS"

# For macOS
xcrun simctl list devices available | grep -i "mac"

# Get specific version
xcrun simctl list devices available | grep "iPhone.*17.0"
```

If simulators are too many, offer to filter further by:
- Specific iOS version
- iPhone vs iPad
- Device model (e.g., iPhone 15 Pro)

### Get Connected Real Devices

```bash
# List connected devices
xcrun devicelist
instruments -s devices
```

### Ask User to Select Target

Present options based on filtered results and use `AskUserQuestion` to let user select:

> **Select target device:**
> - iPhone 15 Pro (iOS 17.0) - Simulator
> - iPhone 15 (iOS 17.0) - Simulator
> - iPhone SE (iOS 16.0) - Simulator
> - My iPhone (udid) - Real Device

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
# Get simulator UDID
SIMULATOR_UDID=$(xcrun simctl list devices available | grep "iPhone 15 Pro" | grep -oE "[0-9a-f-]{36}" | head -1)

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

**For macOS:**
```bash
xcodebuild build \
  -workspace Project.xcworkspace \
  -scheme SchemeName \
  -destination 'platform=macOS'
```

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

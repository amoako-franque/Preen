# Preen for Mac

Privacy-first native macOS system utility built with Swift 6, SwiftUI, SwiftData, and a privileged helper over XPC.

## Requirements

- macOS 14.0+
- Xcode 16.2+
- Swift 6.0
- [Homebrew](https://brew.sh) (recommended): `brew install swiftlint xcbeautify`

## Quick Start

```bash
git clone <your-repo-url>
cd Preen
open Preen.xcodeproj
```

In Xcode:

1. Select the **Preen** scheme.
2. Set your **Team** under Signing & Capabilities for both **Preen** and **PreenHelper**.
3. Build and run (`Cmd+R`).

From the command line:

```bash
xcodebuild -scheme Preen -destination 'platform=macOS' build
xcodebuild -scheme Preen -destination 'platform=macOS' test
```

## Project Structure

```
Preen/
├── Preen/              Main app (SwiftUI + SwiftData)
├── PreenHelper/        Privileged command-line helper (XPC)
├── Shared/             Code shared by app and helper
├── PreenTests/         Unit + snapshot tests
└── PreenUITests/       UI tests
```

## Privileged Helper

The helper is embedded at `Contents/Helper/PreenHelper` with its launchd plist at `Contents/Library/LaunchDaemons/`. Registration uses `SMAppService` and requires admin approval on first run.

**Debug launch arguments** (Scheme → Run → Arguments):

| Argument | Purpose |
|----------|---------|
| `--disable-signature-check` | Skip XPC client signature validation (Debug only) |

## Configuration

| Setting | Value |
|---------|-------|
| App bundle ID | `com.obirasor.Preen` |
| Helper bundle ID | `com.obirasor.Preen.helper` |
| Mach service | `com.obirasor.Preen.helper` |
| Helper version | `0.1.0` |

Update Sparkle keys in `Preen/Info.plist` before shipping (`SUFeedURL`, `SUPublicEDKey`).

## Phase 0 Status

Foundation in place: SwiftData schema, design tokens, XPC protocol, SMAppService registration, SwiftLint, Sparkle SPM, snapshot testing, and CI workflow.

**Before Phase 1:** confirm helper XPC ping-pong with signed binaries on your machine (Dashboard → Register Helper → Test XPC Connection).

## Documentation

Product and engineering docs live in `../dev_files/` at the repo root.

## License

Copyright © 2026 Obirasor. All rights reserved.

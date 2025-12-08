# Copilot Instructions for DiskDevil

DiskDevil is a macOS privacy and security application built with Swift and SwiftUI. This file provides guidance for GitHub Copilot when working with this repository.

## Project Overview

DiskDevil is a macOS application that provides:
- Privacy firewall and network monitoring
- Security scanning and audit tools
- Disk cleanup and recovery utilities
- Subscription-based feature tiers (Free, Premium, Elite)

## Technology Stack

- **Language**: Swift 5.9+
- **Minimum OS**: macOS 13.0 (Ventura)
- **UI Framework**: SwiftUI
- **Build System**: Swift Package Manager (SPM)
- **Code Quality**: SwiftLint + SwiftFormat

## Code Style and Formatting

### SwiftLint
- The project uses SwiftLint for code quality enforcement
- Configuration is in `.swiftlint.yml`
- Run linting with: `swiftlint lint`
- All code must pass SwiftLint checks before committing

### SwiftFormat
- The project uses SwiftFormat for consistent code formatting
- Configuration is in `.swiftformat`
- Run formatting with: `swiftformat .`
- Check formatting with: `swiftformat --lint .`

### Code Conventions
- Use clear, descriptive variable and function names
- Follow Swift API Design Guidelines
- Prefer `let` over `var` when possible
- Use explicit types when it improves clarity
- Add meaningful comments for complex logic, not obvious code
- Keep functions focused and single-purpose
- Use SwiftUI property wrappers appropriately (`@State`, `@Published`, `@ObservedObject`, etc.)

## Project Structure

```
DiskDevil/
├── Models/              # All Swift source files (views, models, managers)
│   ├── *View.swift     # SwiftUI view files
│   ├── *Manager.swift  # Business logic managers
│   ├── *Engine.swift   # Core functionality engines
│   └── DiskDevilApp.swift  # Main app entry point
├── Tests/              # Unit tests
├── scripts/            # Helper scripts for development
├── .github/            # GitHub configuration
│   └── workflows/      # CI/CD workflows
└── Package.swift       # SPM package definition
```

## Development Workflow

### Local Development
1. Install dependencies:
   ```bash
   brew install swiftformat swiftlint
   ```

2. Install git hooks:
   ```bash
   ./scripts/install-hooks.sh
   ```

3. Use the commit helper for conventional commits:
   ```bash
   git add .
   ./scripts/commit.sh
   ```

### Building and Testing
- Build: `swift build`
- Test: `swift test`
- Run checks: `./scripts/run_checks.sh`

### CI/CD
- GitHub Actions CI runs on all pushes and PRs to `main`
- CI checks: SwiftFormat, SwiftLint, build, and tests
- All checks must pass before merging

## Architecture Patterns

### State Management
- Use `@StateObject` for creating observable objects in views
- Use `@ObservedObject` for passing observable objects
- Use `@Published` for properties that trigger view updates
- Keep state as local as possible; lift only when necessary

### Managers and Engines
- **Managers**: Handle business logic and coordination (e.g., `SubscriptionManager`, `PermissionManager`)
- **Engines**: Provide core functionality (e.g., `PrivacyEngine`)
- **Backend**: System-level operations (e.g., `SystemBackend`)
- All should conform to `ObservableObject` when they need to notify views

### Views
- Keep views focused on presentation
- Extract reusable components
- Use view modifiers for common styling
- Follow SwiftUI best practices for composition

## Testing

### Testing Guidelines
- Write tests for business logic in managers and engines
- Test files are located in `Tests/` directory
- Test file naming: `*Tests.swift`
- Run tests with: `swift test`
- Aim for meaningful test coverage, especially for critical functionality

### Existing Tests
- `PrivacyEngineTests.swift`
- `SubscriptionManagerTests.swift`
- `UsageLimitsTests.swift`

## Subscription Tiers

The app has three subscription tiers (defined in `SubscriptionManager.swift`):
1. **Free**: Basic features with limits
2. **Premium**: Enhanced features and higher limits
3. **Elite**: Full features, unlimited usage

When adding features, respect tier limitations and check subscription status appropriately.

## Key Components

### Privacy & Security
- `PrivacyEngine.swift`: Core privacy functionality with 5 privacy levels
- `SecurityScanView.swift`: Security scanning interface
- `NetworkMonitorView.swift`: Network traffic monitoring
- `PermissionManager.swift`: macOS permissions handling

### UI & Navigation
- `ContentView.swift`: Main navigation structure
- `DashboardView.swift`: Main dashboard
- `MenuBarView.swift`: Menu bar interface
- `Theme.swift`: App theming and colors

### Subscription & Monetization
- `SubscriptionManager.swift`: Subscription tier management
- `StoreKitManager.swift`: In-app purchase handling
- `UpgradeView.swift`: Subscription upgrade UI
- `UsageLimits.swift`: Feature usage limits

## Important Implementation Notes

1. **NetworkExtension**: The privacy firewall currently uses simulated data. Real implementation requires NetworkExtension framework (see `IMPLEMENTATION.md`)

2. **Permissions**: The app requires Full Disk Access for full functionality. Handle permission requests gracefully.

3. **StoreKit**: Subscription implementation uses StoreKit 2 (see `STOREKIT_SETUP.md`)

4. **Logging**: Use the `Logger.swift` utility for consistent logging

## Security Considerations

- Never commit API keys, secrets, or credentials
- Validate all user input
- Handle sensitive data appropriately
- Follow macOS security best practices
- Respect user privacy settings

## Documentation

- `README.md`: Developer setup and commit automation
- `IMPLEMENTATION.md`: Detailed backend implementation guide
- `STOREKIT_SETUP.md`: StoreKit integration guide
- `Tests/README.md`: Testing documentation

## Common Tasks

### Adding a New View
1. Create `NewFeatureView.swift` in `Models/`
2. Follow SwiftUI view structure
3. Use existing theme and styling patterns
4. Update navigation in `ContentView.swift` if needed
5. Add tests if the view has testable logic

### Adding a New Manager
1. Create `NewFeatureManager.swift` in `Models/`
2. Conform to `ObservableObject`
3. Use `@Published` for observable properties
4. Add corresponding tests in `Tests/`
5. Document public APIs with comments

### Modifying Subscription Features
1. Update tier definitions in `SubscriptionManager.swift`
2. Update limits in `UsageLimits.swift`
3. Update UI in `UpgradeView.swift`
4. Update tests to cover new functionality

## Best Practices

1. **Minimal Changes**: Make surgical, focused changes
2. **Test Coverage**: Add tests for new functionality
3. **Code Quality**: Ensure SwiftLint and SwiftFormat pass
4. **Documentation**: Update relevant docs when changing APIs
5. **Commit Messages**: Use conventional commit format (enforced by `commit.sh`)
6. **Error Handling**: Use proper error handling, avoid force unwrapping
7. **Performance**: Consider performance implications, especially for UI updates
8. **Accessibility**: Follow accessibility best practices for macOS

## Questions or Issues?

- Check `IMPLEMENTATION.md` for detailed implementation guidance
- Review existing code for patterns and conventions
- Consult Swift and SwiftUI documentation
- Test changes thoroughly before committing

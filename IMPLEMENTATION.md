# DiskDevil Implementation Guide

This document outlines the backend implementation requirements for DiskDevil's core features.

## Table of Contents

1. [NetworkExtension Integration](#networkextension-integration)
2. [Subscription & Payment System](#subscription--payment-system)
3. [Security Scanner Enhancement](#security-scanner-enhancement)
4. [Permission Handling](#permission-handling)
5. [Code Signing & Distribution](#code-signing--distribution)

---

## NetworkExtension Integration

### Current Status
The privacy firewall currently uses simulated data. Real network filtering requires Apple's NetworkExtension framework.

### Implementation Requirements

#### 1. System Extension Setup

```swift
// Create a new System Extension target in Xcode
// File > New > Target > System Extension

import NetworkExtension
import SystemExtensions

class NetworkFilterExtension: NEFilterDataProvider {
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Initialize filter rules based on privacy level
        completionHandler(nil)
    }

    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Check flow against privacy level rules
        // Block or allow based on current privacy level
    }
}
```

#### 2. Entitlements Required

Add to `DiskDevil.entitlements`:
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
    <string>content-filter-provider</string>
</array>
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

#### 3. PrivacyEngine Integration

Update `Models/PrivacyEngine.swift`:

```swift
import NetworkExtension

class PrivacyEngine: ObservableObject {
    private let filterManager = NEFilterManager.shared()

    func setLevel(_ level: Int) {
        currentLevel = level

        // Configure NetworkExtension rules
        filterManager.loadFromPreferences { [weak self] error in
            guard error == nil else { return }
            self?.updateFilterRules(for: level)
        }
    }

    private func updateFilterRules(for level: Int) {
        let rules = generateRules(for: level)
        // Apply rules to NetworkExtension
        filterManager.saveToPreferences { error in
            if error == nil {
                self.filterManager.isEnabled = true
            }
        }
    }
}
```

#### 4. Installation Process

Users must approve system extension installation:
1. App requests installation via `OSSystemExtensionRequest`
2. User approves in System Settings > Privacy & Security
3. Extension activates and begins filtering

### Testing

```bash
# Check extension status
systemextensionsctl list

# Monitor extension logs
log stream --predicate 'subsystem == "com.yourcompany.DiskDevil.extension"'
```

---

## Subscription & Payment System

### Current Status
Subscription tiers are defined but not enforced with real payment processing.

### Recommended Approach: StoreKit 2

#### 1. App Store Connect Setup

1. Create subscription products:
   - `com.yourcompany.diskdevil.premium.monthly` ($9.99/month)
   - `com.yourcompany.diskdevil.elite.monthly` ($19.99/month)
   - Annual variants with 20% discount

2. Configure subscription groups and pricing tiers

#### 2. Implementation

Create `Models/StoreKitManager.swift`:

```swift
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []

    private var updates: Task<Void, Never>? = nil

    init() {
        updates = observeTransactionUpdates()
    }

    func loadProducts() async throws {
        subscriptions = try await Product.products(for: [
            "com.yourcompany.diskdevil.premium.monthly",
            "com.yourcompany.diskdevil.elite.monthly"
        ])
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return transaction

        case .userCancelled, .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                await self.updateSubscriptionStatus()
            }
        }
    }

    private func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                purchasedSubscriptions.append(transaction.product)
            }
        }
    }
}
```

#### 3. Update SubscriptionManager

```swift
class SubscriptionManager: ObservableObject {
    @Published var tier: SubscriptionTier = .free
    @Published var expirationDate: Date?

    private let storeKit = StoreKitManager()

    func updateFromStoreKit() async {
        for subscription in storeKit.purchasedSubscriptions {
            if subscription.id.contains("elite") {
                tier = .elite
            } else if subscription.id.contains("premium") {
                tier = .premium
            }
        }
    }
}
```

#### 4. Receipt Validation

For additional security, validate receipts server-side or use App Store Server API.

### Alternative: Paddle/Gumroad

If distributing outside the Mac App Store:

- Integrate Paddle SDK for license key generation
- Implement license validation on app launch
- Store license locally with encryption

---

## Security Scanner Enhancement

### Current Status
`SystemBackend.swift` has basic scanner structure but needs real implementations.

### Implementation

Update `Models/SystemBackend.swift`:

```swift
class SecurityScanner {
    func run(progressHandler: @escaping (Double) -> Void) async -> [SecurityIssue] {
        var issues: [SecurityIssue] = []

        // 1. Check Firewall Status (10%)
        progressHandler(0.1)
        if !isFirewallEnabled() {
            issues.append(SecurityIssue(
                name: "Firewall Disabled",
                description: "macOS Firewall is not active",
                severity: .high,
                category: .network
            ))
        }

        // 2. Check Gatekeeper (20%)
        progressHandler(0.2)
        if !isGatekeeperEnabled() {
            issues.append(SecurityIssue(
                name: "Gatekeeper Disabled",
                description: "App verification is disabled",
                severity: .critical,
                category: .software
            ))
        }

        // 3. Check SIP (30%)
        progressHandler(0.3)
        if !isSIPEnabled() {
            issues.append(SecurityIssue(
                name: "SIP Disabled",
                description: "System Integrity Protection is off",
                severity: .critical,
                category: .software
            ))
        }

        // 4. Check FileVault (40%)
        progressHandler(0.4)
        if !isFileVaultEnabled() {
            issues.append(SecurityIssue(
                name: "FileVault Disabled",
                description: "Disk encryption is not enabled",
                severity: .high,
                category: .privacy
            ))
        }

        // 5. Scan for suspicious processes (60%)
        progressHandler(0.6)
        issues.append(contentsOf: scanProcesses())

        // 6. Check for outdated software (80%)
        progressHandler(0.8)
        issues.append(contentsOf: checkSoftwareUpdates())

        // 7. Scan network connections (100%)
        progressHandler(1.0)
        issues.append(contentsOf: scanNetworkConnections())

        return issues
    }

    private func isFirewallEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/libexec/ApplicationFirewall/socketfilterfw"
        task.arguments = ["--getglobalstate"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.contains("enabled")
    }

    private func isGatekeeperEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/spctl"
        task.arguments = ["--status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.contains("enabled")
    }

    private func isSIPEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/csrutil"
        task.arguments = ["status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.contains("enabled")
    }

    private func isFileVaultEnabled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/fdesetup"
        task.arguments = ["status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.contains("On")
    }
}
```

---

## Permission Handling

### Current Status
`PermissionManager.swift` has placeholder implementations.

### Full Disk Access Detection

```swift
import Foundation

class PermissionManager: ObservableObject {
    @Published var hasFullDiskAccess = false
    @Published var hasNetworkExtension = false

    func checkFullDiskAccess() {
        // Try to access a protected directory
        let protectedPath = "/Library/Application Support/com.apple.TCC/"
        hasFullDiskAccess = FileManager.default.isReadableFile(atPath: protectedPath)
    }

    func requestFullDiskAccess() {
        // Open System Settings to Privacy & Security
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)

        // Show alert with instructions
        let alert = NSAlert()
        alert.messageText = "Full Disk Access Required"
        alert.informativeText = """
        DiskDevil needs Full Disk Access to function properly.

        1. Click the lock icon to make changes
        2. Enable the toggle next to DiskDevil
        3. Restart the app
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
```

### Network Extension Permission

```swift
func checkNetworkExtensionPermission() async {
    do {
        let status = try await NEFilterManager.shared().loadFromPreferences()
        hasNetworkExtension = NEFilterManager.shared().isEnabled
    } catch {
        hasNetworkExtension = false
    }
}
```

---

## Code Signing & Distribution

### Requirements for NetworkExtension

1. **Developer ID Certificate**
   - System Extensions require Developer ID Application certificate
   - Not available with personal Apple Developer account
   - Requires paid Apple Developer Program membership

2. **Provisioning Profile**
   - Enable System Extension capability
   - Enable Network Extension capability

3. **Notarization**
   - Required for distribution outside Mac App Store
   - Submit to Apple for automated security scan

### Build Process

```bash
# 1. Build with hardened runtime
xcodebuild -scheme DiskDevil \
  -configuration Release \
  -archivePath DiskDevil.xcarchive \
  archive

# 2. Export for Developer ID
xcodebuild -exportArchive \
  -archivePath DiskDevil.xcarchive \
  -exportPath DiskDevil \
  -exportOptionsPlist ExportOptions.plist

# 3. Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  DiskDevil.app

# 4. Create DMG
create-dmg DiskDevil.app

# 5. Notarize
xcrun notarytool submit DiskDevil.dmg \
  --apple-id your@email.com \
  --team-id TEAM_ID \
  --password @keychain:AC_PASSWORD

# 6. Staple notarization ticket
xcrun stapler staple DiskDevil.dmg
```

---

## Next Steps

1. **Immediate (for launch):**
   - Implement Full Disk Access detection
   - Add StoreKit 2 subscription integration
   - Enhance SecurityScanner with real checks

2. **Phase 2 (post-launch):**
   - Implement NetworkExtension for real filtering
   - Add server-side receipt validation
   - Implement telemetry blocking via pf firewall rules

3. **Phase 3 (advanced features):**
   - Machine learning threat detection
   - Cloud sync for privacy settings
   - Enterprise license management

---

## Resources

- [NetworkExtension Documentation](https://developer.apple.com/documentation/networkextension)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [System Extension Programming Guide](https://developer.apple.com/system-extensions/)
- [App Sandbox Design Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)


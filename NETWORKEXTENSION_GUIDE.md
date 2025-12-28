# NetworkExtension Implementation Guide for Xcode

This guide walks you through implementing the real NetworkExtension in Xcode on your M1 Mac.

## Prerequisites

- Xcode 13.0 or later
- macOS 11.0 or later
- Apple Developer Program membership
- Valid Developer ID certificate for code signing

## Architecture Overview

The DiskDevil app now uses a protocol-based architecture that supports both:
- **SimulatedNetworkFilter**: Current development implementation (no actual filtering)
- **NetworkExtensionFilter**: Real implementation using Apple's NetworkExtension framework

Files created:
- `NetworkFilterProtocol.swift`: Protocol definitions and rule structures
- `SimulatedNetworkFilter.swift`: Current simulated implementation
- `NetworkExtensionFilter.swift`: Template for real implementation
- Updated `PrivacyEngine.swift`: Uses the protocol architecture

## Step-by-Step Implementation

### Step 1: Create System Extension Target in Xcode

1. Open DiskDevil.xcodeproj in Xcode
2. Go to **File > New > Target**
3. Select **macOS** tab
4. Choose **System Extension** template
5. Click **Next**

Configuration:
- **Product Name**: DiskDevilExtension
- **Bundle Identifier**: com.diskdevil.extension
- **Language**: Swift
- **Include Tests**: No (optional)

Click **Finish**

### Step 2: Configure Extension Target

#### A. Set Deployment Target
- Select DiskDevilExtension target
- Set **Deployment Target** to macOS 11.0 or later

#### B. Add Required Frameworks
- Select DiskDevilExtension target
- Go to **Build Phases > Link Binary With Libraries**
- Add:
  - NetworkExtension.framework
  - SystemExtensions.framework

#### C. Configure Extension Info.plist

Add to DiskDevilExtension's Info.plist:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.networkextension.filter-data</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).FilterDataProvider</string>
</dict>
```

### Step 3: Create FilterDataProvider

Create new file `FilterDataProvider.swift` in DiskDevilExtension target:

```swift
import NetworkExtension
import os.log

class FilterDataProvider: NEFilterDataProvider {
    
    private let logger = Logger(subsystem: "com.diskdevil.extension", category: "filter")
    private var filterRules: [NetworkFilterRule] = []
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting DiskDevil network filter...")
        
        // Load rules from shared container
        loadRulesFromSharedContainer()
        
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping filter, reason: \(reason.rawValue)")
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Check if flow should be blocked based on rules
        if shouldBlockFlow(flow) {
            logger.info("Blocking flow to: \(flow.url?.host ?? "unknown")")
            return .drop()
        }
        
        return .allow()
    }
    
    private func loadRulesFromSharedContainer() {
        guard let sharedContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.diskdevil.shared"
        ) else {
            logger.error("Cannot access shared container")
            return
        }
        
        let rulesURL = sharedContainer.appendingPathComponent("filter-rules.json")
        
        guard let data = try? Data(contentsOf: rulesURL),
              let rules = try? JSONDecoder().decode([NetworkFilterRule].self, from: data) else {
            logger.error("Cannot load filter rules")
            return
        }
        
        filterRules = rules
        logger.info("Loaded \(rules.count) filter rules")
    }
    
    private func shouldBlockFlow(_ flow: NEFilterFlow) -> Bool {
        guard let url = flow.url else { return false }
        
        // Check each rule
        for rule in filterRules where rule.action == .block {
            if matchesRule(url: url, rule: rule) {
                return true
            }
        }
        
        return false
    }
    
    private func matchesRule(url: URL, rule: NetworkFilterRule) -> Bool {
        guard let host = url.host else { return false }
        
        switch rule.condition.type {
        case .domain:
            return host == rule.condition.pattern
            
        case .domainSuffix:
            return host.hasSuffix(rule.condition.pattern)
            
        case .category:
            // Implement category matching (requires maintaining category lists)
            return false
            
        default:
            return false
        }
    }
}
```

### Step 4: Share NetworkFilterRule Definition

The extension needs access to `NetworkFilterRule` struct. Options:

**Option A: Create Shared Framework** (Recommended)
1. Create new framework target: **File > New > Target > Framework**
2. Name it **DiskDevilShared**
3. Move `NetworkFilterProtocol.swift` to this framework
4. Link both app and extension to this framework

**Option B: Add Files to Both Targets**
1. Select `NetworkFilterProtocol.swift`
2. In File Inspector, check both targets:
   - DiskDevil (app)
   - DiskDevilExtension

### Step 5: Configure Entitlements

#### Main App (DiskDevil.entitlements)

Already configured with:
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>content-filter-provider</string>
    <string>packet-tunnel-provider</string>
    <string>dns-proxy</string>
</array>

<key>com.apple.developer.system-extension.install</key>
<true/>

<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.diskdevil.shared</string>
</array>
```

#### Extension (DiskDevilExtension.entitlements)

Create new entitlements file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>content-filter-provider</string>
    </array>
    
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.diskdevil.shared</string>
    </array>
</dict>
</plist>
```

### Step 6: Configure Code Signing

Both targets need proper signing:

1. **Main App Target**:
   - Signing & Capabilities tab
   - Enable **App Sandbox**
   - Enable **System Extension**
   - Add **App Groups** capability: `group.com.diskdevil.shared`
   - Sign with Developer ID Application certificate

2. **Extension Target**:
   - Sign with Developer ID Application certificate
   - Add **App Groups** capability: `group.com.diskdevil.shared`
   - Extension must be embedded in app bundle

### Step 7: Implement Extension Installation UI

Create a new view for extension management:

```swift
// ExtensionInstallationView.swift

import SwiftUI
import SystemExtensions

struct ExtensionInstallationView: View {
    @StateObject private var installer = ExtensionInstaller()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
            
            Text("Network Extension Setup")
                .font(.title)
            
            Text(installer.statusMessage)
                .foregroundColor(.secondary)
            
            Button("Install Extension") {
                installer.installExtension()
            }
            .disabled(installer.isInstalling)
        }
        .padding()
    }
}

class ExtensionInstaller: NSObject, ObservableObject, OSSystemExtensionRequestDelegate {
    @Published var statusMessage = "Extension not installed"
    @Published var isInstalling = false
    
    func installExtension() {
        isInstalling = true
        statusMessage = "Requesting extension installation..."
        
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: "com.diskdevil.extension",
            queue: .main
        )
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        isInstalling = false
        statusMessage = "Extension installed successfully!"
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        isInstalling = false
        statusMessage = "Installation failed: \(error.localizedDescription)"
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        statusMessage = "Please approve in System Settings > Privacy & Security"
    }
    
    func request(_ request: OSSystemExtensionRequest,
                actionForReplacingExtension existing: OSSystemExtensionProperties,
                withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        return .replace
    }
}
```

### Step 8: Update PrivacyEngine to Use Real Extension

Once extension is installed, update initialization:

```swift
// In PrivacyEngine.swift init()
if #available(macOS 11.0, *) {
    // Check if extension is installed
    if isExtensionInstalled() {
        self.networkFilter = NetworkExtensionFilter()
    } else {
        self.networkFilter = SimulatedNetworkFilter()
    }
} else {
    self.networkFilter = SimulatedNetworkFilter()
}

private func isExtensionInstalled() -> Bool {
    // Implement check using SystemExtensions framework
    // For now, you can manually check after installation
    return UserDefaults.standard.bool(forKey: "networkExtensionInstalled")
}
```

### Step 9: Testing

#### Build and Run
1. Build both targets
2. Run main app
3. Navigate to extension installation view
4. Click "Install Extension"
5. Approve in System Settings when prompted
6. Verify extension is running:
   ```bash
   systemextensionsctl list
   ```

#### Test Filtering
1. Enable privacy protection in app
2. Set privacy level
3. Monitor system log:
   ```bash
   log stream --predicate 'subsystem == "com.diskdevil.extension"' --level debug
   ```

#### Debug Extension
- Extensions run in separate process
- Use `os_log` for logging
- Check Console.app for extension logs
- Use Activity Monitor to see extension process

### Step 10: Distribution

#### For Testing (Development)
- Notarize both app and extension
- Distribute as DMG or ZIP

#### For App Store
- Submit with extension embedded
- Include explanation of NetworkExtension usage
- Provide test account if needed
- Expect extended review time (Apple manually reviews system extensions)

## Troubleshooting

### Extension Not Loading
- Check code signing: `codesign -dvvv /path/to/extension`
- Verify entitlements: `codesign -d --entitlements - /path/to/extension`
- Check System Settings > Privacy & Security for approval status

### Rules Not Applying
- Verify App Group container is accessible
- Check rules file is being written correctly
- Verify extension can read from shared container
- Check extension logs for errors

### Performance Issues
- Optimize rule matching logic
- Use efficient data structures for large rule sets
- Profile extension with Instruments
- Consider caching frequently checked domains

## Next Steps

1. **Complete FilterDataProvider Implementation**
   - Implement full rule matching logic
   - Add support for all condition types
   - Optimize performance

2. **Add Statistics Collection**
   - Track blocked connections
   - Send statistics back to main app via XPC
   - Update UI with real data

3. **Implement XPC Communication**
   - Set up XPC service for app-extension communication
   - Send rule updates in real-time
   - Query statistics from extension

4. **Testing & Validation**
   - Test with various applications
   - Verify no system instability
   - Performance testing under load
   - Memory leak detection

5. **Submit for Review**
   - Prepare App Store listing
   - Create screenshots and videos
   - Write detailed review notes
   - Submit for Apple approval

## Resources

- [Apple NetworkExtension Documentation](https://developer.apple.com/documentation/networkextension)
- [System Extensions Documentation](https://developer.apple.com/documentation/systemextensions)
- [App Groups Guide](https://developer.apple.com/documentation/xcode/configuring-app-groups)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)

## Support

For issues or questions:
- Check implementation examples in NetworkExtensionFilter.swift
- Review Apple's sample code
- Check DiskDevil documentation
- Report issues on GitHub

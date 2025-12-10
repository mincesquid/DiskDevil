# Release Readiness Checklist

This checklist collects the required items to prepare DiskDevil for macOS App Store submission. Use this in combination with `STOREKIT_SETUP.md` and `IMPLEMENTATION.md`.

## High-level milestones (must complete before submitting)

### Build & Code Signing
- [ ] App is a signed, reproducible Xcode build (Xcode project / workspace present)
  - Current Status: Swift Package Manager project exists
  - **ACTION REQUIRED**: Open in Xcode and configure build settings
  - Location: `/Users/triple3ees/Documents/DiskDevil`
- [ ] App bundle identifier configured (recommended: `com.diskdevil.DiskDevil`)
- [ ] Developer certificate configured (Apple Developer Program required)
- [ ] Provisioning profile created and configured

### Visual Assets
- [ ] App icon set created (`.xcassets` with macOS AppIcon)
  - **STATUS**: ✅ Asset catalog structure created at `Assets.xcassets/AppIcon.appiconset/`
  - **ACTION REQUIRED**: Add actual icon PNG files (see `Assets.xcassets/AppIcon.appiconset/README.md`)
  - Required sizes: 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024
- [ ] App screenshots for Mac App Store uploaded
  - Required: At least 1 screenshot (recommended: 3-5)
  - Size: 1280x800, 1440x900, 2880x1800, or 2560x1600
  - Show key features: Dashboard, Privacy Slider, Security Scanner, Network Monitor

### Legal & Documentation
- [ ] Privacy Policy and Terms of Service consistent and online
  - **ACTION REQUIRED**: Create and host at URLs specified in `Models/Constants.swift`:
    - Privacy Policy: https://diskdevil.app/privacy
    - Terms of Service: https://diskdevil.app/terms
    - Support: https://diskdevil.app/support
  - See "Privacy Policy Template" section below
- [ ] App Store Connect metadata completed (description, support URL, marketing copy)
- [ ] Copyright information updated in Info.plist

### In-App Purchases & Subscriptions
- [ ] All in-app products created in App Store Connect
  - Premium Monthly: `com.diskdevil.premium.monthly` ($9.99/mo)
  - Premium Yearly: `com.diskdevil.premium.yearly` ($95.99/yr)
  - Elite Monthly: `com.diskdevil.elite.monthly` ($19.99/mo)
  - Elite Yearly: `com.diskdevil.elite.yearly` ($191.99/yr)
- [ ] Product IDs match code (verified in `Models/Constants.swift:44-47`)
- [ ] Subscription group created ("DiskDevil Pro" or similar)
- [ ] Pricing configured for all territories
- [ ] Sandbox purchases tested
- [ ] Restore functionality verified
- [ ] Free trial configured (optional but recommended: 7-day free trial)

### Permissions & Entitlements
- [ ] Full Disk Access & System Extension entitlements defined
  - **STATUS**: ✅ Entitlements file created at `DiskDevil.entitlements`
  - **ACTION REQUIRED**: Review and test with proper prompts
- [ ] Info.plist usage descriptions added
  - **STATUS**: ✅ Info.plist created with all required usage descriptions
  - Includes: Full Disk Access, Network, Files & Folders, System Extension
- [ ] Full Disk Access permission flow tested
  - App should detect permission status (see `Models/PermissionManager.swift`)
  - App should prompt user with clear instructions
  - App should gracefully handle denial

### NetworkExtension Implementation
- [ ] NetworkExtension-based functionality implemented (not simulated) or clearly labeled if non-functional
  - **CURRENT STATUS**: Simulated (see `IMPLEMENTATION.md`)
  - **OPTIONS**:
    1. Implement real NetworkExtension (see `IMPLEMENTATION.md` for guide)
    2. Remove NetworkExtension entitlements and update app description to reflect actual capabilities
    3. Clearly label as "Coming Soon" feature in UI
  - **IMPORTANT**: Apple may reject if you claim network filtering but don't implement it

### Testing & Quality
- [ ] Unit tests pass locally and in CI
  - Run: `swift test`
  - Tests location: `Tests/`
- [ ] No lint/format errors
  - Run: `swiftlint`
  - Run: `swiftformat --lint .`
- [ ] Manual testing completed:
  - [ ] App launches without crashes
  - [ ] All major features work (Dashboard, Cleanup, Security Scanner, Privacy Slider)
  - [ ] Subscription purchase flow works end-to-end
  - [ ] Restore purchases works
  - [ ] Free tier limits enforced correctly
  - [ ] Premium/Elite features unlock after purchase
  - [ ] App handles permission denials gracefully
  - [ ] Menu bar icon functions properly
  - [ ] Settings persist across app restarts

### Logging & Telemetry
- [ ] Console logging is appropriate
  - **STATUS**: Uses `os.log` framework (see `Models/Logger.swift`)
  - **ACTION REQUIRED**: Review log levels (ensure no sensitive data logged in production)
- [ ] Telemetry consent is documented
  - **ACTION REQUIRED**: Add telemetry opt-in/opt-out in Settings if collecting analytics
  - Document what data is collected in Privacy Policy

## Files you should add to the repo before submission

### Required Files (Created)
- ✅ `Info.plist` — App bundle metadata and human-readable usage descriptions
- ✅ `DiskDevil.entitlements` — App entitlements for NetworkExtension/system extensions and Full Disk Access
- ✅ `Assets.xcassets/AppIcon.appiconset` — App icons for all required sizes (structure created, images needed)

### Optional but Recommended Files
- [ ] `Fastlane/metadata/` — Localized metadata for App Store Connect automation
  - Automates screenshot upload, metadata, and submission
  - See: https://docs.fastlane.tools/actions/deliver/
- [ ] `ExportOptions.plist` — Export configuration for Xcode builds
- [ ] `CHANGELOG.md` — Version history for users and reviewers
- [ ] `CREDITS.md` — Third-party licenses and attributions

## Xcode Project Configuration

Since this is currently a Swift Package Manager project, you need to configure it for Xcode:

### Option 1: Convert to Xcode Project (Recommended for App Store)
1. Open Xcode
2. Create new macOS App project: File > New > Project > macOS > App
3. Name: DiskDevil
4. Organization Identifier: `com.diskdevil` (or your reverse domain)
5. Interface: SwiftUI
6. Language: Swift
7. Copy all Swift files from `Models/` into the Xcode project
8. Add `Info.plist` to the project
9. Add `DiskDevil.entitlements` to the project
10. Add `Assets.xcassets` to the project
11. Configure Build Settings:
    - Signing & Capabilities: Add your Apple Developer account
    - Enable App Sandbox
    - Add capabilities: Network, File Access, In-App Purchase
12. Archive and test

### Option 2: Continue with SPM (Advanced)
1. Open `Package.swift` in Xcode
2. Configure scheme for macOS app target
3. Add Info.plist and entitlements via build settings
4. This is less common for App Store apps but possible

## App Store Connect Setup

### 1. Create App Record
1. Go to https://appstoreconnect.apple.com
2. My Apps > + > New App
3. Platforms: macOS
4. Name: DiskDevil
5. Primary Language: English (US)
6. Bundle ID: Select/create `com.diskdevil.DiskDevil`
7. SKU: `diskdevil-macos-2025`
8. User Access: Full Access

### 2. App Information
- **Subtitle**: "Security & Privacy Suite for macOS"
- **Category**: Utilities (Primary), Developer Tools (Secondary)
- **Privacy Policy URL**: https://diskdevil.app/privacy
- **Support URL**: https://diskdevil.app/support
- **Marketing URL**: https://diskdevil.app (optional)

### 3. Pricing and Availability
- Price: Free (with in-app subscriptions)
- Availability: All territories
- Pre-order: No (for first release)

### 4. App Description (Suggestion)

```
DiskDevil: Unleash Your Mac's Full Potential

Take control of your Mac's security, privacy, and performance with DiskDevil – the ultimate system utility suite.

KEY FEATURES:
• Smart Cleanup: Reclaim gigabytes of disk space by removing system junk, caches, and unnecessary files
• Security Scanner: Detect malware, suspicious processes, and system vulnerabilities
• Privacy Protection: Block trackers and telemetry with 10 customizable privacy levels
• Hidden Files Browser: Reveal and manage hidden system files with ease
• Network Monitor: Track connections and detect suspicious network activity
• Recovery Tools: Restore deleted files and repair disk permissions (Premium)
• System Optimization: Speed up your Mac with one-click maintenance

FREEMIUM MODEL:
• Free tier includes Smart Cleanup with daily limits on premium features
• Premium unlocks unlimited scans, privacy levels 1-9, and recovery tools
• Elite tier adds maximum paranoia mode, advanced threat detection, and priority support

SUBSCRIPTION TIERS:
• Premium: $9.99/month or $95.99/year
• Elite: $19.99/month or $191.99/year

DiskDevil integrates seamlessly with macOS and respects your privacy. We don't collect personal data without your consent.

Download now and give your Mac the security it deserves!
```

### 5. Keywords (100 character limit)
```
disk cleanup,security,privacy,malware,system utility,optimization,hidden files,network monitor
```

### 6. Screenshots
Required: 3-5 screenshots at these sizes:
- 1280x800 (16:10)
- 1440x900 (16:10)
- 2880x1800 (Retina)
- 2560x1600 (16:10)

Suggested screenshots:
1. Dashboard view showing overall system status
2. Privacy Slider with level 10 "MAXIMUM PARANOIA"
3. Security Scanner showing scan results
4. Network Monitor with connection list
5. Upgrade view showing subscription tiers

### 7. Version Information
- Version: 1.0
- Build: 1
- What's New in This Version: "Initial release of DiskDevil"

### 8. Content Rights
- Age Rating: 4+
- Export Compliance: No (unless you implement encryption)

## Privacy Policy Template

Save this to `privacy.html` and host at https://diskdevil.app/privacy:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>DiskDevil Privacy Policy</title>
</head>
<body>
    <h1>Privacy Policy for DiskDevil</h1>
    <p><strong>Effective Date:</strong> [INSERT DATE]</p>

    <h2>Information We Collect</h2>
    <p>DiskDevil is designed with privacy in mind. We collect minimal information:</p>
    <ul>
        <li><strong>Purchase Information:</strong> Subscription status is managed by Apple. We receive anonymized transaction IDs to verify purchases.</li>
        <li><strong>Local System Data:</strong> DiskDevil scans your Mac for security issues and disk usage. This data stays on your device and is never transmitted to our servers.</li>
        <li><strong>Optional Analytics:</strong> If you opt in, we may collect anonymized usage statistics to improve the app (feature usage, crash reports). This can be disabled in Settings.</li>
    </ul>

    <h2>How We Use Your Information</h2>
    <ul>
        <li>To provide and improve DiskDevil's features</li>
        <li>To verify your subscription status</li>
        <li>To respond to support requests</li>
    </ul>

    <h2>Data Sharing</h2>
    <p>We do not sell or share your personal information with third parties. Subscription purchases are processed by Apple.</p>

    <h2>Data Security</h2>
    <p>All data analyzed by DiskDevil remains on your device. Network monitoring and security scans are performed locally.</p>

    <h2>Your Rights</h2>
    <p>You can:</p>
    <ul>
        <li>Cancel your subscription at any time via System Settings > Apple ID > Subscriptions</li>
        <li>Delete the app to remove all local data</li>
        <li>Opt out of analytics in DiskDevil Settings</li>
    </ul>

    <h2>Contact</h2>
    <p>For privacy questions, email: privacy@diskdevil.app</p>

    <h2>Changes to This Policy</h2>
    <p>We may update this policy. Continued use after changes constitutes acceptance.</p>
</body>
</html>
```

## Terms of Service Template

Save this to `terms.html` and host at https://diskdevil.app/terms:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>DiskDevil Terms of Service</title>
</head>
<body>
    <h1>Terms of Service for DiskDevil</h1>
    <p><strong>Effective Date:</strong> [INSERT DATE]</p>

    <h2>Acceptance of Terms</h2>
    <p>By downloading and using DiskDevil, you agree to these Terms of Service.</p>

    <h2>License</h2>
    <p>DiskDevil is licensed, not sold. You may use DiskDevil on any Mac you own or control.</p>

    <h2>Subscriptions</h2>
    <ul>
        <li><strong>Auto-Renewal:</strong> Subscriptions automatically renew unless canceled 24 hours before the end of the current period.</li>
        <li><strong>Cancellation:</strong> Cancel anytime in System Settings > Apple ID > Subscriptions.</li>
        <li><strong>Refunds:</strong> Managed by Apple per their refund policy.</li>
        <li><strong>Free Trial:</strong> If offered, auto-converts to paid subscription unless canceled.</li>
    </ul>

    <h2>Acceptable Use</h2>
    <p>You agree not to:</p>
    <ul>
        <li>Reverse engineer or modify DiskDevil</li>
        <li>Use DiskDevil for illegal purposes</li>
        <li>Circumvent subscription systems</li>
    </ul>

    <h2>Disclaimer of Warranties</h2>
    <p>DiskDevil is provided "as is" without warranty. We are not liable for data loss or system damage. Always backup your data before using system utilities.</p>

    <h2>Limitation of Liability</h2>
    <p>We are not liable for any damages arising from use of DiskDevil, including data loss, system corruption, or security breaches.</p>

    <h2>Termination</h2>
    <p>We may terminate your access if you violate these terms.</p>

    <h2>Contact</h2>
    <p>For support: support@diskdevil.app</p>
</body>
</html>
```

## Helpful Guidance

### System / Network Extensions
- If you use System / Network Extensions, the app must request user consent and use correct entitlements
- See macOS docs on System Extensions and NetworkExtensions
- **IMPORTANT**: These require special entitlement approval from Apple
- Apply at: https://developer.apple.com/contact/request/system-extension/

### Security Feature Claims
- Apple will reject or require clarifications for apps that advertise security features (like blocking or removing malware) but do not implement them
- Ensure your NetworkExtension implementation is real and tested, OR remove claims about network filtering
- Current status: Network filtering is simulated (`PrivacyEngine.swift` uses mock data)
- **Action**: Either implement real NetworkExtension (see `IMPLEMENTATION.md`) or update marketing copy

### Full Disk Access
- Apps cannot programmatically request Full Disk Access
- User must manually grant in System Settings > Privacy & Security > Full Disk Access
- Your app should:
  1. Detect if permission is granted (done in `PermissionManager.swift`)
  2. Show clear instructions when permission is needed
  3. Gracefully degrade if permission is denied

### Testing Checklist Before Submission
- [ ] Test on a clean Mac (not your development machine)
- [ ] Test with a fresh App Store sandbox account
- [ ] Test subscription purchase flow
- [ ] Test subscription restore
- [ ] Test all features without Full Disk Access (graceful degradation)
- [ ] Test all features with Full Disk Access
- [ ] Test free tier limits (3 reveals, 3 network sessions, 2 scans)
- [ ] Verify limits reset at midnight
- [ ] Test upgrade flow from each limit modal
- [ ] Test cancellation and downgrade flows

## Next Steps (Prioritized)

1. **CRITICAL** - Create app icons (see `Assets.xcassets/AppIcon.appiconset/README.md`)
2. **CRITICAL** - Host Privacy Policy and Terms of Service at specified URLs
3. **CRITICAL** - Convert SPM project to Xcode project for code signing
4. **HIGH** - Create App Store Connect record and configure subscriptions
5. **HIGH** - Decide on NetworkExtension: implement or remove claims
6. **MEDIUM** - Take App Store screenshots
7. **MEDIUM** - Test subscription flows in sandbox
8. **LOW** - Set up Fastlane for automated deployment (optional)

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [macOS App Store Submission Guide](https://developer.apple.com/macos/submit/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [NetworkExtension Documentation](https://developer.apple.com/documentation/networkextension)
- [App Sandbox Design Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- [Human Interface Guidelines - macOS](https://developer.apple.com/design/human-interface-guidelines/macos)

## Current Project Status Summary

### ✅ Completed
- Swift codebase with full UI implementation
- StoreKit 2 integration with proper product IDs
- Usage limits system for freemium model
- Subscription tiers defined (Free, Premium, Elite)
- Info.plist with all required usage descriptions
- Entitlements file with necessary permissions
- Asset catalog structure for app icons
- Comprehensive documentation (this file, STOREKIT_SETUP.md, IMPLEMENTATION.md)

### ⚠️ In Progress / Needs Attention
- App icons (structure created, images needed)
- Xcode project configuration for App Store builds
- Privacy Policy and Terms of Service hosting
- App Store Connect setup
- NetworkExtension implementation (currently simulated)

### ❌ Not Started
- App Store screenshots
- Sandbox testing of subscriptions
- Production code signing
- Notarization for distribution
- App Store submission

---

Last Updated: 2025-12-09
Version: 1.0

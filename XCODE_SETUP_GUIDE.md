# Xcode Setup Guide for DiskDevil

This guide walks you through converting the Swift Package Manager (SPM) project to an Xcode project suitable for Mac App Store submission.

## Quick Start

### Option 1: Open in Xcode Directly (Recommended for Development)
1. Open Xcode
2. File > Open
3. Navigate to `/Users/triple3ees/Documents/DiskDevil`
4. Select `Package.swift`
5. Click Open

Xcode will automatically create a workspace for the Swift Package. However, for App Store submission, you'll need to create a proper app target.

### Option 2: Create New Xcode App Project (Recommended for App Store)

This is the recommended approach for App Store distribution.

## Step-by-Step: Create Xcode App Project

### 1. Create New macOS App Project

1. **Open Xcode**
2. **File > New > Project**
3. Select **macOS** tab at the top
4. Choose **App** template
5. Click **Next**

### 2. Configure Project Settings

Fill in the following details:

- **Product Name:** `DiskDevil`
- **Team:** Select your Apple Developer account (required for code signing)
  - If you don't have a team, add one in Xcode Preferences > Accounts
- **Organization Identifier:** `com.diskdevil` (or your reverse domain)
  - This creates Bundle ID: `com.diskdevil.DiskDevil`
- **Interface:** SwiftUI
- **Language:** Swift
- **Use Core Data:** ❌ Uncheck
- **Include Tests:** ✅ Check

Click **Next**, then choose `/Users/triple3ees/Documents/` as the save location.
Name the folder `DiskDevil-Xcode` to keep it separate from the SPM version.

### 3. Add Existing Swift Files

1. Delete the default `DiskDevilApp.swift` and `ContentView.swift` that Xcode created
2. In Finder, open `/Users/triple3ees/Documents/DiskDevil/Models/`
3. Select all `.swift` files (⌘A)
4. Drag them into the Xcode project navigator
5. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Ensure target "DiskDevil" is checked
6. Click **Finish**

### 4. Add Asset Catalog

1. Delete the default `Assets.xcassets` that Xcode created
2. In Finder, navigate to `/Users/triple3ees/Documents/DiskDevil/`
3. Drag `Assets.xcassets` into the Xcode project
4. In the dialog:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
5. Click **Finish**

### 5. Add Info.plist

1. In the Xcode project navigator, select the `DiskDevil` project (blue icon at top)
2. Select the `DiskDevil` target
3. Click the **Info** tab
4. Right-click in the property list and choose **Show Raw Keys/Values**
5. Open `/Users/triple3ees/Documents/DiskDevil/Info.plist` in a text editor
6. Copy all the custom keys (usage descriptions, etc.) and paste into Xcode

**Alternatively:**
1. In Finder, drag `Info.plist` into your Xcode project
2. In the target's **Build Settings**, search for "Info.plist File"
3. Set the path to `DiskDevil/Info.plist`

### 6. Add Entitlements File

1. In Xcode, select the `DiskDevil` target
2. Click the **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add these capabilities:
   - **App Sandbox** (required for Mac App Store)
   - **Network** (Client + Server)
   - **Outgoing Connections (Client)**
   - **File Access** (User Selected Files: Read/Write, Downloads Folder: Read/Write)
   - **In-App Purchase**

5. Xcode will auto-generate `DiskDevil.entitlements`
6. Open `/Users/triple3ees/Documents/DiskDevil/DiskDevil.entitlements` in a text editor
7. Copy the custom entitlements (NetworkExtension, etc.) into the Xcode-generated file

**Or manually add the entitlements file:**
1. Drag `DiskDevil.entitlements` from Finder into Xcode project
2. In target's **Build Settings**, search for "Code Signing Entitlements"
3. Set to `DiskDevil/DiskDevil.entitlements`

### 7. Configure Build Settings

#### Signing & Capabilities
1. Select the `DiskDevil` target
2. Go to **Signing & Capabilities** tab
3. **Automatically manage signing:** ✅ Check (recommended)
4. **Team:** Select your Apple Developer account
5. **Bundle Identifier:** Verify it's `com.diskdevil.DiskDevil`

#### General Settings
1. Go to **General** tab
2. **Minimum Deployments:** macOS 13.0
3. **App Category:** Utilities
4. **Copyright:** © 2025 DiskDevil. All rights reserved.

#### Build Settings (Advanced)
1. Go to **Build Settings** tab
2. Search for "Swift Language Version"
   - Set to **Swift 5**
3. Search for "Optimization Level"
   - Debug: **No Optimization [-Onone]**
   - Release: **Optimize for Speed [-O]**
4. Search for "Enable Hardened Runtime"
   - Set to **Yes** (required for notarization)

### 8. Configure App Sandbox (Required for Mac App Store)

1. Select the `DiskDevil` target
2. **Signing & Capabilities** tab
3. Under **App Sandbox**, configure:

**File Access:**
- ✅ User Selected File: Read/Write
- ✅ Downloads Folder: Read/Write

**Network:**
- ✅ Outgoing Connections (Client)
- ✅ Incoming Connections (Server) - if needed for network monitoring

**Hardware:**
- ✅ USB (for external drive scanning)

**App Data:**
- ✅ Contacts (if needed)
- ❌ Location (not needed)
- ❌ Calendar (not needed)

### 9. Add Test Files (Optional)

1. In Finder, navigate to `/Users/triple3ees/Documents/DiskDevil/Tests/`
2. Drag all test files into the `DiskDevilTests` group in Xcode
3. Ensure they're added to the test target

### 10. Configure StoreKit Configuration File (For Testing)

1. **File > New > File**
2. Choose **StoreKit Configuration File**
3. Name it `DiskDevil.storekit`
4. Click **Create**

5. Click **+** button to add products:

**Product 1: Premium Monthly**
- Reference Name: `DiskDevil Premium Monthly`
- Product ID: `com.diskdevil.premium.monthly`
- Type: Auto-Renewable Subscription
- Subscription Duration: 1 Month
- Price: $9.99
- Localization: English (US)

**Product 2: Premium Yearly**
- Reference Name: `DiskDevil Premium Yearly`
- Product ID: `com.diskdevil.premium.yearly`
- Type: Auto-Renewable Subscription
- Subscription Duration: 1 Year
- Price: $95.99

**Product 3: Elite Monthly**
- Reference Name: `DiskDevil Elite Monthly`
- Product ID: `com.diskdevil.elite.monthly`
- Type: Auto-Renewable Subscription
- Subscription Duration: 1 Month
- Price: $19.99

**Product 4: Elite Yearly**
- Reference Name: `DiskDevil Elite Yearly`
- Product ID: `com.diskdevil.elite.yearly`
- Type: Auto-Renewable Subscription
- Subscription Duration: 1 Year
- Price: $191.99

6. **Enable StoreKit Configuration:**
   - Product > Scheme > Edit Scheme
   - Run > Options tab
   - StoreKit Configuration: Select `DiskDevil.storekit`

## Build and Run

### 1. First Build

1. Select the `DiskDevil` scheme in Xcode toolbar
2. Select "My Mac" as the destination
3. Press **⌘R** to build and run

**Expected Issues:**
- Missing Package Dependencies: If the project uses any Swift Package Manager dependencies, add them via File > Add Packages
- Missing `@main` entry point: Ensure `DiskDevilApp.swift` has `@main` attribute

### 2. Fix Any Build Errors

Common errors and fixes:

**Error: "Cannot find 'AppLogger' in scope"**
- Ensure `Logger.swift` is included in the project
- Check that `import os.log` is present

**Error: "Cannot find type 'AeroTheme' in scope"**
- Ensure `Theme.swift` is included in the project

**Error: Missing StoreKit import**
- Add `import StoreKit` at the top of `StoreKitManager.swift`

### 3. Test Subscriptions Locally

1. Build and run the app (⌘R)
2. Navigate to the Upgrade view
3. Try purchasing a subscription
4. The StoreKit configuration file will simulate the purchase
5. Check Console for transaction logs

**To test restore purchases:**
1. In Xcode menu: Debug > StoreKit > Delete All Transactions
2. Quit and relaunch the app
3. Click "Restore Previous Purchase"

## Prepare for App Store Submission

### 1. Create App Icon

1. See `Assets.xcassets/AppIcon.appiconset/README.md` for instructions
2. Add all required icon sizes to the asset catalog
3. Required sizes:
   - 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024

### 2. Archive the App

1. **Product > Archive**
2. Wait for the archive to complete
3. The Organizer window will open

### 3. Validate the App

1. In Organizer, select the archive
2. Click **Validate App**
3. Select your distribution method: **App Store Connect**
4. Choose distribution options:
   - ✅ Upload your app's symbols to receive symbolicated crash reports
   - ✅ Manage Version and Build Number (recommended)
5. Click **Validate**

**Fix any validation errors before proceeding**

### 4. Upload to App Store Connect

1. Once validation passes, click **Distribute App**
2. Select **App Store Connect**
3. Choose upload options (same as validation)
4. Click **Upload**
5. Wait for upload to complete (may take 10-30 minutes)

### 5. Complete App Store Connect Metadata

1. Go to https://appstoreconnect.apple.com
2. Select your app
3. Fill in all required metadata (see `RELEASE_READINESS.md`)
4. Upload screenshots
5. Submit for review

## Troubleshooting

### App Crashes on Launch

**Symptom:** App builds but crashes immediately

**Fix:**
1. Check Console.app for crash logs
2. Ensure all `@StateObject` and `@EnvironmentObject` are properly initialized
3. Verify all required files are included in the target

### Permissions Not Working

**Symptom:** Full Disk Access detection fails

**Fix:**
1. Ensure `Info.plist` usage descriptions are present
2. Check that entitlements file is properly configured
3. Run the app outside of Xcode (Product > Archive > Export > Export as Mac application)
4. Grant Full Disk Access in System Settings manually

### StoreKit Not Loading Products

**Symptom:** Subscription products show as unavailable

**Fix:**
1. Verify StoreKit configuration file is selected in scheme
2. Check product IDs match exactly between code and StoreKit config
3. Ensure you're running in Debug mode (not Release)
4. Clear StoreKit cache: Debug > StoreKit > Delete All Transactions

### Code Signing Errors

**Symptom:** "Failed to register bundle identifier"

**Fix:**
1. Go to https://developer.apple.com/account/
2. Certificates, Identifiers & Profiles > Identifiers
3. Create new App ID: `com.diskdevil.DiskDevil`
4. Enable capabilities: In-App Purchase, Network Extensions
5. Refresh Xcode: Preferences > Accounts > Download Manual Profiles

## Next Steps

After successful Xcode setup:

1. ✅ Test all features in the app
2. ✅ Run unit tests: Product > Test (⌘U)
3. ✅ Fix any SwiftLint warnings: `swiftlint` in Terminal
4. ✅ Create app screenshots
5. ✅ Archive and validate
6. ✅ Upload to App Store Connect
7. ✅ Submit for review

## Resources

- [Xcode Help](https://developer.apple.com/documentation/xcode)
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)

## Need Help?

If you encounter issues not covered here:

1. Check the main documentation files:
   - `RELEASE_READINESS.md` - Submission checklist
   - `IMPLEMENTATION.md` - Technical implementation details
   - `STOREKIT_SETUP.md` - Subscription setup guide

2. Apple Developer Forums: https://developer.apple.com/forums/
3. Stack Overflow: Tag your question with `xcode`, `swiftui`, `macos`

---

**Last Updated:** December 9, 2024
**For DiskDevil Version:** 1.0

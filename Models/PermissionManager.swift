//
//  PermissionManager.swift
//  DiskDevil
//
//  Manages system permissions and user authorization
//

import AppKit
import Foundation
import os.log

// MARK: - PermissionManager

class PermissionManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        checkPermissions()
        startPeriodicPermissionCheck()
    }

    // MARK: Internal

    @Published var hasFullDiskAccess = false
    @Published var hasNetworkExtension = false
    @Published var lastPermissionCheck = Date()

    /// Check all permissions (can be called manually to refresh)
    func checkPermissions() {
        checkFullDiskAccess()
        checkNetworkExtensionPermission()
        lastPermissionCheck = Date()
    }

    /// Check Full Disk Access permission by attempting to access protected directories
    func checkFullDiskAccess() {
        let fm = FileManager.default

        // Method 1: Check system TCC database (most reliable)
        let systemTCCPath = "/Library/Application Support/com.apple.TCC/"
        if fm.isReadableFile(atPath: systemTCCPath) {
            hasFullDiskAccess = true
            AppLogger.permissions.info("Full Disk Access: Granted (system TCC readable)")
            return
        }

        // Method 2: Try to list contents of user's TCC directory
        let userTCCPath = NSHomeDirectory() + "/Library/Application Support/com.apple.TCC/"
        do {
            _ = try fm.contentsOfDirectory(atPath: userTCCPath)
            hasFullDiskAccess = true
            AppLogger.permissions.info("Full Disk Access: Granted (user TCC readable)")
            return
        } catch {
            // Expected error if FDA not granted
        }

        // Method 3: Try to access user's Safari directory (also protected)
        let safariPath = NSHomeDirectory() + "/Library/Safari/"
        if fm.isReadableFile(atPath: safariPath) {
            do {
                _ = try fm.contentsOfDirectory(atPath: safariPath)
                hasFullDiskAccess = true
                AppLogger.permissions.info("Full Disk Access: Granted (Safari directory readable)")
                return
            } catch {
                // Expected error if FDA not granted
            }
        }

        hasFullDiskAccess = false
        AppLogger.permissions.warning("Full Disk Access: Not granted")
    }

    /// Check Network Extension permission status
    func checkNetworkExtensionPermission() {
        // TODO: Implement NetworkExtension check when extension is implemented
        // For now, always false since NetworkExtension is not yet implemented
        hasNetworkExtension = false
        AppLogger.permissions.info("Network Extension: Not implemented (simulated mode)")
    }

    /// Request Full Disk Access from user with clear instructions
    func requestFullDiskAccess() {
        AppLogger.permissions.info("User prompted for Full Disk Access")

        let alert = NSAlert()
        alert.messageText = "Full Disk Access Required"
        alert.informativeText = """
        DiskDevil needs Full Disk Access to scan system files and perform cleanup operations.

        Steps to grant access:
        1. Click "Open System Settings" below
        2. In Privacy & Security, click "Full Disk Access"
        3. Click the lock icon (🔒) and authenticate
        4. Find DiskDevil in the list and enable the toggle
        5. Quit and restart DiskDevil for changes to take effect

        Without this permission, some features will be limited:
        • Deep system file scanning
        • Security vulnerability detection
        • Hidden file discovery
        • System cleanup operations
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Maybe Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openFullDiskAccessSettings()
        }
    }

    /// Request Network Extension installation (shows info about feature)
    func requestNetworkExtension() {
        AppLogger.permissions.info("User notified about Network Extension status")

        let alert = NSAlert()
        alert.messageText = "Network Extension Not Yet Available"
        alert.informativeText = """
        Real-time network filtering requires a System Extension to be installed.

        Current Status: Development Phase

        This feature requires:
        • macOS 13.0 or later ✓
        • Developer ID signed build (in progress)
        • Network Extension entitlements (configured)
        • Apple approval for system extension (pending)

        What's Available Now:
        • Network monitoring using system tools
        • Connection tracking and logging
        • Privacy level simulations

        Coming Soon:
        • Real-time connection filtering
        • DNS-level ad blocking
        • Advanced threat detection

        We'll notify you when this feature is ready!
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Got It")
        alert.addButton(withTitle: "Learn More")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // Open documentation or website
            if let url = URL(string: "https://diskdevil.app/features/network-extension") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    /// Open System Settings to Privacy & Security > Full Disk Access
    func openFullDiskAccessSettings() {
        // macOS 13+ uses new Settings app URL scheme
        if #available(macOS 13.0, *) {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
        } else {
            // Fallback for older macOS versions
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!
            NSWorkspace.shared.open(url)
        }

        // Schedule permission recheck after user might have changed settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.checkPermissions()
        }
    }

    /// Open System Settings (general)
    func openSystemSettings() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
        }
    }

    /// Check if app should prompt for Full Disk Access
    /// Returns true if FDA is needed but not granted
    func shouldPromptForFullDiskAccess() -> Bool {
        !hasFullDiskAccess
    }

    // MARK: Private

    private var permissionCheckTimer: Timer?

    /// Start periodic permission checking (every 30 seconds)
    /// This helps detect when user grants permission without restarting app
    private func startPeriodicPermissionCheck() {
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkPermissions()
        }
    }

    deinit {
        permissionCheckTimer?.invalidate()
    }
}

// MARK: - Logger Extension

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.diskdevil"

    fileprivate static let permissions = Logger(subsystem: subsystem, category: "permissions")
}

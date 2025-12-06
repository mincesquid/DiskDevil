//
//  PermissionManager.swift
//  DiskDevil
//

import AppKit
import Foundation

class PermissionManager: ObservableObject {
    @Published var hasFullDiskAccess: Bool = false
    @Published var hasNetworkExtension: Bool = false

    init() {
        checkPermissions()
    }

    func checkPermissions() {
        checkFullDiskAccess()
        checkNetworkExtensionPermission()
    }

    func checkFullDiskAccess() {
        // Try to access TCC database (truly protected directory)
        let tccPath = "/Library/Application Support/com.apple.TCC/"
        let fm = FileManager.default

        // First check the TCC directory
        if fm.isReadableFile(atPath: tccPath) {
            hasFullDiskAccess = true
            return
        }

        // Alternative: try to list contents of a protected user directory
        let homeTCCPath = NSHomeDirectory() + "/Library/Application Support/com.apple.TCC/"
        do {
            _ = try fm.contentsOfDirectory(atPath: homeTCCPath)
            hasFullDiskAccess = true
        } catch {
            hasFullDiskAccess = false
        }
    }

    func checkNetworkExtensionPermission() {
        // Check network extension status
        // This would use NetworkExtension framework
        hasNetworkExtension = false // Placeholder
    }

    func requestFullDiskAccess() {
        // Show alert with instructions before opening System Settings
        let alert = NSAlert()
        alert.messageText = "Full Disk Access Required"
        alert.informativeText = """
        DiskDevil needs Full Disk Access to scan system files and perform cleanup operations.

        Steps to grant access:
        1. Click "Open System Settings" below
        2. Click the lock icon and authenticate
        3. Find DiskDevil in the list and enable the toggle
        4. Restart DiskDevil for changes to take effect

        Without this permission, some features will be limited.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Settings to Security & Privacy
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
        }
    }

    func requestNetworkExtension() {
        // Show alert explaining Network Extension requirement
        let alert = NSAlert()
        alert.messageText = "Network Extension Not Configured"
        alert.informativeText = """
        Network filtering requires a System Extension to be installed.

        This feature is currently in development and requires:
        • macOS 13.0 or later
        • Developer ID signed build
        • Network Extension entitlements

        For now, the app will simulate network monitoring using system tools.
        Stay tuned for updates with full network filtering capabilities!
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func openSystemSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
    }
}

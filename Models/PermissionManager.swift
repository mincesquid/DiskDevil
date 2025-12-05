//
//  PermissionManager.swift
//  Mad Scientist
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
        // Check if we can access a protected directory
        let testPath = NSHomeDirectory() + "/Library/Safari"
        hasFullDiskAccess = FileManager.default.isReadableFile(atPath: testPath)
    }

    func checkNetworkExtensionPermission() {
        // Check network extension status
        // This would use NetworkExtension framework
        hasNetworkExtension = false // Placeholder
    }

    func requestFullDiskAccess() {
        // Open System Settings to Security & Privacy
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }

    func requestNetworkExtension() {
        // Request network extension permission
        // This requires NetworkExtension framework setup
    }

    func openSystemSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
    }
}

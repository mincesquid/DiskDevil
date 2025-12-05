//
//  DiskDevilApp.swift
//  DiskDevil
//
//  macOS Security & Recovery Suite
//

import SwiftUI

@main
struct DiskDevilApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var privacyEngine = PrivacyEngine()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var networkMonitor = NetworkMonitorService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(permissionManager)
                .environmentObject(networkMonitor)
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            AppCommands()
        }

        Settings {
            SettingsView()
                .environmentObject(subscriptionManager)
        }

        WindowGroup("Upgrade", id: "upgrade") {
            UpgradeView()
                .environmentObject(subscriptionManager)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("DiskDevil", systemImage: "shield.lefthalf.filled") {
            MenuBarStatusView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(networkMonitor)
                .environmentObject(permissionManager)
        }
        .menuBarExtraStyle(.window)
    }
}

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("DiskDevil Help") {
                // Open help
            }
        }
    }
}

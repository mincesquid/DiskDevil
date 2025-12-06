//
//  DiskDevilApp.swift
//  DiskDevil
//
//  macOS Security & Recovery Suite
//

import SwiftUI

// MARK: - DiskDevilApp

@main
struct DiskDevilApp: App {
    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(permissionManager)
                .environmentObject(networkMonitor)
                .environmentObject(usageLimits)
                .environment(\.font, AeroTheme.baseFont)
                .frame(minWidth: 900, minHeight: 700)
                .onAppear {
                    Task {
                        await subscriptionManager.loadProducts()

                        // Unlock all limits for premium/elite users
                        if subscriptionManager.tier != .free {
                            usageLimits.unlockAll()
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            AppCommands()
        }

        Settings {
            SettingsView()
                .environmentObject(subscriptionManager)
        }

        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(permissionManager)
                .environmentObject(usageLimits)
                .environment(\.font, AeroTheme.baseFont)
        }
        .windowResizability(.contentSize)

        WindowGroup("Privacy Protection", id: "privacy") {
            PrivacySliderView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(permissionManager)
                .environmentObject(usageLimits)
                .environment(\.font, AeroTheme.baseFont)
        }
        .windowResizability(.contentSize)

        WindowGroup("Upgrade", id: "upgrade") {
            UpgradeView()
                .environmentObject(subscriptionManager)
                .environmentObject(usageLimits)
                .environment(\.font, AeroTheme.baseFont)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("DiskDevil", systemImage: "shield.lefthalf.filled") {
            MenuBarStatusView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(networkMonitor)
                .environmentObject(permissionManager)
                .environmentObject(usageLimits)
        }
        .menuBarExtraStyle(.window)
    }

    // MARK: Private

    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var privacyEngine = PrivacyEngine()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var networkMonitor = NetworkMonitorService()
    @StateObject private var usageLimits = UsageLimits()
}

// MARK: - AppCommands

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("DiskDevil Help") {
                // Open help
            }
        }
    }
}

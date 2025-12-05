//
//  MadScientistApp.swift
//  Mad Scientist
//
//  macOS Security & Recovery Suite
//

import SwiftUI

@main
struct MadScientistApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var privacyEngine = PrivacyEngine()
    @StateObject private var permissionManager = PermissionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(privacyEngine)
                .environmentObject(permissionManager)
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
    }
}

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("Mad Scientist Help") {
                // Open help
            }
        }
    }
}

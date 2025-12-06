//
//  SettingsView.swift
//  DiskDevil
//

import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    // MARK: Internal

    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @EnvironmentObject var permissionManager: PermissionManager

    var tierColor: Color {
        switch subscriptionManager.tier {
        case .free: .gray
        case .premium: .orange
        case .elite: .purple
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)

                    Text("Configure DiskDevil preferences")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)

                // General Settings
                SettingsSection(title: "General", icon: "gear") {
                    SettingsToggle(
                        title: "Launch at Login",
                        description: "Start DiskDevil when you log in",
                        isOn: $launchAtLogin
                    )

                    SettingsToggle(
                        title: "Show in Menu Bar",
                        description: "Display status icon in the menu bar",
                        isOn: $showInMenuBar
                    )

                    SettingsToggle(
                        title: "Auto-Update",
                        description: "Automatically download and install updates",
                        isOn: $autoUpdate
                    )
                }

                // Notifications
                SettingsSection(title: "Notifications", icon: "bell") {
                    SettingsToggle(
                        title: "Enable Notifications",
                        description: "Receive alerts for security events",
                        isOn: $notificationsEnabled
                    )
                }

                // Privacy Settings
                SettingsSection(title: "Privacy Protection", icon: "shield.lefthalf.filled") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Level")
                                .font(.headline)
                            Text(
                                "Level \(privacyEngine.currentLevel) - \(privacyEngine.levelNames[privacyEngine.currentLevel] ?? "")"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Configure") {
                            openWindow(id: "privacy")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protection Status")
                                .font(.headline)
                            Text(privacyEngine.isActive ? "Active" : "Disabled")
                                .font(.subheadline)
                                .foregroundColor(privacyEngine.isActive ? .green : .secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { privacyEngine.isActive },
                            set: { _ in privacyEngine.toggleProtection() }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 8)
                }

                // System Permissions
                SettingsSection(title: "System Permissions", icon: "lock.shield") {
                    PermissionRow(
                        title: "Full Disk Access",
                        description: "Required for scanning protected directories",
                        isGranted: permissionManager.hasFullDiskAccess,
                        action: permissionManager.requestFullDiskAccess
                    )

                    PermissionRow(
                        title: "Network Extension",
                        description: "Required for network monitoring",
                        isGranted: permissionManager.hasNetworkExtension,
                        action: permissionManager.requestNetworkExtension
                    )
                }

                // Subscription
                SettingsSection(title: "Subscription", icon: "crown") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Plan")
                                .font(.headline)
                            Text(subscriptionManager.tier.displayName)
                                .font(.subheadline)
                                .foregroundColor(tierColor)
                        }
                        Spacer()
                        if subscriptionManager.tier == .free {
                            NavigationLink(destination: UpgradeView()) {
                                Text("Upgrade")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 8)

                    if let expiration = subscriptionManager.expirationDate {
                        HStack {
                            Text("Expires")
                                .font(.subheadline)
                            Spacer()
                            Text(expiration, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // About
                SettingsSection(title: "About", icon: "info.circle") {
                    HStack {
                        Text("Version")
                            .font(.subheadline)
                        Spacer()
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("Build")
                            .font(.subheadline)
                        Spacer()
                        Text("2024.1")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .padding()
        }
        .aeroBackground()
    }

    // MARK: Private

    @Environment(\.openWindow) private var openWindow

    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    @AppStorage("autoUpdate") private var autoUpdate = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
}

// MARK: - SettingsSection

struct SettingsSection<Content: View>: View {
    // MARK: Lifecycle

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    // MARK: Internal

    let title: String
    let icon: String
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AeroTheme.accent)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(spacing: 0) {
                content
            }
        }
        .padding()
        .glassCard()
    }
}

// MARK: - SettingsToggle

struct SettingsToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - PermissionRow

struct PermissionRow: View {
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isGranted ? .green : .orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isGranted {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
    }
}

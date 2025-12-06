//
//  DashboardView.swift
//  DiskDevil
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @EnvironmentObject var permissionManager: PermissionManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                header

                // Subscription Status
                SubscriptionStatusCard()
                    .glassCard()

                // Privacy Protection Quick Access
                PrivacyQuickCard()
                    .glassCard()

                // System Status
                SystemStatusCard()
                    .glassCard()

                // Quick Actions
                QuickActionsGrid()

                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aeroBackground()
    }

    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 70))
                    .foregroundStyle(AeroTheme.accent, .white)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 6)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.red)
                    .offset(x: 18, y: 22)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
            }

            Text("DiskDevil")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)

            Text("macOS Security & Recovery Suite")
                .font(.title3)
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(.top, 40)
    }
}

struct SubscriptionStatusCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(tierColor)
                Text("Subscription Status")
                    .font(.headline)
                Spacer()
                Text(subscriptionManager.tier.displayName)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(tierColor.opacity(0.2))
                    .foregroundColor(tierColor)
                    .cornerRadius(12)
            }

            if subscriptionManager.tier == .free {
                Text("Unlock premium features with a subscription")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                NavigationLink(destination: UpgradeView()) {
                    Text("Upgrade Now")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Access Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Privacy Level 1-\(subscriptionManager.tier.maxPrivacyLevel)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    if let expiration = subscriptionManager.expirationDate {
                        VStack(alignment: .trailing) {
                            Text("Expires")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(expiration, style: .date)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }

    var tierColor: Color {
        switch subscriptionManager.tier {
        case .free: return .gray
        case .premium: return .orange
        case .elite: return .purple
        }
    }
}

struct PrivacyQuickCard: View {
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(AeroTheme.accent)
                Text("Privacy Protection")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { privacyEngine.isActive },
                    set: { _ in privacyEngine.toggleProtection() }
                ))
                .labelsHidden()
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Current Level")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Level \(privacyEngine.currentLevel) - \(privacyEngine.levelNames[privacyEngine.currentLevel] ?? "")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Blocked Today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(privacyEngine.totalBlockedToday)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AeroTheme.neon)
                }
            }

            Button {
                openWindow(id: "privacy")
            } label: {
                Text("Configure Protection")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct SystemStatusCard: View {
    @EnvironmentObject var permissionManager: PermissionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.green)
                Text("System Status")
                    .font(.headline)
            }

            StatusRow(
                title: "Full Disk Access",
                isGranted: permissionManager.hasFullDiskAccess,
                action: permissionManager.requestFullDiskAccess
            )

            StatusRow(
                title: "Network Extension",
                isGranted: permissionManager.hasNetworkExtension,
                action: permissionManager.requestNetworkExtension
            )
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct StatusRow: View {
    let title: String
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isGranted ? .green : .orange)
            Text(title)
                .font(.subheadline)
            Spacer()
            if !isGranted {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}

struct QuickActionsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionCard(
                    icon: "trash",
                    title: "Smart Cleanup",
                    description: "Free up disk space",
                    destination: AnyView(CleanupView())
                )

                QuickActionCard(
                    icon: "checkmark.shield",
                    title: "Security Scan",
                    description: "Detect threats",
                    destination: AnyView(SecurityScanView())
                )

                QuickActionCard(
                    icon: "eye.slash",
                    title: "Hidden Files",
                    description: "Browse hidden files",
                    destination: AnyView(HiddenFilesView())
                )

                QuickActionCard(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "Telemetry",
                    description: "Inspect tracking",
                    destination: AnyView(TelemetryInspectorView())
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct SubscriptionBadge: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        HStack(spacing: 4) {
            if subscriptionManager.tier == .elite {
                Image(systemName: "crown.fill")
                    .foregroundColor(.purple)
            }
            Text(subscriptionManager.tier.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tierColor.opacity(0.2))
        .foregroundColor(tierColor)
        .cornerRadius(8)
    }

    var tierColor: Color {
        switch subscriptionManager.tier {
        case .free: return .gray
        case .premium: return .orange
        case .elite: return .purple
        }
    }
}

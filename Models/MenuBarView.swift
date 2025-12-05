import AppKit
import SwiftUI

struct MenuBarStatusView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @EnvironmentObject var networkMonitor: NetworkMonitorService
    @EnvironmentObject var permissionManager: PermissionManager

    @State private var isMonitoring = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            protectionRow
            networkRow
            permissionRow
            Divider()
            HStack {
                Button("Open Mad Scientist") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(12)
        .frame(width: 280)
        .onAppear {
            if isMonitoring {
                networkMonitor.start()
            }
        }
        .onChange(of: isMonitoring) { active in
            active ? networkMonitor.start() : networkMonitor.stop()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mad Scientist")
                    .font(.headline)
                Text(subscriptionManager.tier.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tierColor.opacity(0.2))
                    .foregroundColor(tierColor)
                    .cornerRadius(6)
            }
            Spacer()
            Image(systemName: privacyEngine.isActive ? "shield.lefthalf.filled" : "shield")
                .foregroundColor(privacyEngine.isActive ? .green : .gray)
        }
    }

    private var protectionRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Privacy Protection")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(privacyEngine.isActive ? "Level \(privacyEngine.currentLevel)" : "Disabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { privacyEngine.isActive },
                set: { _ in privacyEngine.toggleProtection() }
            ))
            .labelsHidden()
        }
    }

    private var networkRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Network Monitor")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Toggle("", isOn: $isMonitoring)
                    .labelsHidden()
            }
            HStack {
                StatChip(
                    label: "↓ \(ByteCountFormatter.string(fromByteCount: networkMonitor.bytesIn, countStyle: .file))",
                    color: .green
                )
                StatChip(
                    label: "↑ \(ByteCountFormatter.string(fromByteCount: networkMonitor.bytesOut, countStyle: .file))",
                    color: .blue
                )
                StatChip(
                    label: "\(networkMonitor.connections.count) conns",
                    color: .orange
                )
            }
        }
    }

    private var permissionRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Permissions")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack(spacing: 8) {
                PermissionChip(
                    title: "Full Disk",
                    ok: permissionManager.hasFullDiskAccess,
                    action: permissionManager.requestFullDiskAccess
                )
                PermissionChip(
                    title: "Network Ext",
                    ok: permissionManager.hasNetworkExtension,
                    action: permissionManager.requestNetworkExtension
                )
            }
        }
    }

    private var tierColor: Color {
        switch subscriptionManager.tier {
        case .free: return .gray
        case .premium: return .orange
        case .elite: return .purple
        }
    }
}

private struct StatChip: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

private struct PermissionChip: View {
    let title: String
    let ok: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(ok ? .green : .orange)
            Text(title)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
        .onTapGesture {
            if !ok {
                action()
            }
        }
    }
}

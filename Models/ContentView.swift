//
//  ContentView.swift
//  DiskDevil
//

import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @EnvironmentObject var permissionManager: PermissionManager
    @Environment(\.openWindow) private var openWindow

    @State private var selectedTab: NavigationItem = .dashboard
    @State private var lastNonPrivacySelection: NavigationItem = .dashboard

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            VStack(spacing: 0) {
                TopBar(openWindow: openWindow)
                DetailContent(selectedTab: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        .onChange(of: selectedTab) { newValue in
            if newValue == .privacySlider {
                openPrivacyWindow()
                selectedTab = lastNonPrivacySelection
            } else {
                lastNonPrivacySelection = newValue
            }
        }
    }

    private func openPrivacyWindow() {
        openWindow(id: "privacy")

        // Nudge the window so it's visibly separate from the main window.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if let window = NSApp.windows.first(where: { $0.title == "Privacy Protection" }) {
                var frame = window.frame
                frame.origin.x -= 80
                frame.origin.y -= 40
                window.setFrame(frame, display: true, animate: true)
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}

enum NavigationItem: String, CaseIterable, Hashable {
    case dashboard = "Dashboard"
    case privacySlider = "Privacy Protection"
    case hiddenFiles = "Hidden Files"
    case telemetry = "Telemetry Inspector"
    case cleanup = "Smart Cleanup"
    case security = "Security Scan"
    case network = "Network Monitor"
    case recovery = "Recovery Tools"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .privacySlider: return "shield.lefthalf.filled"
        case .hiddenFiles: return "eye.slash"
        case .telemetry: return "antenna.radiowaves.left.and.right"
        case .cleanup: return "trash"
        case .security: return "checkmark.shield"
        case .network: return "network"
        case .recovery: return "bandage"
        case .settings: return "gearshape"
        }
    }

    var isPremium: Bool {
        switch self {
        case .recovery, .network:
            return true
        default:
            return false
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: NavigationItem
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        List(NavigationItem.allCases, id: \.self, selection: $selectedTab) { item in
            HStack {
                Image(systemName: item.icon)
                    .frame(width: 20)
                Text(item.rawValue)
                Spacer()
                if item.isPremium && subscriptionManager.tier == .free {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .tag(item)
            .onTapGesture {
                if !(item.isPremium && subscriptionManager.tier == .free) {
                    selectedTab = item
                }
            }
            .disabled(item.isPremium && subscriptionManager.tier == .free)
        }
        .navigationTitle("DiskDevil")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SubscriptionBadge()
            }
        }
    }
}

struct DetailContent: View {
    let selectedTab: NavigationItem
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        Group {
            if selectedTab.isPremium && subscriptionManager.tier == .free {
                PremiumUpgradeView(feature: selectedTab.rawValue)
            } else {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .privacySlider:
                    PrivacyPlaceholderView()
                case .hiddenFiles:
                    HiddenFilesView()
                case .telemetry:
                    TelemetryInspectorView()
                case .cleanup:
                    CleanupView()
                case .security:
                    SecurityScanView()
                case .network:
                    NetworkMonitorView()
                case .recovery:
                    RecoveryToolsView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PrivacyPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("Privacy Protection opens in its own window.")
                .font(.headline)
            Text("Use the separate window to adjust levels. Sidebar stays active here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TopBar: View {
    let openWindow: OpenWindowAction

    var body: some View {
        HStack {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(AeroTheme.accent)
                .font(.title2)
            Text("DiskDevil")
                .appFont(18, weight: .semibold)
                .foregroundColor(.white)
            Spacer()
            Button {
                openWindow(id: "settings")
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .buttonStyle(.plain)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .glassCard()
    }
}

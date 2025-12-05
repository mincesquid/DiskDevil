//
//  ContentView.swift
//  DiskDevil
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine
    @EnvironmentObject var permissionManager: PermissionManager

    @State private var selectedTab: NavigationItem = .dashboard

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            DetailContent(selectedTab: selectedTab)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
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
                    PrivacySliderView()
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

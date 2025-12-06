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
        .onChange(of: selectedTab, perform: { newValue in
            if newValue == .privacySlider {
                openPrivacyWindow()
                selectedTab = lastNonPrivacySelection
            } else {
                lastNonPrivacySelection = newValue
            }
        })
    }

    private func openPrivacyWindow() {
        openWindow(id: "privacy")

        // Position the window relative to the main window for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let mainWindow = NSApp.mainWindow,
                  let privacyWindow = NSApp.windows.first(where: {
                      $0.title == "Privacy Protection" && $0 != mainWindow
                  })
            else { return }

            // Calculate offset position from main window
            var newFrame = privacyWindow.frame
            let mainFrame = mainWindow.frame

            // Position to the right and slightly below the main window
            newFrame.origin.x = mainFrame.maxX - newFrame.width - 80
            newFrame.origin.y = mainFrame.maxY - newFrame.height - 40

            privacyWindow.setFrame(newFrame, display: true, animate: true)
            privacyWindow.makeKeyAndOrderFront(nil)
        }
    }
}

enum NavigationItem: String, CaseIterable, Hashable {
    case dashboard = "Dashboard"
    case privacySlider = "Privacy Protection"
    case auditKing = "AuditKing"
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
        case .auditKing: return "crown.fill"
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

    var isEliteOnly: Bool {
        switch self {
        case .auditKing:
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
                if item.isPremium, subscriptionManager.tier == .free {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                } else if item.isEliteOnly, subscriptionManager.tier != .elite {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .tag(item)
            .onTapGesture {
                let hasAccess = !(item.isPremium && subscriptionManager.tier == .free) &&
                    !(item.isEliteOnly && subscriptionManager.tier != .elite)
                if hasAccess {
                    selectedTab = item
                }
            }
            .disabled((item.isPremium && subscriptionManager.tier == .free) ||
                (item.isEliteOnly && subscriptionManager.tier != .elite))
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
            if selectedTab.isPremium, subscriptionManager.tier == .free {
                PremiumUpgradeView(feature: selectedTab.rawValue)
            } else if selectedTab.isEliteOnly, subscriptionManager.tier != .elite {
                EliteUpgradeView(feature: selectedTab.rawValue)
            } else {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .privacySlider:
                    PrivacyPlaceholderView()
                case .auditKing:
                    AuditKingView()
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

//
//  RecoveryToolsView.swift
//  DiskDevil
//

import SwiftUI

// MARK: - RecoveryToolsView

struct RecoveryToolsView: View {
    // MARK: Internal

    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "bandage")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                Text("Recovery Tools")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("System repair and recovery utilities")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                if subscriptionManager.tier == .free {
                    Text("Premium Feature")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 20)

            // Progress Section
            if isRunning {
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)

                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .glassCard()
            }

            // Recovery Tools Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(RecoveryTool.allCases, id: \.self) { tool in
                    RecoveryToolCard(tool: tool, isSelected: selectedTool == tool) {
                        selectedTool = tool
                    }
                }
            }
            .padding(.horizontal)

            // Run Button
            Button(action: runSelectedTool) {
                HStack {
                    if isRunning {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 4)
                    }
                    Text(isRunning ? "Running..." : "Run Selected Tool")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedTool == nil || isRunning)
            .padding(.horizontal)

            // Tool Description
            if let tool = selectedTool {
                VStack(alignment: .leading, spacing: 8) {
                    Text(tool.rawValue)
                        .font(.headline)
                    Text(tool.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    if tool.requiresReboot {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("This tool may require a system reboot")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .aeroBackground()
        .onDisappear {
            stopTool()
        }
    }

    // MARK: Private

    @State private var selectedTool: RecoveryTool?
    @State private var isRunning = false
    @State private var progress: Double = 0
    @State private var statusMessage = ""
    @State private var runTimer: Timer?

    private func runSelectedTool() {
        guard let tool = selectedTool else {
            return
        }

        isRunning = true
        progress = 0
        statusMessage = "Initializing \(tool.rawValue)..."

        // Simulate tool running
        runTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            progress += 0.02

            switch progress {
            case 0 ..< 0.25:
                statusMessage = "Analyzing system..."
            case 0.25 ..< 0.5:
                statusMessage = "Running \(tool.rawValue)..."
            case 0.5 ..< 0.75:
                statusMessage = "Applying changes..."
            case 0.75 ..< 1.0:
                statusMessage = "Finalizing..."
            default:
                break
            }

            if progress >= 1.0 {
                timer.invalidate()
                runTimer = nil
                statusMessage = "\(tool.rawValue) completed successfully!"

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isRunning = false
                    statusMessage = ""
                }
            }
        }
    }

    private func stopTool() {
        runTimer?.invalidate()
        runTimer = nil
    }
}

// MARK: - RecoveryTool

enum RecoveryTool: String, CaseIterable {
    case diskRepair = "Disk Repair"
    case permissionsFix = "Permissions Fix"
    case cacheClean = "Cache Clean"
    case systemReset = "System Reset"
    case bootRepair = "Boot Repair"
    case networkReset = "Network Reset"

    // MARK: Internal

    var icon: String {
        switch self {
        case .diskRepair: "internaldrive"
        case .permissionsFix: "lock.shield"
        case .cacheClean: "trash.circle"
        case .systemReset: "arrow.counterclockwise"
        case .bootRepair: "power"
        case .networkReset: "wifi.exclamationmark"
        }
    }

    var color: Color {
        switch self {
        case .diskRepair: .blue
        case .permissionsFix: .green
        case .cacheClean: .orange
        case .systemReset: .red
        case .bootRepair: .purple
        case .networkReset: .cyan
        }
    }

    var description: String {
        switch self {
        case .diskRepair:
            "Verify and repair disk errors, fix file system issues, and optimize disk performance."
        case .permissionsFix:
            "Reset file and folder permissions to default values, fixing access issues."
        case .cacheClean:
            "Clear system and application caches to resolve performance issues."
        case .systemReset:
            "Reset system settings to defaults while preserving user data."
        case .bootRepair:
            "Repair boot configuration and fix startup issues."
        case .networkReset:
            "Reset network settings, clear DNS cache, and renew DHCP lease."
        }
    }

    var requiresReboot: Bool {
        switch self {
        case .systemReset,
             .bootRepair:
            true
        default:
            false
        }
    }
}

// MARK: - RecoveryToolCard

struct RecoveryToolCard: View {
    let tool: RecoveryTool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: tool.icon)
                    .font(.title)
                    .foregroundColor(tool.color)

                Text(tool.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? tool.color.opacity(0.1) : Color(.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? tool.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .glassCard()
    }
}

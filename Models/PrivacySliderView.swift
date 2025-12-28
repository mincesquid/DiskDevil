//
//  PrivacySliderView.swift
//  DiskDevil
//

import SwiftUI

// MARK: - PrivacySliderView

struct PrivacySliderView: View {
    // MARK: Internal

    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var privacyEngine: PrivacyEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)

                    Text("Privacy Protection Slider")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)

                    Text("The Xenophobia Scale")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Security Disclaimer
                    Text("⚠️ Network filtering is currently simulated for demonstration")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                        .padding(.top, 8)
                }
                .padding(.top, 20)

                // Protection Toggle
                HStack {
                    VStack(alignment: .leading) {
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
                    .scaleEffect(1.2)
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)

                // The Slider
                VStack(spacing: 20) {
                    Text("Level \(Int(selectedLevel)): \(privacyEngine.levelNames[Int(selectedLevel)] ?? "")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(levelColor(Int(selectedLevel)))

                    ZStack(alignment: .leading) {
                        // Background gradient
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 8)
                        .cornerRadius(4)
                        .opacity(0.3)

                        // Custom slider
                        GeometryReader { _ in
                            ZStack(alignment: .leading) {
                                // Level markers
                                HStack(spacing: 0) {
                                    ForEach(1 ... 10, id: \.self) { level in
                                        VStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 1, height: 20)
                                            Text("\(level)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }

                                // Slider control
                                HStack(spacing: 0) {
                                    ForEach(1 ... 10, id: \.self) { level in
                                        Color.clear
                                            .frame(maxWidth: .infinity)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if canAccessLevel(level) {
                                                    selectedLevel = Double(level)
                                                    privacyEngine.setLevel(level)
                                                } else {
                                                    openUpgradeWindow()
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .frame(height: 60)
                    }
                    .padding(.vertical)

                    // Level description
                    Text(privacyEngine.levelDescriptions[Int(selectedLevel)] ?? "")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)

                    // Lock indicators
                    VStack(spacing: 12) {
                        if subscriptionManager.tier == .free {
                            LockBanner(
                                levels: "4-10",
                                tier: "Premium or Elite",
                                description: "Unlock Apple telemetry blocking and advanced protection"
                            ) {
                                openUpgradeWindow()
                            }
                        } else if subscriptionManager.tier == .premium {
                            LockBanner(
                                levels: "10",
                                tier: "Elite",
                                description: "Maximum paranoia mode with zero-trust architecture"
                            ) {
                                openUpgradeWindow()
                            }
                        }
                    }
                }
                .padding()
                .glassCard()

                // Level breakdown
                LevelBreakdownView()
                    .glassCard()

                // Statistics
                if privacyEngine.isActive {
                    StatisticsCard()
                        .glassCard()
                }

                // Actions
                HStack(spacing: 12) {
                    Button {
                        applySelection()
                    } label: {
                        HStack {
                            if showAppliedConfirmation {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            Text(showAppliedConfirmation ? "Applied!" : "Apply")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(Int(selectedLevel) == privacyEngine.currentLevel)

                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            selectedLevel = Double(privacyEngine.currentLevel)
        }
        .padding()
        .aeroBackground()
    }

    func canAccessLevel(_ level: Int) -> Bool {
        subscriptionManager.hasAccess(to: level)
    }

    func levelColor(_ level: Int) -> Color {
        switch level {
        case 1 ... 3: .green
        case 4 ... 6: .orange
        case 7 ... 9: .red
        case 10: .purple
        default: .gray
        }
    }

    // MARK: Private

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: Double = 1
    @State private var showAppliedConfirmation = false

    private func openUpgradeWindow() {
        openWindow(id: "upgrade")
    }

    private func applySelection() {
        privacyEngine.setLevel(Int(selectedLevel))

        // Show confirmation feedback
        showAppliedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showAppliedConfirmation = false
        }
    }
}

// MARK: - LockBanner

struct LockBanner: View {
    let levels: String
    let tier: String
    let description: String
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("Levels \(levels) require \(tier)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Upgrade") {
                action()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - LevelBreakdownView

struct LevelBreakdownView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What Each Level Blocks")
                .font(.headline)

            VStack(spacing: 8) {
                LevelRow(level: 1, name: "Relaxed", description: "Basic trackers, ad networks", locked: false)
                LevelRow(level: 2, name: "Aware", description: "Third-party analytics, data collectors", locked: false)
                LevelRow(
                    level: 3,
                    name: "Cautious",
                    description: "Marketing, fingerprinting, suspicious domains",
                    locked: false
                )
                LevelRow(
                    level: 4,
                    name: "Protected",
                    description: "Apple telemetry (diagnostics, usage)",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 5,
                    name: "Hardened",
                    description: "Apple analytics daemons, cloud telemetry",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 6,
                    name: "Isolated",
                    description: "Siri data, Spotlight suggestions",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 7,
                    name: "Military",
                    description: "Deep packet inspection, military-grade firewall",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 8,
                    name: "Cloaked",
                    description: "MAC spoofing, network cloaking, VM isolation",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 9,
                    name: "Offensive",
                    description: "Honeypots, active response, deception tactics",
                    locked: subscriptionManager.tier == .free
                )
                LevelRow(
                    level: 10,
                    name: "MAXIMUM",
                    description: "Zero-trust architecture, complete isolation",
                    locked: subscriptionManager.tier != .elite
                )
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - LevelRow

struct LevelRow: View {
    let level: Int
    let name: String
    let description: String
    let locked: Bool

    var levelColor: Color {
        switch level {
        case 1 ... 3: .green
        case 4 ... 6: .orange
        case 7 ... 9: .red
        case 10: .purple
        default: .gray
        }
    }

    var body: some View {
        HStack {
            Text("\(level)")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(levelColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if locked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .opacity(locked ? 0.6 : 1.0)
        .padding(.vertical, 4)
    }
}

// MARK: - StatisticsCard

struct StatisticsCard: View {
    @EnvironmentObject var privacyEngine: PrivacyEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Protection Statistics")
                .font(.headline)

            HStack(spacing: 20) {
                StatItem(title: "Blocked Today", value: "\(privacyEngine.totalBlockedToday)", color: .green)
                StatItem(title: "Active Level", value: "\(privacyEngine.currentLevel)", color: .blue)
                StatItem(title: "Recent Blocks", value: "\(privacyEngine.blockedConnections.count)", color: .orange)
            }

            if !privacyEngine.blockedConnections.isEmpty {
                Divider()

                Text("Recent Blocked Connections")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(privacyEngine.blockedConnections.prefix(5)) { connection in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(connection.process)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(connection.destination)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("L\(connection.level)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - StatItem

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

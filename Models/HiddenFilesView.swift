//
//  HiddenFilesView.swift
//  DiskDevil
//

import AppKit
import SwiftUI

// MARK: - HiddenFilesView

struct HiddenFilesView: View {
    // MARK: Internal

    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var usageLimits: UsageLimits

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "eye.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                Text("Hidden Files Browser")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Reveal and manage hidden files on your system")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)

            // Usage Limit Banner (Free Users Only)
            if subscriptionManager.tier == .free {
                UsageLimitBanner(
                    remaining: usageLimits.hiddenFilesRevealsRemaining,
                    total: 3,
                    featureName: "reveals",
                    resetTime: usageLimits.timeUntilReset()
                ) {
                    openWindow(id: "upgrade")
                }
                .glassCard()
            }

            // Toggle
            HStack {
                Text("Show Hidden Files")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $showHiddenFiles)
                    .labelsHidden()
            }
            .padding()
            .glassCard()

            // Path
            HStack {
                Text("Current Path:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(currentPath)
                    .font(.system(.subheadline, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
            }
            .padding()
            .glassCard()

            // File List
            List(files) { file in
                HStack {
                    Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundColor(file.isDirectory ? AeroTheme.accent : .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.name)
                            .font(.body)
                            .foregroundColor(file.isHidden ? .secondary : .primary)
                        Text(file.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if file.isHidden {
                        Text("Hidden")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                        Text("Reveal")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                            .onTapGesture {
                                reveal(file.url)
                            }
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.inset)
            .cornerRadius(12)
            .glassCard()

            Spacer()
        }
        .padding()
        .aeroBackground()
        .onAppear {
            loadFiles()
        }
        .onChange(of: showHiddenFiles, perform: { _ in
            loadFiles()
        })
        .sheet(isPresented: $showLimitReached) {
            LimitReachedAlert(
                featureName: "hidden file reveals",
                resetTime: usageLimits.timeUntilReset(),
                onDismiss: {
                    showLimitReached = false
                },
                onUpgrade: {
                    showLimitReached = false
                    openWindow(id: "upgrade")
                }
            )
        }
    }

    // MARK: Private

    @Environment(\.openWindow) private var openWindow

    @State private var showHiddenFiles = false
    @State private var currentPath = FileManager.default.homeDirectoryForCurrentUser.path
    @State private var files: [FileItem] = []
    @State private var showLimitReached = false

    private func loadFiles() {
        let url = URL(fileURLWithPath: currentPath)
        var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants]

        if !showHiddenFiles {
            options.insert(.skipsHiddenFiles)
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .isHiddenKey],
                options: options
            )

            files = contents.compactMap { url in
                let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isHiddenKey])
                return FileItem(
                    name: url.lastPathComponent,
                    path: url.path,
                    url: url,
                    isDirectory: resourceValues?.isDirectory ?? false,
                    isHidden: resourceValues?.isHidden ?? false
                )
            }.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            files = []
        }
    }

    private func reveal(_ url: URL) {
        // Check if free user has reached limit
        if subscriptionManager.tier == .free {
            if !usageLimits.canRevealHiddenFile() {
                showLimitReached = true
                return
            }
            usageLimits.recordHiddenFileReveal()
        }

        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

// MARK: - UsageLimitBanner

struct UsageLimitBanner: View {
    // MARK: Internal

    let remaining: Int
    let total: Int
    let featureName: String
    let resetTime: String
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: remaining > 0 ? "clock" : "lock.fill")
                    .foregroundColor(remaining > 0 ? .orange : .red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(remaining > 0 ? "\(remaining) of \(total) \(featureName) remaining today" :
                        "Daily limit reached")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(remaining > 0 ? "Resets in \(resetTime)" : "Upgrade for unlimited access")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if remaining == 0 {
                    Button {
                        onUpgrade()
                    } label: {
                        Text("Upgrade")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(remaining) / CGFloat(total), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding()
    }

    // MARK: Private

    private var progressColor: Color {
        let percentage = Double(remaining) / Double(total)
        if percentage > 0.5 {
            return .green
        } else if percentage > 0 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - LimitReachedAlert

struct LimitReachedAlert: View {
    let featureName: String
    let resetTime: String
    let onDismiss: () -> Void
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .shadow(color: .black.opacity(0.3), radius: 10)

            VStack(spacing: 12) {
                Text("Daily Limit Reached")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("You've used all your free \(featureName) for today.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                Text("Resets in \(resetTime)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            VStack(spacing: 16) {
                // Benefits of upgrading
                VStack(alignment: .leading, spacing: 12) {
                    BenefitRow(icon: "infinity", text: "Unlimited \(featureName) every day")
                    BenefitRow(icon: "shield.lefthalf.filled", text: "Advanced privacy protection (Levels 4-10)")
                    BenefitRow(icon: "network", text: "Real-time network monitoring")
                    BenefitRow(icon: "bandage", text: "Recovery tools & system repair")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)

                HStack(spacing: 12) {
                    Button("Maybe Later") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)

                    Button("Upgrade Now") {
                        onUpgrade()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: 500)
        .background(
            ZStack {
                AeroTheme.background
                Color.black.opacity(0.3)
            }
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.5), radius: 30)
    }
}

// MARK: - BenefitRow

struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AeroTheme.accent)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

// MARK: - FileItem

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let url: URL
    let isDirectory: Bool
    let isHidden: Bool
}

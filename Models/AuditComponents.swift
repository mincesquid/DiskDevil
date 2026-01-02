//
//  AuditComponents.swift
//  DiskDevil
//
//  AuditKing reusable UI components

import AppKit
import SwiftUI

// MARK: - ThreatLevelCard

struct ThreatLevelCard: View {
    let level: ThreatLevel
    let findingsCount: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(level.color)
                    .frame(width: 20, height: 20)
                    .shadow(color: level.color.opacity(0.5), radius: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text("THREAT LEVEL: \(level.title)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                VStack {
                    Text("\(findingsCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(level.color)
                    Text("Issues")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
    }
}

// MARK: - AuditCategoriesGrid

struct AuditCategoriesGrid: View {
    let categories: [(String, String, Color)] = [
        ("System Integrity", "shield.checkered", .blue),
        ("Security Settings", "lock.shield", .green),
        ("Network Security", "network", .purple),
        ("Privacy Settings", "hand.raised.shield", .orange),
        ("Process Analysis", "cpu", .pink),
        ("File System", "folder.badge.gearshape", .indigo),
        ("Kernel Inspection", "memorychip", .red),
        ("Backdoor Detection", "lock.trianglebadge.exclamationmark", .yellow),
        ("Rootkit Scanning", "ant.circle", .cyan),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audit Coverage")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categories, id: \.0) { category in
                    VStack(spacing: 8) {
                        Image(systemName: category.1)
                            .font(.title2)
                            .foregroundColor(category.2)

                        Text(category.0)
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// MARK: - FindingRow

struct FindingRow: View {
    // MARK: Internal

    let finding: AuditFinding
    
    // MARK: Private
    
    // Static regex for hash validation (SHA256 - 64 hex characters)
    // Using try! because the pattern is hardcoded and guaranteed to be valid
    private static let sha256Regex = try! NSRegularExpression(pattern: "^[a-fA-F0-9]{64}$")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: finding.severity.icon)
                    .foregroundColor(finding.severity.color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(finding.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(finding.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 8) {
                        Text(finding.severity.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(finding.severity.color.opacity(0.2))
                            .foregroundColor(finding.severity.color)
                            .cornerRadius(4)

                        Text(finding.phase.title)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()
            }

            // Action buttons - always show
            HStack(spacing: 12) {
                // View Details button
                Button(action: { showDetails = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                        Text("View Details")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                // Fix button if auto-fixable
                if finding.canAutoFix {
                    Button(action: { attemptFix() }) {
                        HStack(spacing: 4) {
                            if isFixing {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .frame(width: 12, height: 12)
                            } else {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.caption)
                            }
                            Text(isFixing ? "Fixing..." : "Fix Issue")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isFixing)
                }

                // File-specific buttons
                if finding.filePath != nil {
                    Button(action: { showWarning = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.caption)
                            Text("Reveal File")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    if let hash = finding.fileHash {
                        Button(action: { openVirusTotal(hash: hash) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "shield.checkered")
                                    .font(.caption)
                                Text("VirusTotal")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 4)

            // Fix result message
            if let result = fixResult {
                Text(result)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .alert("⚠️ WARNING - DO NOT EXECUTE", isPresented: $showWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Reveal File") {
                if let path = finding.filePath {
                    revealInFinder(path: path)
                }
            }
        } message: {
            Text(
                "This file has been flagged as suspicious. DO NOT open, run, or execute it. Only inspect it to verify if it's a false positive from software you intentionally installed."
            )
        }
        .sheet(isPresented: $showDetails) {
            FindingDetailsSheet(finding: finding)
        }
    }

    // MARK: Private

    @State private var showWarning = false
    @State private var showDetails = false
    @State private var isFixing = false
    @State private var fixResult: String?

    private func attemptFix() {
        isFixing = true

        Task {
            let result = await performFix(for: finding)
            await MainActor.run {
                isFixing = false
                fixResult = result
            }
        }
    }

    private func performFix(for finding: AuditFinding) async -> String {
        // Execute remediation based on finding type
        switch finding.phase {
        case .securitySettings:
            if finding.title.contains("Firewall") {
                return await enableFirewall()
            }
        case .fileSystemAudit:
            if let path = finding.filePath, finding.title.contains("World-Writable") {
                return await fixFilePermissions(path: path)
            }
        case .backdoorDetection:
            if let path = finding.filePath {
                return await disableLaunchAgent(path: path)
            }
        default:
            break
        }
        return "Manual remediation required - see details"
    }

    private func enableFirewall() async -> String {
        // Note: This requires admin privileges and will prompt the user
        // Using sudo is intentional here for firewall configuration
        // The command and arguments are hardcoded to prevent injection
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        // Arguments are hardcoded and not user-controllable - safe from injection
        process.arguments = ["/usr/libexec/ApplicationFirewall/socketfilterfw", "--setglobalstate", "on"]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? "✓ Firewall enabled successfully" : "⚠️ Failed - requires admin privileges"
        } catch {
            return "⚠️ Error: \(error.localizedDescription)"
        }
    }

    private func fixFilePermissions(path: String) async -> String {
        // Validate path to prevent command injection and path traversal
        guard PathValidation.validatePath(path) else {
            return "⚠️ Invalid or non-existent file path"
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/chmod")
        process.arguments = ["644", path]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? "✓ Permissions fixed" : "⚠️ Failed to fix permissions"
        } catch {
            return "⚠️ Error: \(error.localizedDescription)"
        }
    }

    private func disableLaunchAgent(path: String) async -> String {
        // Validate path to prevent command injection and ensure it's a .plist file
        guard PathValidation.validatePath(path, requireExtension: ".plist") else {
            return "⚠️ Invalid or non-existent LaunchAgent path"
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["unload", path]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? "✓ LaunchAgent disabled" : "⚠️ Failed to disable"
        } catch {
            return "⚠️ Error: \(error.localizedDescription)"
        }
    }

    private func revealInFinder(path: String) {
        // Validate path to prevent malicious file access
        guard PathValidation.validatePath(path) else {
            return
        }
        
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func openVirusTotal(hash: String) {
        // Validate hash format (SHA256 is 64 hex characters)
        let range = NSRange(hash.startIndex..., in: hash)
        guard Self.sha256Regex.numberOfMatches(in: hash, range: range) == 1 else {
            return
        }
        
        let urlString = "https://www.virustotal.com/gui/file/\(hash)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - FindingDetailsSheet

struct FindingDetailsSheet: View {
    // MARK: Internal

    let finding: AuditFinding

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: finding.severity.icon)
                        .font(.title)
                        .foregroundColor(finding.severity.color)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(finding.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            Text(finding.severity.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(finding.severity.color.opacity(0.2))
                                .foregroundColor(finding.severity.color)
                                .cornerRadius(4)

                            Text(finding.phase.title)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                // Root Cause Analysis
                DetailSection(
                    title: "Root Cause",
                    icon: "magnifyingglass.circle.fill",
                    color: .orange,
                    content: finding.rootCause
                )

                // Security Impact
                DetailSection(
                    title: "Security Impact",
                    icon: "exclamationmark.shield.fill",
                    color: .red,
                    content: finding.impact
                )

                // Remediation Steps
                DetailSection(
                    title: "How to Fix",
                    icon: "wrench.and.screwdriver.fill",
                    color: .green,
                    content: finding.remediation
                )

                // File Information (if applicable)
                if let filePath = finding.filePath {
                    DetailSection(
                        title: "File Location",
                        icon: "doc.fill",
                        color: .blue,
                        content: filePath
                    )
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 600, height: 500)
        .aeroBackground()
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
}

// MARK: - DetailSection

struct DetailSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.headline)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

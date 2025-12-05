//
//  SecurityScanView.swift
//  Mad Scientist
//

import SwiftUI

struct SecurityScanView: View {
    @State private var isScanning = false
    @State private var scanProgress: Double = 0
    @State private var securityIssues: [SecurityIssue] = []
    @State private var scanComplete = false
    @State private var scanTimer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("Security Scan")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Detect vulnerabilities and security threats")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // Scan Progress
            if isScanning {
                VStack(spacing: 12) {
                    ProgressView(value: scanProgress)
                        .progressViewStyle(.linear)

                    Text("Scanning... \(Int(scanProgress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
            }

            // Scan Button
            Button(action: performScan) {
                HStack {
                    if isScanning {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 4)
                    }
                    Text(isScanning ? "Scanning..." : "Start Security Scan")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isScanning)
            .padding(.horizontal)

            // Summary
            if scanComplete {
                HStack(spacing: 20) {
                    ScanSummaryItem(
                        count: securityIssues.filter { $0.severity == .critical }.count,
                        label: "Critical",
                        color: .red
                    )
                    ScanSummaryItem(
                        count: securityIssues.filter { $0.severity == .high }.count,
                        label: "High",
                        color: .orange
                    )
                    ScanSummaryItem(
                        count: securityIssues.filter { $0.severity == .medium }.count,
                        label: "Medium",
                        color: .yellow
                    )
                    ScanSummaryItem(
                        count: securityIssues.filter { $0.severity == .low }.count,
                        label: "Low",
                        color: .green
                    )
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
            }

            // Results
            if securityIssues.isEmpty && !isScanning {
                VStack(spacing: 12) {
                    Image(systemName: scanComplete ? "checkmark.shield.fill" : "shield")
                        .font(.system(size: 40))
                        .foregroundColor(scanComplete ? .green : .gray)
                    Text(scanComplete ? "No threats detected!" : "Ready to scan")
                        .font(.headline)
                    Text(scanComplete ? "Your system appears to be secure" : "Start a scan to check for security issues")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List(securityIssues) { issue in
                    SecurityIssueRow(issue: issue)
                }
                .listStyle(.inset)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .onDisappear {
            stopScan()
        }
    }

    private func performScan() {
        isScanning = true
        scanProgress = 0
        securityIssues = []
        scanComplete = false

        // Simulate scanning with progress
        scanTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            scanProgress += 0.05

            if scanProgress >= 1.0 {
                timer.invalidate()
                scanTimer = nil

                // Simulate finding some issues
                securityIssues = [
                    SecurityIssue(
                        name: "Outdated Software",
                        description: "Some applications need security updates",
                        severity: .medium,
                        category: .software
                    ),
                    SecurityIssue(
                        name: "Weak Password Detected",
                        description: "Keychain contains passwords with weak entropy",
                        severity: .high,
                        category: .passwords
                    ),
                    SecurityIssue(
                        name: "Firewall Disabled",
                        description: "macOS firewall is currently disabled",
                        severity: .medium,
                        category: .network
                    ),
                ]

                isScanning = false
                scanComplete = true
            }
        }
    }

    private func stopScan() {
        scanTimer?.invalidate()
        scanTimer = nil
    }
}

enum SecuritySeverity: String {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.circle.fill"
        case .medium: return "exclamationmark.circle"
        case .low: return "info.circle"
        }
    }
}

enum SecurityCategory: String {
    case software = "Software"
    case network = "Network"
    case passwords = "Passwords"
    case privacy = "Privacy"
    case malware = "Malware"
}

struct SecurityIssue: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let severity: SecuritySeverity
    let category: SecurityCategory
}

struct SecurityIssueRow: View {
    let issue: SecurityIssue

    var body: some View {
        HStack {
            Image(systemName: issue.severity.icon)
                .foregroundColor(issue.severity.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.name)
                    .font(.headline)
                Text(issue.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(issue.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(issue.severity.color.opacity(0.2))
                    .foregroundColor(issue.severity.color)
                    .cornerRadius(4)
                Text(issue.category.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ScanSummaryItem: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

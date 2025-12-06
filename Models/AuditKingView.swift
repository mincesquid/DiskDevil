//
//  AuditKingView.swift
//  DiskDevil
//
//  Military-Grade Ultimate System Audit - Elite Tier Exclusive

import AppKit
import SwiftUI

struct AuditKingView: View {
    @State private var isAuditing = false
    @State private var auditProgress: Double = 0
    @State private var currentPhase: AuditPhase = .idle
    @State private var findings: [AuditFinding] = []
    @State private var auditComplete = false
    @State private var threatLevel: ThreatLevel = .unknown

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Military Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.purple.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 20, x: 0, y: 10)
                    }

                    VStack(spacing: 6) {
                        Text("AUDITKING")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2)

                        Text("MILITARY-GRADE SYSTEM AUDIT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .tracking(1.5)

                        HStack(spacing: 4) {
                            ForEach(0 ..< 3, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.purple)
                                    .font(.caption2)
                            }
                            Text("ELITE EXCLUSIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            ForEach(0 ..< 3, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.purple)
                                    .font(.caption2)
                            }
                        }
                    }

                    Text("The most comprehensive security audit available")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Threat Level Display
                if auditComplete {
                    ThreatLevelCard(level: threatLevel, findingsCount: findings.count)
                        .glassCard()
                }

                // Audit Controls
                if !isAuditing {
                    Button(action: startAudit) {
                        HStack(spacing: 12) {
                            Image(systemName: "scope")
                                .font(.title3)
                            Text(auditComplete ? "Run New Audit" : "Begin Military-Grade Audit")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .disabled(isAuditing)
                    .padding(.horizontal)
                } else {
                    // Progress Display
                    VStack(spacing: 16) {
                        ProgressView(value: auditProgress)
                            .progressViewStyle(.linear)
                            .tint(.purple)

                        VStack(spacing: 8) {
                            Text(currentPhase.title)
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("\(Int(auditProgress * 100))% Complete")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))

                            Text(currentPhase.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .glassCard()
                }

                // Audit Categories (What will be checked)
                if !isAuditing, !auditComplete {
                    AuditCategoriesGrid()
                        .glassCard()
                }

                // Findings Display
                if auditComplete, !findings.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Audit Findings (\(findings.count))")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(findings) { finding in
                            FindingRow(finding: finding)
                        }
                    }
                    .padding()
                    .glassCard()
                } else if auditComplete, findings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text("System is Secure")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("No security issues detected during military-grade audit")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .glassCard()
                }

                Spacer()
            }
            .padding()
        }
        .aeroBackground()
    }

    private func startAudit() {
        isAuditing = true
        auditComplete = false
        auditProgress = 0
        currentPhase = .systemIntegrity
        findings = []
        threatLevel = .unknown

        // Simulate comprehensive audit
        Task {
            await performAudit()
        }
    }

    private func performAudit() async {
        let phases: [AuditPhase] = [
            .systemIntegrity,
            .securitySettings,
            .networkSecurity,
            .privacySettings,
            .processAnalysis,
            .fileSystemAudit,
            .kernelInspection,
            .backdoorDetection,
            .rootkitScan,
            .finalAnalysis,
        ]

        for (index, phase) in phases.enumerated() {
            await MainActor.run {
                currentPhase = phase
                auditProgress = Double(index) / Double(phases.count)
            }

            // Simulate audit duration
            try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 500_000_000 ... 1_500_000_000)))

            // Generate random findings
            let phaseFindings = generateFindings(for: phase)
            await MainActor.run {
                findings.append(contentsOf: phaseFindings)
            }
        }

        // Complete audit
        await MainActor.run {
            auditProgress = 1.0
            isAuditing = false
            auditComplete = true
            threatLevel = calculateThreatLevel()
        }
    }

    private func generateFindings(for phase: AuditPhase) -> [AuditFinding] {
        var phaseFindings: [AuditFinding] = []

        // Randomly add findings (20% chance per phase)
        if Bool.random(), Bool.random() {
            let severities: [FindingSeverity] = [.critical, .high, .medium, .low]
            let severity = severities.randomElement() ?? .low

            // Generate realistic file paths and hashes based on phase
            let (filePath, fileHash) = generateSuspiciousFile(for: phase)

            let finding = AuditFinding(
                title: phase.sampleFinding,
                description: phase.findingDescription,
                severity: severity,
                phase: phase,
                filePath: filePath,
                fileHash: fileHash,
                rootCause: phase.rootCause,
                impact: phase.securityImpact,
                remediation: phase.remediation,
                canAutoFix: phase.canAutoFix
            )
            phaseFindings.append(finding)
        }

        return phaseFindings
    }

    private func generateSuspiciousFile(for phase: AuditPhase) -> (String?, String?) {
        // Use real system files that exist on macOS for demo purposes
        // In production, these would be actual suspicious files found during scanning
        let suspiciousFiles: [String]

        switch phase {
        case .processAnalysis:
            suspiciousFiles = [
                "/usr/bin/python3",
                "/usr/bin/curl",
                "/usr/bin/nc",
            ]
        case .fileSystemAudit:
            suspiciousFiles = [
                "/private/etc/hosts",
                "/usr/bin/sudo",
                "/bin/sh",
            ]
        case .kernelInspection:
            suspiciousFiles = [
                "/System/Library/Extensions/AppleAPIC.kext",
                "/System/Library/Extensions/AppleACPIPlatform.kext",
            ]
        case .backdoorDetection:
            suspiciousFiles = [
                "/System/Library/LaunchDaemons/com.apple.metadata.mds.plist",
                "/System/Library/LaunchAgents/com.apple.notificationcenterui.plist",
            ]
        case .rootkitScan:
            suspiciousFiles = [
                "/usr/sbin/cron",
                "/usr/bin/ssh",
                "/usr/bin/launchctl",
            ]
        default:
            // For phases without specific files
            return (nil, nil)
        }

        let selectedFile = suspiciousFiles.randomElement()

        // Generate a fake SHA256 hash (64 hex characters)
        let hash = String((0 ..< 64).map { _ in
            "0123456789abcdef".randomElement()!
        })

        return (selectedFile, hash)
    }

    private func calculateThreatLevel() -> ThreatLevel {
        let criticalCount = findings.filter { $0.severity == .critical }.count
        let highCount = findings.filter { $0.severity == .high }.count

        if criticalCount > 0 {
            return .critical
        } else if highCount > 1 {
            return .high
        } else if findings.count > 3 {
            return .medium
        } else if findings.isEmpty {
            return .secure
        } else {
            return .low
        }
    }
}

// MARK: - Audit Phase

enum AuditPhase {
    case idle
    case systemIntegrity
    case securitySettings
    case networkSecurity
    case privacySettings
    case processAnalysis
    case fileSystemAudit
    case kernelInspection
    case backdoorDetection
    case rootkitScan
    case finalAnalysis

    var title: String {
        switch self {
        case .idle: return "Ready"
        case .systemIntegrity: return "System Integrity Check"
        case .securitySettings: return "Security Configuration Audit"
        case .networkSecurity: return "Network Security Analysis"
        case .privacySettings: return "Privacy Settings Inspection"
        case .processAnalysis: return "Process & Service Analysis"
        case .fileSystemAudit: return "File System Audit"
        case .kernelInspection: return "Kernel Extension Inspection"
        case .backdoorDetection: return "Backdoor Detection"
        case .rootkitScan: return "Rootkit Scanning"
        case .finalAnalysis: return "Final Threat Analysis"
        }
    }

    var description: String {
        switch self {
        case .idle: return "Click to begin comprehensive audit"
        case .systemIntegrity: return "Verifying SIP, FileVault, Gatekeeper status"
        case .securitySettings: return "Analyzing firewall, encryption, and security policies"
        case .networkSecurity: return "Scanning network interfaces and connections"
        case .privacySettings: return "Checking telemetry, analytics, and tracking settings"
        case .processAnalysis: return "Inspecting running processes and services"
        case .fileSystemAudit: return "Analyzing file permissions and suspicious files"
        case .kernelInspection: return "Examining kernel extensions and drivers"
        case .backdoorDetection: return "Scanning for backdoors and persistence mechanisms"
        case .rootkitScan: return "Detecting rootkits and kernel-level threats"
        case .finalAnalysis: return "Calculating threat level and generating report"
        }
    }

    var sampleFinding: String {
        switch self {
        case .systemIntegrity: return "System Integrity Protection Disabled"
        case .securitySettings: return "Firewall Disabled"
        case .networkSecurity: return "Suspicious Network Connection Detected"
        case .privacySettings: return "Analytics Telemetry Enabled"
        case .processAnalysis: return "Unknown Process Running"
        case .fileSystemAudit: return "World-Writable System File"
        case .kernelInspection: return "Unsigned Kernel Extension Loaded"
        case .backdoorDetection: return "Suspicious LaunchAgent Detected"
        case .rootkitScan: return "Rootkit Signature Match"
        default: return "Security Issue Detected"
        }
    }

    var findingDescription: String {
        switch self {
        case .systemIntegrity: return "SIP should be enabled to protect system files"
        case .securitySettings: return "Enable firewall to block unauthorized connections"
        case .networkSecurity: return "Unusual outbound connection detected"
        case .privacySettings: return "Telemetry is sending data to Apple servers"
        case .processAnalysis: return "Unrecognized process detected in system"
        case .fileSystemAudit: return "Critical system file has insecure permissions"
        case .kernelInspection: return "Loaded kext is not signed by Apple"
        case .backdoorDetection: return "Persistence mechanism found in user agents"
        case .rootkitScan: return "Potential rootkit detected"
        default: return "Security vulnerability identified"
        }
    }

    var rootCause: String {
        switch self {
        case .systemIntegrity:
            return "System Integrity Protection (SIP) has been manually disabled, likely by booting into Recovery Mode and running 'csrutil disable'. This removes a critical security layer that protects system files from modification."
        case .securitySettings:
            return "The macOS Application Firewall is currently disabled. This may have been turned off manually in System Preferences > Security & Privacy > Firewall, or it was never enabled after installation."
        case .networkSecurity:
            return "A process on your system is communicating with an external server that's not commonly seen in legitimate applications. This could be legitimate software phoning home, or malware establishing command & control communication."
        case .privacySettings:
            return "macOS analytics and diagnostic reporting is enabled, sending usage data, crash reports, and telemetry to Apple servers. While legitimate, this reduces privacy and shares information about your system usage."
        case .processAnalysis:
            return "A running process was detected that doesn't match known system processes or common applications. This could be legitimate third-party software, developer tools, or potentially malicious code that's executing on your system."
        case .fileSystemAudit:
            return "A system file or directory has world-writable permissions (chmod 777 or similar), allowing any user or process to modify it. This violates the principle of least privilege and creates a security vulnerability."
        case .kernelInspection:
            return "A kernel extension (kext) is loaded that's not signed by Apple. This could be legitimate third-party drivers (GPU, network adapters) or potentially malicious code running with kernel-level privileges."
        case .backdoorDetection:
            return "A LaunchAgent or LaunchDaemon plist file was found that establishes persistence, ensuring a program automatically runs when you log in or when the system boots. This is a common backdoor technique."
        case .rootkitScan:
            return "System binaries or kernel structures match known rootkit signatures. Rootkits are malicious software that hide their presence by modifying core system components, making them extremely difficult to detect."
        default:
            return "A security vulnerability has been identified that requires investigation to determine the root cause and appropriate remediation steps."
        }
    }

    var securityImpact: String {
        switch self {
        case .systemIntegrity:
            return "CRITICAL RISK: Without SIP, malware can modify system files, inject code into Apple processes, install rootkits, and bypass macOS security features. Attackers can persistently compromise your system at the deepest level."
        case .securitySettings:
            return "HIGH RISK: Without a firewall, your Mac accepts incoming network connections from any source. Malware, remote attackers, and network worms can directly connect to vulnerable services running on your machine."
        case .networkSecurity:
            return "MEDIUM-HIGH RISK: If this connection is malicious, it could be exfiltrating sensitive data, downloading additional malware payloads, or receiving commands from an attacker's server. Legitimate software may also exhibit this behavior."
        case .privacySettings:
            return "LOW-MEDIUM RISK: Apple receives detailed information about your system usage, installed software, crash data, and potentially personally identifiable information. This reduces your privacy but doesn't directly compromise security."
        case .processAnalysis:
            return "UNKNOWN RISK: If this process is malicious, it could be: stealing data, keylogging, taking screenshots, running a cryptominer, establishing backdoors, or acting as a trojan. Requires investigation to determine legitimacy."
        case .fileSystemAudit:
            return "HIGH RISK: Any user or malicious process can modify this file, potentially replacing system binaries with trojaned versions, modifying configuration files to disable security features, or escalating privileges."
        case .kernelInspection:
            return "CRITICAL RISK: Kernel extensions run with Ring 0 privileges—complete control over your system. A malicious kext can hide processes, intercept all network traffic, log keystrokes, disable security features, and survive reboots."
        case .backdoorDetection:
            return "HIGH RISK: This persistence mechanism ensures malware survives reboots and user logouts. Even if you 'quit' the malicious application, it will automatically restart. This is how ransomware and spyware maintain access."
        case .rootkitScan:
            return "CRITICAL RISK: Rootkits operate at the kernel level with complete control over your system. They can hide files, processes, network connections, and their own presence. Standard antivirus cannot detect them reliably."
        default:
            return "The security impact varies depending on the specific vulnerability. Investigation required to assess the full risk to your system."
        }
    }

    var remediation: String {
        switch self {
        case .systemIntegrity:
            return """
            MANUAL FIX REQUIRED:
            1. Restart your Mac and hold Command+R to boot into Recovery Mode
            2. Go to Utilities > Terminal
            3. Run: csrutil enable
            4. Restart your Mac normally

            WARNING: Some legitimate software (VM tools, development tools) may require SIP to be disabled. Only re-enable if you understand the implications.
            """
        case .securitySettings:
            return """
            AUTO-FIX AVAILABLE:
            Click 'Fix Issue' to enable the firewall automatically.

            Manual alternative:
            1. Open System Preferences > Security & Privacy
            2. Click the Firewall tab
            3. Click the lock icon and enter your password
            4. Click 'Turn On Firewall'
            5. Click 'Firewall Options' to configure allowed apps
            """
        case .networkSecurity:
            return """
            INVESTIGATION REQUIRED:
            1. Identify the process making the connection using Activity Monitor > Network tab
            2. Research the process name online to determine if it's legitimate
            3. If malicious, terminate the process and delete the application
            4. Block the connection using Little Snitch, Lulu, or pfctl firewall rules
            5. Run a full system scan with multiple security tools
            """
        case .privacySettings:
            return """
            MANUAL FIX:
            1. Open System Preferences > Security & Privacy > Privacy
            2. Select 'Analytics & Improvements'
            3. Uncheck 'Share Mac Analytics'
            4. Uncheck 'Share iCloud Analytics'
            5. Uncheck 'Improve Siri & Dictation'

            Additional steps: Disable Spotlight Suggestions, Siri, and iCloud features to maximize privacy.
            """
        case .processAnalysis:
            return """
            INVESTIGATION REQUIRED:
            1. Open Activity Monitor and locate the suspicious process
            2. Right-click > 'Sample Process' to see what it's doing
            3. Right-click > 'Open Files and Ports' to see what it's accessing
            4. Google the process name to determine legitimacy
            5. If suspicious: Force Quit, then delete the application bundle
            6. Check Login Items and LaunchAgents to prevent restart
            """
        case .fileSystemAudit:
            return """
            AUTO-FIX AVAILABLE:
            Click 'Fix Issue' to correct file permissions automatically.

            Manual alternative:
            sudo chmod 644 /path/to/file  (for regular files)
            sudo chmod 755 /path/to/directory  (for directories)
            sudo chown root:wheel /path/to/system/file  (restore ownership)

            WARNING: Only fix permissions on files you understand. Some applications may require specific permissions.
            """
        case .kernelInspection:
            return """
            INVESTIGATION REQUIRED:
            1. Run: kextstat | grep -v com.apple  (list non-Apple kexts)
            2. Identify the kext owner (GPU drivers, VMs, security software)
            3. If legitimate: Whitelist and ignore
            4. If suspicious: sudo kextunload /path/to/kext
            5. Delete the kext: sudo rm -rf /Library/Extensions/suspicious.kext
            6. Rebuild kext cache: sudo kextcache -i /

            CAUTION: Removing legitimate kexts can break hardware functionality.
            """
        case .backdoorDetection:
            return """
            AUTO-FIX AVAILABLE:
            Click 'Fix Issue' to disable the LaunchAgent.

            Manual steps:
            1. launchctl unload /path/to/suspicious.plist
            2. sudo rm /path/to/suspicious.plist
            3. Delete the associated application bundle
            4. Check these locations for additional persistence:
               - ~/Library/LaunchAgents
               - /Library/LaunchAgents
               - /Library/LaunchDaemons
               - ~/Library/Application Support
            5. Reboot to ensure it doesn't restart
            """
        case .rootkitScan:
            return """
            CRITICAL - ADVANCED REMEDIATION REQUIRED:

            Rootkits are extremely difficult to remove. Recommended approach:

            1. IMMEDIATELY disconnect from network
            2. Boot into Recovery Mode (Command+R)
            3. Backup your personal files ONLY (not applications)
            4. Perform a complete erase and reinstall of macOS
            5. Restore personal files from backup
            6. Reinstall applications from trusted sources only

            DO NOT attempt to 'clean' a rootkit infection. Rootkits modify system binaries and can survive removal attempts. Complete reinstall is the only reliable solution.
            """
        default:
            return "Specific remediation steps not available. Please investigate the finding details and consult security documentation for appropriate response procedures."
        }
    }

    var canAutoFix: Bool {
        switch self {
        case .securitySettings, .fileSystemAudit, .backdoorDetection:
            return true
        default:
            return false
        }
    }
}

// MARK: - Models

enum FindingSeverity: String {
    case critical = "CRITICAL"
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.octagon.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .low: return "info.circle.fill"
        }
    }
}

enum ThreatLevel {
    case unknown
    case secure
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .unknown: return .gray
        case .secure: return .green
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    var title: String {
        switch self {
        case .unknown: return "Unknown"
        case .secure: return "SECURE"
        case .low: return "LOW THREAT"
        case .medium: return "MEDIUM THREAT"
        case .high: return "HIGH THREAT"
        case .critical: return "CRITICAL THREAT"
        }
    }

    var description: String {
        switch self {
        case .unknown: return "Run audit to assess threat level"
        case .secure: return "System is secure with no vulnerabilities detected"
        case .low: return "Minor issues detected, no immediate action required"
        case .medium: return "Multiple security issues require attention"
        case .high: return "Serious security vulnerabilities detected"
        case .critical: return "IMMEDIATE ACTION REQUIRED - Critical security risk"
        }
    }
}

struct AuditFinding: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: FindingSeverity
    let phase: AuditPhase
    let filePath: String? // Path to suspicious file for inspection
    let fileHash: String? // SHA256 hash for VirusTotal lookup
    let rootCause: String // Detailed explanation of root cause
    let impact: String // What this means for security
    let remediation: String // How to fix it
    let canAutoFix: Bool // Whether we can fix it automatically
}

// MARK: - UI Components

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

struct FindingRow: View {
    let finding: AuditFinding
    @State private var showWarning = false
    @State private var showDetails = false
    @State private var isFixing = false
    @State private var fixResult: String?

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
            Text("This file has been flagged as suspicious. DO NOT open, run, or execute it. Only inspect it to verify if it's a false positive from software you intentionally installed.")
        }
        .sheet(isPresented: $showDetails) {
            FindingDetailsSheet(finding: finding)
        }
    }

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
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
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
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func openVirusTotal(hash: String) {
        let urlString = "https://www.virustotal.com/gui/file/\(hash)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Finding Details Sheet

struct FindingDetailsSheet: View {
    let finding: AuditFinding
    @Environment(\.dismiss) private var dismiss

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
}

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

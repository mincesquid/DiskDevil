//
//  AuditModels.swift
//  DiskDevil
//
//  AuditKing data models and enums

import Foundation
import SwiftUI

// MARK: - AuditPhase

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

    // MARK: Internal

    var title: String {
        switch self {
        case .idle: "Ready"
        case .systemIntegrity: "System Integrity Check"
        case .securitySettings: "Security Configuration Audit"
        case .networkSecurity: "Network Security Analysis"
        case .privacySettings: "Privacy Settings Inspection"
        case .processAnalysis: "Process & Service Analysis"
        case .fileSystemAudit: "File System Audit"
        case .kernelInspection: "Kernel Extension Inspection"
        case .backdoorDetection: "Backdoor Detection"
        case .rootkitScan: "Rootkit Scanning"
        case .finalAnalysis: "Final Threat Analysis"
        }
    }

    var description: String {
        switch self {
        case .idle: "Click to begin comprehensive audit"
        case .systemIntegrity: "Verifying SIP, FileVault, Gatekeeper status"
        case .securitySettings: "Analyzing firewall, encryption, and security policies"
        case .networkSecurity: "Scanning network interfaces and connections"
        case .privacySettings: "Checking telemetry, analytics, and tracking settings"
        case .processAnalysis: "Inspecting running processes and services"
        case .fileSystemAudit: "Analyzing file permissions and suspicious files"
        case .kernelInspection: "Examining kernel extensions and drivers"
        case .backdoorDetection: "Scanning for backdoors and persistence mechanisms"
        case .rootkitScan: "Detecting rootkits and kernel-level threats"
        case .finalAnalysis: "Calculating threat level and generating report"
        }
    }

    var sampleFinding: String {
        switch self {
        case .systemIntegrity: "System Integrity Protection Disabled"
        case .securitySettings: "Firewall Disabled"
        case .networkSecurity: "Suspicious Network Connection Detected"
        case .privacySettings: "Analytics Telemetry Enabled"
        case .processAnalysis: "Unknown Process Running"
        case .fileSystemAudit: "World-Writable System File"
        case .kernelInspection: "Unsigned Kernel Extension Loaded"
        case .backdoorDetection: "Suspicious LaunchAgent Detected"
        case .rootkitScan: "Rootkit Signature Match"
        default: "Security Issue Detected"
        }
    }

    var findingDescription: String {
        switch self {
        case .systemIntegrity: "SIP should be enabled to protect system files"
        case .securitySettings: "Enable firewall to block unauthorized connections"
        case .networkSecurity: "Unusual outbound connection detected"
        case .privacySettings: "Telemetry is sending data to Apple servers"
        case .processAnalysis: "Unrecognized process detected in system"
        case .fileSystemAudit: "Critical system file has insecure permissions"
        case .kernelInspection: "Loaded kext is not signed by Apple"
        case .backdoorDetection: "Persistence mechanism found in user agents"
        case .rootkitScan: "Potential rootkit detected"
        default: "Security vulnerability identified"
        }
    }

    var rootCause: String {
        switch self {
        case .systemIntegrity:
            """
            System Integrity Protection (SIP) has been manually disabled, likely by booting into Recovery Mode \
            and running 'csrutil disable'. This removes a critical security layer that protects system files \
            from modification.
            """
        case .securitySettings:
            """
            The macOS Application Firewall is currently disabled. This may have been turned off manually in \
            System Preferences > Security & Privacy > Firewall, or it was never enabled after installation.
            """
        case .networkSecurity:
            """
            A process on your system is communicating with an external server that's not commonly seen in \
            legitimate applications. This could be legitimate software phoning home, or malware establishing \
            command & control communication.
            """
        case .privacySettings:
            """
            macOS analytics and diagnostic reporting is enabled, sending usage data, crash reports, and \
            telemetry to Apple servers. While legitimate, this reduces privacy and shares information about \
            your system usage.
            """
        case .processAnalysis:
            """
            A running process was detected that doesn't match known system processes or common applications. \
            This could be legitimate third-party software, developer tools, or potentially malicious code \
            that's executing on your system.
            """
        case .fileSystemAudit:
            """
            A system file or directory has world-writable permissions (chmod 777 or similar), allowing any \
            user or process to modify it. This violates the principle of least privilege and creates a \
            security vulnerability.
            """
        case .kernelInspection:
            """
            A kernel extension (kext) is loaded that's not signed by Apple. This could be legitimate \
            third-party drivers (GPU, network adapters) or potentially malicious code running with \
            kernel-level privileges.
            """
        case .backdoorDetection:
            """
            A LaunchAgent or LaunchDaemon plist file was found that establishes persistence, ensuring a \
            program automatically runs when you log in or when the system boots. This is a common backdoor \
            technique.
            """
        case .rootkitScan:
            """
            System binaries or kernel structures match known rootkit signatures. Rootkits are malicious \
            software that hide their presence by modifying core system components, making them extremely \
            difficult to detect.
            """
        default:
            """
            A security vulnerability has been identified that requires investigation to determine the root \
            cause and appropriate remediation steps.
            """
        }
    }

    var securityImpact: String {
        switch self {
        case .systemIntegrity:
            """
            CRITICAL RISK: Without SIP, malware can modify system files, inject code into Apple processes, \
            install rootkits, and bypass macOS security features. Attackers can persistently compromise your \
            system at the deepest level.
            """
        case .securitySettings:
            """
            HIGH RISK: Without a firewall, your Mac accepts incoming network connections from any source. \
            Malware, remote attackers, and network worms can directly connect to vulnerable services running \
            on your machine.
            """
        case .networkSecurity:
            """
            MEDIUM-HIGH RISK: If this connection is malicious, it could be exfiltrating sensitive data, \
            downloading additional malware payloads, or receiving commands from an attacker's server. \
            Legitimate software may also exhibit this behavior.
            """
        case .privacySettings:
            """
            LOW-MEDIUM RISK: Apple receives detailed information about your system usage, installed software, \
            crash data, and potentially personally identifiable information. This reduces your privacy but \
            doesn't directly compromise security.
            """
        case .processAnalysis:
            """
            UNKNOWN RISK: If this process is malicious, it could be: stealing data, keylogging, taking \
            screenshots, running a cryptominer, establishing backdoors, or acting as a trojan. Requires \
            investigation to determine legitimacy.
            """
        case .fileSystemAudit:
            """
            HIGH RISK: Any user or malicious process can modify this file, potentially replacing system \
            binaries with trojaned versions, modifying configuration files to disable security features, or \
            escalating privileges.
            """
        case .kernelInspection:
            """
            CRITICAL RISK: Kernel extensions run with Ring 0 privileges—complete control over your system. \
            A malicious kext can hide processes, intercept all network traffic, log keystrokes, disable \
            security features, and survive reboots.
            """
        case .backdoorDetection:
            """
            HIGH RISK: This persistence mechanism ensures malware survives reboots and user logouts. Even if \
            you 'quit' the malicious application, it will automatically restart. This is how ransomware and \
            spyware maintain access.
            """
        case .rootkitScan:
            """
            CRITICAL RISK: Rootkits operate at the kernel level with complete control over your system. They \
            can hide files, processes, network connections, and their own presence. Standard antivirus cannot \
            detect them reliably.
            """
        default:
            """
            The security impact varies depending on the specific vulnerability. Investigation required to \
            assess the full risk to your system.
            """
        }
    }

    var remediation: String {
        switch self {
        case .systemIntegrity:
            """
            MANUAL FIX REQUIRED:
            1. Restart your Mac and hold Command+R to boot into Recovery Mode
            2. Go to Utilities > Terminal
            3. Run: csrutil enable
            4. Restart your Mac normally

            WARNING: Some legitimate software (VM tools, development tools) may require SIP to be disabled. \
            Only re-enable if you understand the implications.
            """
        case .securitySettings:
            """
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
            """
            INVESTIGATION REQUIRED:
            1. Identify the process making the connection using Activity Monitor > Network tab
            2. Research the process name online to determine if it's legitimate
            3. If malicious, terminate the process and delete the application
            4. Block the connection using Little Snitch, Lulu, or pfctl firewall rules
            5. Run a full system scan with multiple security tools
            """
        case .privacySettings:
            """
            MANUAL FIX:
            1. Open System Preferences > Security & Privacy > Privacy
            2. Select 'Analytics & Improvements'
            3. Uncheck 'Share Mac Analytics'
            4. Uncheck 'Share iCloud Analytics'
            5. Uncheck 'Improve Siri & Dictation'

            Additional steps: Disable Spotlight Suggestions, Siri, and iCloud features to maximize privacy.
            """
        case .processAnalysis:
            """
            INVESTIGATION REQUIRED:
            1. Open Activity Monitor and locate the suspicious process
            2. Right-click > 'Sample Process' to see what it's doing
            3. Right-click > 'Open Files and Ports' to see what it's accessing
            4. Google the process name to determine legitimacy
            5. If suspicious: Force Quit, then delete the application bundle
            6. Check Login Items and LaunchAgents to prevent restart
            """
        case .fileSystemAudit:
            """
            AUTO-FIX AVAILABLE:
            Click 'Fix Issue' to correct file permissions automatically.

            Manual alternative:
            sudo chmod 644 /path/to/file  (for regular files)
            sudo chmod 755 /path/to/directory  (for directories)
            sudo chown root:wheel /path/to/system/file  (restore ownership)

            WARNING: Only fix permissions on files you understand. Some applications may require specific permissions.
            """
        case .kernelInspection:
            """
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
            """
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
            """
            CRITICAL - ADVANCED REMEDIATION REQUIRED:

            Rootkits are extremely difficult to remove. Recommended approach:

            1. IMMEDIATELY disconnect from network
            2. Boot into Recovery Mode (Command+R)
            3. Backup your personal files ONLY (not applications)
            4. Perform a complete erase and reinstall of macOS
            5. Restore personal files from backup
            6. Reinstall applications from trusted sources only

            DO NOT attempt to 'clean' a rootkit infection. Rootkits modify system binaries and can \
            survive removal attempts. Complete reinstall is the only reliable solution.
            """
        default:
            """
            Specific remediation steps not available. Please investigate the finding details and consult \
            security documentation for appropriate response procedures.
            """
        }
    }

    var canAutoFix: Bool {
        switch self {
        case .securitySettings,
             .fileSystemAudit,
             .backdoorDetection:
            true
        default:
            false
        }
    }
}

// MARK: - FindingSeverity

enum FindingSeverity: String {
    case critical = "CRITICAL"
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    // MARK: Internal

    var color: Color {
        switch self {
        case .critical: .red
        case .high: .orange
        case .medium: .yellow
        case .low: .blue
        }
    }

    var icon: String {
        switch self {
        case .critical: "exclamationmark.octagon.fill"
        case .high: "exclamationmark.triangle.fill"
        case .medium: "exclamationmark.circle.fill"
        case .low: "info.circle.fill"
        }
    }
}

// MARK: - ThreatLevel

enum ThreatLevel {
    case unknown
    case secure
    case low
    case medium
    case high
    case critical

    // MARK: Internal

    var color: Color {
        switch self {
        case .unknown: .gray
        case .secure: .green
        case .low: .blue
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }

    var title: String {
        switch self {
        case .unknown: "Unknown"
        case .secure: "SECURE"
        case .low: "LOW THREAT"
        case .medium: "MEDIUM THREAT"
        case .high: "HIGH THREAT"
        case .critical: "CRITICAL THREAT"
        }
    }

    var description: String {
        switch self {
        case .unknown: "Run audit to assess threat level"
        case .secure: "System is secure with no vulnerabilities detected"
        case .low: "Minor issues detected, no immediate action required"
        case .medium: "Multiple security issues require attention"
        case .high: "Serious security vulnerabilities detected"
        case .critical: "IMMEDIATE ACTION REQUIRED - Critical security risk"
        }
    }
}

// MARK: - AuditFinding

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

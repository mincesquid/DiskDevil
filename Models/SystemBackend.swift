import Foundation

// MARK: - NetworkMonitorService

// Lightweight backend services for system data the UI can consume.

final class NetworkMonitorService: ObservableObject {
    // MARK: Internal

    @Published private(set) var connections: [NetworkConnection] = []
    @Published private(set) var bytesIn: Int64 = 0
    @Published private(set) var bytesOut: Int64 = 0

    func start() {
        guard timer == nil else {
            return
        }
        bytesIn = 0
        bytesOut = 0
        lastInterfaceTotals = nil

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .seconds(2))
        timer.setEventHandler { [weak self] in
            self?.poll()
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    // MARK: Private

    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "app.diskdevil.networkmonitor")
    private var lastInterfaceTotals: (Int64, Int64)?
    private let maxConnections = 80

    private func poll() {
        let newConnections = fetchConnections()
        let interfaceTotals = readInterfaceTotals()

        var updatedBytesIn = bytesIn
        var updatedBytesOut = bytesOut

        if let totals = interfaceTotals, let last = lastInterfaceTotals {
            let deltaIn = max(0, totals.0 - last.0)
            let deltaOut = max(0, totals.1 - last.1)
            updatedBytesIn += deltaIn
            updatedBytesOut += deltaOut
        }

        if let totals = interfaceTotals {
            lastInterfaceTotals = totals
        }

        DispatchQueue.main.async {
            self.connections = newConnections
            self.bytesIn = updatedBytesIn
            self.bytesOut = updatedBytesOut
        }
    }

    private func fetchConnections() -> [NetworkConnection] {
        guard let output = runCommand("/usr/sbin/lsof", arguments: ["-i", "-n", "-P", "-F", "pcfnPT"]) else {
            return []
        }

        struct Partial {
            var pid: String?
            var process: String?
            var proto: String?
            var name: String?
            var state: String?
        }

        var records: [NetworkConnection] = []
        var current = Partial()

        func commitCurrent() {
            guard let name = current.name else {
                return
            }

            let process = current.process ?? "Unknown"
            let proto = current.proto?.replacingOccurrences(of: "P", with: "").uppercased() ?? "TCP"
            let state = current.state?.replacingOccurrences(of: "TST=", with: "").uppercased() ?? "LISTEN"

            let parsed = parseName(name)
            let remoteAddress = parsed.address ?? "Unknown"
            let port = parsed.port ?? 0

            let connection = NetworkConnection(
                process: process,
                remoteAddress: remoteAddress,
                port: port,
                protocol: proto,
                status: mapState(state)
            )

            records.append(connection)
        }

        for line in output.split(separator: "\n") {
            guard let prefix = line.first else {
                continue
            }
            let value = String(line.dropFirst())

            switch prefix {
            case "p":
                commitCurrent()
                current = Partial()
                current.pid = value
            case "c":
                current.process = value
            case "P":
                current.proto = value
            case "n":
                current.name = value
            case "T":
                if line.hasPrefix("TST=") {
                    current.state = value
                }
            default:
                continue
            }
        }

        commitCurrent()

        if records.count > maxConnections {
            return Array(records.prefix(maxConnections))
        }

        return records
    }

    private func parseName(_ name: String) -> (address: String?, port: Int?) {
        let target: String =
            if let range = name.range(of: "->") {
                String(name[range.upperBound...])
            } else {
                name
            }

        // Strip any status suffix like " (LISTEN)"
        let cleaned: String =
            if let paren = target.range(of: " (") {
                String(target[..<paren.lowerBound])
            } else {
                target
            }

        guard let colonIndex = cleaned.lastIndex(of: ":") else {
            return (address: cleaned, port: nil)
        }

        let address = String(cleaned[..<colonIndex])
        let portString = String(cleaned[cleaned.index(after: colonIndex)...])
        let port = Int(portString) ?? nil

        return (address: address, port: port)
    }

    private func mapState(_ state: String) -> ConnectionStatus {
        switch state {
        case "ESTABLISHED":
            .established
        case "LISTEN":
            .listening
        case "TIME_WAIT":
            .timeWait
        default:
            .closed
        }
    }

    private func readInterfaceTotals() -> (Int64, Int64)? {
        guard let output = runCommand("/usr/sbin/netstat", arguments: ["-ib"]) else {
            return nil
        }

        var inbound: Int64 = 0
        var outbound: Int64 = 0

        for line in output.split(separator: "\n").dropFirst() {
            let parts = line.split(whereSeparator: { $0.isWhitespace })
            guard parts.count >= 10 else {
                continue
            }

            if let iBytes = Int64(parts[6]), let oBytes = Int64(parts[9]) {
                inbound += iBytes
                outbound += oBytes
            }
        }

        return (inbound, outbound)
    }

    private func runCommand(_ launchPath: String, arguments: [String]) -> String? {
        // Security: Validate command path is in allowed system directories
        let allowedPaths = ["/usr/sbin/", "/usr/bin/", "/usr/libexec/"]
        guard allowedPaths.contains(where: { launchPath.hasPrefix($0) }) else {
            return nil
        }
        
        // Security: Validate arguments don't contain shell metacharacters or path traversal
        for arg in arguments {
            // Check for shell metacharacters that could be dangerous
            let dangerousChars = CharacterSet(charactersIn: ";|&$`<>(){}[]\\'\"\n")
            if arg.rangeOfCharacter(from: dangerousChars) != nil {
                return nil
            }
            
            // Check for path traversal attempts
            if arg.contains("../") || arg.contains("/..") {
                return nil
            }
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return nil
        }

        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - TelemetryStatus

enum TelemetryStatus {
    case enabled
    case disabled
    case unknown

    // MARK: Internal

    var label: String {
        switch self {
        case .enabled: "Enabled"
        case .disabled: "Disabled"
        case .unknown: "Unknown"
        }
    }
}

// MARK: - TelemetrySetting

struct TelemetrySetting: Identifiable {
    let id = UUID()
    let name: String
    let status: TelemetryStatus
    let detail: String
}

// MARK: - TelemetryEvent

struct TelemetryEvent: Identifiable {
    let id = UUID()
    let title: String
    let path: String
    let date: Date
    let size: Int64?
}

// MARK: - TelemetryService

final class TelemetryService: ObservableObject {
    // MARK: Internal

    @Published private(set) var settings: [TelemetrySetting] = []
    @Published private(set) var recentEvents: [TelemetryEvent] = []

    func refresh() {
        Task.detached { [weak self] in
            guard let self else {
                return
            }
            let settings = collectSettings()
            let events = collectEvents()

            await MainActor.run {
                self.settings = settings
                self.recentEvents = events
            }
        }
    }

    // MARK: Private

    private func collectSettings() -> [TelemetrySetting] {
        var results: [TelemetrySetting] = []

        let probes: [(String, String, String)] = [
            ("Diagnostics & Usage", "com.apple.SubmitDiagInfo", "AutoSubmit"),
            ("App Analytics", "com.apple.SubmitDiagInfo", "ThirdPartyDataSubmit"),
            ("Crash Reports to Apple", "com.apple.CrashReporter", "AutoSubmit"),
            ("Safari Suggestions", "com.apple.Safari", "UniversalSearchEnabled"),
        ]

        for probe in probes {
            let status = readPreference(domain: probe.1, key: probe.2)
            results.append(TelemetrySetting(
                name: probe.0,
                status: status ?? .unknown,
                detail: status == nil ? "No local preference found" : probe.1
            ))
        }

        return results
    }

    private func collectEvents() -> [TelemetryEvent] {
        let fm = FileManager.default
        let locations = [
            ("Analytics", "~/Library/Logs/Analytics"),
            ("Diagnostic Reports", "~/Library/Logs/DiagnosticReports"),
            ("CrashReporter", "~/Library/Logs/CrashReporter"),
        ]

        var events: [TelemetryEvent] = []
        let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey]

        for (label, path) in locations {
            let expanded = NSString(string: path).expandingTildeInPath
            let url = URL(fileURLWithPath: expanded)
            guard let contents = try? fm.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: Array(resourceKeys),
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for file in contents {
                guard let values = try? file.resourceValues(forKeys: resourceKeys),
                      values.isDirectory != true
                else {
                    continue
                }
                let date = values.contentModificationDate ?? Date()
                let size = values.fileSize.map { Int64($0) }

                events.append(TelemetryEvent(
                    title: "\(label): \(file.lastPathComponent)",
                    path: file.path,
                    date: date,
                    size: size
                ))
            }
        }

        events.sort { $0.date > $1.date }
        return Array(events.prefix(25))
    }

    private func readPreference(domain: String, key: String) -> TelemetryStatus? {
        guard let value = CFPreferencesCopyAppValue(key as CFString, domain as CFString) else {
            return nil
        }

        if let boolValue = value as? Bool {
            return boolValue ? .enabled : .disabled
        }

        return .unknown
    }
}

// MARK: - SecurityScanner

struct SecurityScanner {
    // MARK: Internal

    func run(progress: @escaping (Double) -> Void) async -> [SecurityIssue] {
        var findings: [SecurityIssue] = []

        let checks: [(Double, () -> SecurityIssue?)] = [
            (0.25, firewallStatus),
            (0.5, gatekeeperStatus),
            (0.75, sipStatus),
            (1.0, fileVaultStatus),
        ]

        for (checkpoint, check) in checks {
            if let issue = check() {
                findings.append(issue)
            }
            await MainActor.run {
                progress(checkpoint)
            }
        }

        return findings
    }

    // MARK: Private

    private func firewallStatus() -> SecurityIssue? {
        guard let output = runCommand("/usr/libexec/ApplicationFirewall/socketfilterfw", ["--getglobalstate"]) else {
            return SecurityIssue(
                name: "Firewall Status Unknown",
                description: "Could not read firewall state.",
                severity: .medium,
                category: .network
            )
        }

        if output.lowercased().contains("enabled") || output.contains("= 1") {
            return nil
        }

        return SecurityIssue(
            name: "Firewall Disabled",
            description: "macOS firewall appears to be off.",
            severity: .high,
            category: .network
        )
    }

    private func gatekeeperStatus() -> SecurityIssue? {
        guard let output = runCommand("/usr/sbin/spctl", ["--status"]) else {
            return SecurityIssue(
                name: "Gatekeeper Status Unknown",
                description: "Could not read Gatekeeper state.",
                severity: .medium,
                category: .software
            )
        }

        if output.lowercased().contains("enabled") {
            return nil
        }

        return SecurityIssue(
            name: "Gatekeeper Disabled",
            description: "App assessment is disabled. Enable Gatekeeper for safer app installs.",
            severity: .high,
            category: .software
        )
    }

    private func sipStatus() -> SecurityIssue? {
        guard let output = runCommand("/usr/bin/csrutil", ["status"]) else {
            return SecurityIssue(
                name: "System Integrity Protection Unknown",
                description: "Could not determine SIP status.",
                severity: .medium,
                category: .software
            )
        }

        if output.lowercased().contains("enabled") {
            return nil
        }

        return SecurityIssue(
            name: "System Integrity Protection Disabled",
            description: "SIP is disabled. Re-enable SIP to protect system files.",
            severity: .critical,
            category: .software
        )
    }

    private func fileVaultStatus() -> SecurityIssue? {
        guard let output = runCommand("/usr/bin/fdesetup", ["status"]) else {
            return SecurityIssue(
                name: "FileVault Status Unknown",
                description: "Could not determine FileVault encryption status.",
                severity: .medium,
                category: .privacy
            )
        }

        if output.lowercased().contains("filevault is on") {
            return nil
        }

        return SecurityIssue(
            name: "FileVault Disabled",
            description: "Disk encryption is turned off. Enable FileVault to protect data at rest.",
            severity: .high,
            category: .privacy
        )
    }

    private func runCommand(_ launchPath: String, _ arguments: [String]) -> String? {
        // Security: Validate command path is in allowed system directories
        let allowedPaths = ["/usr/sbin/", "/usr/bin/", "/usr/libexec/"]
        guard allowedPaths.contains(where: { launchPath.hasPrefix($0) }) else {
            return nil
        }
        
        // Security: Validate arguments don't contain shell metacharacters or path traversal
        for arg in arguments {
            // Check for shell metacharacters that could be dangerous
            let dangerousChars = CharacterSet(charactersIn: ";|&$`<>(){}[]\\'\"\n")
            if arg.rangeOfCharacter(from: dangerousChars) != nil {
                return nil
            }
            
            // Check for path traversal attempts
            if arg.contains("../") || arg.contains("/..") {
                return nil
            }
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return nil
        }

        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}

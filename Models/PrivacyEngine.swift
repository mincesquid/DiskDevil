//
//  PrivacyEngine.swift
//  DiskDevil
//
//  Main privacy engine coordinating network filtering
//  Uses NetworkFilterProtocol for abstraction between simulated and real implementation

import Combine
import Foundation
import os.log

// MARK: - BlockedConnection

struct BlockedConnection: Identifiable {
    let id = UUID()
    let timestamp: Date
    let process: String
    let destination: String
    let reason: String
    let level: Int
}

// MARK: - PrivacyEngine

class PrivacyEngine: ObservableObject {
    // MARK: Lifecycle
    
    init() {
        // Use simulated filter by default
        // When NetworkExtension is ready, switch to:
        // if #available(macOS 11.0, *) {
        //     self.networkFilter = NetworkExtensionFilter()
        // } else {
        //     self.networkFilter = SimulatedNetworkFilter()
        // }
        self.networkFilter = SimulatedNetworkFilter()
        setupFilterObserver()
    }
    
    // MARK: Internal

    @Published var currentLevel = 1
    @Published var isActive = false
    @Published var blockedConnections: [BlockedConnection] = []
    @Published var totalBlockedToday = 0
    @Published var filterStatus: NetworkFilterStatus = .idle

    let levelDescriptions: [Int: String] = [
        1: "Block basic trackers and ad networks",
        2: "Block third-party analytics and common data collectors",
        3: "Block marketing services, fingerprinting, suspicious domains",
        4: "Block basic Apple telemetry (diagnostics, usage data)",
        5: "Block enhanced Apple services (analytics daemons, cloud telemetry)",
        6: "Block aggressive Apple services (Siri data, Spotlight suggestions)",
        7: "Military-grade firewall with deep packet inspection",
        8: "Network cloaking, MAC spoofing, VM isolation",
        9: "Offensive defense mode (honeypots, active response, deception)",
        10: "MAXIMUM PARANOIA - Zero-trust architecture, complete isolation",
    ]

    let levelNames: [Int: String] = [
        1: "Relaxed",
        2: "Aware",
        3: "Cautious",
        4: "Protected",
        5: "Hardened",
        6: "Isolated",
        7: "Military",
        8: "Cloaked",
        9: "Offensive",
        10: "MAXIMUM",
    ]

    func setLevel(_ level: Int) {
        currentLevel = max(AppConstants.minimumPrivacyLevel,
                           min(level, AppConstants.maximumPrivacyLevel))
        UserDefaults.standard.set(currentLevel, forKey: UserDefaultsKey.privacyLevel)

        if isActive {
            Task {
                await applyRules()
            }
        }
    }

    func toggleProtection() {
        isActive.toggle()

        if isActive {
            Task {
                await startProtection()
            }
        } else {
            Task {
                await stopProtection()
            }
        }
    }

    // MARK: Private

    private var timer: Timer?
    private let networkFilter: NetworkFilterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private func setupFilterObserver() {
        // Observe filter status changes
        networkFilter.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.filterStatus = status
                self?.handleFilterStatusChange(status)
            }
            .store(in: &cancellables)
    }
    
    private func handleFilterStatusChange(_ status: NetworkFilterStatus) {
        switch status {
        case .active:
            startMonitoring()
        case .idle, .stopping:
            stopMonitoring()
        case .error(let error):
            AppLogger.privacy.error("Filter error: \(error.localizedDescription)")
        case .starting:
            AppLogger.privacy.info("Filter starting...")
        }
    }

    private func startProtection() async {
        await applyRules()
    }

    private func stopProtection() async {
        let result = await networkFilter.stop()
        if case .failure(let error) = result {
            AppLogger.privacy.error("Failed to stop filter: \(error.localizedDescription)")
        }
    }

    private func applyRules() async {
        // Generate rules based on current level
        let rules = PrivacyLevelRules.rules(for: currentLevel)
        
        AppLogger.privacy.info("Applying privacy level \(self.currentLevel) rules (\(rules.count) rules)...")

        let result = await networkFilter.start(with: rules)
        
        switch result {
        case .success:
            AppLogger.privacy.info("Successfully applied \(rules.count) filter rules")
        case .failure(let error):
            AppLogger.privacy.error("Failed to apply rules: \(error.localizedDescription)")
        }
    }

    private func startMonitoring() {
        // Start monitoring network connections
        // Update UI with statistics from filter
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.updateStatistics()
            }
        }
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateStatistics() async {
        let stats = await networkFilter.getStatistics()
        
        DispatchQueue.main.async {
            self.totalBlockedToday = stats.totalBlocked
            
            // Update blocked connections list for UI
            // In real implementation, get actual blocked connections from extension
            self.updateBlockedConnectionsList(from: stats)
        }
    }
    
    private func updateBlockedConnectionsList(from stats: NetworkFilterStatistics) {
        // Convert statistics to BlockedConnection entries for UI display
        for (domain, count) in stats.topBlockedDomains.prefix(5) {
            let connection = BlockedConnection(
                timestamp: Date(),
                process: "Various",
                destination: domain,
                reason: "Matched level \(currentLevel) blocking rule",
                level: currentLevel
            )
            
            blockedConnections.insert(connection, at: 0)
        }
        
        // Keep list manageable
        if blockedConnections.count > 100 {
            blockedConnections = Array(blockedConnections.prefix(100))
        }
    }

    private func checkConnections() {
        // Legacy method - now handled by updateStatistics()
        // Kept for compatibility but delegates to new architecture
        Task {
            await updateStatistics()
        }
    }

    /// Rule application methods - deprecated, now using PrivacyLevelRules
    @available(*, deprecated, message: "Use PrivacyLevelRules.rules(for:) instead")
    private func applyBasicRules() {
        // Block ad networks and basic trackers
    }

    @available(*, deprecated, message: "Use PrivacyLevelRules.rules(for:) instead")
    private func applyAppleBlockingRules() {
        // Block Apple telemetry services
    }

    @available(*, deprecated, message: "Use PrivacyLevelRules.rules(for:) instead")
    private func applyMilitaryGradeRules() {
        // Advanced firewall with packet inspection
    }

    @available(*, deprecated, message: "Use PrivacyLevelRules.rules(for:) instead")
    private func applyMaximumParanoiaRules() {
        // Zero-trust, complete isolation
    }
}

// MARK: - NetworkExtension Support

extension PrivacyEngine {
    /// Check if real NetworkExtension is available and installed
    var isNetworkExtensionAvailable: Bool {
        #if canImport(NetworkExtension)
        if #available(macOS 11.0, *) {
            // Check if extension is installed
            // TODO: Implement actual check when extension is ready
            return false
        }
        #endif
        return false
    }
    
    /// Switch to using real NetworkExtension
    /// Call this after extension is installed and approved
    func enableNetworkExtension() async -> Result<Void, NetworkFilterError> {
        #if canImport(NetworkExtension)
        if #available(macOS 11.0, *) {
            // In future implementation, switch to NetworkExtensionFilter
            // For now, return not available
            return .failure(.extensionNotInstalled)
        }
        #endif
        return .failure(.extensionNotInstalled)
    }
}

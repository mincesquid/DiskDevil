//
//  NetworkFilterProtocol.swift
//  DiskDevil
//
//  Protocol definitions for NetworkExtension integration
//  This provides a clean interface that can be implemented by both
//  the simulated filter (for development) and real NetworkExtension

import Foundation
import Combine

// MARK: - NetworkFilterProtocol

/// Protocol defining the interface for network filtering
/// Can be implemented by:
/// - SimulatedNetworkFilter (current implementation, for development/testing)
/// - NetworkExtensionFilter (real implementation using NEFilterDataProvider)
protocol NetworkFilterProtocol {
    /// Current filter status
    var isEnabled: Bool { get }
    
    /// Observable status changes
    var statusPublisher: AnyPublisher<NetworkFilterStatus, Never> { get }
    
    /// Start the network filter with specified rules
    /// - Parameter rules: Array of filtering rules to apply
    /// - Returns: Result indicating success or failure
    func start(with rules: [NetworkFilterRule]) async -> Result<Void, NetworkFilterError>
    
    /// Stop the network filter
    func stop() async -> Result<Void, NetworkFilterError>
    
    /// Update rules without stopping the filter
    /// - Parameter rules: New set of rules to apply
    func updateRules(_ rules: [NetworkFilterRule]) async -> Result<Void, NetworkFilterError>
    
    /// Get statistics about blocked connections
    func getStatistics() async -> NetworkFilterStatistics
}

// MARK: - NetworkFilterStatus

enum NetworkFilterStatus {
    case idle
    case starting
    case active
    case stopping
    case error(NetworkFilterError)
}

// MARK: - NetworkFilterError

enum NetworkFilterError: Error, LocalizedError {
    case extensionNotInstalled
    case extensionLoadFailed(Error)
    case permissionDenied
    case invalidConfiguration
    case systemError(Error)
    
    var errorDescription: String? {
        switch self {
        case .extensionNotInstalled:
            return "Network Extension is not installed. Please install it from Settings."
        case .extensionLoadFailed(let error):
            return "Failed to load Network Extension: \(error.localizedDescription)"
        case .permissionDenied:
            return "Network filtering permission denied. Please grant permission in System Settings."
        case .invalidConfiguration:
            return "Invalid filter configuration."
        case .systemError(let error):
            return "System error: \(error.localizedDescription)"
        }
    }
}

// MARK: - NetworkFilterRule

/// Represents a single network filtering rule
struct NetworkFilterRule: Codable, Identifiable {
    let id: UUID
    let priority: Int
    let action: FilterAction
    let condition: FilterCondition
    let description: String
    
    init(priority: Int, action: FilterAction, condition: FilterCondition, description: String) {
        self.id = UUID()
        self.priority = priority
        self.action = action
        self.condition = condition
        self.description = description
    }
}

// MARK: - FilterAction

enum FilterAction: String, Codable {
    case allow
    case block
    case redirect
}

// MARK: - FilterCondition

/// Conditions for applying a filter rule
struct FilterCondition: Codable {
    let type: ConditionType
    let pattern: String
    
    enum ConditionType: String, Codable {
        case domain          // Match domain name
        case domainSuffix    // Match domain suffix (e.g., ".tracking.com")
        case ipAddress       // Match IP address
        case ipRange         // Match IP range
        case port            // Match port number
        case processName     // Match process name
        case category        // Match category (ads, tracking, etc.)
    }
}

// MARK: - NetworkFilterStatistics

struct NetworkFilterStatistics {
    let totalBlocked: Int
    let blockedByCategory: [String: Int]
    let topBlockedDomains: [(String, Int)]
    let activeRules: Int
    let startTime: Date?
}

// MARK: - PrivacyLevel Rule Mapping

/// Maps privacy levels to specific filtering rules
struct PrivacyLevelRules {
    /// Generate rules for a specific privacy level
    /// - Parameter level: Privacy level (1-10)
    /// - Returns: Array of filter rules
    static func rules(for level: Int) -> [NetworkFilterRule] {
        var rules: [NetworkFilterRule] = []
        
        // Level 1-3: Basic tracking and ads
        if level >= 1 {
            rules.append(contentsOf: basicTrackingRules())
        }
        
        // Level 4-6: Apple telemetry
        if level >= 4 {
            rules.append(contentsOf: appleTelemetryRules())
        }
        
        // Level 7-9: Advanced filtering
        if level >= 7 {
            rules.append(contentsOf: advancedFilteringRules())
        }
        
        // Level 10: Maximum paranoia
        if level >= 10 {
            rules.append(contentsOf: maximumParanoiaRules())
        }
        
        return rules
    }
    
    // MARK: - Rule Sets
    
    private static func basicTrackingRules() -> [NetworkFilterRule] {
        [
            NetworkFilterRule(
                priority: 100,
                action: .block,
                condition: FilterCondition(type: .domainSuffix, pattern: ".doubleclick.net"),
                description: "Block Google DoubleClick advertising"
            ),
            NetworkFilterRule(
                priority: 100,
                action: .block,
                condition: FilterCondition(type: .domainSuffix, pattern: ".facebook.com/tr"),
                description: "Block Facebook tracking pixel"
            ),
            NetworkFilterRule(
                priority: 100,
                action: .block,
                condition: FilterCondition(type: .domainSuffix, pattern: ".google-analytics.com"),
                description: "Block Google Analytics"
            ),
            NetworkFilterRule(
                priority: 100,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "advertising"),
                description: "Block advertising networks"
            ),
        ]
    }
    
    private static func appleTelemetryRules() -> [NetworkFilterRule] {
        [
            NetworkFilterRule(
                priority: 200,
                action: .block,
                condition: FilterCondition(type: .domain, pattern: "metrics.apple.com"),
                description: "Block Apple metrics collection"
            ),
            NetworkFilterRule(
                priority: 200,
                action: .block,
                condition: FilterCondition(type: .domain, pattern: "metrics.icloud.com"),
                description: "Block iCloud metrics"
            ),
            NetworkFilterRule(
                priority: 200,
                action: .block,
                condition: FilterCondition(type: .domain, pattern: "api-adservices.apple.com"),
                description: "Block Apple ad services"
            ),
        ]
    }
    
    private static func advancedFilteringRules() -> [NetworkFilterRule] {
        [
            NetworkFilterRule(
                priority: 300,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "fingerprinting"),
                description: "Block browser fingerprinting"
            ),
            NetworkFilterRule(
                priority: 300,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "cryptomining"),
                description: "Block cryptocurrency mining"
            ),
            NetworkFilterRule(
                priority: 300,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "malware"),
                description: "Block known malware domains"
            ),
        ]
    }
    
    private static func maximumParanoiaRules() -> [NetworkFilterRule] {
        [
            NetworkFilterRule(
                priority: 400,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "social-media-tracking"),
                description: "Block all social media tracking"
            ),
            NetworkFilterRule(
                priority: 400,
                action: .block,
                condition: FilterCondition(type: .category, pattern: "cloud-telemetry"),
                description: "Block cloud service telemetry"
            ),
        ]
    }
}

//
//  SubscriptionManager.swift
//  DiskDevil
//

import Combine
import Foundation

enum SubscriptionTier: String, Codable {
    case free = "Free"
    case premium = "Premium"
    case elite = "Elite"

    var maxPrivacyLevel: Int {
        switch self {
        case .free: return 3
        case .premium: return 9
        case .elite: return 10
        }
    }

    var displayName: String {
        rawValue
    }

    var color: String {
        switch self {
        case .free: return "gray"
        case .premium: return "orange"
        case .elite: return "purple"
        }
    }
}

class SubscriptionManager: ObservableObject {
    @Published var tier: SubscriptionTier = .free
    @Published var expirationDate: Date?
    @Published var isActive: Bool = true

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSubscriptionStatus()
    }

    func loadSubscriptionStatus() {
        // Load from UserDefaults or keychain
        if let savedTier = UserDefaults.standard.string(forKey: "subscriptionTier"),
           let tier = SubscriptionTier(rawValue: savedTier)
        {
            self.tier = tier
        }

        if let expiration = UserDefaults.standard.object(forKey: "subscriptionExpiration") as? Date {
            expirationDate = expiration
            isActive = expiration > Date()
        }
    }

    func updateSubscription(tier: SubscriptionTier, expirationDate: Date?) {
        self.tier = tier
        self.expirationDate = expirationDate
        isActive = expirationDate == nil || expirationDate! > Date()

        UserDefaults.standard.set(tier.rawValue, forKey: "subscriptionTier")
        if let expiration = expirationDate {
            UserDefaults.standard.set(expiration, forKey: "subscriptionExpiration")
        }
    }

    func hasAccess(to level: Int) -> Bool {
        return level <= tier.maxPrivacyLevel
    }

    func canAccessFeature(_ feature: String) -> Bool {
        // Add feature-specific logic
        switch feature {
        case "network_monitor", "recovery_tools", "vm_isolation", "offensive_defense":
            return tier != .free
        case "threat_hunting", "api_access", "incident_response":
            return tier == .elite
        default:
            return true
        }
    }

    // Mock subscription purchase - replace with real implementation
    func purchaseSubscription(tier: SubscriptionTier, isAnnual: Bool = false) async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let duration: TimeInterval = isAnnual ? 365 * 24 * 60 * 60 : 30 * 24 * 60 * 60
        let expiration = Date().addingTimeInterval(duration)

        await MainActor.run {
            updateSubscription(tier: tier, expirationDate: expiration)
        }
    }

    func restoreSubscription() async throws {
        // Implement restore logic
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}

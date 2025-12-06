//
//  SubscriptionManager.swift
//  DiskDevil
//

import Combine
import Foundation
import StoreKit

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
    private let storeKit: StoreKitManager

    init(storeKit: StoreKitManager) {
        self.storeKit = storeKit
        loadSubscriptionStatus()

        // Observe StoreKit subscription status
        Task {
            await storeKit.updateSubscriptionStatus()
            await syncWithStoreKit()
        }
    }

    convenience init() {
        self.init(storeKit: StoreKitManager())
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

    // MARK: - StoreKit Integration

    func loadProducts() async {
        await storeKit.loadProducts()
    }

    func purchaseSubscription(tier: SubscriptionTier, isAnnual: Bool = false) async throws {
        guard let product = storeKit.product(for: tier, isYearly: isAnnual) else {
            throw StoreError.productNotFound
        }

        let transaction = try await storeKit.purchase(product)
        if transaction != nil {
            await syncWithStoreKit()
        }
    }

    func restoreSubscription() async throws {
        await storeKit.restorePurchases()
        await syncWithStoreKit()
    }

    private func syncWithStoreKit() async {
        await storeKit.updateSubscriptionStatus()

        await MainActor.run {
            if let status = storeKit.subscriptionStatus {
                updateSubscription(tier: status.tier, expirationDate: status.expirationDate)
            }
        }
    }

    // MARK: - Product Access

    func getStoreKitManager() -> StoreKitManager {
        storeKit
    }
}

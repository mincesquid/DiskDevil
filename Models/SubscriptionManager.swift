//
//  SubscriptionManager.swift
//  DiskDevil
//

import Combine
import Foundation
import StoreKit

// MARK: - SubscriptionTier

enum SubscriptionTier: String, Codable {
    case free = "Free"
    case premium = "Premium"
    case elite = "Elite"

    // MARK: Internal

    var maxPrivacyLevel: Int {
        switch self {
        case .free: 3
        case .premium: 9
        case .elite: 10
        }
    }

    var displayName: String {
        rawValue
    }

    var color: String {
        switch self {
        case .free: "gray"
        case .premium: "orange"
        case .elite: "purple"
        }
    }
}

// MARK: - SubscriptionManager

class SubscriptionManager: ObservableObject {
    // MARK: Lifecycle

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

    // MARK: Internal

    @Published var tier: SubscriptionTier = .free
    @Published var expirationDate: Date?
    @Published var isActive = true

    func loadSubscriptionStatus() {
        // Load from UserDefaults or keychain
        if let savedTier = UserDefaults.standard.string(forKey: UserDefaultsKey.subscriptionTier),
           let tier = SubscriptionTier(rawValue: savedTier)
        {
            self.tier = tier
        }

        if let expiration = UserDefaults.standard.object(forKey: UserDefaultsKey.subscriptionExpiration) as? Date {
            expirationDate = expiration
            isActive = expiration > Date()
        }
    }

    func updateSubscription(tier: SubscriptionTier, expirationDate: Date?) {
        self.tier = tier
        self.expirationDate = expirationDate
        isActive = expirationDate.map { $0 > Date() } ?? true

        UserDefaults.standard.set(tier.rawValue, forKey: UserDefaultsKey.subscriptionTier)
        if let expiration = expirationDate {
            UserDefaults.standard.set(expiration, forKey: UserDefaultsKey.subscriptionExpiration)
        }
    }

    func hasAccess(to level: Int) -> Bool {
        level <= tier.maxPrivacyLevel
    }

    func canAccessFeature(_ feature: String) -> Bool {
        // Add feature-specific logic
        switch feature {
        case "network_monitor",
             "recovery_tools",
             "vm_isolation",
             "offensive_defense":
            tier != .free
        case "threat_hunting",
             "api_access",
             "incident_response":
            tier == .elite
        default:
            true
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

    // MARK: - Product Access

    func getStoreKitManager() -> StoreKitManager {
        storeKit
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private let storeKit: StoreKitManager

    private func syncWithStoreKit() async {
        await storeKit.updateSubscriptionStatus()

        await MainActor.run {
            if let status = storeKit.subscriptionStatus {
                updateSubscription(tier: status.tier, expirationDate: status.expirationDate)
            }
        }
    }
}

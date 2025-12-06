//
//  StoreKitManager.swift
//  DiskDevil
//
//  StoreKit 2 subscription management

import Foundation
import StoreKit

enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
}

class StoreKitManager: ObservableObject {
    // Product IDs - configure these in App Store Connect
    private let premiumMonthlyID = "com.diskdevil.premium.monthly"
    private let premiumYearlyID = "com.diskdevil.premium.yearly"
    private let eliteMonthlyID = "com.diskdevil.elite.monthly"
    private let eliteYearlyID = "com.diskdevil.elite.yearly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: [Product] = []
    @Published private(set) var subscriptionStatus: SubscriptionStatus?

    private var updates: Task<Void, Never>?

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        do {
            let productIDs = [
                premiumMonthlyID,
                premiumYearlyID,
                eliteMonthlyID,
                eliteYearlyID,
            ]

            products = try await Product.products(for: productIDs)

            // Sort by price for display
            products.sort { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
            products = []
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            // Purchase is pending (e.g., Ask to Buy)
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var currentTier: SubscriptionTier = .free
        var expirationDate: Date?
        var activeSubs: [Product] = []

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }

            // Skip revoked transactions
            if transaction.revocationDate != nil {
                continue
            }

            // Get the product
            if let product = products.first(where: { $0.id == transaction.productID }) {
                activeSubs.append(product)

                // Determine tier based on product ID
                if transaction.productID.contains("elite") {
                    currentTier = .elite
                } else if transaction.productID.contains("premium"), currentTier != .elite {
                    currentTier = .premium
                }

                // Get expiration date
                if let expiration = transaction.expirationDate {
                    if expirationDate == nil || expiration > expirationDate! {
                        expirationDate = expiration
                    }
                }
            }
        }

        purchasedProducts = activeSubs
        subscriptionStatus = SubscriptionStatus(
            tier: currentTier,
            expirationDate: expirationDate,
            isActive: !activeSubs.isEmpty
        )
    }

    // MARK: - Transaction Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case let .verified(safe):
            return safe
        }
    }

    // MARK: - Transaction Updates

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                await self.updateSubscriptionStatus()
            }
        }
    }

    // MARK: - Helper Methods

    func product(for tier: SubscriptionTier, isYearly: Bool = false) -> Product? {
        let searchID: String
        switch tier {
        case .free:
            return nil
        case .premium:
            searchID = isYearly ? premiumYearlyID : premiumMonthlyID
        case .elite:
            searchID = isYearly ? eliteYearlyID : eliteMonthlyID
        }

        return products.first { $0.id == searchID }
    }

    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }
}

struct SubscriptionStatus {
    let tier: SubscriptionTier
    let expirationDate: Date?
    let isActive: Bool
}

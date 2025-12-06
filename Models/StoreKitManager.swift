//
//  StoreKitManager.swift
//  DiskDevil
//
//  StoreKit 2 subscription management

import Foundation
import os.log
import StoreKit

// MARK: - StoreError

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    case networkError
    case restoreFailed(Error)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "Could not verify purchase. Please try again."
        case .productNotFound:
            "Product not available. Please check your internet connection."
        case .purchaseFailed:
            "Purchase could not be completed. Please try again later."
        case .networkError:
            "Network error. Please check your internet connection."
        case let .restoreFailed(underlying):
            "Could not restore purchases: \(underlying.localizedDescription)"
        }
    }
}

// MARK: - StoreKitManager

class StoreKitManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: Internal

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: [Product] = []
    @Published private(set) var subscriptionStatus: SubscriptionStatus?
    @Published var lastError: StoreError?
    @Published private(set) var isLoading = false

    // MARK: - Product Loading

    @MainActor
    func loadProducts() async {
        isLoading = true
        lastError = nil

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

            AppLogger.storeKit.info("Loaded \(self.products.count) products successfully")
        } catch {
            AppLogger.storeKit.error("Failed to load products: \(error.localizedDescription)")
            lastError = .networkError
            products = []
        }

        isLoading = false
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

    @MainActor
    func restorePurchases() async {
        isLoading = true
        lastError = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            AppLogger.storeKit.info("Purchases restored successfully")
        } catch {
            AppLogger.storeKit.error("Failed to restore purchases: \(error.localizedDescription)")
            lastError = .restoreFailed(error)
        }

        isLoading = false
    }

    /// Clears the last error - call this when dismissing error alerts
    func clearError() {
        lastError = nil
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var currentTier: SubscriptionTier = .free
        var expirationDate: Date?
        var activeSubs: [Product] = []

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else {
                continue
            }

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

                // Get expiration date - use the latest one
                if let expiration = transaction.expirationDate {
                    if let currentExpiration = expirationDate {
                        expirationDate = max(expiration, currentExpiration)
                    } else {
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

    // MARK: Private

    // Product IDs from centralized constants
    private let premiumMonthlyID = AppConstants.ProductID.premiumMonthly
    private let premiumYearlyID = AppConstants.ProductID.premiumYearly
    private let eliteMonthlyID = AppConstants.ProductID.eliteMonthly
    private let eliteYearlyID = AppConstants.ProductID.eliteYearly

    private var updates: Task<Void, Never>?

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
            for await _ in Transaction.updates {
                await self.updateSubscriptionStatus()
            }
        }
    }
}

// MARK: - SubscriptionStatus

struct SubscriptionStatus {
    let tier: SubscriptionTier
    let expirationDate: Date?
    let isActive: Bool
}

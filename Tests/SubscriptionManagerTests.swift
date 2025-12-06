//
//  SubscriptionManagerTests.swift
//  DiskDevilTests
//
//  Unit tests for SubscriptionManager functionality

@testable import DiskDevil
import XCTest

// MARK: - SubscriptionManagerTests

final class SubscriptionManagerTests: XCTestCase {
    var subscriptionManager: SubscriptionManager!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "subscriptionTier")
        UserDefaults.standard.removeObject(forKey: "subscriptionExpiration")

        subscriptionManager = SubscriptionManager()
    }

    override func tearDown() {
        subscriptionManager = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialTierIsFree() {
        XCTAssertEqual(subscriptionManager.tier, .free,
                       "Initial subscription tier should be free")
    }

    func testInitiallyIsActive() {
        XCTAssertTrue(subscriptionManager.isActive,
                      "Subscription should be active initially (free tier is always active)")
    }

    // MARK: - Tier Update Tests

    func testUpdateSubscriptionToPremium() {
        let futureDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
        subscriptionManager.updateSubscription(tier: .premium, expirationDate: futureDate)

        XCTAssertEqual(subscriptionManager.tier, .premium,
                       "Tier should be updated to premium")
        XCTAssertTrue(subscriptionManager.isActive,
                      "Subscription should be active with future expiration")
    }

    func testUpdateSubscriptionToElite() {
        let futureDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year
        subscriptionManager.updateSubscription(tier: .elite, expirationDate: futureDate)

        XCTAssertEqual(subscriptionManager.tier, .elite,
                       "Tier should be updated to elite")
    }

    func testExpiredSubscriptionIsNotActive() {
        let pastDate = Date().addingTimeInterval(-24 * 60 * 60) // Yesterday
        subscriptionManager.updateSubscription(tier: .premium, expirationDate: pastDate)

        // After checking expiration, should revert to free
        subscriptionManager.checkExpiration()

        XCTAssertEqual(subscriptionManager.tier, .free,
                       "Expired subscription should revert to free tier")
    }

    // MARK: - Days Remaining Tests

    func testDaysRemainingCalculation() {
        let futureDate = Date().addingTimeInterval(10 * 24 * 60 * 60) // 10 days
        subscriptionManager.updateSubscription(tier: .premium, expirationDate: futureDate)

        let daysRemaining = subscriptionManager.daysRemaining

        // Should be approximately 10 (accounting for time of day)
        XCTAssertTrue(daysRemaining >= 9 && daysRemaining <= 10,
                      "Days remaining should be approximately 10")
    }

    func testDaysRemainingIsZeroForExpiredSubscription() {
        let pastDate = Date().addingTimeInterval(-24 * 60 * 60) // Yesterday
        subscriptionManager.updateSubscription(tier: .premium, expirationDate: pastDate)

        XCTAssertEqual(subscriptionManager.daysRemaining, 0,
                       "Days remaining should be 0 for expired subscription")
    }

    // MARK: - Feature Access Tests

    func testFreeTierCannotAccessPremiumFeatures() {
        XCTAssertFalse(subscriptionManager.tier == .premium || subscriptionManager.tier == .elite,
                       "Free tier should not have premium/elite access")
    }

    func testPremiumTierHasAccess() {
        let futureDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        subscriptionManager.updateSubscription(tier: .premium, expirationDate: futureDate)

        XCTAssertTrue(subscriptionManager.tier == .premium,
                      "Premium tier should be accessible")
    }

    // MARK: - Persistence Tests

    func testSubscriptionPersistsAcrossInstances() {
        let futureDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        subscriptionManager.updateSubscription(tier: .elite, expirationDate: futureDate)

        // Create new instance
        let newManager = SubscriptionManager()

        XCTAssertEqual(newManager.tier, .elite,
                       "Subscription tier should persist across instances")
    }
}

// MARK: - SubscriptionTierTests

final class SubscriptionTierTests: XCTestCase {
    func testTierRawValues() {
        XCTAssertEqual(SubscriptionTier.free.rawValue, "Free")
        XCTAssertEqual(SubscriptionTier.premium.rawValue, "Premium")
        XCTAssertEqual(SubscriptionTier.elite.rawValue, "Elite")
    }

    func testTierMaxPrivacyLevel() {
        XCTAssertEqual(SubscriptionTier.free.maxPrivacyLevel, 3)
        XCTAssertEqual(SubscriptionTier.premium.maxPrivacyLevel, 9)
        XCTAssertEqual(SubscriptionTier.elite.maxPrivacyLevel, 10)
    }
}

//
//  Constants.swift
//  DiskDevil
//
//  Centralized constants for type-safe access

import Foundation

// MARK: - UserDefaultsKey

/// Type-safe UserDefaults keys to prevent typos and enable autocomplete
enum UserDefaultsKey {
    // MARK: Usage Limits

    enum Usage {
        static let hiddenFilesCount = "usage.hiddenFiles.count"
        static let hiddenFilesResetDate = "usage.hiddenFiles.resetDate"
        static let networkMonitorCount = "usage.networkMonitor.count"
        static let networkMonitorResetDate = "usage.networkMonitor.resetDate"
        static let securityScanCount = "usage.securityScan.count"
        static let securityScanResetDate = "usage.securityScan.resetDate"
    }

    // MARK: Subscription

    static let subscriptionTier = "subscription.tier"
    static let subscriptionExpiration = "subscription.expiration"

    static let privacyLevel = "privacy.level"

    // MARK: Settings

    static let hasCompletedOnboarding = "settings.hasCompletedOnboarding"
    static let lastAuditDate = "settings.lastAuditDate"
    static let preferredTheme = "settings.preferredTheme"
}

// MARK: - AppConstants

enum AppConstants {
    // MARK: StoreKit Product IDs

    enum ProductID {
        static let premiumMonthly = "com.diskdevil.premium.monthly"
        static let premiumYearly = "com.diskdevil.premium.yearly"
        static let eliteMonthly = "com.diskdevil.elite.monthly"
        static let eliteYearly = "com.diskdevil.elite.yearly"

        static var all: [String] {
            [premiumMonthly, premiumYearly, eliteMonthly, eliteYearly]
        }
    }

    // MARK: URLs

    enum URLs {
        static let privacyPolicy = URL(string: "https://diskdevil.app/privacy")!
        static let termsOfService = URL(string: "https://diskdevil.app/terms")!
        static let support = URL(string: "https://diskdevil.app/support")!
    }

    // MARK: Usage Limits

    static let freeHiddenFileRevealsPerDay = 3
    static let freeNetworkMonitorUsesPerDay = 3
    static let freeSecurityScansPerDay = 2

    // MARK: Privacy Levels

    static let minimumPrivacyLevel = 1
    static let maximumPrivacyLevel = 10
    static let freeMaxPrivacyLevel = 3
    static let premiumMaxPrivacyLevel = 9
    static let eliteMaxPrivacyLevel = 10
}

// MARK: - Notification Names

extension Notification.Name {
    static let subscriptionDidChange = Notification.Name("subscriptionDidChange")
    static let privacyLevelDidChange = Notification.Name("privacyLevelDidChange")
    static let usageLimitReached = Notification.Name("usageLimitReached")
}

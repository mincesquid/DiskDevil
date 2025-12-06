//
//  UsageLimits.swift
//  DiskDevil
//
//  Track usage limits for free tier users

import Foundation
import SwiftUI

class UsageLimits: ObservableObject {
    // MARK: Lifecycle

    init() {
        resetIfNeeded()
        loadUsage()
    }

    // MARK: Internal

    @Published var hiddenFilesRevealsRemaining = 3
    @Published var networkMonitorUsesRemaining = 3
    @Published var securityScansRemaining = 2

    // MARK: - Usage Tracking

    func canRevealHiddenFile() -> Bool {
        hiddenFilesRevealsRemaining > 0
    }

    func recordHiddenFileReveal() {
        let current = defaults.integer(forKey: hiddenFilesRevealCountKey)
        defaults.set(current + 1, forKey: hiddenFilesRevealCountKey)
        loadUsage()
    }

    func canUseNetworkMonitor() -> Bool {
        networkMonitorUsesRemaining > 0
    }

    func recordNetworkMonitorUse() {
        let current = defaults.integer(forKey: networkMonitorCountKey)
        defaults.set(current + 1, forKey: networkMonitorCountKey)
        loadUsage()
    }

    func canRunSecurityScan() -> Bool {
        securityScansRemaining > 0
    }

    func recordSecurityScan() {
        let current = defaults.integer(forKey: securityScanCountKey)
        defaults.set(current + 1, forKey: securityScanCountKey)
        loadUsage()
    }

    // MARK: - Time Until Reset

    func timeUntilReset() -> String {
        let calendar = Calendar.current
        let now = Date()

        // Get midnight tonight
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return "24 hours"
        }

        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)

        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes) minutes"
            }
        }

        return "Soon"
    }

    // MARK: - Reset for Premium/Elite Users

    func unlockAll() {
        // Called when user upgrades - reset limits to unlimited
        hiddenFilesRevealsRemaining = .max
        networkMonitorUsesRemaining = .max
        securityScansRemaining = .max
    }

    // MARK: Private

    // Storage keys
    private let hiddenFilesRevealCountKey = "usage.hiddenFiles.count"
    private let hiddenFilesResetDateKey = "usage.hiddenFiles.resetDate"
    private let networkMonitorCountKey = "usage.networkMonitor.count"
    private let networkMonitorResetDateKey = "usage.networkMonitor.resetDate"
    private let securityScanCountKey = "usage.securityScan.count"
    private let securityScanResetDateKey = "usage.securityScan.resetDate"

    private let defaults = UserDefaults.standard

    // MARK: - Daily Reset Logic

    private func resetIfNeeded() {
        let calendar = Calendar.current

        // Reset hidden files if needed
        if let lastReset = defaults.object(forKey: hiddenFilesResetDateKey) as? Date {
            if !calendar.isDateInToday(lastReset) {
                defaults.set(0, forKey: hiddenFilesRevealCountKey)
                defaults.set(Date(), forKey: hiddenFilesResetDateKey)
            }
        } else {
            defaults.set(Date(), forKey: hiddenFilesResetDateKey)
        }

        // Reset network monitor if needed
        if let lastReset = defaults.object(forKey: networkMonitorResetDateKey) as? Date {
            if !calendar.isDateInToday(lastReset) {
                defaults.set(0, forKey: networkMonitorCountKey)
                defaults.set(Date(), forKey: networkMonitorResetDateKey)
            }
        } else {
            defaults.set(Date(), forKey: networkMonitorResetDateKey)
        }

        // Reset security scans if needed
        if let lastReset = defaults.object(forKey: securityScanResetDateKey) as? Date {
            if !calendar.isDateInToday(lastReset) {
                defaults.set(0, forKey: securityScanCountKey)
                defaults.set(Date(), forKey: securityScanResetDateKey)
            }
        } else {
            defaults.set(Date(), forKey: securityScanResetDateKey)
        }
    }

    private func loadUsage() {
        let hiddenFilesUsed = defaults.integer(forKey: hiddenFilesRevealCountKey)
        hiddenFilesRevealsRemaining = max(0, 3 - hiddenFilesUsed)

        let networkUsed = defaults.integer(forKey: networkMonitorCountKey)
        networkMonitorUsesRemaining = max(0, 3 - networkUsed)

        let scansUsed = defaults.integer(forKey: securityScanCountKey)
        securityScansRemaining = max(0, 2 - scansUsed)
    }
}

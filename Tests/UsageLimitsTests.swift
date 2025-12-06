//
//  UsageLimitsTests.swift
//  DiskDevilTests
//
//  Unit tests for UsageLimits functionality

@testable import DiskDevil
import XCTest

final class UsageLimitsTests: XCTestCase {
    var usageLimits: UsageLimits!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "hiddenFilesUsedToday")
        UserDefaults.standard.removeObject(forKey: "networkMonitorUsesToday")
        UserDefaults.standard.removeObject(forKey: "securityScansToday")
        UserDefaults.standard.removeObject(forKey: "lastUsageResetDate")

        usageLimits = UsageLimits()
    }

    override func tearDown() {
        usageLimits = nil
        super.tearDown()
    }

    // MARK: - Hidden Files Reveal Tests

    func testInitialHiddenFilesRevealsRemaining() {
        XCTAssertEqual(usageLimits.hiddenFilesRevealsRemaining, 3,
                       "Should have 3 hidden file reveals available initially")
    }

    func testCanRevealHiddenFileWhenUnderLimit() {
        XCTAssertTrue(usageLimits.canRevealHiddenFile(),
                      "Should be able to reveal hidden file when under limit")
    }

    func testRecordHiddenFileRevealDecrementsCount() {
        let initialCount = usageLimits.hiddenFilesRevealsRemaining
        usageLimits.recordHiddenFileReveal()

        XCTAssertEqual(usageLimits.hiddenFilesRevealsRemaining, initialCount - 1,
                       "Hidden file reveals remaining should decrement by 1")
    }

    func testCannotRevealHiddenFileWhenAtLimit() {
        // Use all 3 reveals
        usageLimits.recordHiddenFileReveal()
        usageLimits.recordHiddenFileReveal()
        usageLimits.recordHiddenFileReveal()

        XCTAssertFalse(usageLimits.canRevealHiddenFile(),
                       "Should not be able to reveal hidden file when at limit")
        XCTAssertEqual(usageLimits.hiddenFilesRevealsRemaining, 0,
                       "Should have 0 reveals remaining")
    }

    // MARK: - Network Monitor Tests

    func testInitialNetworkMonitorUsesRemaining() {
        XCTAssertEqual(usageLimits.networkMonitorUsesRemaining, 3,
                       "Should have 3 network monitor uses available initially")
    }

    func testCanUseNetworkMonitorWhenUnderLimit() {
        XCTAssertTrue(usageLimits.canUseNetworkMonitor(),
                      "Should be able to use network monitor when under limit")
    }

    func testRecordNetworkMonitorUseDecrementsCount() {
        let initialCount = usageLimits.networkMonitorUsesRemaining
        usageLimits.recordNetworkMonitorUse()

        XCTAssertEqual(usageLimits.networkMonitorUsesRemaining, initialCount - 1,
                       "Network monitor uses remaining should decrement by 1")
    }

    // MARK: - Security Scans Tests

    func testInitialSecurityScansRemaining() {
        XCTAssertEqual(usageLimits.securityScansRemaining, 2,
                       "Should have 2 security scans available initially")
    }

    func testCanRunSecurityScanWhenUnderLimit() {
        XCTAssertTrue(usageLimits.canRunSecurityScan(),
                      "Should be able to run security scan when under limit")
    }

    func testRecordSecurityScanDecrementsCount() {
        let initialCount = usageLimits.securityScansRemaining
        usageLimits.recordSecurityScan()

        XCTAssertEqual(usageLimits.securityScansRemaining, initialCount - 1,
                       "Security scans remaining should decrement by 1")
    }

    // MARK: - Unlock All Tests

    func testUnlockAllSetsUnlimitedAccess() {
        usageLimits.unlockAll()

        XCTAssertEqual(usageLimits.hiddenFilesRevealsRemaining, Int.max,
                       "Hidden files reveals should be unlimited after unlock")
        XCTAssertEqual(usageLimits.networkMonitorUsesRemaining, Int.max,
                       "Network monitor uses should be unlimited after unlock")
        XCTAssertEqual(usageLimits.securityScansRemaining, Int.max,
                       "Security scans should be unlimited after unlock")
    }

    // MARK: - Time Until Reset Tests

    func testTimeUntilResetReturnsValidFormat() {
        let resetTime = usageLimits.timeUntilReset()

        // Should contain 'h' and 'm' for hours and minutes
        XCTAssertTrue(resetTime.contains("h") || resetTime.contains("m"),
                      "Reset time should be in format like '12h 30m' or similar")
    }
}

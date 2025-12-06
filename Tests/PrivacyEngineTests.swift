//
//  PrivacyEngineTests.swift
//  DiskDevilTests
//
//  Unit tests for PrivacyEngine functionality

@testable import DiskDevil
import XCTest

// MARK: - PrivacyEngineTests

final class PrivacyEngineTests: XCTestCase {
    var privacyEngine: PrivacyEngine!

    override func setUp() {
        super.setUp()
        privacyEngine = PrivacyEngine()
    }

    override func tearDown() {
        privacyEngine = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialLevelIsOne() {
        XCTAssertEqual(privacyEngine.currentLevel, 1,
                       "Initial privacy level should be 1")
    }

    func testInitiallyNotActive() {
        XCTAssertFalse(privacyEngine.isActive,
                       "Privacy protection should not be active initially")
    }

    func testInitialBlockedConnectionsIsEmpty() {
        XCTAssertTrue(privacyEngine.blockedConnections.isEmpty,
                      "Blocked connections should be empty initially")
    }

    // MARK: - Level Setting Tests

    func testSetLevelUpdatesCurrentLevel() {
        privacyEngine.setLevel(5)

        XCTAssertEqual(privacyEngine.currentLevel, 5,
                       "Current level should be updated to 5")
    }

    func testSetLevelClampsToValidRange() {
        privacyEngine.setLevel(15) // Above max
        XCTAssertLessThanOrEqual(privacyEngine.currentLevel, 10,
                                 "Level should be clamped to max of 10")

        privacyEngine.setLevel(0) // Below min
        XCTAssertGreaterThanOrEqual(privacyEngine.currentLevel, 1,
                                    "Level should be clamped to min of 1")
    }

    // MARK: - Level Description Tests

    func testLevelDescriptionsExist() {
        for level in 1 ... 10 {
            XCTAssertNotNil(privacyEngine.levelDescriptions[level],
                            "Description should exist for level \(level)")
        }
    }

    func testLevel1Description() {
        let description = privacyEngine.levelDescriptions[1]
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("tracker") ?? false,
                      "Level 1 should mention trackers")
    }

    func testLevel10Description() {
        let description = privacyEngine.levelDescriptions[10]
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.lowercased().contains("paranoia") ?? false,
                      "Level 10 should mention paranoia or maximum security")
    }

    // MARK: - Toggle Tests

    func testToggleProtectionActivates() {
        XCTAssertFalse(privacyEngine.isActive)

        privacyEngine.toggleProtection()

        XCTAssertTrue(privacyEngine.isActive,
                      "Protection should be active after toggle")
    }

    func testToggleProtectionDeactivates() {
        privacyEngine.toggleProtection() // Activate
        XCTAssertTrue(privacyEngine.isActive)

        privacyEngine.toggleProtection() // Deactivate

        XCTAssertFalse(privacyEngine.isActive,
                       "Protection should be inactive after second toggle")
    }

    // MARK: - Blocked Connections Tests

    func testTotalBlockedTodayInitiallyZero() {
        XCTAssertEqual(privacyEngine.totalBlockedToday, 0,
                       "Total blocked today should be 0 initially")
    }
}

// MARK: - BlockedConnectionTests

final class BlockedConnectionTests: XCTestCase {
    func testBlockedConnectionCreation() {
        let connection = BlockedConnection(
            timestamp: Date(),
            process: "TestProcess",
            destination: "tracker.example.com",
            reason: "Known tracker",
            level: 1
        )

        XCTAssertEqual(connection.process, "TestProcess")
        XCTAssertEqual(connection.destination, "tracker.example.com")
        XCTAssertEqual(connection.reason, "Known tracker")
        XCTAssertEqual(connection.level, 1)
        XCTAssertNotNil(connection.id, "Connection should have a UUID")
    }

    func testBlockedConnectionHasUniqueID() {
        let connection1 = BlockedConnection(
            timestamp: Date(),
            process: "Process1",
            destination: "dest1.com",
            reason: "Reason",
            level: 1
        )

        let connection2 = BlockedConnection(
            timestamp: Date(),
            process: "Process2",
            destination: "dest2.com",
            reason: "Reason",
            level: 2
        )

        XCTAssertNotEqual(connection1.id, connection2.id,
                          "Each connection should have a unique ID")
    }
}

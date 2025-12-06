//
//  Logger.swift
//  DiskDevil
//
//  Centralized logging using os.Logger for production-ready logging

import Foundation
import os.log

// MARK: - AppLogger

/// Centralized logging for DiskDevil app
/// Uses os.Logger for efficient, privacy-aware logging that integrates with Console.app
enum AppLogger {
    // MARK: Internal

    // MARK: - Category Loggers

    /// Logger for StoreKit and subscription-related operations
    static let storeKit = Logger(subsystem: subsystem, category: "StoreKit")

    /// Logger for privacy engine operations
    static let privacy = Logger(subsystem: subsystem, category: "Privacy")

    /// Logger for security scanning operations
    static let security = Logger(subsystem: subsystem, category: "Security")

    /// Logger for network monitoring operations
    static let network = Logger(subsystem: subsystem, category: "Network")

    /// Logger for file system operations
    static let fileSystem = Logger(subsystem: subsystem, category: "FileSystem")

    /// Logger for UI-related events
    static let ui = Logger(subsystem: subsystem, category: "UI")

    /// Logger for permission-related operations
    static let permissions = Logger(subsystem: subsystem, category: "Permissions")

    /// Logger for audit operations
    static let audit = Logger(subsystem: subsystem, category: "Audit")

    /// General purpose logger
    static let general = Logger(subsystem: subsystem, category: "General")

    // MARK: Private

    // MARK: - Subsystem

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.diskdevil.app"
}

// MARK: - Convenience Extensions

extension Logger {
    /// Log an error with the underlying error details
    func logError(_ message: String, underlyingError: Error) {
        error("\(message): \(underlyingError.localizedDescription)")
    }

    /// Log a debug message (only visible in debug builds)
    func verbose(_ message: String) {
        #if DEBUG
            debug("\(message)")
        #endif
    }
}

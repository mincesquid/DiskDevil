//
//  SecurityValidation.swift
//  DiskDevil
//
//  Shared security validation utilities
//

import Foundation

// MARK: - PathValidation

enum PathValidation {
    /// Validates a file path to prevent command injection and path traversal attacks
    /// - Parameters:
    ///   - path: The path to validate
    ///   - requireExtension: Optional required file extension (e.g., ".plist")
    /// - Returns: true if the path is safe to use, false otherwise
    static func validatePath(_ path: String, requireExtension: String? = nil) -> Bool {
        guard !path.isEmpty,
              !path.contains("../"),
              !path.contains("/.."),
              !path.contains(";"),
              !path.contains("|"),
              !path.contains("&"),
              !path.contains("`"),
              !path.contains("$"),
              !path.contains("\n"),
              !path.contains("\r"),
              FileManager.default.fileExists(atPath: path) else {
            return false
        }
        
        // Check for required extension if specified
        if let ext = requireExtension, !path.hasSuffix(ext) {
            return false
        }
        
        return true
    }
    
    /// Validates a file URL to prevent malicious file access
    /// - Parameter url: The URL to validate
    /// - Returns: true if the URL is safe to use, false otherwise
    static func validateFileURL(_ url: URL) -> Bool {
        guard url.isFileURL,
              !url.path.contains("../"),
              !url.path.contains("/.."),
              FileManager.default.fileExists(atPath: url.path) else {
            return false
        }
        return true
    }
}

//
//  SecurityValidation.swift
//  DiskDevil
//
//  Shared security validation utilities
//

import Foundation

// MARK: - PathValidation

enum PathValidation {
    // MARK: Internal
    
    /// Validates a file path to prevent command injection and path traversal attacks
    /// - Parameters:
    ///   - path: The path to validate
    ///   - requireExtension: Optional required file extension (e.g., ".plist")
    /// - Returns: true if the path is safe to use, false otherwise
    static func validatePath(_ path: String, requireExtension: String? = nil) -> Bool {
        guard !path.isEmpty else {
            return false
        }
        
        // Resolve to canonical path to handle symlinks
        let url = URL(fileURLWithPath: path)
        let canonicalPath = url.resolvingSymlinksInPath().path
        
        // Validate using shared logic
        guard isPathSafe(canonicalPath) else {
            return false
        }
        
        // Check for required extension if specified
        if let ext = requireExtension, !canonicalPath.hasSuffix(ext) {
            return false
        }
        
        return true
    }
    
    /// Validates a file URL to prevent malicious file access
    /// - Parameter url: The URL to validate
    /// - Returns: true if the URL is safe to use, false otherwise
    static func validateFileURL(_ url: URL) -> Bool {
        guard url.isFileURL else {
            return false
        }
        
        // Resolve to canonical path to handle symlinks
        let canonicalPath = url.resolvingSymlinksInPath().path
        
        // Validate using shared logic
        return isPathSafe(canonicalPath)
    }
    
    /// Validates a SHA256 hash format
    /// - Parameter hash: The hash string to validate
    /// - Returns: true if the hash is a valid SHA256 format (64 hex characters)
    static func validateSHA256Hash(_ hash: String) -> Bool {
        // SHA256 is exactly 64 hexadecimal characters
        guard hash.count == 64 else {
            return false
        }
        
        // Check if all characters are valid hex using static character set
        return hash.unicodeScalars.allSatisfy { hexCharacterSet.contains($0) }
    }
    
    // MARK: Private
    
    /// Static hex character set for efficient hash validation
    private static let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    
    /// Shared validation logic for canonical paths
    private static func isPathSafe(_ canonicalPath: String) -> Bool {
        // Check file existence first to prevent TOCTOU attacks
        guard FileManager.default.fileExists(atPath: canonicalPath) else {
            return false
        }
        
        // Validate against path traversal and command injection
        guard !canonicalPath.contains("../"),
              !canonicalPath.contains("/.."),
              !canonicalPath.contains(";"),
              !canonicalPath.contains("|"),
              !canonicalPath.contains("&"),
              !canonicalPath.contains("`"),
              !canonicalPath.contains("$"),
              !canonicalPath.contains("\n"),
              !canonicalPath.contains("\r") else {
            return false
        }
        
        return true
    }
}

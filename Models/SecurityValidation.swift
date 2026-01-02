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
        guard !path.isEmpty else {
            return false
        }
        
        // Resolve to canonical path to handle symlinks
        let url = URL(fileURLWithPath: path)
        let canonicalURL = url.resolvingSymlinksInPath()
        let canonicalPath = canonicalURL.path
        
        // Validate the canonical path
        guard !canonicalPath.contains("../"),
              !canonicalPath.contains("/.."),
              !canonicalPath.contains(";"),
              !canonicalPath.contains("|"),
              !canonicalPath.contains("&"),
              !canonicalPath.contains("`"),
              !canonicalPath.contains("$"),
              !canonicalPath.contains("\n"),
              !canonicalPath.contains("\r"),
              FileManager.default.fileExists(atPath: canonicalPath) else {
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
        let canonicalURL = url.resolvingSymlinksInPath()
        let canonicalPath = canonicalURL.path
        
        // Validate the canonical path with same checks as validatePath
        guard !canonicalPath.contains("../"),
              !canonicalPath.contains("/.."),
              !canonicalPath.contains(";"),
              !canonicalPath.contains("|"),
              !canonicalPath.contains("&"),
              !canonicalPath.contains("`"),
              !canonicalPath.contains("$"),
              !canonicalPath.contains("\n"),
              !canonicalPath.contains("\r"),
              FileManager.default.fileExists(atPath: canonicalPath) else {
            return false
        }
        
        return true
    }
}

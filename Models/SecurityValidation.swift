//
//  SecurityValidation.swift
//  DiskDevil
//
//  Shared security validation utilities
//

import Foundation
import os.log

// MARK: - PathValidation

/// Security-focused validation helpers used as one layer in DiskDevil's
/// defense-in-depth model. These checks assume additional protections:
/// - Process execution is sandboxed and does not run arbitrary shell commands
/// - Arguments are passed as arrays to `Process` (not interpolated shell strings)
/// - Sensitive filesystem operations require Full Disk Access and explicit
///   permission handling elsewhere in the app
///
/// Callers must still follow secure coding practices and not treat a `true`
/// result as a guarantee that an operation is universally safe—only that it
/// passes these specific validation rules.
enum PathValidation {
    // MARK: Internal
    
    /// Validates a file path to prevent command injection and path traversal attacks
    /// - Parameters:
    ///   - path: The path to validate
    ///   - requireExtension: Optional required file extension (e.g., ".plist")
    /// - Returns: true if the path is safe to use, false otherwise
    static func validatePath(_ path: String, requireExtension: String? = nil) -> Bool {
        guard !path.isEmpty else {
            AppLogger.security.warning("Path validation failed: empty path")
            return false
        }
        
        // Validate original path before resolving symlinks
        guard isPathSafe(path, checkExistence: false) else {
            AppLogger.security.warning("Path validation failed for original path: \(path)")
            return false
        }
        
        // Resolve to canonical path to handle symlinks
        let url = URL(fileURLWithPath: path)
        let canonicalPath = url.resolvingSymlinksInPath().path
        
        // Validate canonical path with existence check
        guard isPathSafe(canonicalPath, checkExistence: true) else {
            AppLogger.security.warning("Path validation failed for canonical path: \(canonicalPath)")
            return false
        }
        
        // Check for required extension if specified
        if let ext = requireExtension {
            // Normalize required extension (support both ".plist" and "plist" inputs)
            let requiredExtension = ext.hasPrefix(".") ? String(ext.dropFirst()) : ext
            let actualExtension = URL(fileURLWithPath: canonicalPath).pathExtension
            
            // Require an exact (case-insensitive) extension match
            if actualExtension.isEmpty ||
                actualExtension.caseInsensitiveCompare(requiredExtension) != .orderedSame {
                AppLogger.security.warning("Path validation failed: extension mismatch (expected: \(requiredExtension), got: \(actualExtension))")
                return false
            }
        }
        
        return true
    }
    
    /// Validates a file URL to prevent malicious file access
    /// - Parameter url: The URL to validate
    /// - Returns: true if the URL is safe to use, false otherwise
    static func validateFileURL(_ url: URL) -> Bool {
        guard url.isFileURL else {
            AppLogger.security.warning("URL validation failed: not a file URL")
            return false
        }
        
        let originalPath = url.path
        
        // Validate original path before resolving symlinks
        guard isPathSafe(originalPath, checkExistence: false) else {
            AppLogger.security.warning("URL validation failed for original path: \(originalPath)")
            return false
        }
        
        // Resolve to canonical path to handle symlinks
        let canonicalPath = url.resolvingSymlinksInPath().path
        
        // Validate canonical path with existence check
        guard isPathSafe(canonicalPath, checkExistence: true) else {
            AppLogger.security.warning("URL validation failed for canonical path: \(canonicalPath)")
            return false
        }
        
        return true
    }
    
    /// Validates a SHA256 hash format
    /// - Parameter hash: The hash string to validate
    /// - Returns: true if the hash is a valid SHA256 format (64 hex characters)
    static func validateSHA256Hash(_ hash: String) -> Bool {
        // SHA256 is exactly 64 hexadecimal characters
        guard hash.count == 64 else {
            AppLogger.security.warning("Hash validation failed: incorrect length (expected 64, got \(hash.count))")
            return false
        }
        
        // Check if all characters are valid hex using static character set
        let isValid = hash.unicodeScalars.allSatisfy { hexCharacterSet.contains($0) }
        if !isValid {
            AppLogger.security.warning("Hash validation failed: contains non-hexadecimal characters")
        }
        return isValid
    }
    
    // MARK: Private
    
    /// Static hex character set for efficient hash validation
    private static let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    
    /// Shared validation logic for paths
    /// - Parameters:
    ///   - path: The path to validate
    ///   - checkExistence: Whether to verify the file exists (used after symlink resolution)
    /// - Returns: true if the path is safe, false otherwise
    private static func isPathSafe(_ path: String, checkExistence: Bool) -> Bool {
        // Validate against path traversal and command injection
        // Includes all dangerous characters from SystemBackend for consistency
        guard !path.contains("../"),
              !path.contains("/.."),
              !path.contains(";"),
              !path.contains("|"),
              !path.contains("&"),
              !path.contains("`"),
              !path.contains("$"),
              !path.contains("\n"),
              !path.contains("\r"),
              !path.contains("("),
              !path.contains(")"),
              !path.contains("["),
              !path.contains("]"),
              !path.contains("'"),
              !path.contains("\""),
              !path.contains("\\"),
              !path.contains("<"),
              !path.contains(">"),
              !path.contains("{"),
              !path.contains("}") else {
            return false
        }
        
        // Check file existence only after other validations (prevents TOCTOU)
        if checkExistence {
            guard FileManager.default.fileExists(atPath: path) else {
                return false
            }
        }
        
        return true
    }
}

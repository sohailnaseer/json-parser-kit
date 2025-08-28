import Foundation

// MARK: - Error Types

/// Custom error types for JSON parsing operations
public enum JsonError: Error, LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case invalidJSON(String)
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let message):
            return "Encoding failed: \(message)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        }
    }
}
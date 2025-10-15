import Foundation

/// Strategy for converting property names to JSON keys
public enum JsonKeyStrategy: String {
    /// Keep property names as is (e.g., userName stays userName)
    case original
    
    /// Convert property names to snake_case (e.g., userName becomes user_name)
    case snakeCase
}

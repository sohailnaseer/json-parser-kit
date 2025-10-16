import Foundation

/// Helper for converting strings between different cases
public enum StringCaseConverter {
    /// Convert a string to snake_case by adding underscore before capital letters
    /// - Parameter input: The input string (e.g., "userName")
    /// - Returns: The snake_case version (e.g., "user_name")
    public static func toSnakeCase(_ input: String) -> String {
        var result = ""
        let chars = Array(input)
        
        for (index, char) in chars.enumerated() {
            if char.isUppercase && index > 0 && chars[index - 1].isLowercase {
                result += "_\(char.lowercased())"
            } else {
                result += String(char.lowercased())
            }
        }
        
        return result
    }
}

import Foundation

// MARK: - Encodable Extensions

/// Convenience methods for Encodable types to simplify JSON encoding
public extension Encodable {
    
    /// Convert the object to a JSON string
    /// - Parameter prettyPrint: Whether to format the JSON with indentation
    /// - Returns: JSON string representation
    /// - Throws: JsonError if encoding fails
    func toJSONString(prettyPrint: Bool = false) throws -> String {
        return try JsonParser.encode(self, prettyPrint: prettyPrint)
    }
    
    /// Convert the object to JSON data
    /// - Returns: JSON data representation
    /// - Throws: JsonError if encoding fails
    func toJSONData() throws -> Data {
        return try JsonParser.encode(self)
    }
    
    /// Convert the object to a dictionary
    /// - Returns: Dictionary representation
    /// - Throws: JsonError if encoding fails
    func toDictionary() throws -> [String: Any] {
        return try JsonParser.encodeToDictionary(self)
    }
}

// MARK: - Decodable Extensions

/// Convenience methods for Decodable types to simplify JSON decoding
public extension Decodable {
    
    /// Create an object from a JSON string
    /// - Parameter jsonString: The JSON string to decode
    /// - Returns: Decoded object instance
    /// - Throws: JsonError if decoding fails
    static func fromJSONString(_ jsonString: String) throws -> Self {
        return try JsonParser.decode(jsonString, as: Self.self)
    }
    
    /// Create an object from JSON data
    /// - Parameter data: The JSON data to decode
    /// - Returns: Decoded object instance
    /// - Throws: JsonError if decoding fails
    static func fromJSONData(_ data: Data) throws -> Self {
        return try JsonParser.decode(data, as: Self.self)
    }
    
    /// Create an object from a dictionary
    /// - Parameter dictionary: The dictionary to decode
    /// - Returns: Decoded object instance
    /// - Throws: JsonError if decoding fails
    static func fromDictionary(_ dictionary: [String: Any]) throws -> Self {
        return try JsonParser.decodeFromDictionary(dictionary, as: Self.self)
    }
}
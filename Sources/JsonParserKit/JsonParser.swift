import Foundation

// MARK: - JsonParser Utility Class

/// A utility class providing static methods for JSON encoding and decoding operations
public class JsonParser {
    
    // MARK: - Encoding Methods
    
    /// Encode an Encodable object to a JSON string
    /// - Parameters:
    ///   - object: The object to encode
    ///   - prettyPrint: Whether to format the JSON with indentation
    /// - Returns: JSON string representation
    /// - Throws: JsonError if encoding fails
    public static func encode<T: Encodable>(_ object: T, prettyPrint: Bool = false) throws -> String {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        
        do {
            let data = try encoder.encode(object)
            guard let string = String(data: data, encoding: .utf8) else {
                throw JsonError.encodingFailed("Failed to convert data to string")
            }
            return string
        } catch {
            throw JsonError.encodingFailed(error.localizedDescription)
        }
    }
    
    /// Encode an Encodable object to JSON data
    /// - Parameter object: The object to encode
    /// - Returns: JSON data representation
    /// - Throws: JsonError if encoding fails
    public static func encode<T: Encodable>(_ object: T) throws -> Data {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(object)
        } catch {
            throw JsonError.encodingFailed(error.localizedDescription)
        }
    }
    
    /// Encode an Encodable object to a dictionary
    /// - Parameter object: The object to encode
    /// - Returns: Dictionary representation
    /// - Throws: JsonError if encoding fails
    public static func encodeToDictionary<T: Encodable>(_ object: T) throws -> [String: Any] {
        let data = try encode(object)
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw JsonError.encodingFailed("Failed to convert to dictionary")
            }
            return dictionary
        } catch {
            throw JsonError.encodingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Decoding Methods
    
    /// Decode a JSON string to a Decodable object
    /// - Parameters:
    ///   - jsonString: The JSON string to decode
    ///   - type: The type to decode to
    /// - Returns: Decoded object
    /// - Throws: JsonError if decoding fails
    public static func decode<T: Decodable>(_ jsonString: String, as type: T.Type) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw JsonError.invalidJSON("Invalid UTF-8 string")
        }
        return try decode(data, as: type)
    }
    
    /// Decode JSON data to a Decodable object
    /// - Parameters:
    ///   - data: The JSON data to decode
    ///   - type: The type to decode to
    /// - Returns: Decoded object
    /// - Throws: JsonError if decoding fails
    public static func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw JsonError.decodingFailed(error.localizedDescription)
        }
    }
    
    /// Decode a dictionary to a Decodable object
    /// - Parameters:
    ///   - dictionary: The dictionary to decode
    ///   - type: The type to decode to
    /// - Returns: Decoded object
    /// - Throws: JsonError if decoding fails
    public static func decodeFromDictionary<T: Decodable>(_ dictionary: [String: Any], as type: T.Type) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            return try decode(data, as: type)
        } catch {
            throw JsonError.decodingFailed(error.localizedDescription)
        }
    }
}
import Foundation

extension KeyedDecodingContainer {
    public func decodeSafe<T: Decodable>(_ type: [T].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: key)
        var elements: [T] = []
        
        while !container.isAtEnd {
            if let element = try? container.decode(T.self) {
                elements.append(element)
            } else {
                // Skip this element if it can't be decoded
                _ = try? container.superDecoder()
            }
        }
        
        return elements
    }

    public func decodeSafeIfPresent<T: Decodable>(_ type: [T].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [T]? {
        try? decodeSafe(type, forKey: key)
    }
}
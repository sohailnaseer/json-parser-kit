import Foundation

extension KeyedDecodingContainer {
    public func decodeSafe<T: Decodable>(_ type: [T].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: key)
        var elements: [T] = []
        
        while !container.isAtEnd {
            guard let element = try? container.decode(T.self) else {
                _ = try? container.superDecoder()
                continue
            }

            elements.append(element)
        }
        
        return elements
    }

    public func decodeSafeIfPresent<T: Decodable>(_ type: [T].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [T]? {
        try? decodeSafe(type, forKey: key)
    }
}
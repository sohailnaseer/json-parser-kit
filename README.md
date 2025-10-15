# JsonParserKit

A powerful Swift JSON parsing library that leverages Swift's built-in `Codable` protocol with the convenience of macros, similar to Jackson for Android. JsonParserKit provides automatic JSON encoding/decoding with support for custom key names, default values, and more.

## Features

- 🚀 **Swift Macros**: Automatically generate JSON encoding/decoding code
- 🔑 **Custom JSON Keys**: Map Swift property names to custom JSON field names
- 🐍 **Key Strategy**: Automatic snake_case conversion for JSON keys
- 🎯 **Selective Coding**: Use `@JsonDecodable` or `@JsonEncodable` for specific needs
- 🚫 **Property Exclusion**: Skip properties from JSON serialization with `@JsonExclude`
- 🛡️ **Safe Array Decoding**: Skip invalid elements instead of failing
- 📱 **Platform Support**: Works on iOS, macOS, tvOS, and watchOS
- ⚡ **Performance**: Built on Swift's native `Codable` protocol for optimal performance
- 🎨 **Pretty Printing**: Human-readable JSON output

## Requirements

- Swift 6.2+
- iOS 16.0+
- macOS 13.0+
- tvOS 16.0+
- watchOS 9.0+

## Installation

### Swift Package Manager

Add JsonParserKit to your project dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/JsonParserKit.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

Simply add the `@JsonCodable` macro to your structs and classes:

```swift
import JsonParserKit

@JsonCodable
struct User {
    let id: Int
    let name: String
    let email: String
    let age: Int?
}
```

Now you can automatically encode and decode JSON:

```swift
// Create a user
let user = User(id: 1, name: "John Doe", email: "john@example.com", age: 30)

// Encode to JSON string
let jsonString = try user.toJSONString()
print(jsonString)
// Output: {"id":1,"name":"John Doe","email":"john@example.com","age":30}

// Decode from JSON string
let decodedUser = try User.fromJSONString(jsonString)
print(decodedUser.name) // "John Doe"
```

### Custom JSON Keys

Use the `@JsonKey` macro to specify custom JSON field names:

```swift
@JsonCodable
struct Product {
    let id: String
    let name: String
    @JsonKey("product_price")
    let price: Double
    @JsonKey("in_stock")
    let isAvailable: Bool
}
```

This will generate JSON like:
```json
{
    "id": "prod123",
    "name": "iPhone",
    "product_price": 999.99,
    "in_stock": true
}
```

### Key Strategy

The `@JsonCodable` macro supports two key strategies for property name conversion:

```swift
// Default: snake_case strategy
@JsonCodable
struct User {
    let firstName: String  // becomes "first_name" in JSON
    let lastName: String   // becomes "last_name" in JSON
}

// Keep original property names
@JsonCodable(.original)
struct Product {
    let productId: String  // stays "productId" in JSON
    let productName: String // stays "productName" in JSON
}
```

### Optional Properties

Optional properties are handled automatically:

```swift
@JsonCodable
struct Profile {
    let id: Int
    let name: String
    let bio: String?        // Optional - can be nil
    let avatar: String?     // Optional - can be nil
}
```

### Nested Objects and Arrays

JsonParserKit handles complex nested structures:

```swift
@JsonCodable
struct Order {
    let id: String
    let customer: User
    let items: [Product]
    let total: Double
}

@JsonCodable
struct User {
    let id: Int
    let name: String
    let email: String
}

@JsonCodable
struct Product {
    let id: String
    let name: String
    let price: Double
}
```

### Using the JsonParser Class

For more control, use the static methods:

```swift
// Encode with pretty printing
let prettyJson = try JsonParser.encode(user, prettyPrint: true)

// Decode from Data
let userData = try JsonParser.encode(user)
let decodedUser = try JsonParser.decode(userData, as: User.self)

// Convert to/from dictionaries
let dict = try JsonParser.encodeToDictionary(user)
let userFromDict = try JsonParser.decodeFromDictionary(dict, as: User.self)
```

### Separate Encoding and Decoding

For cases where you only need encoding or decoding, use the dedicated macros:

```swift
// Only decoding needed
@JsonDecodable
struct APIResponse {
    let status: String
    let data: [String: Any]
}

// Only encoding needed
@JsonEncodable
struct RequestPayload {
    let id: String
    let params: [String: Any]
}
```

### Excluding Properties

Use `@JsonExclude` to exclude properties from JSON serialization:

```swift
@JsonCodable
struct User {
    let id: Int
    let name: String
    
    @JsonExclude
    let temporaryCache: [String: Any] // This won't be included in JSON
}
```

### Safe Array Decoding

JsonParserKit provides safe array decoding that skips invalid elements instead of failing:

```swift
@JsonCodable
struct Response {
    let validItems: [Item] // Will contain only successfully decoded items
}

// If the JSON contains invalid items, they will be skipped:
// Input: {"validItems": [{"id": 1}, {"invalid": true}, {"id": 2}]}
// Result: validItems will contain items with id 1 and 2, skipping the invalid one
```

## Advanced Features

### Custom Coding Keys

The macro automatically generates `CodingKeys` for custom JSON key mapping:

```swift
@JsonCodable
struct APIResponse {
    let status: String
    @JsonKey("data")
    let responseData: [String: Any]
    @JsonKey("error_code")
    let errorCode: Int?
}
```

### Error Handling

JsonParserKit provides comprehensive error handling:

```swift
do {
    let user = try User.fromJSONString(jsonString)
    print("User: \(user.name)")
} catch JsonError.missingRequiredField(let field) {
    print("Missing required field: \(field)")
} catch JsonError.typeMismatch(let expected, let actual) {
    print("Type mismatch: expected \(expected), got \(actual)")
} catch {
    print("Other error: \(error)")
}
```

## Error Types

- `JsonError.encodingFailed`: Failed to encode object to JSON
- `JsonError.decodingFailed`: Failed to decode JSON to object
- `JsonError.invalidJSON`: Invalid JSON format
- `JsonError.invalidString`: Invalid string encoding
- `JsonError.missingRequiredField(String)`: Missing required field
- `JsonError.typeMismatch(String, String)`: Type mismatch

## Performance Considerations

- JsonParserKit uses Swift's native `Codable` protocol for optimal performance
- Macros generate code at compile time, so there's no runtime overhead
- The library is designed to be lightweight and efficient

## Migration from Other Libraries

### From Codable (Manual)

Before:
```swift
struct User: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
```

After:
```swift
@JsonCodable
struct User {
    let id: Int
    let name: String
}
```

### From Custom JSON Parsing

Before:
```swift
struct User {
    let id: Int
    let name: String
    
    static func fromJSON(_ json: [String: Any]) -> User? {
        guard let id = json["id"] as? Int,
              let name = json["name"] as? String else {
            return nil
        }
        return User(id: id, name: name)
    }
}
```

After:
```swift
@JsonCodable
struct User {
    let id: Int
    let name: String
}
// Now just use: User.fromJSONString(jsonString)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on Swift's powerful `Codable` protocol
- Inspired by Jackson for Android
- Uses Swift macros for compile-time code generation 
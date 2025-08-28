# JsonParserKit

A powerful Swift JSON parsing library that leverages Swift's built-in `Codable` protocol with the convenience of macros, similar to Jackson for Android. JsonParserKit provides automatic JSON encoding/decoding with support for custom key names, default values, and more.

## Features

- 🚀 **Swift Macros**: Automatically generate JSON encoding/decoding code
- 🔑 **Custom JSON Keys**: Map Swift property names to custom JSON field names
- 💡 **Default Values**: Provide fallback values for missing JSON fields
- 📱 **Platform Support**: Works on iOS, macOS, tvOS, and watchOS
- ⚡ **Performance**: Built on Swift's native `Codable` protocol for optimal performance
- 🛡️ **Type Safety**: Full compile-time type checking
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

### Default Values

Use the `@DefaultValue` macro to provide fallback values:

```swift
@JsonCodable
struct Settings {
    let theme: String
    @DefaultValue("en")
    let language: String
    @DefaultValue(true)
    let notifications: Bool
    @DefaultValue(0.0)
    let volume: Double
}
```

If the JSON doesn't contain these fields, the default values will be used.

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

### Property Wrapper for Default Values

Use the `@Default` property wrapper for more complex default value scenarios:

```swift
@JsonCodable
struct Configuration {
    @Default(wrappedValue: nil, defaultValue: "default")
    let theme: String?
    
    @Default(wrappedValue: nil, defaultValue: 100)
    let maxItems: Int?
}
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
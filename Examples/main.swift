import Foundation
import JsonParserKit

// MARK: - Example Models

@JsonCodable
struct User {
    let id: Int
    let name: String
    @JsonKey("email_address")
    let email: String
    @JsonKey(defaultValue: "active")
    let status: String
    let age: Int?
    @JsonKey(defaultValue: 0.0)
    let score: Double
}

@JsonCodable
struct Product {
    let id: String
    let name: String
    let price: Double
    @JsonKey("in_stock", defaultValue: true)
    let isAvailable: Bool
    let tags: [String]
    let metadata: [String: String]?
}

@JsonCodable
struct Order {
    let id: String
    let customer: User
    let items: [Product]
    let total: Double
    @JsonKey(defaultValue: "pending")
    let status: String
    
    @JsonKey("product", defaultValue: Product(
        id: "prod123",
        name: "iPhone 15",
        price: 999.99,
        isAvailable: true,
        tags: ["electronics", "smartphone", "apple"],
        metadata: ["color": "black", "storage": "128GB"]
    ))
    let product: Product
}

// MARK: - Example Usage

func runBasicExample() {
    print("=== JsonParserKit Basic Example ===\n")
    
    // Create a user
    let user = User(
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        status: "active",
        age: 30,
        score: 95.5
    )
    
    print("Created user: \(user.name) (ID: \(user.id))")
    
    // Encode to JSON
    do {
        let jsonString = try user.toJSONString(prettyPrint: true)
        print("\nUser as JSON:")
        print(jsonString)
        
        // Decode from JSON
        let decodedUser = try User.fromJSONString(jsonString)
        print("\nDecoded user: \(decodedUser.name) (ID: \(decodedUser.id))")
        
    } catch {
        print("Error: \(error)")
    }
}

func runCustomKeysExample() {
    print("\n=== Custom JSON Keys Example ===\n")
    
    let product = Product(
        id: "prod123",
        name: "iPhone 15",
        price: 999.99,
        isAvailable: true,
        tags: ["electronics", "smartphone", "apple"],
        metadata: ["color": "black", "storage": "128GB"]
    )
    
    print("Created product: \(product.name) (ID: \(product.id))")
    
    do {
        let jsonString = try product.toJSONString(prettyPrint: true)
        print("\nProduct as JSON (note custom keys):")
        print(jsonString)
        
        // Notice how "in_stock" is used instead of "isAvailable"
        // and the custom key mapping is applied
        
    } catch {
        print("Error: \(error)")
    }
}

func runDefaultValuesExample() {
    print("\n=== Default Values Example ===\n")
    
    let order = Order(
        id: "order456",
        customer: User(
            id: 2,
            name: "Jane Smith",
            email: "jane@example.com",
            status: "active",
            age: 25,
            score: 88.0
        ),
        items: [
            Product(
                id: "prod1",
                name: "Laptop",
                price: 1299.99,
                isAvailable: true,
                tags: ["electronics", "computer"],
                metadata: nil
            )
        ],
        total: 1299.99
        // Note: status is not provided, so default value "pending" will be used
    )
    
    print("Created order: \(order.id) for \(order.customer.name)")
    print("Order status: \(order.status)") // Will show default value "pending"
    
    do {
        let jsonString = try order.toJSONString(prettyPrint: true)
        print("\nOrder as JSON:")
        print(jsonString)
        
    } catch {
        print("Error: \(error)")
    }
}

func runComplexNestedExample() {
    print("\n=== Complex Nested Objects Example ===\n")
    
    let complexOrder = Order(
        id: "complex789",
        customer: User(
            id: 3,
            name: "Bob Johnson",
            email: "bob@example.com",
            status: "active",
            age: 35,
            score: 92.0
        ),
        items: [
            Product(
                id: "prod2",
                name: "Headphones",
                price: 199.99,
                isAvailable: true,
                tags: ["audio", "wireless"],
                metadata: ["brand": "Sony", "color": "white"]
            ),
            Product(
                id: "prod3",
                name: "Mouse",
                price: 49.99,
                isAvailable: false,
                tags: ["computer", "accessory"],
                metadata: ["brand": "Logitech"]
            )
        ],
        total: 249.98,
        status: "confirmed"
    )
    
    print("Created complex order: \(complexOrder.id)")
    print("Customer: \(complexOrder.customer.name)")
    print("Items: \(complexOrder.items.count)")
    print("Total: $\(complexOrder.total)")
    
    do {
        let jsonString = try complexOrder.toJSONString(prettyPrint: true)
        print("\nComplex order as JSON:")
        print(jsonString)
        
        // Test decoding
        let decodedOrder = try Order.fromJSONString(jsonString)
        print("\nSuccessfully decoded order with \(decodedOrder.items.count) items")
        
    } catch {
        print("Error: \(error)")
    }
}

func runJsonParserMethodsExample() {
    print("\n=== JsonParser Static Methods Example ===\n")
    
    let user = User(
        id: 4,
        name: "Alice Brown",
        email: "alice@example.com",
        status: "active",
        age: 28,
        score: 87.0
    )
    
    do {
        // Using JsonParser static methods
        let jsonString = try JsonParser.encode(user, prettyPrint: true)
        let jsonData = try JsonParser.encode(user)
        let dictionary = try JsonParser.encodeToDictionary(user)
        
        print("Encoded to string: \(jsonString.prefix(50))...")
        print("Encoded to data: \(jsonData.count) bytes")
        print("Encoded to dictionary: \(dictionary.keys.joined(separator: ", "))")
        
        // Decode using different methods
        let userFromString = try JsonParser.decode(jsonString, as: User.self)
        let userFromData = try JsonParser.decode(jsonData, as: User.self)
        let userFromDict = try JsonParser.decodeFromDictionary(dictionary, as: User.self)
        
        print("\nAll decode methods successful:")
        print("- From string: \(userFromString.name)")
        print("- From data: \(userFromData.name)")
        print("- From dictionary: \(userFromDict.name)")
        
    } catch {
        print("Error: \(error)")
    }
}

// MARK: - Main Function

func main() {
    runBasicExample()
    runCustomKeysExample()
    runDefaultValuesExample()
    runComplexNestedExample()
    runJsonParserMethodsExample()
    
    print("\n=== Example Complete ===")
}

// Call the main function
main()

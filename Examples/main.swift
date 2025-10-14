import Foundation
import JsonParserKit

@JsonCodable
struct User {
    let id: Int
    let name: String
    var email: String?
    @JsonKey("user_age") var age: Int
    var nickname: String? = "Anonymous"
    var isActive: Bool = true
    @JsonExclude var internalId: String = UUID().uuidString
    var tags: [String]?
    @JsonKey("phone_number") var phoneNumber: String?
}

@JsonCodable
struct Product {
    let id: String
    let title: String
    var price: Double
    @JsonKey("discount_percentage") var discountPercentage: Double? = 0.0
    var inStock: Bool = true
    @JsonExclude var cache: String? = nil
    
    init(id: String, title: String, price: Double) {
        self.id = id
        self.title = title
        self.price = price
    }
}

@JsonCodable
struct Address {
    let street: String
    let city: String
    @JsonKey("zip_code") let zipCode: String
    var apartment: String?
    var floor: Int? = 1
}

func testUserParsing() {
    print("Testing User Parsing...")
    print("-" * 50)
    
    let json = """
    {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "user_age": 30,
        "tags": ["developer", "swift"],
        "phone_number": "+1234567890"
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let user = try JSONDecoder().decode(User.self, from: data)
        
        print("Decoded User:")
        print("  ID: \(user.id)")
        print("  Name: \(user.name)")
        print("  Email: \(user.email ?? "nil")")
        print("  Age: \(user.age)")
        print("  Nickname: \(user.nickname ?? "nil")")
        print("  Is Active: \(user.isActive)")
        print("  Tags: \(user.tags ?? [])")
        print("  Phone: \(user.phoneNumber ?? "nil")")
        print("  Internal ID (excluded): \(user.internalId)")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(user)
        print("\nRe-encoded JSON:")
        print(String(data: encoded, encoding: .utf8)!)
    } catch {
        print("Error: \(error)")
    }
}

func testUserWithDefaults() {
    print("\nTesting User with Default Values...")
    print("-" * 50)
    
    let json = """
    {
        "id": 2,
        "name": "Jane Smith",
        "user_age": 25
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let user = try JSONDecoder().decode(User.self, from: data)
        
        print("Decoded User (with defaults):")
        print("  ID: \(user.id)")
        print("  Name: \(user.name)")
        print("  Email: \(user.email ?? "nil")")
        print("  Age: \(user.age)")
        print("  Nickname: \(user.nickname ?? "nil") (default)")
        print("  Is Active: \(user.isActive) (default)")
    } catch {
        print("Error: \(error)")
    }
}

func testProductParsing() {
    print("\nTesting Product (Class) Parsing...")
    print("-" * 50)
    
    let json = """
    {
        "id": "PROD-001",
        "title": "MacBook Pro",
        "price": 2499.99,
        "discount_percentage": 10.5
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let product = try JSONDecoder().decode(Product.self, from: data)
        
        print("Decoded Product:")
        print("  ID: \(product.id)")
        print("  Title: \(product.title)")
        print("  Price: $\(product.price)")
        print("  Discount: \(product.discountPercentage ?? 0)%")
        print("  In Stock: \(product.inStock) (default)")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(product)
        print("\nRe-encoded JSON:")
        print(String(data: encoded, encoding: .utf8)!)
    } catch {
        print("Error: \(error)")
    }
}

func testAddressParsing() {
    print("\nTesting Address Parsing...")
    print("-" * 50)
    
    let json = """
    {
        "street": "123 Main St",
        "city": "New York",
        "zip_code": "10001",
        "apartment": "4B"
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let address = try JSONDecoder().decode(Address.self, from: data)
        
        print("Decoded Address:")
        print("  Street: \(address.street)")
        print("  City: \(address.city)")
        print("  Zip Code: \(address.zipCode)")
        print("  Apartment: \(address.apartment ?? "nil")")
        print("  Floor: \(address.floor ?? 0)")
    } catch {
        print("Error: \(error)")
    }
}

func testAddressWithDefaults() {
    print("\nTesting Address with Default Floor...")
    print("-" * 50)
    
    let json = """
    {
        "street": "456 Oak Ave",
        "city": "Los Angeles",
        "zip_code": "90001"
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let address = try JSONDecoder().decode(Address.self, from: data)
        
        print("Decoded Address (with default floor):")
        print("  Street: \(address.street)")
        print("  City: \(address.city)")
        print("  Zip Code: \(address.zipCode)")
        print("  Apartment: \(address.apartment ?? "nil")")
        print("  Floor: \(address.floor ?? 0) (default)")
    } catch {
        print("Error: \(error)")
    }
}

// Example with JsonDecodable (decode only)
@JsonDecodable
struct ApiRequest {
    let endpoint: String
    @JsonKey("api_key") let apiKey: String
    let timestamp: Date?
}

// Example with JsonEncodable (encode only)
@JsonEncodable
struct ApiResponse {
    let status: String
    @JsonKey("response_data") let responseData: String
    var timestamp: Date = Date()
    @JsonExclude var cached: Bool = false
}

func testJsonDecodable() {
    print("\nTesting JsonDecodable (decode only)...")
    print("-" * 50)
    
    let json = """
    {
        "endpoint": "/api/users",
        "api_key": "secret123"
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        let request = try JSONDecoder().decode(ApiRequest.self, from: data)
        
        print("Decoded ApiRequest:")
        print("  Endpoint: \(request.endpoint)")
        print("  API Key: \(request.apiKey)")
        print("  Timestamp: \(request.timestamp?.description ?? "nil")")
        
        // This would fail to compile because ApiRequest is not Encodable
        // let encoded = try JSONEncoder().encode(request)
    } catch {
        print("Error: \(error)")
    }
}

func testJsonEncodable() {
    print("\nTesting JsonEncodable (encode only)...")
    print("-" * 50)
    
    let response = ApiResponse(
        status: "success",
        responseData: "User data retrieved"
    )
    
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(response)
        print("Encoded ApiResponse:")
        print(String(data: encoded, encoding: .utf8)!)
        
        // This would fail to compile because ApiResponse is not Decodable
        // let decoded = try JSONDecoder().decode(ApiResponse.self, from: encoded)
    } catch {
        print("Error: \(error)")
    }
}

testUserParsing()
testUserWithDefaults()
testProductParsing()
testAddressParsing()
testAddressWithDefaults()
testJsonDecodable()
testJsonEncodable()

print("\n✅ All tests completed!")

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        String(repeating: lhs, count: rhs)
    }
}

import XCTest
@testable import JsonParserKit

final class JsonParserKitTests: XCTestCase {
    
    // MARK: - Test Models
    
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
        
        static let testDefault = Product(
            id: "default123",
            name: "Default Product",
            price: 99.99,
            isAvailable: true,
            tags: ["default"],
            metadata: ["type": "default"]
        )
    }
    
    @JsonCodable
    struct NestedObject {
        let user: User
        let products: [Product]
        @JsonKey(defaultValue: "default_category")
        let category: String
    }
    
    @JsonCodable
    struct TestWithDefaults {
        let id: Int
        let name: String
        @JsonKey(defaultValue: "default_status")
        let status: String
        @JsonKey(defaultValue: 100)
        let points: Int
    }
    
    @JsonCodable
    struct NumericalTest {
        let intMax: Int
        let intMin: Int
        let doubleMax: Double
        let doubleMin: Double
        let doubleZero: Double
        let doubleNegativeZero: Double
    }
    
    @JsonCodable
    struct Level1 {
        let level2: Level2
    }
    
    @JsonCodable
    struct Level2 {
        let level3: Level3
    }
    
    @JsonCodable
    struct Level3 {
        let value: String
        let numbers: [Int]
    }
    
    @JsonCodable
    struct OrderWithProducts {
        let id: String
        let products: [Product]
        let userList: [User]
    }
    
    @JsonCodable
    struct BoolNumericTest {
        @JsonKey(defaultValue: true)
        let defaultTrue: Bool
        
        @JsonKey(defaultValue: false) 
        let defaultFalse: Bool
        
        @JsonKey(defaultValue: 42)
        let defaultInt: Int
        
        @JsonKey(defaultValue: 3.14159)
        let defaultDouble: Double
        
        let required: String
    }
    
    @JsonCodable
    struct TestStruct {
        @JsonKey(defaultValue: "default")
        let value: String?
    }
    
    @JsonCodable
    struct TestVariations {
        // Custom key only
        @JsonKey("custom_field")
        let customKeyOnly: String
        
        // Default value only  
        @JsonKey(defaultValue: "defaulted")
        let defaultValueOnly: String
        
        // Both custom key and default value
        @JsonKey("renamed_field", defaultValue: "both")
        let bothCustomAndDefault: String
        
        // No annotation (uses property name)
        let noAnnotation: String
    }
    
    // Test struct for complex default values
    @JsonCodable
    struct OrderWithComplexDefault {
        let id: String
        @JsonKey("main_product", defaultValue: Product.testDefault)
        let product: Product
    }
    
    // MARK: - Basic Encoding/Decoding Tests
    
    func testBasicEncodingDecoding() throws {
        let user = User(
            id: 1,
            name: "John Doe",
            email: "john@example.com",
            status: "active",
            age: 30,
            score: 95.5
        )
        
        // Test encoding
        let jsonString = try user.toJSONString()
        XCTAssertFalse(jsonString.isEmpty)
        
        // Test decoding
        let decodedUser = try User.fromJSONString(jsonString)
        XCTAssertEqual(decodedUser.id, user.id)
        XCTAssertEqual(decodedUser.name, user.name)
        XCTAssertEqual(decodedUser.email, user.email)
        XCTAssertEqual(decodedUser.status, user.status)
        XCTAssertEqual(decodedUser.age, user.age)
        XCTAssertEqual(decodedUser.score, user.score)
    }
    
    func testCustomJsonKeys() throws {
        let user = User(
            id: 1,
            name: "Jane Doe",
            email: "jane@example.com",
            status: "inactive",
            age: nil,
            score: 88.0
        )
        
        let jsonString = try user.toJSONString()
        let jsonData = jsonString.data(using: .utf8)!
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        
        // Check that custom JSON keys are used
        XCTAssertNotNil(jsonObject["email_address"])
        XCTAssertNil(jsonObject["email"])
        XCTAssertEqual(jsonObject["email_address"] as? String, "jane@example.com")
    }
    
    func testDefaultValues() throws {
        let user = User(
            id: 1,
            name: "Bob Smith",
            email: "bob@example.com",
            status: "active",
            age: nil,
            score: 75.0
        )
        
        let jsonString = try user.toJSONString()
        let decodedUser = try User.fromJSONString(jsonString)
        
        // Check that default values are applied
        XCTAssertEqual(decodedUser.status, "active") // Default value
        XCTAssertEqual(decodedUser.score, 75.0) // Provided value
    }
    
    func testOptionalProperties() throws {
        let user = User(
            id: 1,
            name: "Alice Johnson",
            email: "alice@example.com",
            status: "active",
            age: nil, // Optional property
            score: 92.0
        )
        
        let jsonString = try user.toJSONString()
        let decodedUser = try User.fromJSONString(jsonString)
        
        XCTAssertEqual(decodedUser.age, nil)
        XCTAssertEqual(decodedUser.name, "Alice Johnson")
    }
    
    func testComplexObject() throws {
        let user = User(
            id: 1,
            name: "Test User",
            email: "test@example.com",
            status: "active",
            age: 25,
            score: 85.0
        )
        
        let products = [
            Product(
                id: "prod1",
                name: "Product 1",
                price: 29.99,
                isAvailable: true,
                tags: ["electronics", "gadgets"],
                metadata: ["brand": "TestBrand"]
            ),
            Product(
                id: "prod2",
                name: "Product 2",
                price: 49.99,
                isAvailable: false,
                tags: ["clothing", "fashion"],
                metadata: nil
            )
        ]
        
        let nested = NestedObject(
            user: user,
            products: products,
            category: "electronics"
        )
        
        let jsonString = try nested.toJSONString()
        let decodedNested = try NestedObject.fromJSONString(jsonString)
        
        XCTAssertEqual(decodedNested.user.id, user.id)
        XCTAssertEqual(decodedNested.products.count, 2)
        XCTAssertEqual(decodedNested.category, "electronics")
    }
    
    func testArrayAndDictionary() throws {
        let product = Product(
            id: "test",
            name: "Test Product",
            price: 19.99,
            isAvailable: true,
            tags: ["tag1", "tag2", "tag3"],
            metadata: ["key1": "value1", "key2": "value2"]
        )
        
        let jsonString = try product.toJSONString()
        let decodedProduct = try Product.fromJSONString(jsonString)
        
        XCTAssertEqual(decodedProduct.tags.count, 3)
        XCTAssertEqual(decodedProduct.tags[0], "tag1")
        XCTAssertEqual(decodedProduct.metadata?["key1"], "value1")
    }
    
    func testJsonParserStaticMethods() throws {
        let user = User(
            id: 1,
            name: "Static Test",
            email: "static@test.com",
            status: "active",
            age: 35,
            score: 90.0
        )
        
        // Test static encode method
        let jsonString = try JsonParser.encode(user)
        XCTAssertFalse(jsonString.isEmpty)
        
        // Test static decode method
        let decodedUser = try JsonParser.decode(jsonString, as: User.self)
        XCTAssertEqual(decodedUser.id, user.id)
        
        // Test data encoding/decoding
        let jsonData = try JsonParser.encode(user)
        let decodedFromData = try JsonParser.decode(jsonData, as: User.self)
        XCTAssertEqual(decodedFromData.name, user.name)
        
        // Test dictionary conversion
        let dictionary = try JsonParser.encodeToDictionary(user)
        XCTAssertEqual(dictionary["id"] as? Int, user.id)
        
        let decodedFromDict = try JsonParser.decodeFromDictionary(dictionary, as: User.self)
        XCTAssertEqual(decodedFromDict.email, user.email)
    }
    
    func testPrettyPrinting() throws {
        let user = User(
            id: 1,
            name: "Pretty Print Test",
            email: "pretty@test.com",
            status: "active",
            age: 28,
            score: 87.5
        )
        
        let compactJson = try user.toJSONString(prettyPrint: false)
        let prettyJson = try user.toJSONString(prettyPrint: true)
        
        // Pretty printed JSON should have more characters due to formatting
        XCTAssertTrue(prettyJson.count > compactJson.count)
        
        // Both should decode to the same object
        let compactDecoded = try User.fromJSONString(compactJson)
        let prettyDecoded = try User.fromJSONString(prettyJson)
        
        XCTAssertEqual(compactDecoded.id, prettyDecoded.id)
        XCTAssertEqual(compactDecoded.name, prettyDecoded.name)
    }
    
    func testErrorHandling() throws {
        // Test invalid JSON string
        let invalidJSON = "{ invalid json }"
        
        do {
            _ = try User.fromJSONString(invalidJSON)
            XCTFail("Should have thrown an error for invalid JSON")
        } catch {
            // Expected to throw an error
            XCTAssertTrue(error is DecodingError || error is JsonError)
        }
    }
    
    func testDefaultPropertyWrapper() throws {
        // Create JSON without the value field to test default value behavior
        let jsonString = "{}"
        let decoded = try TestStruct.fromJSONString(jsonString)
        
        // The @JsonKey macro with defaultValue should provide the default value
        XCTAssertEqual(decoded.value, "default")
    }
    
    func testJsonKeyVariations() throws {
        let jsonString = """
        {
            "custom_field": "custom_value",
            "noAnnotation": "no_annotation_value"
        }
        """
        
        let decoded = try TestVariations.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.customKeyOnly, "custom_value")
        XCTAssertEqual(decoded.defaultValueOnly, "defaulted")     // Should use default
        XCTAssertEqual(decoded.bothCustomAndDefault, "both")      // Should use default (renamed_field not in JSON)
        XCTAssertEqual(decoded.noAnnotation, "no_annotation_value")
    }
    
    // MARK: - Memberwise Initializer Tests
    
    func testMemberwiseInitializerBasic() throws {
        // Test that the macro generates working memberwise initializers
        let user = User(
            id: 42,
            name: "Memberwise Test",
            email: "test@memberwise.com",
            status: "active",
            age: 30,
            score: 95.0
        )
        
        XCTAssertEqual(user.id, 42)
        XCTAssertEqual(user.name, "Memberwise Test")
        XCTAssertEqual(user.email, "test@memberwise.com")
        XCTAssertEqual(user.status, "active")
        XCTAssertEqual(user.age, 30)
        XCTAssertEqual(user.score, 95.0)
    }
    
    func testMemberwiseInitializerWithDefaults() throws {
        // Test memberwise initializer with default values
        // Test with all parameters
        let full = TestWithDefaults(id: 1, name: "Full", status: "custom", points: 200)
        XCTAssertEqual(full.status, "custom")
        XCTAssertEqual(full.points, 200)
        
        // Test with default values
        let withDefaults = TestWithDefaults(id: 2, name: "Defaults")
        XCTAssertEqual(withDefaults.status, "default_status")
        XCTAssertEqual(withDefaults.points, 100)
    }
    
    func testMemberwiseInitializerWithOptionals() throws {
        // Test memberwise initializer with optional properties
        let userWithAge = User(
            id: 1,
            name: "With Age",
            email: "with@age.com",
            status: "active",
            age: 25,
            score: 88.0
        )
        XCTAssertEqual(userWithAge.age, 25)
        
        let userWithoutAge = User(
            id: 2,
            name: "Without Age",
            email: "without@age.com",
            status: "active",
            age: nil,
            score: 88.0
        )
        XCTAssertNil(userWithoutAge.age)
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testEmptyArraysAndDictionaries() throws {
        let product = Product(
            id: "empty",
            name: "Empty Collections",
            price: 0.0,
            isAvailable: true,
            tags: [], // Empty array
            metadata: [:] // Empty dictionary
        )
        
        let jsonString = try product.toJSONString()
        let decoded = try Product.fromJSONString(jsonString)
        
        XCTAssertTrue(decoded.tags.isEmpty)
        XCTAssertTrue(decoded.metadata?.isEmpty == true)
    }
    
    func testNilOptionalCollections() throws {
        let product = Product(
            id: "nil_collections",
            name: "Nil Collections",
            price: 0.0,
            isAvailable: false,
            tags: [],
            metadata: nil // Nil optional dictionary
        )
        
        let jsonString = try product.toJSONString()
        let decoded = try Product.fromJSONString(jsonString)
        
        XCTAssertNil(decoded.metadata)
        XCTAssertEqual(decoded.tags.count, 0)
    }
    
    func testSpecialCharactersAndUnicode() throws {
        let user = User(
            id: 1,
            name: "🚀 Unicode Test 中文 한글",
            email: "unicode@тест.com",
            status: "special chars: !@#$%^&*()",
            age: 30,
            score: 95.5
        )
        
        let jsonString = try user.toJSONString()
        let decoded = try User.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.name, "🚀 Unicode Test 中文 한글")
        XCTAssertEqual(decoded.email, "unicode@тест.com")
        XCTAssertEqual(decoded.status, "special chars: !@#$%^&*()")
    }
    
    func testNumericalEdgeCases() throws {
        let nums = NumericalTest(
            intMax: Int.max,
            intMin: Int.min,
            doubleMax: Double.greatestFiniteMagnitude,
            doubleMin: -Double.greatestFiniteMagnitude,
            doubleZero: 0.0,
            doubleNegativeZero: -0.0
        )
        
        let jsonString = try nums.toJSONString()
        let decoded = try NumericalTest.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.intMax, Int.max)
        XCTAssertEqual(decoded.intMin, Int.min)
        XCTAssertEqual(decoded.doubleMax, Double.greatestFiniteMagnitude)
        XCTAssertEqual(decoded.doubleMin, -Double.greatestFiniteMagnitude)
        XCTAssertEqual(decoded.doubleZero, 0.0)
    }
    
    func testDeepNestedStructures() throws {
        let deep = Level1(
            level2: Level2(
                level3: Level3(
                    value: "deeply nested",
                    numbers: [1, 2, 3, 4, 5]
                )
            )
        )
        
        let jsonString = try deep.toJSONString()
        let decoded = try Level1.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.level2.level3.value, "deeply nested")
        XCTAssertEqual(decoded.level2.level3.numbers, [1, 2, 3, 4, 5])
    }
    
    func testLargeDataStructures() throws {
        let largeTagArray = (1...1000).map { "tag\($0)" }
        let largeMetadata = Dictionary(
            uniqueKeysWithValues: (1...100).map { ("key\($0)", "value\($0)") }
        )
        
        let product = Product(
            id: "large",
            name: "Large Data Test",
            price: 999.99,
            isAvailable: true,
            tags: largeTagArray,
            metadata: largeMetadata
        )
        
        let jsonString = try product.toJSONString()
        let decoded = try Product.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.tags.count, 1000)
        XCTAssertEqual(decoded.metadata?.count, 100)
        XCTAssertEqual(decoded.tags.first, "tag1")
        XCTAssertEqual(decoded.tags.last, "tag1000")
        XCTAssertEqual(decoded.metadata?["key50"], "value50")
    }
    
    func testMalformedJSONHandling() throws {
        let malformedJSONs = [
            "{ incomplete json",
            "{ \"name\": }",
            "{ \"id\": \"not_a_number\" }",
            "[]", // Array instead of object
            "null",
            "",
            "{ \"id\": 1, \"name\": \"test\", }", // Trailing comma
        ]
        
        for malformedJSON in malformedJSONs {
            do {
                _ = try User.fromJSONString(malformedJSON)
                XCTFail("Should have failed for malformed JSON: \(malformedJSON)")
            } catch {
                // Expected to fail
                XCTAssertTrue(error is DecodingError || error is JsonError)
            }
        }
    }
    
    func testTypeMismatchHandling() throws {
        let typeMismatchJSONs = [
            "{ \"id\": \"string_instead_of_int\", \"name\": \"test\", \"email_address\": \"test@test.com\" }",
            "{ \"id\": 1, \"name\": 123, \"email_address\": \"test@test.com\" }", // name should be string
            "{ \"id\": 1, \"name\": \"test\", \"email_address\": 456 }", // email should be string
            "{ \"id\": 1, \"name\": \"test\", \"email_address\": \"test@test.com\", \"age\": \"thirty\" }", // age should be int
        ]
        
        for typeMismatchJSON in typeMismatchJSONs {
            do {
                _ = try User.fromJSONString(typeMismatchJSON)
                XCTFail("Should have failed for type mismatch: \(typeMismatchJSON)")
            } catch {
                // Expected to fail
                XCTAssertTrue(error is DecodingError)
            }
        }
    }
    
    func testMissingRequiredFields() throws {
        let incompleteJSONs = [
            "{ \"name\": \"test\" }", // Missing id and email
            "{ \"id\": 1 }", // Missing name and email
            "{ \"id\": 1, \"name\": \"test\" }", // Missing email
            "{}" // Missing everything required
        ]
        
        for incompleteJSON in incompleteJSONs {
            do {
                _ = try User.fromJSONString(incompleteJSON)
                XCTFail("Should have failed for missing required fields: \(incompleteJSON)")
            } catch {
                // Expected to fail
                XCTAssertTrue(error is DecodingError)
            }
        }
    }
    
    func testDefaultValueFallback() throws {
        // JSON missing fields that have default values should succeed
        let jsonWithMissingDefaults = """
        {
            "id": 1,
            "name": "Test User",
            "email_address": "test@example.com"
        }
        """
        
        let user = try User.fromJSONString(jsonWithMissingDefaults)
        
        // Should use default values for missing fields
        XCTAssertEqual(user.status, "active") // Default from @JsonKey(defaultValue: "active")
        XCTAssertEqual(user.score, 0.0) // Default from @JsonKey(defaultValue: 0.0)
        XCTAssertNil(user.age) // Optional field, should be nil
    }
    
    func testComplexNestedArrays() throws {
        let products = [
            Product(id: "1", name: "Product 1", price: 10.0, isAvailable: true, tags: ["tag1"], metadata: nil),
            Product(id: "2", name: "Product 2", price: 20.0, isAvailable: false, tags: ["tag2"], metadata: ["key": "value"])
        ]
        
        let users = [
            User(id: 1, name: "User 1", email: "user1@test.com", status: "active", age: 25, score: 85.0),
            User(id: 2, name: "User 2", email: "user2@test.com", status: "inactive", age: nil, score: 75.0)
        ]
        
        let order = OrderWithProducts(
            id: "order123",
            products: products,
            userList: users
        )
        
        let jsonString = try order.toJSONString()
        let decoded = try OrderWithProducts.fromJSONString(jsonString)
        
        XCTAssertEqual(decoded.products.count, 2)
        XCTAssertEqual(decoded.userList.count, 2)
        XCTAssertEqual(decoded.products[0].name, "Product 1")
        XCTAssertEqual(decoded.userList[1].name, "User 2")
        XCTAssertNil(decoded.userList[1].age)
    }
    
    func testBooleanAndNumericDefaults() throws {
        let json = """
        {
            "required": "test"
        }
        """
        
        let decoded = try BoolNumericTest.fromJSONString(json)
        
        XCTAssertTrue(decoded.defaultTrue)
        XCTAssertFalse(decoded.defaultFalse)
        XCTAssertEqual(decoded.defaultInt, 42)
        XCTAssertEqual(decoded.defaultDouble, 3.14159, accuracy: 0.00001)
        XCTAssertEqual(decoded.required, "test")
    }
    
    func testComplexDefaultValues() throws {
        // Test JSON without the main_product field to verify default is used
        let jsonWithoutProduct = """
        {
            "id": "order789"
        }
        """
        
        let order = try OrderWithComplexDefault.fromJSONString(jsonWithoutProduct)
        
        // Should use the default Product.testDefault
        XCTAssertEqual(order.id, "order789")
        XCTAssertEqual(order.product.id, "default123")
        XCTAssertEqual(order.product.name, "Default Product")
        XCTAssertEqual(order.product.price, 99.99)
        XCTAssertTrue(order.product.isAvailable)
        XCTAssertEqual(order.product.tags, ["default"])
        XCTAssertEqual(order.product.metadata?["type"], "default")
    }
    
    func testPerformanceEncodingDecoding() throws {
        let users = (1...1000).map { i in
            User(
                id: i,
                name: "User \(i)",
                email: "user\(i)@test.com",
                status: "active",
                age: 20 + (i % 50),
                score: Double(i) * 0.1
            )
        }
        
        let nested = NestedObject(
            user: users[0],
            products: (1...100).map { i in
                Product(
                    id: "prod\(i)",
                    name: "Product \(i)",
                    price: Double(i) * 9.99,
                    isAvailable: i % 2 == 0,
                    tags: ["tag1", "tag2", "tag\(i)"],
                    metadata: ["id": "\(i)", "category": "test"]
                )
            },
            category: "performance_test"
        )
        
        measure {
            do {
                let jsonString = try nested.toJSONString()
                _ = try NestedObject.fromJSONString(jsonString)
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testBasicEncodingDecoding", testBasicEncodingDecoding),
        ("testCustomJsonKeys", testCustomJsonKeys),
        ("testDefaultValues", testDefaultValues),
        ("testOptionalProperties", testOptionalProperties),
        ("testComplexObject", testComplexObject),
        ("testArrayAndDictionary", testArrayAndDictionary),
        ("testJsonParserStaticMethods", testJsonParserStaticMethods),
        ("testPrettyPrinting", testPrettyPrinting),
        ("testErrorHandling", testErrorHandling),
        ("testDefaultPropertyWrapper", testDefaultPropertyWrapper),
        ("testJsonKeyVariations", testJsonKeyVariations),
        // New tests
        ("testMemberwiseInitializerBasic", testMemberwiseInitializerBasic),
        ("testMemberwiseInitializerWithDefaults", testMemberwiseInitializerWithDefaults),
        ("testMemberwiseInitializerWithOptionals", testMemberwiseInitializerWithOptionals),
        ("testEmptyArraysAndDictionaries", testEmptyArraysAndDictionaries),
        ("testNilOptionalCollections", testNilOptionalCollections),
        ("testSpecialCharactersAndUnicode", testSpecialCharactersAndUnicode),
        ("testNumericalEdgeCases", testNumericalEdgeCases),
        ("testDeepNestedStructures", testDeepNestedStructures),
        ("testLargeDataStructures", testLargeDataStructures),
        ("testMalformedJSONHandling", testMalformedJSONHandling),
        ("testTypeMismatchHandling", testTypeMismatchHandling),
        ("testMissingRequiredFields", testMissingRequiredFields),
        ("testDefaultValueFallback", testDefaultValueFallback),
        ("testComplexNestedArrays", testComplexNestedArrays),
        ("testBooleanAndNumericDefaults", testBooleanAndNumericDefaults),
        ("testComplexDefaultValues", testComplexDefaultValues),
        ("testPerformanceEncodingDecoding", testPerformanceEncodingDecoding)
    ]
}

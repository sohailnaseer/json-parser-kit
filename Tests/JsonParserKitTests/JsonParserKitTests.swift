import XCTest
import JsonParserKit

final class JsonParserKitTests: XCTestCase {
    
    func testBasicStructParsing() throws {
        @JsonCodable
        struct BasicUser {
            let id: Int
            let name: String
            let email: String
        }
        
        let json = """
        {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
        """
        
        let data = json.data(using: .utf8)!
        let user = try JSONDecoder().decode(BasicUser.self, from: data)
        
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
        
        let encoded = try JSONEncoder().encode(user)
        let decodedAgain = try JSONDecoder().decode(BasicUser.self, from: encoded)
        XCTAssertEqual(decodedAgain.id, user.id)
        XCTAssertEqual(decodedAgain.name, user.name)
        XCTAssertEqual(decodedAgain.email, user.email)
    }
    
    func testOptionalProperties() throws {
        @JsonCodable
        struct UserWithOptionals {
            let id: Int
            let name: String
            var nickname: String?
            var age: Int?
        }
        
        let jsonWithAll = """
        {
            "id": 1,
            "name": "Jane",
            "nickname": "J",
            "age": 25
        }
        """
        
        let jsonWithoutOptionals = """
        {
            "id": 2,
            "name": "Bob"
        }
        """
        
        let data1 = jsonWithAll.data(using: .utf8)!
        let user1 = try JSONDecoder().decode(UserWithOptionals.self, from: data1)
        XCTAssertEqual(user1.nickname, "J")
        XCTAssertEqual(user1.age, 25)
        
        let data2 = jsonWithoutOptionals.data(using: .utf8)!
        let user2 = try JSONDecoder().decode(UserWithOptionals.self, from: data2)
        XCTAssertNil(user2.nickname)
        XCTAssertNil(user2.age)
    }
    
    func testDefaultValues() throws {
        @JsonCodable
        struct ConfigWithDefaults {
            let id: String
            var retryCount: Int = 3
            var timeout: Double = 30.0
            var isEnabled: Bool = true
        }
        
        let jsonPartial = """
        {
            "id": "config-1"
        }
        """
        
        let jsonOverride = """
        {
            "id": "config-2",
            "retryCount": 5,
            "timeout": 60.0,
            "isEnabled": false
        }
        """
        
        let data1 = jsonPartial.data(using: .utf8)!
        let config1 = try JSONDecoder().decode(ConfigWithDefaults.self, from: data1)
        XCTAssertEqual(config1.retryCount, 3)
        XCTAssertEqual(config1.timeout, 30.0)
        XCTAssertEqual(config1.isEnabled, true)
        
        let data2 = jsonOverride.data(using: .utf8)!
        let config2 = try JSONDecoder().decode(ConfigWithDefaults.self, from: data2)
        XCTAssertEqual(config2.retryCount, 5)
        XCTAssertEqual(config2.timeout, 60.0)
        XCTAssertEqual(config2.isEnabled, false)
    }
    
    func testOptionalWithDefaultValue() throws {
        @JsonCodable
        struct OptionalDefaults {
            let id: Int
            var status: String? = "pending"
            var priority: Int? = 5
        }
        
        let jsonWithoutOptionals = """
        {
            "id": 1
        }
        """
        
        let jsonWithNullOptionals = """
        {
            "id": 2,
            "status": null,
            "priority": null
        }
        """
        
        let jsonWithValues = """
        {
            "id": 3,
            "status": "active",
            "priority": 10
        }
        """
        
        let data1 = jsonWithoutOptionals.data(using: .utf8)!
        let obj1 = try JSONDecoder().decode(OptionalDefaults.self, from: data1)
        XCTAssertEqual(obj1.status, "pending")
        XCTAssertEqual(obj1.priority, 5)
        
        let data2 = jsonWithNullOptionals.data(using: .utf8)!
        let obj2 = try JSONDecoder().decode(OptionalDefaults.self, from: data2)
        XCTAssertNil(obj2.status)
        XCTAssertNil(obj2.priority)
        
        let data3 = jsonWithValues.data(using: .utf8)!
        let obj3 = try JSONDecoder().decode(OptionalDefaults.self, from: data3)
        XCTAssertEqual(obj3.status, "active")
        XCTAssertEqual(obj3.priority, 10)
    }
    
    func testJsonKeyMapping() throws {
        @JsonCodable
        struct ApiResponse {
            let id: Int
            @JsonKey("response_code") let responseCode: String
            @JsonKey("created_at") let createdAt: String
            @JsonKey("updated_at") var updatedAt: String?
        }
        
        let json = """
        {
            "id": 100,
            "response_code": "SUCCESS",
            "created_at": "2024-01-01",
            "updated_at": "2024-01-02"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ApiResponse.self, from: data)
        
        XCTAssertEqual(response.id, 100)
        XCTAssertEqual(response.responseCode, "SUCCESS")
        XCTAssertEqual(response.createdAt, "2024-01-01")
        XCTAssertEqual(response.updatedAt, "2024-01-02")
        
        let encoded = try JSONEncoder().encode(response)
        let jsonDict = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertNotNil(jsonDict["response_code"])
        XCTAssertNotNil(jsonDict["created_at"])
        XCTAssertNotNil(jsonDict["updated_at"])
        XCTAssertNil(jsonDict["responseCode"])
        XCTAssertNil(jsonDict["createdAt"])
        XCTAssertNil(jsonDict["updatedAt"])
    }
    
    func testJsonExclude() throws {
        @JsonCodable
        struct DataModel {
            let id: Int
            let name: String
            @JsonExclude var cachedValue: String = "cache"
            @JsonExclude var internalState: Int = 42
        }
        
        let json = """
        {
            "id": 1,
            "name": "Test Model"
        }
        """
        
        let data = json.data(using: .utf8)!
        let model = try JSONDecoder().decode(DataModel.self, from: data)
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.name, "Test Model")
        XCTAssertEqual(model.cachedValue, "cache")
        XCTAssertEqual(model.internalState, 42)
        
        let encoded = try JSONEncoder().encode(model)
        let jsonDict = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertEqual(jsonDict.count, 2)
        XCTAssertNotNil(jsonDict["id"])
        XCTAssertNotNil(jsonDict["name"])
        XCTAssertNil(jsonDict["cachedValue"])
        XCTAssertNil(jsonDict["internalState"])
    }
    
    func testComplexNestedTypes() throws {
        @JsonCodable
        struct NestedData {
            let items: [String]
            let metadata: [String: String]
            let scores: [Int]?
            var tags: Set<String>? = []
        }
        
        let json = """
        {
            "items": ["a", "b", "c"],
            "metadata": {"key1": "value1", "key2": "value2"},
            "scores": [10, 20, 30]
        }
        """
        
        let data = json.data(using: .utf8)!
        let nested = try JSONDecoder().decode(NestedData.self, from: data)
        
        XCTAssertEqual(nested.items, ["a", "b", "c"])
        XCTAssertEqual(nested.metadata["key1"], "value1")
        XCTAssertEqual(nested.scores, [10, 20, 30])
        XCTAssertEqual(nested.tags, [])
    }
    
    func testClassWithJsonParser() throws {
        @JsonCodable
        class Vehicle {
            let id: String
            let brand: String
            @JsonKey("model_name") var modelName: String
            var year: Int = 2024
            @JsonExclude var maintenanceLog: [String] = []
            
            init(id: String, brand: String, modelName: String) {
                self.id = id
                self.brand = brand
                self.modelName = modelName
            }
        }
        
        let json = """
        {
            "id": "V001",
            "brand": "Tesla",
            "model_name": "Model S",
            "year": 2023
        }
        """
        
        let data = json.data(using: .utf8)!
        let vehicle = try JSONDecoder().decode(Vehicle.self, from: data)
        
        XCTAssertEqual(vehicle.id, "V001")
        XCTAssertEqual(vehicle.brand, "Tesla")
        XCTAssertEqual(vehicle.modelName, "Model S")
        XCTAssertEqual(vehicle.year, 2023)
        XCTAssertEqual(vehicle.maintenanceLog, [])
        
        let encoded = try JSONEncoder().encode(vehicle)
        let jsonDict = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertNotNil(jsonDict["model_name"])
        XCTAssertNil(jsonDict["modelName"])
        XCTAssertNil(jsonDict["maintenanceLog"])
    }
    
    func testMixedAttributes() throws {
        @JsonCodable
        struct ComplexModel {
            let id: Int
            @JsonKey("first_name") let firstName: String
            @JsonKey("last_name") var lastName: String?
            var age: Int? = 18
            @JsonKey("is_verified") var isVerified: Bool = false
            @JsonExclude var computedHash: String = "hash"
            var tags: [String]? = ["default"]
        }
        
        let json = """
        {
            "id": 1,
            "first_name": "Alice",
            "last_name": "Smith",
            "is_verified": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let model = try JSONDecoder().decode(ComplexModel.self, from: data)
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.firstName, "Alice")
        XCTAssertEqual(model.lastName, "Smith")
        XCTAssertEqual(model.age, 18)
        XCTAssertEqual(model.isVerified, true)
        XCTAssertEqual(model.computedHash, "hash")
        XCTAssertEqual(model.tags, ["default"])
    }
    
    func testJsonDecodableOnly() throws {
        @JsonDecodable
        struct ReadOnlyData {
            let id: String
            @JsonKey("read_only") let readOnly: Bool
            var value: Int? = 100
        }
        
        let json = """
        {
            "id": "test-id",
            "read_only": true,
            "value": 200
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(ReadOnlyData.self, from: data)
        
        XCTAssertEqual(decoded.id, "test-id")
        XCTAssertEqual(decoded.readOnly, true)
        XCTAssertEqual(decoded.value, 200)
        
        // Verify it only conforms to Decodable, not Encodable
        // This would cause a compile error: try JSONEncoder().encode(decoded)
    }
    
    func testJsonEncodableOnly() throws {
        @JsonEncodable
        struct WriteOnlyData {
            let id: String
            @JsonKey("write_only") let writeOnly: Bool
            var value: Int = 100
            @JsonExclude var excluded: String = "hidden"
        }
        
        // Can't decode into WriteOnlyData since it's not Decodable
        // This would cause a compile error: try JSONDecoder().decode(WriteOnlyData.self, from: data)
        
        // But we can create and encode it
        let writeData = WriteOnlyData(id: "test-id", writeOnly: true)
        let encoded = try JSONEncoder().encode(writeData)
        let jsonDict = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertEqual(jsonDict["id"] as? String, "test-id")
        XCTAssertEqual(jsonDict["write_only"] as? Bool, true)
        XCTAssertEqual(jsonDict["value"] as? Int, 100)
        XCTAssertNil(jsonDict["excluded"])
        XCTAssertNil(jsonDict["writeOnly"])
    }
    
    func testJsonDecodableWithDefaults() throws {
        @JsonDecodable
        struct ConfigData {
            let name: String
            @JsonKey("max_retries") var maxRetries: Int = 3
            var timeout: Double? = 30.0
        }
        
        let minimalJson = """
        {
            "name": "config1"
        }
        """
        
        let fullJson = """
        {
            "name": "config2",
            "max_retries": 5,
            "timeout": 60.0
        }
        """
        
        let data1 = minimalJson.data(using: .utf8)!
        let config1 = try JSONDecoder().decode(ConfigData.self, from: data1)
        XCTAssertEqual(config1.name, "config1")
        XCTAssertEqual(config1.maxRetries, 3)
        XCTAssertEqual(config1.timeout, 30.0)
        
        let data2 = fullJson.data(using: .utf8)!
        let config2 = try JSONDecoder().decode(ConfigData.self, from: data2)
        XCTAssertEqual(config2.name, "config2")
        XCTAssertEqual(config2.maxRetries, 5)
        XCTAssertEqual(config2.timeout, 60.0)
    }
}

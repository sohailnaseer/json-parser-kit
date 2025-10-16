import XCTest
import JsonParserKit

final class JsonParserKitTests: XCTestCase {
    
    func testBasicStructParsing() throws {
        let json = """
        {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "mobile_uuid": "12345789"
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
        let jsonPartial = """
        {
            "id": "config-1"
        }
        """
        
        let jsonOverride = """
        {
            "id": "config-2",
            "retry_count": 5,
            "timeout": 60.0,
            "is_enabled": false
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
        XCTAssertNotNil(obj2.status)
        XCTAssertNotNil(obj2.priority)
        
        let data3 = jsonWithValues.data(using: .utf8)!
        let obj3 = try JSONDecoder().decode(OptionalDefaults.self, from: data3)
        XCTAssertEqual(obj3.status, "active")
        XCTAssertEqual(obj3.priority, 10)
    }
    
    func testJsonKeyMapping() throws {
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
        
        XCTAssertEqual(jsonDict.count, 3)
        XCTAssertNotNil(jsonDict["id"])
        XCTAssertNotNil(jsonDict["name"])
        XCTAssertNotNil(jsonDict["cached_value"])
        XCTAssertNil(jsonDict["internalState"])
    }
    
    func testComplexNestedTypes() throws {
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
    
    func testNestedPartialArrayDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "id": 1,
                    "name": "Valid Item 1"
                },
                {
                    "id": null,
                    "name": "Invalid Item"
                },
                {
                    "id": 3,
                    "name": "Valid Item 2"
                }
            ],
            "total_count": 3
        }
        """
        
        let data = json.data(using: .utf8)!
        let itemList = try JSONDecoder().decode(ItemList.self, from: data)
        
        // Should only get the valid items (first and third)
        XCTAssertEqual(itemList.items.count, 2)
        XCTAssertEqual(itemList.items[0].id, 1)
        XCTAssertEqual(itemList.items[0].name, "Valid Item 1")
        XCTAssertEqual(itemList.items[1].id, 3)
        XCTAssertEqual(itemList.items[1].name, "Valid Item 2")
        XCTAssertEqual(itemList.totalCount, 3)
        
        // Test encoding works normally
        let encoded = try JSONEncoder().encode(itemList)
        let decoded = try JSONDecoder().decode(ItemList.self, from: encoded)
        XCTAssertEqual(decoded.items.count, 2)
        XCTAssertEqual(decoded.totalCount, 3)
    }
    
    func testJsonEncodableOnly() throws {
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
    
    func testSafeArrayDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "id": 1,
                    "name": "Item 1",
                    "value": 10.5,
                    "tags": ["a", "b"]
                },
                {
                    "id": null,
                    "name": "Invalid Item",
                    "value": "not a number",
                    "tags": null
                },
                {
                    "id": 2,
                    "name": "Item 2",
                    "value": 20.5,
                    "tags": ["c", "d"]
                },
                {
                    "invalid": "json"
                }
            ],
            "optional_items": [
                {
                    "id": 3,
                    "name": "Item 3",
                    "value": 30.5,
                    "tags": ["e", "f"]
                },
                {
                    "id": "invalid",
                    "name": 123,
                    "value": null,
                    "tags": [1, 2]
                }
            ],
            "metadata": {
                "version": "1.0"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let itemList = try JSONDecoder().decode(ComplexItemList.self, from: data)
        
        // Check that valid items were decoded
        XCTAssertEqual(itemList.items.count, 2)
        XCTAssertEqual(itemList.items[0].id, 1)
        XCTAssertEqual(itemList.items[0].name, "Item 1")
        XCTAssertEqual(itemList.items[0].value, 10.5)
        XCTAssertEqual(itemList.items[0].tags, ["a", "b"])
        
        XCTAssertEqual(itemList.items[1].id, 2)
        XCTAssertEqual(itemList.items[1].name, "Item 2")
        XCTAssertEqual(itemList.items[1].value, 20.5)
        XCTAssertEqual(itemList.items[1].tags, ["c", "d"])
        
        // Check optional array
        XCTAssertNotNil(itemList.optionalItems)
        XCTAssertEqual(itemList.optionalItems.count, 1)
        XCTAssertEqual(itemList.optionalItems[0].id, 3)
        XCTAssertEqual(itemList.optionalItems[0].name, "Item 3")
        XCTAssertEqual(itemList.optionalItems[0].value, 30.5)
        XCTAssertEqual(itemList.optionalItems[0].tags, ["e", "f"])
        
        // Check metadata was preserved
        XCTAssertEqual(itemList.metadata["version"], "1.0")
        
        // Test encoding works normally
        let encoded = try JSONEncoder().encode(itemList)
        let decoded = try JSONDecoder().decode(ComplexItemList.self, from: encoded)
        XCTAssertEqual(decoded.items.count, 2)
        XCTAssertEqual(decoded.optionalItems.count, 1)
        XCTAssertEqual(decoded.metadata["version"], "1.0")
    }
}

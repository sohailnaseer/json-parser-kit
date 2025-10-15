import Foundation
import JsonParserKit
import JsonParserKitCore

// MARK: - Basic Types

@JsonCodable
struct BasicUser {
    let id: Int
    let name: String
    let email: String
}

@JsonCodable
struct UserWithOptionals {
    let id: Int
    let name: String
    var nickname: String?
    var age: Int?
}

// MARK: - Configuration Types

@JsonCodable
struct ConfigWithDefaults {
    let id: String
    var retryCount: Int = 3
    var timeout: Double = 30.0
    var isEnabled: Bool = true
}

@JsonCodable
struct OptionalDefaults {
    let id: Int
    var status: String? = "pending"
    var priority: Int? = 5
}

@JsonCodable
struct ConfigData {
    let name: String
    @JsonKey("max_retries") var maxRetries: Int = 3
    var timeout: Double? = 30.0
}

// MARK: - API Types

@JsonCodable
struct ApiResponse {
    let id: Int
    @JsonKey("response_code") let responseCode: String
    @JsonKey("created_at") let createdAt: String
    @JsonKey("updated_at") var updatedAt: String?
}

@JsonCodable
struct DataModel {
    let id: Int
    let name: String
    var cachedValue: String = "cache"
    @JsonExclude var internalState: Int = 42
}

// MARK: - Complex Types

@JsonCodable
struct NestedData {
    let items: [String]
    let metadata: [String: String]
    let scores: [Int]?
    var tags: Set<String>? = []
}

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

// MARK: - Partial Conformance Types

@JsonDecodable
struct ReadOnlyData {
    let id: String
    @JsonKey("read_only") let readOnly: Bool
    var value: Int? = 100
}

@JsonEncodable
struct WriteOnlyData {
    let id: String
    @JsonKey("write_only") let writeOnly: Bool
    var value: Int = 100
    @JsonExclude var excluded: String = "hidden"
}

// MARK: - Array Test Types

@JsonDecodable
struct User {
    let id: Int
    let name: String
    let email: String
}

@JsonCodable
struct Item {
    let id: Int
    let name: String
}

@JsonCodable
struct ItemList {
    var items: [Item]
    let totalCount: Int
}

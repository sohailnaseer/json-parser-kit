import Foundation

// MARK: - Macro Declarations

/// A macro that generates Codable conformance for structs and classes with custom JSON handling
@attached(member, names: named(init(from:)), named(encode(to:)), named(CodingKeys), arbitrary)
@attached(extension, conformances: Codable)
public macro JsonCodable() = #externalMacro(module: "JsonParserKitMacros", type: "JsonCodableMacro")

/// A macro that specifies a custom JSON key and/or default value for a property
/// - Parameters:
///   - key: Custom JSON key name (optional, defaults to property name)
///   - defaultValue: Default value to use when JSON field is missing (optional)
@attached(peer)
public macro JsonKey(_ key: String? = nil, defaultValue: Any? = nil) = #externalMacro(module: "JsonParserKitMacros", type: "JsonKeyMacro")
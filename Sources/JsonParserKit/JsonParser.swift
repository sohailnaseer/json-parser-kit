import Foundation

@attached(member, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
@attached(extension, conformances: Codable)
public macro JsonCodable() = #externalMacro(module: "JsonParserKitMacros", type: "JsonCodableMacro")

@attached(member, names: named(CodingKeys), named(init(from:)))
@attached(extension, conformances: Decodable)
public macro JsonDecodable() = #externalMacro(module: "JsonParserKitMacros", type: "JsonDecodableMacro")

@attached(member, names: named(CodingKeys), named(encode(to:)))
@attached(extension, conformances: Encodable)
public macro JsonEncodable() = #externalMacro(module: "JsonParserKitMacros", type: "JsonEncodableMacro")

@attached(peer)
public macro JsonKey(_ key: String) = #externalMacro(module: "JsonParserKitMacros", type: "JsonKeyMacro")

@attached(peer)
public macro JsonExclude() = #externalMacro(module: "JsonParserKitMacros", type: "JsonExcludeMacro")

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct JsonCodableMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroExpansionError.message("@JsonCodable can only be applied to structs")
        }
        
        let properties = extractProperties(from: structDecl)
        let codingKeys = generateCodingKeys(for: properties)
        let memberwiseInit = generateMemberwiseInit(for: properties)
        let initMethod = generateInitFromDecoder(for: properties)
        let encodeMethod = generateEncodeToEncoder(for: properties)
        
        return [
            codingKeys,
            memberwiseInit,
            initMethod,
            encodeMethod
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let codableExtension = try ExtensionDeclSyntax("extension \(type): Codable {}")
        return [codableExtension]
    }
    
    // MARK: - Helper Methods
    
    private static func extractProperties(from structDecl: StructDeclSyntax) -> [PropertyInfo] {
        var properties: [PropertyInfo] = []
        
        for member in structDecl.memberBlock.members {
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            
            for binding in variableDecl.bindings {
                if let propertyInfo = createPropertyInfo(from: binding, with: variableDecl.attributes) {
                    properties.append(propertyInfo)
                }
            }
        }
        
        return properties
    }
    
    private static func createPropertyInfo(from binding: PatternBindingSyntax, with attributes: AttributeListSyntax) -> PropertyInfo? {
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            return nil
        }
        
        let propertyName = identifier.identifier.text
        let type = binding.typeAnnotation?.type.trimmed.description ?? "Unknown"
        let isOptional = type.hasSuffix("?")
        
        // Extract custom JSON key and default value from @JsonKey attribute
        let (customKey, defaultValue) = extractJsonKeyAndDefault(from: attributes)
        
        return PropertyInfo(
            name: propertyName,
            type: type,
            jsonKey: customKey ?? propertyName,
            defaultValue: defaultValue,
            isOptional: isOptional
        )
    }
    
    private static func extractJsonKeyAndDefault(from attributes: AttributeListSyntax) -> (String?, String?) {
        for attribute in attributes {
            guard let attributeSyntax = attribute.as(AttributeSyntax.self) else {
                continue
            }
            
            guard let attributeName = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
                continue
            }
            
            guard attributeName == "JsonKey" else {
                continue
            }
            
            guard let arguments = attributeSyntax.arguments?.as(LabeledExprListSyntax.self) else {
                continue
            }
            
            var customKey: String?
            var defaultValue: String?
            
            for argument in arguments {
                processJsonKeyArgument(argument, customKey: &customKey, defaultValue: &defaultValue)
            }
            
            return (customKey, defaultValue)
        }
        return (nil, nil)
    }
    
    private static func extractStringFromLiteral(_ stringLiteral: StringLiteralExprSyntax) -> String? {
        return stringLiteral.segments.first?.as(StringSegmentSyntax.self)?.content.text
    }
    
    private static func processJsonKeyArgument(_ argument: LabeledExprSyntax, customKey: inout String?, defaultValue: inout String?) {
        if argument.label == nil { // First positional argument is the key
            if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                customKey = extractStringFromLiteral(stringLiteral)
            }
        } else if argument.label?.text == "defaultValue" {
            defaultValue = argument.expression.trimmed.description
        }
    }
    
    private static func generateCodingKeys(for properties: [PropertyInfo]) -> DeclSyntax {
        let cases = properties.map { property in
            property.jsonKey != property.name 
                ? "case \(property.name) = \"\(property.jsonKey)\""
                : "case \(property.name)"
        }.joined(separator: "\n        ")
        
        return DeclSyntax(stringLiteral: """
        enum CodingKeys: String, CodingKey {
            \(cases)
        }
        """)
    }
    
    private static func generateMemberwiseInit(for properties: [PropertyInfo]) -> DeclSyntax {
        let parameters = properties.map { property in
            generateInitParameter(for: property)
        }.joined(separator: ", ")
        
        let assignments = properties.map { property in
            "self.\(property.name) = \(property.name)"
        }.joined(separator: "\n        ")
        
        return DeclSyntax(stringLiteral: """
        public init(\(parameters)) {
            \(assignments)
        }
        """)
    }
    
    private static func generateInitParameter(for property: PropertyInfo) -> String {
        if let defaultValue = property.defaultValue {
            // If there's a default value, make the parameter optional with the default
            return "\(property.name): \(property.type) = \(defaultValue)"
        } else {
            // Otherwise, use the property type as-is
            return "\(property.name): \(property.type)"
        }
    }
    
    private static func generateInitFromDecoder(for properties: [PropertyInfo]) -> DeclSyntax {
        let decodingStatements = properties.map { property in
            generateDecodingStatement(for: property)
        }.joined(separator: "\n        ")
        
        return DeclSyntax(stringLiteral: """
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            \(decodingStatements)
        }
        """)
    }
    
    private static func generateDecodingStatement(for property: PropertyInfo) -> String {
        if let defaultValue = property.defaultValue {
            return generateDecodingWithDefault(for: property, defaultValue: defaultValue)
        } else if property.isOptional {
            let baseType = property.type.replacingOccurrences(of: "?", with: "")
            return "self.\(property.name) = try container.decodeIfPresent(\(baseType).self, forKey: .\(property.name))"
        } else {
            return "self.\(property.name) = try container.decode(\(property.type).self, forKey: .\(property.name))"
        }
    }
    
    private static func generateDecodingWithDefault(for property: PropertyInfo, defaultValue: String) -> String {
        if property.isOptional {
            // For optional properties with default values, use decodeIfPresent and provide default
            let baseType = property.type.replacingOccurrences(of: "?", with: "")
            return "self.\(property.name) = try container.decodeIfPresent(\(baseType).self, forKey: .\(property.name)) ?? \(defaultValue)"
        } else {
            // For non-optional properties with default values, try decode first, fallback to default
            return "self.\(property.name) = (try? container.decode(\(property.type).self, forKey: .\(property.name))) ?? \(defaultValue)"
        }
    }
    
    private static func generateEncodeToEncoder(for properties: [PropertyInfo]) -> DeclSyntax {
        let encodingStatements = properties.map { property in
            generateEncodingStatement(for: property)
        }.joined(separator: "\n        ")
        
        return DeclSyntax(stringLiteral: """
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(encodingStatements)
        }
        """)
    }
    
    private static func generateEncodingStatement(for property: PropertyInfo) -> String {
        if property.isOptional {
            return "try container.encodeIfPresent(self.\(property.name), forKey: .\(property.name))"
        } else {
            return "try container.encode(self.\(property.name), forKey: .\(property.name))"
        }
    }
}

// MARK: - Supporting Types

struct PropertyInfo {
    let name: String
    let type: String
    let jsonKey: String
    let defaultValue: String?
    let isOptional: Bool
}

enum MacroExpansionError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

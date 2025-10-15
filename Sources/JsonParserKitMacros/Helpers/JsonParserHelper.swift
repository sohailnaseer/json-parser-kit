import SwiftSyntax
import JsonParserKitCore
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A helper class that handles the generation of Codable-related implementations
final class JsonParserHelper {
    
    /// The original declaration being processed
    private let declaration: DeclGroupSyntax
    
    /// The extracted properties from the declaration
    private let properties: [PropertyInfo]
    
    /// The key conversion strategy to use
    private let keyStrategy: JsonKeyStrategy
    
    /// Initialize the helper with a declaration and key strategy
    /// - Parameters:
    ///   - declaration: The declaration to process
    ///   - keyStrategy: The strategy for converting property names to JSON keys
    init(declaration: DeclGroupSyntax, keyStrategy: JsonKeyStrategy) {
        self.declaration = declaration
        self.keyStrategy = keyStrategy
        self.properties = Self.extractProperties(from: declaration)
    }
    
    /// Convert a property name to its JSON key name based on the strategy
    /// - Parameter propertyName: The original property name
    /// - Returns: The converted key name
    private func convertToJsonKey(_ propertyName: String) -> String {
        switch keyStrategy {
        case .snakeCase:
            return StringCaseConverter.toSnakeCase(propertyName)
        case .original:
            return propertyName
        }
    }
    
    /// Whether the declaration has any properties to process
    var hasProperties: Bool {
        !properties.isEmpty
    }
    
    /// Generate the CodingKeys enum for the properties
    /// - Returns: The generated CodingKeys enum declaration
    func generateCodingKeys() -> DeclSyntax {
        let casesString = properties.map { property in
            let jsonKey = property.jsonKey ?? convertToJsonKey(property.name)
            return jsonKey == property.name
                ? "        case \(property.name)"
                : "        case \(property.name) = \"\(jsonKey)\""
        }.joined(separator: "\n")
        
        return """
        enum CodingKeys: String, CodingKey {
        \(raw: casesString)
        }
        """
    }
    
    /// Generate the Decodable initializer
    /// - Returns: The generated init(from:) implementation
    func generateInitFromDecoder() -> DeclSyntax {
        let decodingStatements = properties
            .map(generateDecodingStatement)
            .joined(separator: "\n")
        
        let isClass = declaration.is(ClassDeclSyntax.self)
        let requiredKeyword = isClass ? "required " : ""
        
        return """
        \(raw: requiredKeyword)public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
        \(raw: decodingStatements)
        }
        """
    }
    
    /// Generate the Encodable encode(to:) method
    /// - Returns: The generated encode(to:) implementation
    func generateEncode() -> DeclSyntax {
        let encodingStatements = properties.map { property in
            property.isOptional
                ? "try container.encodeIfPresent(\(property.name), forKey: .\(property.name))"
                : "try container.encode(\(property.name), forKey: .\(property.name))"
        }.joined(separator: "\n")
        
        return """
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
        \(raw: encodingStatements)
        }
        """
    }
    
    /// Generate a decoding statement for a single property
    /// - Parameter property: The property to generate decoding for
    /// - Returns: The generated decoding statement
    private func generateDecodingStatement(for property: PropertyInfo) -> String {
        let propertyName = property.name
        let unwrappedType = property.unwrappedType
        let defaultExpr = property.defaultValueExpr
        let keyPath = ".\(propertyName)"
        let isOnlyArray = property.isArray && !property.isDictionary
        let methodName = isOnlyArray ? "decodeSafe" : "decode"
        let methodNameOptional = isOnlyArray ? "decodeSafeIfPresent" : "decodeIfPresent"
        
        if property.hasDefaultValue, let defaultExpr {
            return "self.\(propertyName) = (try? container.\(methodNameOptional)(\(unwrappedType).self, forKey: \(keyPath))) ?? \(defaultExpr)"
        } else if property.isOptional {
            return "self.\(propertyName) = try? container.\(methodNameOptional)(\(unwrappedType).self, forKey: \(keyPath))"
        } else {
            return "self.\(propertyName) = try container.\(methodName)(\(unwrappedType).self, forKey: \(keyPath))"
        }
    }
    
    /// Extract stored properties from a declaration
    /// - Parameter declaration: The declaration to process
    /// - Returns: Array of PropertyInfo for each valid property
    private static func extractProperties(from declaration: DeclGroupSyntax) -> [PropertyInfo] {
        var properties = [PropertyInfo]()
        
        for member in declaration.memberBlock.members {
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self),
                  !variableDecl.isStatic,
                  variableDecl.isStoredProperty
            else {
                continue
            }
            
            for binding in variableDecl.bindings {
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    continue
                }
                
                let propertyName = identifier.identifier.text
                let propertyType = binding.typeAnnotation?.type
                let defaultValue = binding.initializer?.value
                let attributes = variableDecl.attributes
                
                guard !attributes.hasJsonExclude else {
                    continue
                }
                
                let propertyInfo = PropertyInfo(
                    name: propertyName,
                    type: propertyType,
                    jsonKey: attributes.jsonKeyValue,
                    hasDefaultValue: defaultValue != nil,
                    defaultValueExpr: defaultValue
                )
                
                properties.append(propertyInfo)
            }
        }
        
        return properties
    }
}

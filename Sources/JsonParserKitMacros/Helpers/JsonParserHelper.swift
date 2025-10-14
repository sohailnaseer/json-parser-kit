import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A helper class that handles the generation of Codable-related implementations
final class JsonParserHelper {
    
    /// The original declaration being processed
    private let declaration: DeclGroupSyntax
    
    /// The extracted properties from the declaration
    private let properties: [PropertyInfo]
    
    /// Initialize the helper with a declaration
    /// - Parameter declaration: The declaration to process
    init(declaration: DeclGroupSyntax) {
        self.declaration = declaration
        self.properties = Self.extractProperties(from: declaration)
    }
    
    /// Whether the declaration has any properties to process
    var hasProperties: Bool {
        !properties.isEmpty
    }
    
    /// Generate the CodingKeys enum for the properties
    /// - Returns: The generated CodingKeys enum declaration
    func generateCodingKeys() -> DeclSyntax {
        let casesString = properties.map { property in
            let jsonKey = property.jsonKey ?? property.name
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
        
        return """
        public init(from decoder: Decoder) throws {
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
                ? "        try container.encodeIfPresent(\(property.name), forKey: .\(property.name))"
                : "        try container.encode(\(property.name), forKey: .\(property.name))"
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
        let keyPath = ".\(propertyName)"
        
        switch (property.isOptional, property.hasDefaultValue, property.defaultValueExpr) {
        case (true, true, .some(let defaultExpr)):
            return "        self.\(propertyName) = (try? container.decodeIfPresent(\(unwrappedType).self, forKey: \(keyPath))) ?? \(defaultExpr)"
            
        case (true, false, _):
            return "        self.\(propertyName) = try? container.decodeIfPresent(\(unwrappedType).self, forKey: \(keyPath))"
            
        case (false, true, .some(let defaultExpr)):
            return "        self.\(propertyName) = (try? container.decodeIfPresent(\(unwrappedType).self, forKey: \(keyPath))) ?? \(defaultExpr)"
            
        case (false, false, _):
            return "        self.\(propertyName) = try container.decode(\(unwrappedType).self, forKey: \(keyPath))"
            
        default:
            return "        self.\(propertyName) = try container.decode(\(unwrappedType).self, forKey: \(keyPath))"
        }
    }
    
    /// Extract stored properties from a declaration
    /// - Parameter declaration: The declaration to process
    /// - Returns: Array of PropertyInfo for each valid property
    private static func extractProperties(from declaration: DeclGroupSyntax) -> [PropertyInfo] {
        declaration.memberBlock.members.compactMap { member in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self),
                  !variableDecl.isStatic,
                  variableDecl.isStoredProperty else {
                return nil
            }
            
            return variableDecl.bindings.compactMap { binding in
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    return nil
                }
                
                let propertyName = identifier.identifier.text
                let propertyType = binding.typeAnnotation?.type
                let defaultValue = binding.initializer?.value
                let attributes = variableDecl.attributes
                
                guard !attributes.hasJsonExclude else {
                    return nil
                }
                
                return PropertyInfo(
                    name: propertyName,
                    type: propertyType,
                    jsonKey: attributes.jsonKeyValue,
                    hasDefaultValue: defaultValue != nil,
                    defaultValueExpr: defaultValue
                )
            }
        }.flatMap { $0 }
    }
}

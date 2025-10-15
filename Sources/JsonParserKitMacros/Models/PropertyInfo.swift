import SwiftSyntax
import Foundation

/// A model representing a property in a type declaration that can be encoded/decoded
struct PropertyInfo {
    /// The name of the property as declared in the type
    let name: String
    
    /// The Swift type of the property
    let type: TypeSyntax?
    
    /// The custom JSON key name if specified via @JsonKey, otherwise nil
    let jsonKey: String?
    
    /// Whether the property has a default value
    let hasDefaultValue: Bool
    
    /// The default value expression if any
    let defaultValueExpr: ExprSyntax?
    
    /// Whether the property type is optional
    var isOptional: Bool {
        guard let type = type else { return false }
        let typeDescription = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return typeDescription.hasSuffix("?") || typeDescription.hasPrefix("Optional<")
    }
    
    /// The unwrapped type name without Optional wrapper
    var unwrappedType: String {
        guard let type else { return "Any" }
        
        let typeString = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if typeString.hasSuffix("?") {
            return String(typeString.dropLast())
        }
        
        if typeString.hasPrefix("Optional<"), typeString.hasSuffix(">") {
            let startIndex = typeString.index(typeString.startIndex, offsetBy: 9)
            let endIndex = typeString.index(typeString.endIndex, offsetBy: -1)
            return String(typeString[startIndex..<endIndex])
        }
        
        return typeString
    }
    
    /// Whether the property type is an array
    var isArray: Bool {
        guard let type = type else { 
            return false 
        }

        let typeString = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let isShortArraySyntax = typeString.hasPrefix("[") && (typeString.hasSuffix("]") || typeString.hasSuffix("]?"))
        let isArraySyntax = typeString.hasPrefix("Array<") && (typeString.hasSuffix(">") || typeString.hasSuffix(">?"))

        return isShortArraySyntax || isArraySyntax
    }

    var isDictionary: Bool {
        guard let type = type else { 
            return false 
        }

        let typeString = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let isShortDictionarySyntax = typeString.contains(":") && typeString.hasPrefix("[") && (typeString.hasSuffix("]") || typeString.hasSuffix("]?"))
        let isDictionarySyntax = typeString.hasPrefix("Dictionary<") && (typeString.hasSuffix(">") || typeString.hasSuffix(">?"))

        return isShortDictionarySyntax || isDictionarySyntax
    }
}

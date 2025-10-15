import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import JsonParserKitCore

/// A macro that adds Codable conformance to a type
public struct JsonCodableMacro: MemberMacro, ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let strategy = extractStrategy(from: node)
        let helper = JsonParserHelper(declaration: declaration, keyStrategy: strategy)
        
        guard helper.hasProperties else {
            return []
        }
        
        return [
            helper.generateCodingKeys(),
            helper.generateInitFromDecoder(),
            helper.generateEncode()
        ]
    }
    
    private static func extractStrategy(from node: AttributeSyntax) -> JsonKeyStrategy {
        guard let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression,
              let memberAccess = argument.as(MemberAccessExprSyntax.self) 
        else {
            return .snakeCase
        }

        return memberAccess.declName.baseName.text == "snakeCase" ? .snakeCase : .original
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [try ExtensionDeclSyntax("extension \(type.trimmed): Codable {}")]
    }
}

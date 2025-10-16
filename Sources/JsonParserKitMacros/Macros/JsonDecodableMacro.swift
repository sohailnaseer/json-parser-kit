import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import JsonParserKitCore

/// A macro that adds Decodable conformance to a type
public struct JsonDecodableMacro: MemberMacro, ExtensionMacro {
    
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
            helper.generateInitFromDecoder()
        ]
    }
    
    private static func extractStrategy(from node: AttributeSyntax) -> JsonKeyStrategy {
        guard let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression,
              let memberAccess = argument.as(MemberAccessExprSyntax.self) 
        else {
            return .original
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
        let alreadyConforms = protocols.contains { proto in
            guard let id = proto.as(IdentifierTypeSyntax.self) else {
                return false
            }

            return id.name.text == "Decodable"
        }

        return alreadyConforms ? [] : [try ExtensionDeclSyntax("extension \(type.trimmed): Decodable {}")]
    }
}

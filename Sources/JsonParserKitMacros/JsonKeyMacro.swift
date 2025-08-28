import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct JsonKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro is purely for annotation purposes
        // The actual logic is handled in JsonCodableMacro
        return []
    }
}
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct JsonParserKitMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonCodableMacro.self,
        JsonKeyMacro.self
    ]
}
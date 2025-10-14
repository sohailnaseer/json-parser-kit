import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// The main plugin that registers all JSON parsing macros
@main
struct JsonParserKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonCodableMacro.self,
        JsonDecodableMacro.self,
        JsonEncodableMacro.self,
        JsonKeyMacro.self,
        JsonExcludeMacro.self
    ]
}

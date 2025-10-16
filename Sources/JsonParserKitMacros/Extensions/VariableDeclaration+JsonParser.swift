import SwiftSyntax

extension VariableDeclSyntax {
    var isStatic: Bool {
        modifiers.contains { $0.name.text == "static" }
    }
    
    var isStoredProperty: Bool {
        // Only treat as stored property if it's a 'let' or 'var', and no accessor block (computed property)
        (bindingSpecifier.text == "let" || bindingSpecifier.text == "var")
            && bindings.allSatisfy { $0.accessorBlock == nil }
    }
}

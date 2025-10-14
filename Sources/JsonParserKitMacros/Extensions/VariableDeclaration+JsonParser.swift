import SwiftSyntax

extension VariableDeclSyntax {
    var isStatic: Bool {
        modifiers.contains { $0.name.text == "static" }
    }
    
    var isStoredProperty: Bool {
        bindingSpecifier.text == "let" || bindingSpecifier.text == "var"
    }
}

import SwiftSyntax

extension AttributeListSyntax {
    var jsonKeyValue: String? {
        for attribute in self {
            guard let attr = attribute.as(AttributeSyntax.self),
                  attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "JsonKey",
                  let arguments = attr.arguments?.as(LabeledExprListSyntax.self),
                  let firstArgument = arguments.first?.expression,
                  let stringLiteral = firstArgument.as(StringLiteralExprSyntax.self),
                  let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
            else {
                continue
            }
            
            return segment.content.text
        }
        return nil
    }
    
    var hasJsonExclude: Bool {
        contains { attribute in
            guard let attr = attribute.as(AttributeSyntax.self) else {
                return false
            }
            
            return attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "JsonExclude"
        }
    }
}

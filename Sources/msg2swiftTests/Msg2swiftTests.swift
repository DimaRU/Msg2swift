/////
////  Msg2swiftTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import msg2swift

class Msg2swiftTests: XCTestCase {
    
    let messageText = """
int32[] unbounded_integer_array          # comment
int32[5] five_integers_array
   int32[<=5] up_to_five_integers_array  # comment
string string_of_unbounded_size
string<=10 up_to_ten_characters_string
string[<=5] up_to_five_unbounded_strings
string<=10[] unbounded_array_of_strings_up_to_ten_characters_each
string<=10[<=5] up_to_five_strings_up_to_ten_characters_each
uint8 x 42
int16 y -2000
string full_name "John Doe"
int32[] samples [-200, -100, 0, 100, 200]#comment
int32 X=123
int32 Y = -123
string FOO  =   "foo"
string EXAMPLE='bar'
"""

    func testGenerator() throws {
        let generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .class,
                                       declarationSuffix: .codable,
                                       snakeCase: true)
            
        let parsed = try generator.parseMessageText(messageText)
        let preparsed: [SwiftGenerator.Parsedline] = [
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "int32", arrayCount: Optional(0), name: "unbounded_integer_array", defaultValue: ""), trailingSpace: "          ", comment: "# comment"),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "int32", arrayCount: Optional(5), name: "five_integers_array", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "   ", definition: SwiftGenerator.DefinitionType.field(type: "int32", arrayCount: Optional(0), name: "up_to_five_integers_array", defaultValue: ""), trailingSpace: "  ", comment: "# comment"),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: nil, name: "string_of_unbounded_size", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: nil, name: "up_to_ten_characters_string", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: Optional(0), name: "up_to_five_unbounded_strings", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: Optional(0), name: "unbounded_array_of_strings_up_to_ten_characters_each", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: Optional(0), name: "up_to_five_strings_up_to_ten_characters_each", defaultValue: ""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "uint8", arrayCount: nil, name: "x", defaultValue: "42"), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "int16", arrayCount: nil, name: "y", defaultValue: "-2000"), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "string", arrayCount: nil, name: "full_name", defaultValue: "\"John Doe\""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.field(type: "int32", arrayCount: Optional(0), name: "samples", defaultValue: "[-200, -100, 0, 100, 200]"), trailingSpace: "", comment: "#comment"),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.constant(type: "int32", name: "X", value: "123"), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.constant(type: "int32", name: "Y", value: "-123"), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.constant(type: "string", name: "FOO", value: "\"foo\""), trailingSpace: "", comment: ""),
            SwiftGenerator.Parsedline(leadingSpace: "", definition: SwiftGenerator.DefinitionType.constant(type: "string", name: "EXAMPLE", value: "\'bar\'"), trailingSpace: "", comment: ""),
        ]
        XCTAssertEqual(parsed, preparsed)
    }
}

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
    let messageTextEnum = """
# Power supply status constants
uint8 POWER_SUPPLY_STATUS_UNKNOWN = 0
uint8 POWER_SUPPLY_STATUS_CHARGING = 1
uint8 POWER_SUPPLY_STATUS_DISCHARGING = 2
uint8 POWER_SUPPLY_STATUS_NOT_CHARGING = 3
uint8 POWER_SUPPLY_STATUS_FULL = 4

# Power supply health constants
uint8 POWER_SUPPLY_HEALTH_UNKNOWN = 0
uint8 POWER_SUPPLY_HEALTH_GOOD = 1
uint8 POWER_SUPPLY_HEALTH_OVERHEAT = 2
uint8 POWER_SUPPLY_HEALTH_DEAD = 3
uint8 POWER_SUPPLY_HEALTH_OVERVOLTAGE = 4
uint8 POWER_SUPPLY_HEALTH_UNSPEC_FAILURE = 5
uint8 POWER_SUPPLY_HEALTH_COLD = 6
uint8 POWER_SUPPLY_HEALTH_WATCHDOG_TIMER_EXPIRE = 7
uint8 POWER_SUPPLY_HEALTH_SAFETY_TIMER_EXPIRE = 8

# Power supply technology (chemistry) constants
uint8 POWER_SUPPLY_TECHNOLOGY_UNKNOWN = 0
uint8 POWER_SUPPLY_TECHNOLOGY_NIMH = 1
uint8 POWER_SUPPLY_TECHNOLOGY_LION = 2
uint8 POWER_SUPPLY_TECHNOLOGY_LIPO = 3
uint8 POWER_SUPPLY_TECHNOLOGY_LIFE = 4
uint8 POWER_SUPPLY_TECHNOLOGY_NICD = 5
uint8 POWER_SUPPLY_TECHNOLOGY_LIMN = 6
uint8 SOME_CONST = 6
uint8 field
"""
    
    
    func testGenerator() throws {
        let generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .class,
                                       declarationProtocol: .codable,
                                       snakeCase: true,
                                       compact: false,
                                       detectEnum: true)
        
        let parsed = try generator.parseMessageText(messageText)
        let preparsed: [SwiftGenerator.Parsedline] = [
            .init(leading: "", definition: .field(type: "int32", name: "unbounded_integer_array", arrayCount: Optional(0), defaultValue: ""), trailing: "          ", comment: "# comment"),
            .init(leading: "", definition: .field(type: "int32", name: "five_integers_array", arrayCount: Optional(5), defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "   ", definition: .field(type: "int32", name: "up_to_five_integers_array", arrayCount: Optional(0), defaultValue: ""), trailing: "  ", comment: "# comment"),
            .init(leading: "", definition: .field(type: "string", name: "string_of_unbounded_size", arrayCount: nil, defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "string", name: "up_to_ten_characters_string", arrayCount: nil, defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "string", name: "up_to_five_unbounded_strings", arrayCount: Optional(0), defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "string", name: "unbounded_array_of_strings_up_to_ten_characters_each", arrayCount: Optional(0), defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "string", name: "up_to_five_strings_up_to_ten_characters_each", arrayCount: Optional(0), defaultValue: ""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "uint8", name: "x", arrayCount: nil, defaultValue: "42"), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "int16", name: "y", arrayCount: nil, defaultValue: "-2000"), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "string", name: "full_name", arrayCount: nil, defaultValue: "\"John Doe\""), trailing: "", comment: ""),
            .init(leading: "", definition: .field(type: "int32", name: "samples", arrayCount: Optional(0), defaultValue: "[-200, -100, 0, 100, 200]"), trailing: "", comment: "#comment"),
            .init(leading: "", definition: .constant(type: "int32", name: "X", value: "123"), trailing: "", comment: ""),
            .init(leading: "", definition: .constant(type: "int32", name: "Y", value: "-123"), trailing: "", comment: ""),
            .init(leading: "", definition: .constant(type: "string", name: "FOO", value: "\"foo\""), trailing: "", comment: ""),
            .init(leading: "", definition: .constant(type: "string", name: "EXAMPLE", value: "\'bar\'"), trailing: "", comment: ""),
        ]
        XCTAssertEqual(parsed, preparsed)
    }
    
    func testMarkEnum() throws {
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .class,
                                       declarationProtocol: .codable,
                                       snakeCase: true,
                                       compact: false,
                                       detectEnum: true)
        
        generator.parsed = try generator.parseMessageText(messageTextEnum)
        generator.markEnums()
        let preparsed: [SwiftGenerator.Parsedline] = [
            .init(leading: "", definition: .empty, trailing: "", comment: "# Power supply status constants", type: "", name: ""),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_STATUS", value: "0"), trailing: "", comment: "", type: "uint8", name: "UNKNOWN"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_STATUS", value: "1"), trailing: "", comment: "", type: "uint8", name: "CHARGING"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_STATUS", value: "2"), trailing: "", comment: "", type: "uint8", name: "DISCHARGING"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_STATUS", value: "3"), trailing: "", comment: "", type: "uint8", name: "NOT_CHARGING"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_STATUS", value: "4"), trailing: "", comment: "", type: "uint8", name: "FULL"),
            .init(leading: "", definition: .empty, trailing: "", comment: "# Power supply health constants", type: "", name: ""),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "0"), trailing: "", comment: "", type: "uint8", name: "UNKNOWN"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "1"), trailing: "", comment: "", type: "uint8", name: "GOOD"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "2"), trailing: "", comment: "", type: "uint8", name: "OVERHEAT"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "3"), trailing: "", comment: "", type: "uint8", name: "DEAD"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "4"), trailing: "", comment: "", type: "uint8", name: "OVERVOLTAGE"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "5"), trailing: "", comment: "", type: "uint8", name: "UNSPEC_FAILURE"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "6"), trailing: "", comment: "", type: "uint8", name: "COLD"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "7"), trailing: "", comment: "", type: "uint8", name: "WATCHDOG_TIMER_EXPIRE"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_HEALTH", value: "8"), trailing: "", comment: "", type: "uint8", name: "SAFETY_TIMER_EXPIRE"),
            .init(leading: "", definition: .empty, trailing: "", comment: "# Power supply technology (chemistry) constants", type: "", name: ""),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "0"), trailing: "", comment: "", type: "uint8", name: "UNKNOWN"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "1"), trailing: "", comment: "", type: "uint8", name: "NIMH"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "2"), trailing: "", comment: "", type: "uint8", name: "LION"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "3"), trailing: "", comment: "", type: "uint8", name: "LIPO"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "4"), trailing: "", comment: "", type: "uint8", name: "LIFE"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "5"), trailing: "", comment: "", type: "uint8", name: "NICD"),
            .init(leading: "", definition: .enumcase(type: "uint8", enum: "POWER_SUPPLY_TECHNOLOGY", value: "6"), trailing: "", comment: "", type: "uint8", name: "LIMN"),
            .init(leading: "", definition: .constant(type: "uint8", name: "SOME_CONST", value: "6"), trailing: "", comment: "", type: "uint8", name: "SOME_CONST"),
            .init(leading: "", definition: .field(type: "uint8", name: "field", arrayCount: nil, defaultValue: ""), trailing: "", comment: "", type: "uint8", name: "field"),
        ]
        XCTAssertEqual(generator.parsed, preparsed)
    }
    
    func testParams() throws {
        let message = """
# Comment
float32 field_test # comment2
"""
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .struct,
                                       declarationProtocol: .codable,
                                       snakeCase: true,
                                       compact: false,
                                       detectEnum: true)
        var code = try generator.processFile(name: "TestModel", messageText: message).joined(separator: "\n")
        XCTAssertEqual(code, """
struct TestModel: Codable {
    // Comment
    let fieldTest: Float // comment2
}
""")
        
        generator = SwiftGenerator(propertyDeclaration: .var,
                                   objectDeclaration: .class,
                                   declarationProtocol: .encodable,
                                   snakeCase: true,
                                   compact: true,
                                   detectEnum: true)
        code = try generator.processFile(name: "TestModel", messageText: message).joined(separator: "\n")
        XCTAssertEqual(code, """
class TestModel: Encodable {
    var fieldTest: Float
}
""")
        
        generator = SwiftGenerator(propertyDeclaration: .var,
                                   objectDeclaration: .class,
                                   declarationProtocol: .decodable,
                                   snakeCase: true,
                                   compact: true,
                                   detectEnum: true)
        code = try generator.processFile(name: "TestModel", messageText: message).joined(separator: "\n")
        XCTAssertEqual(code, """
class TestModel: Decodable {
    var fieldTest: Float
}
""")
        
        generator = SwiftGenerator(propertyDeclaration: .let,
                                   objectDeclaration: .class,
                                   declarationProtocol: .codable,
                                   snakeCase: false,
                                   compact: true,
                                   detectEnum: true)
        code = try generator.processFile(name: "TestModel", messageText: message).joined(separator: "\n")
        XCTAssertEqual(code, """
class TestModel: Codable {
    let field_test: Float
}
""")
        
    }
    
    func testErrorMessage() {
        let messageText = """
# Comment
uint8 POWER_SUPPLY_TECHNOLOGY_LIMN =
"""
        
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .class,
                                       declarationProtocol: .codable,
                                       snakeCase: false,
                                       compact: true,
                                       detectEnum: true)
        XCTAssertThrowsError(try generator.processFile(name: "BadFile", messageText: messageText), "Must be error message at line 2") { error in
            guard let error = error as? SwiftGeneratorError else {
                XCTFail("Error is't SwiftGeneratorError type")
                return
            }
            XCTAssertEqual(error.message, "Empty constant expression value at line 2")
        }
    }
    
    func testQouted() throws {
        let messageText = """
# Comment
uint8 self
"""
        
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .struct,
                                       declarationProtocol: .codable,
                                       snakeCase: false,
                                       compact: true,
                                       detectEnum: true)
        
        let code = try generator.processFile(name: "TestModel", messageText: messageText).joined(separator: "\n")
        XCTAssertEqual(code, """
struct TestModel: Codable {
    let `self`: UInt8
}
""")
    }
}

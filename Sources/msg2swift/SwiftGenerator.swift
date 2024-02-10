/////
////  SwiftGenerator.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import Algorithms

fileprivate let SwiftBuiltins: [String: String] = [
    "bool"    : "Bool",
    "byte"    : "UInt8",
    "char"    : "Int8",
    "int8"    : "Int8",
    "UInt8"   : "UInt8",
    "int16"   : "Int16",
    "UInt16"  : "UInt16",
    "int32"   : "Int32",
    "UInt32"  : "UInt32",
    "int64"   : "Int64",
    "UInt64"  : "UInt64",
    "float32" : "Float",
    "float64" : "Double",
    "string"  : "String",
]

struct SwiftGenerator {
    var messageLines: [String] = []
    var swiftLines: [String] = []

    let propertyDeclaration: PropertyDeclaration
    let objectDeclaration: ObjectDeclaration
    let declarationSuffix: DeclarationSuffix
    let snakeCase: Bool

    init(propertyDeclaration: PropertyDeclaration, objectDeclaration: ObjectDeclaration, declarationSuffix: DeclarationSuffix, snakeCase: Bool) {
        self.propertyDeclaration = propertyDeclaration
        self.objectDeclaration = objectDeclaration
        self.declarationSuffix = declarationSuffix
        self.snakeCase = snakeCase
    }
    
    mutating func generateSwiftModel(name: String,
                            messageText: String) throws -> String {
        
        
        messageLines = messageText.split(separator: "\n").map{ String($0.trimmingSuffix(while: \.isWhitespace)) }
        
        return """
\(objectDeclaration.rawValue) \(name): \(declarationSuffix.rawValue) {
    \(propertyDeclaration.rawValue) i: Int8
}
"""
    }
}

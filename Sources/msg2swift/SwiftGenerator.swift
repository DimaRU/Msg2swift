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

struct SwiftGeneratorError: Error {
    let message: String
}

struct SwiftGenerator {
    enum DefinitionType: Equatable {
        case empty
        case field(type: String, arrayCount: Int?, name: String, defaultValue: String)
        case constant(type: String, name: String, value: String)
        case enumcase (type: String, name: String, case: String, value: String)
    }
    
    struct Parsedline: Equatable {
        var leadingSpace: Substring
        var definition: DefinitionType
        var trailingSpace: Substring
        var comment: Substring
    }
    
    private let propertyDeclaration: PropertyDeclaration
    private let objectDeclaration: ObjectDeclaration
    private let declarationSuffix: DeclarationSuffix
    private let snakeCase: Bool

    init(propertyDeclaration: PropertyDeclaration, objectDeclaration: ObjectDeclaration, declarationSuffix: DeclarationSuffix, snakeCase: Bool) {
        self.propertyDeclaration = propertyDeclaration
        self.objectDeclaration = objectDeclaration
        self.declarationSuffix = declarationSuffix
        self.snakeCase = snakeCase
    }
    
    //commonPrefix(with:options:)
    // <constanttype> <CONSTANTNAME> = <value>
    private func parseConstant(line: Substring)  throws -> DefinitionType {
        let eqIndex = line.firstIndex(where: { $0 == "="} )!
        let valueStart = line.index(after: eqIndex)
        let value = line[valueStart..<line.endIndex].trimmingCharacters(in: .whitespaces)
        guard !value.isEmpty
        else { throw SwiftGeneratorError(message: "Constant expression value is empty") }
        let parts = line[line.startIndex..<eqIndex]
            .split(separator: #/\s/#, omittingEmptySubsequences: true)
            .map{ String($0) }
        guard
            parts.count == 2,
            SwiftBuiltins[parts[0]] != nil
        else { throw SwiftGeneratorError(message: "Wrong constant expression") }
        return .constant(type: parts[0], name: parts[1], value: value)
    }
    
    // `<fieldtype> <fieldname> [defaultvalue]`
    private func parseField(line: Substring) throws -> DefinitionType {
        let stripped = line.replacing(#/<=[0-9]*/#, with: "")
        let parts = stripped.split(separator: #/\s/#, maxSplits: 2,
                                   omittingEmptySubsequences: true)
        let defaultValue = parts.count == 3 ? parts[2].trimmingCharacters(in: .whitespaces) : ""
        if let arrayDef = parts[0].firstMatch(of: #/\[\d*\]$/#) {
            let arrayCount = Int(String(arrayDef.output).dropFirst().dropLast()) ?? 0
            return .field(type: parts[0].replacingCharacters(in: arrayDef.range, with: ""),
                          arrayCount: arrayCount,
                          name: String(parts[1]),
                          defaultValue: defaultValue)
        }
        
        return .field(type: String(parts[0]),
                      arrayCount: nil,
                      name: String(parts[1]),
                      defaultValue: defaultValue)
    }
    
    private func parseDefinition(line: Substring) throws -> DefinitionType {
        guard
            !line.isEmpty
        else { return .empty }
        
        // Strip any strings
        let testLine = line.replacing(#/(\".*\")|(\'.*\')/#, with: "")
        if !testLine.contains(#/<=[0-9]*/#), testLine.contains("=") {
            return try parseConstant(line: line)
        }
        return try parseField(line: line)
    }
    
    private func parse(line: Substring) throws -> Parsedline {
        var parsed = Parsedline(leadingSpace: "", definition: .empty, trailingSpace: "", comment: "")
        guard 
            let startNonLeading = line.firstIndex(where: {!$0.isWhitespace})
        else { return parsed }
        parsed.leadingSpace = line[line.startIndex..<startNonLeading]
        let startComment = line.firstIndex(where: { $0 == "#" }) ?? line.endIndex
        parsed.comment = line[startComment..<line.endIndex]
        guard
            let endDefIndex = line[startNonLeading..<startComment].lastIndex(where: {!$0.isWhitespace})
        else { return parsed }
        
        let trailingStart = line.index(after: endDefIndex)
        parsed.trailingSpace = line[trailingStart..<startComment]
        parsed.definition = try parseDefinition(line: line[startNonLeading..<trailingStart])
        return parsed
    }
    
    func parseMessageText(_ messageText: String) throws -> [Parsedline] {
        let messageLines = messageText.split(separator: "\n").map{ $0.trimmingSuffix(while: \.isWhitespace) }
        return try messageLines.map(parse(line:))
        
    }

    func generateSwiftModel(name: String, parsed: [Parsedline]) throws -> String {
        return """
\(objectDeclaration.rawValue) \(name): \(declarationSuffix.rawValue) {
    \(propertyDeclaration.rawValue) i: Int8
}
"""
    }

    func processFile(name: String, messageText: String) throws -> String {
        let parsed = try parseMessageText(messageText)
        return try generateSwiftModel(name: name, parsed: parsed)
    }
   
}

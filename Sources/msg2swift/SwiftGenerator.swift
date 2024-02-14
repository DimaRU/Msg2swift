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
    "uint8"   : "UInt8",
    "int16"   : "Int16",
    "uint16"  : "UInt16",
    "int32"   : "Int32",
    "uint32"  : "UInt32",
    "int64"   : "Int64",
    "uint64"  : "UInt64",
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
        case field(type: String, name: String, arrayCount: Int?, defaultValue: String)
        case constant(type: String, name: String, value: String)
        case enumcase (type: String, enum: String, value: String)
    }
    
    struct Parsedline: Equatable {
        var leading: Substring
        var definition: DefinitionType
        var trailing: Substring
        var comment: Substring
        var type: String
        var name: String

        init(leading: Substring, definition: DefinitionType, trailing: Substring, comment: Substring, type: String, name: String) {
            self.leading = leading
            self.definition = definition
            self.trailing = trailing
            self.comment = comment
            self.type = type
            self.name = name
        }
        
        init(leading: Substring, definition: DefinitionType, trailing: Substring, comment: Substring) {
            self.leading = leading
            self.definition = definition
            self.trailing = trailing
            self.comment = comment
            switch definition {
            case .field(type: let type, name: let name, arrayCount: _, defaultValue: _),
                    .constant(type: let type, name: let name, value: _):
                self.name = name
                self.type = type
            case .empty:
                self.name = ""
                self.type = ""
            default:
                fatalError()
            }
        }

        init() {
            leading = ""
            definition = .empty
            trailing = ""
            comment = ""
            name = ""
            type = ""
        }
    }
    
    var parsed: [Parsedline] = []
    var keyList: [(name: String, count: Int)] = []
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
                          name: String(parts[1]), 
                          arrayCount: arrayCount,
                          defaultValue: defaultValue)
        }
        
        return .field(type: String(parts[0]),
                      name: String(parts[1]), 
                      arrayCount: nil,
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
        guard
            let startNonLeading = line.firstIndex(where: {!$0.isWhitespace})
        else { return Parsedline() }
        let leading = line[line.startIndex..<startNonLeading]
        let startComment = line.firstIndex(where: { $0 == "#" }) ?? line.endIndex
        let comment = line[startComment..<line.endIndex]
        guard
            let endDefIndex = line[startNonLeading..<startComment].lastIndex(where: {!$0.isWhitespace})
        else {
            return Parsedline(leading: leading,
                              definition: .empty,
                              trailing: "",
                              comment: comment)
        }
        
        let trailingStart = line.index(after: endDefIndex)
        let trailing = line[trailingStart..<startComment]
        let definition = try parseDefinition(line: line[startNonLeading..<trailingStart])
        return Parsedline(leading: leading,
                          definition: definition,
                          trailing: trailing,
                          comment: comment)
    }
    
    func parseMessageText(_ messageText: String) throws -> [Parsedline] {
        let messageLines = messageText.split(separator: "\n").map{ $0.trimmingSuffix(while: \.isWhitespace) }
        return try messageLines.map(parse(line:))
    }
    
    mutating func markEnums() {
        var cursor = 0
        func getNextIndex() -> Int? {
            defer {
                cursor += 1
            }
            while cursor < parsed.count {
                if case .constant = parsed[cursor].definition {
                    return cursor
                }
                cursor += 1
            }
            return nil
        }
        func searchCommon() {
            var commonIndices: [Int] = []
            defer {
                cursor -= 1
            }
            guard
                let first = getNextIndex(),
                let next = getNextIndex()
            else { return }
            let commonPrefix = parsed[first].name.commonPrefix(with: parsed[next].name)
            guard
                let underscoreIndex = commonPrefix.lastIndex(of: "_")
            else { return }
            let prefix = commonPrefix[commonPrefix.startIndex...underscoreIndex]
            guard
                prefix.count > 4,
                parsed[first].type == parsed[next].type
            else { return }
            commonIndices.append(first)
            commonIndices.append(next)
            while true {
                guard
                    let another = getNextIndex()
                else { break }
                guard
                    parsed[another].name.hasPrefix(prefix),
                    parsed[another].type == parsed[first].type
                else {
                    break
                }
                commonIndices.append(another)
            }
            markAsEnum(prefix: prefix, indices: commonIndices)
        }
        
        func markAsEnum(prefix: Substring, indices: [Int]) {
            let enumName = String(prefix.dropLast())
            for i in indices {
                guard 
                    case .constant(type: let type, name: let name, value: let value) = parsed[i].definition
                else { fatalError() }
                parsed[i].name = String(name.trimmingPrefix(prefix))
                parsed[i].definition = .enumcase(type: type,
                                                 enum: enumName,
                                                 value: value)
            }
        }

        while cursor < parsed.count - 1 {
            searchCommon()
        }
    }
    
    private func translate(name: String) -> String {
        guard snakeCase else { return name }
        return convertFromSnakeCase(name)
    }

    private func translate(type: String, arrayCount: Int?) -> String {
        var translated = String(type.split(separator: "/", omittingEmptySubsequences: true).last!)
        translated =  SwiftBuiltins[translated] ?? translated
        if arrayCount != nil {
            translated = "[\(translated)]"
        }
        return translated
    }

    private func translate(comment: Substring) -> Substring {
        guard !comment.isEmpty else { return comment }
        if comment.allSatisfy({ $0 == "#" }), comment.count >= 3 {
            let translated = comment.dropFirst().dropLast().replacing("#", with: "*")
            return "//" + translated + "//"
        }
        var translated = comment.dropFirst()
        if translated.last == "#" {
            translated = translated.dropLast() + "//"
        }
        return "//" + translated
    }


    mutating func prepareTranslated() {
        // Mark enums
        markEnums()
        // Translate field name
        // Translate type
        // Translate comment
        for i in parsed.indices {
            parsed[i].comment = translate(comment: parsed[i].comment)
            switch parsed[i].definition {
            case .field(type: _, name: _, arrayCount: let arrayCount, defaultValue: _):
                parsed[i].type = translate(type: parsed[i].type, arrayCount: arrayCount)
                parsed[i].name = translate(name: parsed[i].name)
            case .constant(type: _, name: _, value: _):
                parsed[i].type = translate(type: parsed[i].type, arrayCount: nil)
                parsed[i].name = translate(name: parsed[i].name)
            case .enumcase(type: let type, enum: let `enum`, value: let value):
                parsed[i].type = translate(type: parsed[i].type, arrayCount: nil)
                parsed[i].name = translate(name: parsed[i].name)
                if snakeCase {
                    let translated = convertFromSnakeCase(`enum`).capitalized
                    parsed[i].definition = .enumcase(type: type, enum: translated, value: value)
                }
            case .empty:
                break
            }
        }
    }
    
    mutating func prepareCodableKeys() {
        var count = 1
        for line in parsed {
            guard case .field(type: _, name: _, arrayCount: let arrayCount, defaultValue: _) = line.definition else {
                continue
            }
            if let arrayCount, arrayCount > 0 {
                keyList.append((name: line.name, count: arrayCount << 16 + count))
            } else {
                keyList.append((name: line.name, count: count))
            }
            count += 1
        }
    }
    
    mutating func generateSwiftModel(name: String) -> String {
        // Emit file heap
        // Emit declaration open
        // Emit enums
        // Emit body
        // Emit codable keys, if need
        // Emit declaration close "}"
        return """
\(objectDeclaration.rawValue) \(name): \(declarationSuffix.rawValue) {
}
"""
    }

    mutating func processFile(name: String, messageText: String) throws -> String {
        parsed = try parseMessageText(messageText)
        prepareTranslated()
        prepareCodableKeys()
        return generateSwiftModel(name: name)
    }
}

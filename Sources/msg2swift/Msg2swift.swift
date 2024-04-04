/////
////  Msg2swift.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import ArgumentParser

enum PropertyDeclaration: String, EnumerableFlag {
    case `let`
    case `var`
}

enum ObjectDeclaration: String, EnumerableFlag {
    case `struct`
    case `class`
}

enum DeclarationProtocol: String, EnumerableFlag {
    case codable = "Codable"
    case encodable = "Encodable"
    case decodable = "Decodable"
}

@main
struct Msg2swift: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "msg2swift",
        abstract: "Generate Swift codable models from ROS message files.",
        version: "1.0.0")

    @Argument(help: ".msg file(s) to convert.", transform: { URL(fileURLWithPath: $0) })
    var file: [URL]

    @Flag(exclusivity: .exclusive,
          help: "Use var or let for model properties.")
    var propertyDeclaration: PropertyDeclaration = .let

    @Flag(exclusivity: .exclusive,
          help: "Struct or class declaration.")
    var objectDeclaration: ObjectDeclaration = .struct

    @Flag(exclusivity: .exclusive,
          help: ArgumentHelp("Model declaration protocol."))
    var declarationProtocol: DeclarationProtocol = .codable
    
    @Flag(name: .long,
          inversion: .prefixedNo,
          exclusivity: .chooseLast,
          help: ArgumentHelp(stringLiteral: #"Convert property names from "snake_case" to "camelCase""#))
    var snakeCase = true
    
    @Flag(name: .shortAndLong, 
          help: ArgumentHelp("Compact generated code.",
                             discussion: "Strip all comments and remove empty lines."))
    var compact = false

    @Flag(name: .long, 
          inversion: .prefixedNo,
          exclusivity: .chooseLast,
          help: ArgumentHelp("Detect enums.",
                             discussion: "Detect and group constants into Swift enum."))
    var detectEnum = true

    @Option(name: .shortAndLong,
            help: ArgumentHelp("Object name.",
                               discussion: "By default file name used."))
    var name: String?
    
    @Option(name: .shortAndLong,
            help: ArgumentHelp("The output path for generated files.",
                               discussion: "By default generated files written to the current directory.",
                               valueName: "path"))
    var outputDirectory: String?

    @Flag(name: .shortAndLong, help: "Don't print processed file names.")
    var silent = false


    mutating func run() throws {
        for url in file {
            let messageText = try String(contentsOf: url)
            let name = name ?? url.deletingPathExtension().lastPathComponent
            
            var generator = SwiftGenerator(propertyDeclaration: propertyDeclaration,
                                           objectDeclaration: objectDeclaration,
                                           declarationProtocol: declarationProtocol,
                                           snakeCase: snakeCase,
                                           compact: compact,
                                           detectEnum: detectEnum)
            let model = try generator.processFile(name: name, messageText: messageText)
            
            let outputDirectory = outputDirectory ?? url.deletingLastPathComponent().path
            let outputURL = URL(fileURLWithPath: outputDirectory).appendingPathComponent(name).appendingPathExtension("swift")
            let header = """
//
// \(name).swift
//
// This file was generated from ROS message file using msg2swift.
//


"""
            let text = model.joined(separator: "\n")
            try (header + text).write(to: outputURL, atomically: false, encoding: .utf8)
            
            if !silent {
                print("Created \(outputURL.path)")
            }
        }
    }
}

//
//  Msg2swift.swift
//
//
//  Created by Dmitriy Borovikov on 08.02.2024.
//

import Foundation
import ArgumentParser

enum PropertyDeclarationStyle: String, EnumerableFlag {
    case `let`
    case `var`
}

enum ObjectDeclarationStyle: String, EnumerableFlag {
    case `struct`
    case `class`
}

@main
struct Msg2swift: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "msg2swift",
        abstract: "Translate ROS .msg files into Swift codable one.",
        version: "0.0.1")

    @Argument(help: ".msg file(s) to compile.", transform: { URL(fileURLWithPath: $0) })
    var file: [URL]

    @Flag(exclusivity: .exclusive,
          help: ArgumentHelp("Use var or let for object properties."))
    var propertyDeclaration: PropertyDeclarationStyle = .let

    @Flag(exclusivity: .exclusive,
          help: ArgumentHelp("Struct or class declaration."))
    var objectDeclaration: ObjectDeclarationStyle = .struct

    @Flag(name: .shortAndLong, help: "Verbose output")
    var verbose = false

    @Option(name: .shortAndLong,
            help: ArgumentHelp("The output path for generated files.",
            discussion: "By default generated files written to current directory.",
            valueName: "path"))
    var outputDirectory: String?

    mutating func run() throws {
    }
}

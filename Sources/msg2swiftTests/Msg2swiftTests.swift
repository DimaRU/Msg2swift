/////
////  Msg2swiftTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import msg2swift

class Msg2swiftTests: XCTestCase {
    
    func testGenerator() throws {
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .class,
                                       declarationSuffix: .codable,
                                       snakeCase: true)
            
            
        let model = try generator.generateSwiftModel(name: "TestModel",
                                                     messageText: "int i")
        print(model)
    }
}

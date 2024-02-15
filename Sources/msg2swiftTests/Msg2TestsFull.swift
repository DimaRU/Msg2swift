/////
////  Msg2TestsFull.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import msg2swift

class Msg2swiftTestsFull: XCTestCase {

    func testConvertBatteryState() throws {
        let url = Bundle.module.url(forResource: "BatteryState", withExtension: "msg")
        let messageText = try String(contentsOf: url!)
        
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .struct,
                                       declarationSuffix: .codable,
                                       snakeCase: true,
                                       compact: true)

        let codeExpected = """
struct BatteryState: Codable {
    enum PowerSupplyStatus: UInt8, Codable {
        case unknown = 0
        case charging = 1
        case discharging = 2
        case notCharging = 3
        case full = 4
    }
    enum PowerSupplyHealth: UInt8, Codable {
        case unknown = 0
        case good = 1
        case overheat = 2
        case dead = 3
        case overvoltage = 4
        case unspecFailure = 5
        case cold = 6
        case watchdogTimerExpire = 7
        case safetyTimerExpire = 8
    }
    enum PowerSupplyTechnology: UInt8, Codable {
        case unknown = 0
        case nimh = 1
        case lion = 2
        case lipo = 3
        case life = 4
        case nicd = 5
        case limn = 6
    }
    let header: Header
    let voltage: Float
    let temperature: Float
    let current: Float
    let charge: Float
    let capacity: Float
    let designCapacity: Float
    let percentage: Float
    let powerSupplyStatus: PowerSupplyStatus
    let powerSupplyHealth: PowerSupplyHealth
    let powerSupplyTechnology: PowerSupplyTechnology
    let present: Bool
    let cellVoltage: [Float]
    let cellTemperature: [Float]
    let location: String
    let serialNumber: String
}

"""
        let code = try generator.processFile(name: "BatteryState", messageText: messageText)
        XCTAssertEqual(code, codeExpected)
    }
    
    func testConvertCameraInfo() throws {
        let url = Bundle.module.url(forResource: "CameraInfo", withExtension: "msg")
        let messageText = try String(contentsOf: url!)
        
        var generator = SwiftGenerator(propertyDeclaration: .let,
                                       objectDeclaration: .struct,
                                       declarationSuffix: .codable,
                                       snakeCase: true,
                                       compact: true)

        let codeExpected = """
struct CameraInfo: Codable {
    let header: Header
    let height: UInt32
    let width: UInt32
    let distortionModel: String
    let d: [Double]
    let k: [Double]
    let r: [Double]
    let p: [Double]
    let binningX: UInt32
    let binningY: UInt32
    let roi: RegionOfInterest

    enum CodingKeys: Int, CodingKey {
        case header = 1
        case height = 2
        case width = 3
        case distortionModel = 4
        case d = 5
        case k = 0x90006
        case r = 0x90007
        case p = 0xc0008
        case binningX = 9
        case binningY = 10
        case roi = 11
    }
}

"""
        let code = try generator.processFile(name: "CameraInfo", messageText: messageText)
        XCTAssertEqual(code, codeExpected)
    }

}

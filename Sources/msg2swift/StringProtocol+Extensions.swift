/////
////  StringProtocol+Extensions.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}

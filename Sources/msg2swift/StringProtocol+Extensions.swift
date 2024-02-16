/////
////  StringProtocol+Extensions.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    
    public func trimmingWhitespace() -> SubSequence {
      let end = firstNonWhitespace()
      return self[startIndex..<end]
    }
    
    func firstNonWhitespace() -> Index {
        if let end = lastIndex(where: { !$0.isWhitespace }) {
            return index(after: end)
        }
        return startIndex
            
    }

}

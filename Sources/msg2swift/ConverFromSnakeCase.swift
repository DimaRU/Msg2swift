//
// ConverFromSnakeCase.swift
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
import Foundation

/// Convert from "snake_case" to "camelCase"
///
/// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
///
/// Converting from snake case to camel case:
/// 1. Capitalizes the word starting after each `_`
/// 2. Removes all `_`
/// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
/// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.

func convertFromSnakeCase(_ stringKey: String) -> String {
    guard !stringKey.isEmpty else { return stringKey }

    // Find the first non-underscore character
    guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
        // Reached the end without finding an _
        return stringKey
    }

    // Find the last non-underscore character
    var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
    while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
        stringKey.formIndex(before: &lastNonUnderscore)
    }

    let keyRange = firstNonUnderscore...lastNonUnderscore
    let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
    let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex

    let components = stringKey[keyRange].split(separator: "_")
    let joinedString: String
    if components.count == 1 {
        // No underscores in key, leave the word as is - maybe already camel cased
        joinedString = String(stringKey[keyRange])
    } else {
        joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
    }

    // Do a cheap isEmpty check before creating and appending potentially empty strings
    let result: String
    if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
        result = joinedString
    } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
        // Both leading and trailing underscores
        result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
    } else if (!leadingUnderscoreRange.isEmpty) {
        // Just leading
        result = String(stringKey[leadingUnderscoreRange]) + joinedString
    } else {
        // Just trailing
        result = joinedString + String(stringKey[trailingUnderscoreRange])
    }
    return result
}

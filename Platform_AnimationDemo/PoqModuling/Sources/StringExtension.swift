//
//  StringExtension.swift
//  Pods
//
//  Created by Nikolay Dzhulay on 7/17/17.
//
//

import Foundation
import PoqUtilities

extension String {
    
    /// Key to check against if the string is missing from a searched bundle's localized resources.
    private static let missingLocalizedStringValue = "M1ssingL0cal1zedStringValue"

    /// Search for localized string in all project bundles and returns the first found or self.
    public var localizedPoqString: String {
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        let languageCode = Locale.current.languageCode
        
        for bundle in bundles {
            guard bundle.path(forResource: languageCode, ofType: "lproj") != nil else {
                continue
            }
            
            let value = bundle.localizedString(forKey: self, value: .missingLocalizedStringValue, table: nil)
            if value != .missingLocalizedStringValue {
                // If the value does not match the static missing string then we found our value.
                return value
            }
        }
       
        return self
    }
    
    /// Subscript the integer value into a character
    /// - parameter i: Integer value
    public subscript (indexValue: Int) -> Character {
        return self[index(startIndex, offsetBy: indexValue)]
    }
    
    /// Subscript the integer value into a string
    /// - parameter i: Integer value
    public subscript (indexValue: Int) -> String {
        return String(self[indexValue] as Character)
    }
    
    /// Converts the string to a bool if it matches true, yes or 1, otherwise this is false.
    public func toBool() -> Bool {
        return NSString(string: self).boolValue
    }
}

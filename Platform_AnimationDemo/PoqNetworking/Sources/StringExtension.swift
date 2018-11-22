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
        
    /**
    Encode URL values like :,/,& etc.
    */
    public func escapeStr() -> String {
        
        var allowedCharacters = CharacterSet.urlHostAllowed
        allowedCharacters.insert(charactersIn: "[].")
        allowedCharacters.remove(charactersIn: ":/?&=;+!@#$()',*")
        
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
    
    /**
    Decode URL values like :,/,& etc.
    */
    public func descapeStr() -> String {
        
        return removingPercentEncoding ?? self
    }
    
    /**
     Subscript the closed range into a string. Result incluse first AND last character
     */
    public subscript (r: ClosedRange<Int>) -> String {
        let start: String.Index = index(startIndex, offsetBy: r.lowerBound)
        let end: String.Index = index(startIndex, offsetBy: r.upperBound)
        let range = ClosedRange<String.Index>(uncheckedBounds: (start, end))
        return String(self[range])
    }
    
    public func isNullOrEmpty() -> Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    /// Adds spaces to Pascal Cased strings, for example: 'NSThisNeedsSomeDIYSpaces' becomes 'NS This Needs Some DIY Spaces'.
    public func spaced() -> String {
        // This regex finds sets of characters which are either capitalized words or uppercased acronyms
        guard let regex = try? NSRegularExpression(pattern: "((?<=\\p{Ll})\\p{Lu})|((?!\\A)\\p{Lu}(?>\\p{Ll}))", options: []) else {
            Log.error("Failed to create spaced regex")
            return self
        }
        
        let string = NSMutableString(string: self)
        regex.replaceMatches(in: string, options: [], range: NSRange(location: 0, length: string.length), withTemplate: " $0")
        
        return string as String
    }
    
    /// Return nil if string is empy - should help with some cases, where nil is proper value, while empty string isn't
    public func nilForEmptyString() -> String? {
        guard !isEmpty else {
            return nil
        }
        return self
    }
}

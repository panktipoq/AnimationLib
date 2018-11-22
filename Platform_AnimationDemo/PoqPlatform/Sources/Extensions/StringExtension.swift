//
//  StringExtension.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities

extension String {
    
    // MARK: - REGEX
    
    // Regex for parsing email address
    fileprivate var emailRegex: String {
        return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    }
    
    // Regex for parsing double with 2 digits floating points
    fileprivate var doubleRegex: String {
        return "\\d+(\\.\\d{1,2})?"
    }
    
    // MARK: - PRIVATE UTILITY METHODS
    
    // MARK: - UTILITY PARSERS AND VALUE CHEKS
    
    /**
    Returns array of double values 2 digits floating points found in the string
    */
    public func findDoubles() -> [Double?] {
        let values = String.matchesForRegexInText(doubleRegex, text: self)
        return values.map {
            $0.toDouble()
        }
    }
    
    /**
    Export email address
    */
    public func findEmails() -> [String] {
        return String.matchesForRegexInText(AppSettings.sharedInstance.emailValidationRegex, text: self)
    }

    /**
    Check if the string is a valid email
    */
    public func isValidEmail() -> Bool {
        return String.matchesForRegexInText(AppSettings.sharedInstance.emailValidationRegex, text: self).count > 0
    }
    
    // MARK: - UTILITY PARSERS AND VALUE CHEKS
    
    /**
     Returns number of elements
     */
    public var length: Int {
        return self.count
    }
    
    /**
     Returns the first double value with 2 digits floating points found in the string
     */
    public func toDouble() -> Double? {
        
        let values = String.matchesForRegexInText(doubleRegex, text: self)
        
        if values.count > 0 {
            
            return (values[0] as NSString).doubleValue
        } else {
            
            return nil
        }
    }
    
    public func toInt() -> Int? {
        let formatter = NumberFormatter()
        if let number = formatter.number(from: self) {
            return Int(number.int32Value)
        }
        return nil
    }
    
    // TODO: This extension is mainly used in signupviewcontroller.
    // Due to time pressure, I couldn't refactore signupviewcontroller. 
    // It uses this method in some different places and it was risky to refactor at the moment
    // For now, I moved the password validation type here.
    // Best practice could be creating different methods here and checking password validation type in signupvc
    public func isValidPassword() -> Bool {
        
        if AppSettings.sharedInstance.passwordValidationType == PasswordValidationType.default.rawValue {
            
            /**
             Check if the string is a valid password.
             Minimum 8 characters at least 1 Alphabet and 1 Number
             */
            
            let passwordRegEx = AppSettings.sharedInstance.passwordValidationRegExp
            
            let matches: [String] = String.matchesForRegexInText(passwordRegEx, text: self)
            return  matches.count > 0
        } else {
            
            // Min 6 characters and spaceses trimmed
            return self.trimmingCharacters(in: CharacterSet.whitespaces).length >= 6
        }
    }
    
    public func isValidPhoneNumber() -> Bool {
        return String.matchesForRegexInText(AppSettings.sharedInstance.phoneRegex, text: self).count > 0
    }
    
    public func isValidUKPostCode() -> Bool {
        return String.matchesForRegexInText(AppSettings.sharedInstance.postCodeUKRegex, text: self).count > 0
    }
    
    public func isValidUSAZipCode() -> Bool {
        return String.matchesForRegexInText(AppSettings.sharedInstance.zipCodeUSARegex, text: self).count > 0
    }

    /**
     Check that string is US in any case(upper, low, camel)
     */
    public func isUSISOCountryCode() -> Bool {
        return self.caseInsensitiveCompare("us") == ComparisonResult.orderedSame
    }
    
    public func isUrlLink() -> Bool {
        return self.contains("http://") || self.contains("https://")
    }
    
    public func removeInderline() -> String {
        return replacingOccurrences(of: "_", with: " ")
    }
    
    // @return A string formatted by applying phoneNUmberFormat string
    public func phoneNumberFormat() -> String? {
        
        let format = AppSettings.sharedInstance.phoneNumberFormat
        
        guard !format.isEmpty else {
            return self
        }
        
        let formatPlaceholderPlaces = format.enumerated().compactMap {(index, element) in
            return element == "@" ? index : nil
        }
        
        guard count == formatPlaceholderPlaces.count else {
            Log.warning("Attempt to format invalid phone number")
            return self
        }
        
        return String(format: format, arguments: map { String($0) as CVarArg })
    }
    
    // @brief Strip symbols and whitespace, leave decimals only
    public func getNumbersOnly() -> String? {
        guard !AppSettings.sharedInstance.phoneNumberFormat.isEmpty else {
            return self
        }
        
        let numbersArray = components(separatedBy: CharacterSet.decimalDigits.inverted)
        return numbersArray.joined(separator: "")
    }
}

// MARK: - Utility methods
extension String {
   
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

// MARK: - Private
extension String {
    
    fileprivate static func matchesForRegexInText(_ regexOrNil: String?, text textOrNil: String?) -> [String] {
        guard let text = textOrNil else {
            return []
        }
        guard let regexString: String = regexOrNil, !regexString.isEmpty else {
            return [text]
        }
        
        do {
            let regex = try NSRegularExpression(pattern: regexString, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            return results.map {
                nsString.substring(with: $0.range)
            }
        } catch {
            Log.error("Could not initialise regex.")
            return []
        }
    }
}

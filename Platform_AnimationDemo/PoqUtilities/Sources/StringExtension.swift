//
//  StringUtils.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 03/04/2018.
//

extension String {
    
    /// Combine strings, if they are not nil or empty. Allow to avoid extra separators in line
    /// - parameter components: array of optional strings. We will put separator in result string after component if it is not empty
    /// - returns: Stirng, where conmonened joined via separator or nil, if no non-emoty string in components array
    public static func combineComponents(_ components: [String?], separator: String) -> String? {
        return components.compactMap { $0 }.joined(separator: separator)
    }
}

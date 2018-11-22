//
//  TurnpikeString+Sanitizer.swift
//  Turnpike
//
//  Created by GabrielMassana on 18/04/2018.
//  Copyright (c) 2018 Poq Studio. All rights reserved.
//
import Foundation
extension String {
    
    // Turns a=b&c=d into [a:b, c:d].
    internal func queryStringToMap() -> [String: String] {
        var queryMapped = [String: String]()
        let queries = components(separatedBy: "&")
        for query in queries {
            let keyValue = query.components(separatedBy: "=")
            
            // An improperly encoded string will crash the app if we don't check the index count
            if keyValue.count == 2 {
                
                let key = keyValue[0]
                let value = keyValue[1]
                queryMapped[key] = value
            }
        }
        return queryMapped
    }
    
    // swiftlint:disable comments_space
    /// Returns a URL with format scheme://host/path?query. Thus, discarding other components like fragment, password, port, user.
    /// This method exists because we are using the URL to build our own /a/:b format.
    internal func sanitize() -> String {
        if let url = URL(string: self) {
            var scheme = ""
            var host = ""
            let path = url.path
            var query = ""
            if let urlScheme = url.scheme {
                scheme = urlScheme + "://"
            }
            if let urlHost = url.host {
                host = urlHost
            }
            if let urlQuery = url.query {
                query = "?" + urlQuery
            }
            let sanitized = scheme + host + path + query
            return sanitized
        }
        return self
    }
    
    // swiftlint:disable comments_space
    /**
     Turns :: into :, // into /, and removes starting and trailing slashes.
     Instead trying to fix common typos, it would be simpler to reject URLs other than our format [a-zA-Z]+[//:[a-zA-Z]+]* and log the error.
     */
    internal func sanitizeMappedPath() -> String {
        let string = NSMutableString(string: self)
        let multipleColons = try? NSRegularExpression(pattern: "::+", options: .caseInsensitive)
        let multipleSlashes = try? NSRegularExpression(pattern: "//+", options: .caseInsensitive)
        let leadingTrailingSlashes = try? NSRegularExpression(pattern: "(^/)|(/$)", options: .caseInsensitive)
        multipleColons?.replaceMatches(in: string,
                                       options: .reportProgress,
                                       range: NSRange(location: 0, length: string.length),
                                       withTemplate: ":")
        multipleSlashes?.replaceMatches(in: string,
                                        options: .reportProgress,
                                        range: NSRange(location: 0, length: string.length),
                                        withTemplate: "/")
        leadingTrailingSlashes?.replaceMatches(in: string,
                                               options: .reportProgress,
                                               range: NSRange(location: 0, length: string.length),
                                               withTemplate: "")
        return string as String
    }
}

//
//  ErrorExtension.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Jean-Dominique on 17/01/2017.
//
//

import Foundation

extension NSError {
    @nonobjc
    func isCancelledRequestError() -> Bool {
        return code == URLError.cancelled.rawValue
    }
    
    @nonobjc
    func trackingData() -> [String: String] {
        var trackingData:[String: String] = [:]
        
        trackingData["description"] = localizedDescription
        trackingData["domain"] = domain
        
        if let url = userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
            trackingData["url"] = url
        }
        
        if let failureReason = localizedFailureReason {
            trackingData["localizedFailureReason"] = failureReason
        }
        
        if let recoverySuggestion = localizedRecoverySuggestion {
            trackingData["localizedRecoverySuggestion"] = recoverySuggestion
        }
        
        return trackingData
    }
}

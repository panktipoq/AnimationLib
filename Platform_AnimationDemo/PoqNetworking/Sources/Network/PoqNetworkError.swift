//
//  PoqNetworkError.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 26/08/2016.
//
//

import Foundation

extension NSError {
    
    @nonobjc
    public class func errorWithMessage( _ message: String ) -> NSError {
        return NSError.errorWithTitle("", statusCode: 0, message: message, userInfo: nil)
    }
    
    @nonobjc
    public class func errorWithTitle( _ title: String, statusCode: Int, message: String, userInfo requestUserInfo: AnyObject?) -> NSError {

        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = message
        if let key = NSErrorDef.errorTitle as? NSString {
            userInfo[key as String] = title
        }

        if let validUserInfo = requestUserInfo {
            userInfo[NSErrorDef.userInfo] = validUserInfo
        }

        return NSError(domain: NSErrorDef.errorDomain, code: statusCode, userInfo: userInfo)
    }
    
    @nonobjc
    public func errorTitle() -> String {
        guard let errorTitle = userInfo[NSErrorDef.errorTitle.description] as? String else {
            return ""
        }
        return errorTitle
    }
    
    @nonobjc
    public func errorMessage() -> String {
        guard let errorMessage: String = userInfo[NSLocalizedDescriptionKey] as? String else {
            return ""
        }
        return errorMessage
    }
    
    @nonobjc
    public func errorUserInfoObject() -> AnyObject? {

        return userInfo[NSErrorDef.userInfo] as AnyObject?
    }
}

//
//  CallButtonHelper.swift
//  Poq.iOS
//
//  Created by Denisa Bokar on 22/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

public final class CallButtonHelper {
    
    public static func launchPhoneCall(_ rawPhoneNumber: String) {
        
        let phoneNumber = rawPhoneNumber.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.caseInsensitive).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let tel = "telprompt://\(phoneNumber)"
        NavigationHelper.sharedInstance.loadExternalLink(tel)
    }
    
    public static func displayPopup(_ message: String, title: String) -> UIAlertController {

        let okText = "OK".localizedPoqString
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
        }))
        return alertController
    }
}

//
//  PoqShareTracking.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 1/8/16.
//  Copyright © 2016 Poq. All rights reserved.
//

import Foundation
import UIKit

public enum PoqShareEventType: String {
    case Twitter = "Twitter"
    case Facebook = "Facebook"
    case Whatsapp = "Whatsapp"
    case Email = "Email"
    case Message = "Message"
}

open class PoqShareTracking {
    public static func trackShareEvent(_ activityName: String?) {
        var activityLabel = ""
        guard let activityString = activityName else {
            return
        }
        
        switch activityString {
        case UIActivityType.postToTwitter.rawValue:
            activityLabel = PoqShareEventType.Twitter.rawValue
            
        case UIActivityType.postToFacebook.rawValue:
            activityLabel = PoqShareEventType.Facebook.rawValue
            
        case "net.whatsapp.WhatsApp.ShareExtension":
            activityLabel = PoqShareEventType.Whatsapp.rawValue
            
        case UIActivityType.mail.rawValue:
            activityLabel = PoqShareEventType.Email.rawValue
            
        case UIActivityType.message.rawValue:
            activityLabel = PoqShareEventType.Message.rawValue
            
        default:
            activityLabel = activityString
        }
        
        PoqTracker.sharedInstance.logAnalyticsEvent("Sharing Activity", action: "ActivityType", label: activityLabel, extraParams:nil)
        
    }
	
	public init() {
		
	}

}

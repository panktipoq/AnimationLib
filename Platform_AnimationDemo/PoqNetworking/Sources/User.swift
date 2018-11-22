//
//  User.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/27/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public class User: NSObject {
    
    static let userIdKey = "userId"
    
    public static func getUserId() -> String {

        if let userIdUnwrapped = UserDefaults.standard.object(forKey: userIdKey) as? String {
            return userIdUnwrapped
        }
        
        let userId = UUID().uuidString
        UserDefaults.standard.set(userId, forKey: userIdKey)
        
        return userId
        
    }
    
    public static func resetUserId() {
        
        UserDefaults.standard.removeObject(forKey: userIdKey)
        
    }
   
}

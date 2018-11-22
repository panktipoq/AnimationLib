//
//  StoreHelper.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/29/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import PoqUtilities
import UIKit

open class StoreHelper: NSObject {
    
    static private let storeKey: String = "favoriteStoreId"
    
    class func getStoreKey() -> String {
        if let email = LoginHelper.getAccounDetails()?.email, LoginHelper.isLoggedIn(), AppSettings.sharedInstance.favoriteStoreRequiresLoggedInUser {
            return email + storeKey
        }
        return storeKey
    }
    
    open class func getFavoriteStoreId() -> Int {
        if LoginHelper.isLoggedIn() || !AppSettings.sharedInstance.favoriteStoreRequiresLoggedInUser {
            let defaults = UserDefaults.standard
            return defaults.integer(forKey: StoreHelper.getStoreKey())
        } else {
            return 0
        }
    }
    
    public static func hasFavoriteStore() -> Bool {
        return StoreHelper.getFavoriteStoreId() > 0
    }
    
    open class func addFavorite(storeId: Int) {
        if LoginHelper.isLoggedIn() || !AppSettings.sharedInstance.favoriteStoreRequiresLoggedInUser {
            // Always override the current value
            // User will have only 1 store selected
            let defaults = UserDefaults.standard
            defaults.set(storeId, forKey: StoreHelper.getStoreKey())
            defaults.synchronize()
        } else {
            Log.error("User is not logged in no storeId is saved this should not happen anymore")
        }
    }
}

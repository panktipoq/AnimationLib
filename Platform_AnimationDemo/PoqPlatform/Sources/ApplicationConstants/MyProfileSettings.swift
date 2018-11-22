//
//  MyProfileSettings.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 11/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public struct MyProfileSettings {

    // My profile section titles
    public static let myProfileRewardCardDetailTitle = AppLocalization.sharedInstance.myProfileRewardCardDetailTitle
    public static let myProfileFavoriteStoreTitle = AppLocalization.sharedInstance.myProfileFavoriteStoreTitle
    public static let myProfileFavoriteSizeTitle = AppLocalization.sharedInstance.myProfileFavoriteSizeTitle
    public static let myProfileHistoryTitle = AppLocalization.sharedInstance.myProfileHistoryTitle
    public static let myProfileRecognitionActionButtonTitle = AppLocalization.sharedInstance.myProfileRecognitionActionButtonTitle
    public static let myProfileLoginActionButtonTitle = AppLocalization.sharedInstance.myProfileLoginActionButtonTitle
    public static let myProfileSignupActionButtonTitle = AppLocalization.sharedInstance.myProfileSignupActionButtonTitle
    public static let myProfileLogoutActionButtonTitle = AppLocalization.sharedInstance.myProfileLogoutActionButtonTitle
    public static let myProfileBackToTopActionButtonTitle = AppLocalization.sharedInstance.myProfileBackToTopActionButtonTitle
    
    // My profile size links
    public static let myProfileSizeManLinkTitle = AppLocalization.sharedInstance.myProfileSizeManLinkTitle
    public static let myProfileSizeWomanLinkTitle = AppLocalization.sharedInstance.myProfileSizeWomanLinkTitle
    public static let myProfileSizeKidsLinkTitle = AppLocalization.sharedInstance.myProfileSizeKidsLinkTitle
    
    // My profile other links
    public static let myProfileRecentlyViewLinkTitle = AppLocalization.sharedInstance.myProfileRecentlyViewLinkTitle
    public static let myProfileOrderHistoryLinkTitle = AppLocalization.sharedInstance.myProfileOrderHistoryLinkTitle
    
    public static let myProfileTitleHeight = 80
    public static let myProfileLinkHeight = 60
    public static let myProfileSeperatorHeight = 1
    public static let myProfileMasterCardInfoHeight = 270
    public static let myProfileRewardCardInfoHeight = 180
    public static let myProfileRewardCardDetailHeight = 375
    public static let myProfileRecognitionDashboardHeight = 520
    public static let myProfileMyStoreHeight = 330
    public static let myProfileLoggedInBannerHeight = DeviceType.IS_IPAD ? 300 : 180
    public static let myProfileActionButtonHeight = AppSettings.sharedInstance.myProfileActionButtonHeight

    public static var myProfileLoginHeight: Int {
        get {
            if DeviceType.IS_IPHONE_6_OR_LESS { return 455 }
            else if DeviceType.IS_IPAD {
                
                // we don't have really access to tab and nav bar and they are not properly sized for a while
                let navBarHeight: CGFloat = 64.0
                let tabBarHeight: CGFloat = 49.0
                
                let res = UIScreen.main.bounds.size.height - navBarHeight - tabBarHeight
                return Int(res / 3) * 2
            } else {
                //iphone 6
                return 553
            }
        }
    }

}

// Custom cell actions
public enum MyProfileCellAction {
    
    case none
    case selectStore
    case selectSizeMan
    case selectSizeWoman
    case selectSizeKids
    case selectRecentlyViewed
    case selectOrderHistory
    case selectRewardCardInfo
    case selectLogin
    case selectLogout
    case selectSignUp
    case selectCallStore
    case scrollToTop
    case openWebView(url: String)
}

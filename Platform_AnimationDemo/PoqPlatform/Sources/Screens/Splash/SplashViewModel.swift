//
//  PageListViewModel.swift
//  Poq.iOS
//
//  Created by Huishan Loh on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import Fabric
import PoqModuling
import PoqNetworking
import PoqAnalytics
import PoqUtilities

/**
 `SplashViewModel` is responsible for booting up the Application.
 
 - Downloading, parsing and persisting MightyBot settings
 - Configuring the Application's TabBar, Deep links, Onboarding etc.
 - Configuring the Data tracking providers
 - Checks if should force the user to update to latest version
 */
class SplashViewModel: PoqSplashService {
    
    // MARK: - PoqSplashService variables
    
    weak var presenter: PoqSplashPresenter?
    var splash: PoqSplash?
    
    // MARK: - PoqSplashService functions
    
    /**
     At first it checks if `Force Update` is enabled and if there are newer version of the app
     to force the user to update to the latest one.
     
     Calls `setUpView()` of the current `UIApplication.delegate` to configure
     the initial state of the app (UA, TabBar, Onboarding etc).
     Also sets up the appropriate badge for each TabBar item (if applicable).
     
     Configures the StatusBar styling.
     */
    func setupApplication() {
        
        // Check if the App needs a force udpate
        guard !AppSettings.sharedInstance.forceUpdate else {
            presenter?.showForceUpdateViewController()
            return
        }
        
        PoqPlatform.shared.setupApplication()
        
        // Update bag and wishlist badges
        BadgeHelper.initBadgesValue()
        
        let statusBarStyle: PoqStatusBarStyle? = PoqStatusBarStyle(rawValue: AppSettings.sharedInstance.statusBarStyle)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.statusBarStyle(statusBarStyle)
        
        // Init tracking providers
        PoqTracker.sharedInstance.initProviders()
        
        if let attributionLink = UserDefaults.standard.url(forKey: PoqTracker.attributionUrlUserDefaultKey) {
            PoqTracker.sharedInstance.trackCampaignAttribution(from: attributionLink)
        }
    }
    
    /**
     Checks for already persisted `splashBackgroundColor` in CoreData and returns it.
     If such color is not found, it returns the default value from `AppTheme`.
     */
    func getSplashBackgroundColorStyle() -> UIColor {
        var setting: PoqSetting?
        setting = SettingsCoreDataHelper.fetchSetting(nil, key: "splashBackgroundColor", settingTypeId: PoqSettingsType.theme.rawValue, appId: PoqNetworkTaskConfig.appId)
        
        if let value = setting?.value, !value.isEmpty {
            return UIColor.hexColor(value)
        }
        
        // First time running using default color
        return AppTheme.sharedInstance.splashBackgroundColor
    }
}

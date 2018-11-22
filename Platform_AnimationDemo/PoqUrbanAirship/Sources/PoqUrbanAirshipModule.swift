//
//  PoqUrbanAirshipModule.swift
//  PoqUrbanAirship
//
//  Created by Joshua White on 27/04/2018.
//

import AirshipKit
import Foundation
import PoqAnalytics
import PoqModuling
import PoqNetworking
import PoqUtilities

/// The Urban Airship module to be registered with the PoqPlatform.
/// - important: This should be registered if it is to be used at all in the `setupModules` and unregistered if not needed either straight away.
public class PoqUrbanAirshipModule: PoqModule {
    
    /// The analytics tracking provider for Urban Airship.
    public let analyticsProvider = PoqUrbanAirshipTracker()
    
    /// Hidden default initializer.
    private init() {
    }
    
    /// Initializes an instance of the `PoqUrbanAishiprModule` with the specified config or `UAConfig.default()` if nil.
    /// - parameter config: The Urban Airship config to use; defaults to `UAConfig.default()`.
    public init?(config: UAConfig = .default()) {
        config.isAutomaticSetupEnabled = false
        
        guard config.validate() else {
            Log.error("[UA] No valid configuration for initialization.")
            return nil
        }
        
        UAirship.setLogging(false)
        UAirship.takeOff(config)
        
        let environment = config.isInProduction ? "production" : "development"
        Log.debug("[UA] Setup for \(environment) remote notifications")
    }
    
    // MARK: - PoqModule Protocol Adoption
    
    public func didAddToPlatform() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationSettingsChanged), name: .userNotificationSettingsChanged, object: nil)
        
        PoqUserNotificationCenter.shared.addHandler(self)
        PoqTrackerV2.shared.addProvider(analyticsProvider)
        
        setupPush()
        setupNotificationCategories()
    }
    
    public func willRemoveFromPlatform() {
        NotificationCenter.default.removeObserver(self)
        
        PoqUserNotificationCenter.shared.removeHandler(self)
        PoqTrackerV2.shared.removeProvider(analyticsProvider)
        
        tearDownPush()
        tearDownNotificationCategories()
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        UAirship.push()?.resetBadge()
    }
    
    @objc private func userNotificationSettingsChanged(_ notification: Notification) {
        let notificationSettings = PoqUserNotificationCenter.shared.settings
        
        let userNotificationsEnabled = notificationSettings?.authorizationStatus == .authorized
        var notificationOptions = UANotificationOptions()
        
        if notificationSettings?.alertSetting == .enabled {
            notificationOptions.insert(.alert)
        }
        if notificationSettings?.badgeSetting == .enabled {
            notificationOptions.insert(.badge)
        }
        if notificationSettings?.carPlaySetting == .enabled {
            notificationOptions.insert(.carPlay)
        }
        
        UAirship.push()?.notificationOptions = notificationOptions
        UAirship.push()?.userPushNotificationsEnabled = userNotificationsEnabled
        UAirship.push()?.updateRegistration()
    }
    
    /// Performs initial setup on the UAirship's UAPush object.
    private func setupPush() {
        UAirship.push()?.alias = User.getUserId()
        UAirship.push()?.updateRegistration()
    }
    
    /// Installs notification categories used by Urban Airship.
    private func setupNotificationCategories() {
        let actionOk = UNNotificationAction(identifier: "ACCEPT_IDENTIFIER", title: "OK", options: .foreground)
        let actionCancel = UNNotificationAction(identifier: "NOT_NOW_IDENTIFIER", title: "Not Now", options: .destructive)
        let category = UNNotificationCategory(identifier: "INVITE_CATEGORY", actions: [actionOk, actionCancel], intentIdentifiers: [])
        PoqUserNotificationCenter.shared.categories.insert(category)
    }
    
    /// Deinitializes the UAirship's UAPush object, disabling push via Urban Airship.
    private func tearDownPush() {
        UAirship.push()?.userPushNotificationsEnabled = false
        UAirship.push()?.updateRegistration()
    }
    
    /// Uninstalls notification categories initially installed for use by Urban Airship.
    private func tearDownNotificationCategories() {
        PoqUserNotificationCenter.shared.removeCategories(withIdentifier: "INVITE_CATEGORY")
    }
    
}

// MARK: - PoqNotificationHandler Function Forwarding
extension PoqUrbanAirshipModule: PoqUserNotificationHandler {
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UAAppIntegration.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
        if let channelId = UAirship.push()?.channelID {
            Log.info("[UA] Setup with channel ID: \(channelId)")
        }
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UAAppIntegration.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UAAppIntegration.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UAAppIntegration.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UAAppIntegration.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
}

//
//  PoqAnalyticsModule.swift
//  PoqAnalytics
//
//  Created by Joshua White on 22/05/2018.
//

import Foundation
import PoqModuling
import UserNotifications

/// Typealias for the analytics module this is useful when using Analytics.
/// TODO: Refactor TrackerV2 into just this class and change it to a non-singleton...
/// TODO: Access through `PoqPlatform.shared.module(ofType: PoqAnalytics.self)`.
public typealias PoqAnalytics = PoqAnalyticsModule

/// The analytics framework's module to handle app launch tracking.
/// Later we could combine this and the TrackerV2 as a single class, and to make the class more readable we can separate protocols and conformance into separate extension files (e.g. PoqAnalyticsModule+ContentTracking).
public class PoqAnalyticsModule: PoqModule {
    
    /// Launch methods for app launch tracking.
    enum AppLaunchMethod: String {
        case direct = "Direct"
        case push = "Push"
        case deeplink = "Deeplink"
        case shortcut = "Shortcut"
    }
    
    /// The launch method of the application to send when ready to all analytics trackers.
    /// We must store this and send it singularly as the app will try to handle a deeplink after moving to the foreground.
    var appLaunchMethod = AppLaunchMethod.direct
    var appLaunchData: String?
    
    /// Default initializer for the Analytics Module.
    public init() {
    }
    
    public func didAddToPlatform() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        PoqUserNotificationCenter.shared.addHandler(self)
    }
    
    public func willRemoveFromPlatform() {
        NotificationCenter.default.removeObserver(self)
        PoqUserNotificationCenter.shared.removeHandler(self)
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        appLaunchMethod = .direct
        appLaunchData = nil
    }
    
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        PoqTrackerV2.shared.appOpen(method: appLaunchMethod.rawValue, campaign: appLaunchData ?? "")
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        appLaunchMethod = .deeplink
        appLaunchData = String(describing: url)
        
        // TODO: Refactor this launch stuff...
        // We need to know if we handle the deeplink so we need some sort of deeplink handler built into the Poq Core Module.
        // Currently the PoqPlatformModule returns true for most deeplinks... perhaps thats good?
        return false
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        appLaunchMethod = .shortcut
        appLaunchData = shortcutItem.type
        completionHandler(false)
    }
    
    public func setupApplication() {
        PoqTrackerV2.shared.initProviders()
    }
    
}

extension PoqAnalyticsModule: PoqUserNotificationHandler {
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        appLaunchMethod = .push
        appLaunchData = userInfo["push_id"] as? String
        completionHandler(.noData)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            appLaunchMethod = .push
            appLaunchData = String(describing: response.notification.request.content.userInfo["push_id"])
            // TODO: The above is a UA key, we could use `response.notification.request.identifier` but this is the collapse id... need to test if its the same thing.
        }
        completionHandler()
    }
    
}

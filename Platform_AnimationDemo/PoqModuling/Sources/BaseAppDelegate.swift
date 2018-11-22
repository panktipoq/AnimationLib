//
//  BaseAppDelegate.swift
//  PoqModuling
//
//  Created by Joshua White on 27/04/2018.
//

import Foundation

@UIApplicationMain
/// This class **must be subclassed** and is responsible for iOS application life-cycle events and forwarding.
open class BaseAppDelegate: UIResponder, UIApplicationDelegate {
    
    /// The main window of the shared application.
    open var window: UIWindow?
    
    /// This function must be overriden by a subclass to register and setup required modules with the PoqPlatform.
    /// This is called at the start of the application lifecycle before `willFinishLaunchingWithOptions`.
    /// - important: All apps **must subclass** `BaseAppDelegate` and **must override** `setupModules`.
    open func setupModules() {
    }
    
    // MARK: - Lifecycle Event Forwarding
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Setup the main window for the application.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        setupModules()
        
        PoqPlatform.shared.application(application, willFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PoqPlatform.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    // MARK: - Navigation Event Forwarding
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return PoqPlatform.shared.application(app, open: url, options: options)
    }
    
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        PoqPlatform.shared.application(application, performActionFor: shortcutItem, completionHandler: completionHandler)
    }
    
    // MARK: - Notification Event Forwarding
    
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PoqUserNotificationCenter.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PoqUserNotificationCenter.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PoqUserNotificationCenter.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
}

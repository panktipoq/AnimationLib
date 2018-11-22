//
//  PoqUserNotificationHandler.swift
//  PoqModuling
//
//  Created by Joshua White on 27/04/2018.
//

import UserNotifications

/// Plug-point interface for frameworks to handle notifications.
/// An implementation of this protocol should be registered with the `PoqNotificationCenter`.
public protocol PoqUserNotificationHandler: class {
    
    /// Notifies the handler that it has been added to the `PoqNotificationCenter`.
    func didAddToNotificationCenter()
    
    /// Notifies the handler that it will be removed from the `PoqNotificationCenter`.
    func willRemoveFromNotificationCenter()
    
    // MARK: - UIApplicationDelegate Handling
    
    /// Optional function forwarded from the `UIApplicationDelegate`.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    
    /// Optional function forwarded from the `UIApplicationDelegate`.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    
    /// Optional function forwarded from the `UIApplicationDelegate` to handle background fetch notifications.
    /// - note: It's not clear if this is still in use as the `userNotificationCenter(:didReceive:withCompletionHandler:)` should handle this.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    
    // MARK: - UNUserNotificationCenterDelegate Handling
    
    /// Optional function asking how to present a notification whilst the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
    /// Required function notifying that the application received a notification forwarded from the `UNUserNotificationCenter`.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
}

// MARK: - Default Implementation
extension PoqUserNotificationHandler {
    
    public func didAddToNotificationCenter() {
    }
    
    public func willRemoveFromNotificationCenter() {
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
}

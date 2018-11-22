//
//  PoqUserNotificationCenter.swift
//  PoqModuling
//
//  Created by Joshua White on 27/04/2018.
//

import Foundation
import PoqUtilities
import UserNotifications

/// Encapsulates UserNotification functionality to allow related function forwarding to managed Handlers.
public class PoqUserNotificationCenter: NSObject {
    
    /// Shared instance of the PoqUserNotificationCenter.
    public static let shared: PoqUserNotificationCenter = {
        let notificationCenter = PoqUserNotificationCenter()
        UNUserNotificationCenter.current().delegate = notificationCenter
        return notificationCenter
    }()
    
    /// The timeout for completion handler forwarding. Currently this applies to:
    /// - `application(:didReceiveRemoteNotification:fetchCompletionHandler:)`
    /// - `userNotificationCenter(:willPresent:withCompletionHandler:)`
    /// - `userNotificationCenter(:didReceive:withCompletionHandler:)`
    public static var forwardingTimeout = TimeInterval(5)
    
    /// Array of notification handlers (providers) that wish to handle notification related functionality.
    public private(set) var handlers = [PoqUserNotificationHandler]()
    
    /// The set of registered notification categories.
    /// Changes to this set are reflected on the current `UNUserNotificationCenter` and override its categories.
    public var categories = Set<UNNotificationCategory>() {
        didSet {
            UNUserNotificationCenter.current().setNotificationCategories(categories)
        }
    }
    
    /// The most recent state of notification-related settings; this is updated through calling the `fetchSettings` function.
    /// If this value changes the shared `PoqNotificationCenter` posts a `Notification.Name.userNotificationSettingsChanged` notification.
    /// - important: This should be observed by handlers to update remote server behaviour.
    public private(set) var settings: UNNotificationSettings? {
        didSet {
            if settings != oldValue {
                NotificationCenter.default.post(name: .userNotificationSettingsChanged, object: self)
            }
        }
    }
    
    /// The default settings to return to the completion of `userNotificationCenter(:willPresent:withCompletionHandler:)`.
    /// These settings control how a notification is presented whilst the app is in the foreground.
    /// By default notification alerts and sound are enabled.
    public var presentationOptions: UNNotificationPresentationOptions = [.alert, .sound]
    
    /// Internal default initializer used only for unit testing.
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSettings), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        // Avoid leaks whilst unit testing.
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Registers a handler to receive forwarded local and remote notification events.
    /// - parameter handler: The handler to register to receive events.
    public func addHandler(_ handler: PoqUserNotificationHandler) {
        handlers.insert(handler, at: 0)
        handler.didAddToNotificationCenter()
    }
    
    /// Unregisters a handler from receiving forwarded local and remote notification events.
    /// - parameter handler: The handler to unregister from receiving events.
    public func removeHandler(_ handler: PoqUserNotificationHandler) {
        guard let index = handlers.index(where: { $0 === handler }) else {
            Log.error("Unable find and remove the specified notification handler.")
            return
        }
        
        handler.willRemoveFromNotificationCenter()
        handlers.remove(at: index)
    }
    
    /// Removes all notifications categories with the specified identifier.
    /// - parameter identifier: The identifier of the category to remove from the `notificationCategories` set.
    public func removeCategories(withIdentifier identifier: String) {
        categories = categories.filter({ $0.identifier != identifier })
    }
    
    /// Updates the settings property with the most recent app notification-related settings.
    /// Upon any changes to the PoqNotificationCenter's settings a notification will be sent that can be observed by providers.
    @objc public func fetchSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    /// This is a wrapper function for the `UNUserNotificationCenter.current().requestAuthorization`.
    /// It requests authorization to interact with the user when local and remote notifications arrive
    /// - important: This function also calls `fetchSettings` on completion to update `settings` and notify providers of any changes.
    /// **Please see the same function on UNUserNotificationCenter.**
    /// - parameter options: The authorization options your app is requesting.
    /// - parameter completionHandler: The block to execute asynchronously with the results. This block may be executed on a background thread.
    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        guard !AutomationTestsUtilities.isRunningTests && !AutomationTestsUtilities.isRunningUITests else {
            Log.info("User notifications are disable whilst testing.")
            completionHandler(false, nil)
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            DispatchQueue.main.async {
                if let error = error {
                    Log.error("Unable to authorize notification options with error: \(error)")
                }
                
                if granted {
                    self.fetchSettings()
                }
                
                completionHandler(granted, error)
            }
        }
    }
    
    /// Call this function to first request authorization for the specified options.
    /// Then, **if successful**, register for remote notifications.
    public func setupRemoteNotifications(withOptions options: UNAuthorizationOptions = [.alert, .badge, .sound]) {
        requestAuthorization(options: options) { (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}

// MARK: - UIApplicationDelegate Function Forwarding
extension PoqUserNotificationCenter {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        handlers.forEach({ $0.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken) })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handlers.forEach({ $0.application(application, didFailToRegisterForRemoteNotificationsWithError: error) })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handlers.reduceAsync(UIBackgroundFetchResult.noData, timeout: PoqUserNotificationCenter.forwardingTimeout, resultCombiner: { (groupResult, nextPartialResult) in
            groupResult != .failed && nextPartialResult != .noData ? nextPartialResult : groupResult
        }, body: { (handler, completionHandler) in
            handler.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }, completion: { (result, timeoutResult) in
            if timeoutResult == .timedOut {
                Log.error("PoqNotificationCenter forwarding `application(:didReceiveRemoteNotification:fetchCompletionHandler:)` timed out.")
                Log.error("To avoid timeout make sure to call completionHandler within `PoqNotificationCenter.forwardingTimeout`.")
            }
            
            completionHandler(result)
        })
    }
    
}

// MARK: - UNUserNotificationCenterDelegate Function Forwarding
extension PoqUserNotificationCenter: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handlers.reduceAsync(presentationOptions, timeout: PoqUserNotificationCenter.forwardingTimeout, resultCombiner: { (groupResult, nextPartialResult) in
            groupResult.intersection(nextPartialResult)
        }, body: { (handler, completion) in
            handler.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completion)
        }, completion: { (result, timeoutResult) in
            if timeoutResult == .timedOut {
                Log.error("PoqNotificationCenter forwarding `userNotificationCenter(:willPresent:withCompletionHandler:)` timed out.")
                Log.error("To avoid timeout make sure to call completionHandler within `PoqNotificationCenter.forwardingTimeout`.")
            }
            
            completionHandler(result)
        })
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handlers.forEachAsync(timeout: PoqUserNotificationCenter.forwardingTimeout, body: { (handler, completion) in
            handler.userNotificationCenter(center, didReceive: response, withCompletionHandler: completion)
        }, completion: { (timeoutResult) in
            if timeoutResult == .timedOut {
                Log.error("PoqNotificationCenter forwarding `userNotificationCenter(:didReceive:withCompletionHandler:)` timed out.")
                Log.error("To avoid timeout make sure to call completionHandler within `PoqNotificationCenter.forwardingTimeout`.")
            }
            
            completionHandler()
        })
    }
    
}

// MARK: - NSNotificationCenter Notification Declarations
extension Notification.Name {
    
    /// Sent when a change to the user notification settings is detected.
    public static let userNotificationSettingsChanged = Notification.Name("userNotificationSettingsChanged")
    
}

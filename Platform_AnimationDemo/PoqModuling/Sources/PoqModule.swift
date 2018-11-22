//
//  PoqModule.swift
//  PoqModuling
//
//  Created by Nikolay Dzhulay on 11/02/16.
//

import Foundation

/// Plug-point interface for frameworks to hook into the lifecycle of the application and platform.
/// A registered module will receive application and platform lifecycle events and act as an interface for a framework to locate resources.
public protocol PoqModule: AnyObject {
    
    /// The bundle for this module's resources (xibs, assets, fonts...).
    var bundle: Bundle { get }
    
    /// Notifies the module that it has been added to the platform.
    /// Implement this function to setup / register any objects that rely on or are managed by the module.
    func didAddToPlatform()
    
    /// Notifies the module that it will be removed from the platform.
    /// Implement this function to clean up / unregister any objects that rely on or are managed by the module.
    func willRemoveFromPlatform()
    
    // MARK: - UIApplicationDelegate Lifecycle Handling
    
    /// Optional application lifecycle function forwarded from the `UIApplicationDelegate`.
    /// We have disallowed the return of this function to be handled by modules as the group return value cannot easily be merged.
    /// Instead a client must subclass the `BaseAppDelegate` and override this function **and must call super**.
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    
    /// Optional application lifecycle function forwarded from the `UIApplicationDelegate`.
    /// We have disallowed the return of this function to be handled by modules as the group return value cannot easily be merged.
    /// Instead a client must subclass the `BaseAppDelegate` and override this function **and must call super**.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    
    // MARK: - UIApplicationDelegate Navigation Handling
    
    /// Optional application navigation function forwarded from the `UIApplicationDelegate`.
    /// Implement this to handle performing an action or navigation upon the application being opened from the specified URL.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool
    
    /// Optional application navigation function forwarded from the `UIApplicationDelegate`.
    /// Implement this to handle performing an action for an `UIApplicationShortcutItem`.
    /// - important: You must call completionHandler within the `PoqPlatform.forwardingTimeout` time.
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    
    // MARK: - Lifecycle Handling
    
    /// Called whilst loading settings and configurations.
    // TODO: Refactor this into its own mechanism that requires subscribing some settingsable file to receive updates with some core manager.
    func apply(settings: [PoqSettingsType: [PoqSetting]])
    
    /// Called after the application has loaded all settings and configurations.
    func setupApplication()
    
    /// Called when the platform is told to reset the application from the splash screen.
    /// The platform will then fetch and load settings as needed before calling `setupApplication`.
    func resetApplication()
    
    // MARK: - Navigation Handling
    
    /// Used by the platform to resolve view controllers by a name. Especially for tabs in the `TabBarViewController`.
    func createViewController(forName name: String) -> UIViewController?
    
    // TODO: Remove this function and move this functionality to PoqAnalytics.
    func createTrackers() -> [PoqTrackingProtocol]
    
}

// MARK: - Default Implementation
extension PoqModule {
    
    public var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    public func didAddToPlatform() {
    }
    
    public func willRemoveFromPlatform() {
    }
    
    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return false
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(false)
    }
    
    public func apply(settings: [PoqSettingsType: [PoqSetting]]) {
    }
    
    public func setupApplication() {
    }
    
    public func resetApplication() {
    }
    
    public func createViewController(forName name: String) -> UIViewController? {
        return nil
    }
    
    public func createTrackers() -> [PoqTrackingProtocol] {
        return []
    }
    
}

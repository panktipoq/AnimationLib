//
//  PoqPlatform.swift
//  PoqModuling
//
//  Created by Nikolay Dzhulay on 11/02/16.
//

import Foundation
import PoqUtilities

/// The module manager for the entire poq platform. This is the heart of the platform.
/// Most modules MUST be registered within a subclass of the BaseAppDelegate's `setupModules()` function.
/// This class forwards lifecycle events to, and resolves resources through, its registered modules in order.
public class PoqPlatform {
    
    /// Shared instance of the Poq Platform (PoqModule Manager).
    public static let shared = PoqPlatform()
    
    /// The timeout for completion handler forwarding. Currently this applies to:
    /// - `application(:performActionFor:completionHandler:)`
    public static var forwardingTimeout = TimeInterval(5)
    
    /// The array of all registered modules.
    public private(set) var modules = [PoqModule]()
    
    /// Registers the specified module to receive platform events.
    /// This allows the module to act upon application and platform lifecycle events.
    /// Additionally, this call's the module's `didAddToPlatform()` after adding it.
    /// - important: Modules will be added at the front of the array.
    /// This means that the last added modules will be the first to handle events.
    /// - parameter module: The module to add to the platform.
    public func addModule(_ module: PoqModule) {
        modules.insert(module, at: 0)
        module.didAddToPlatform()
    }
    
    /// Unregisters the specified module from receiving platform events.
    /// Additionally, this call's the module's `willRemoveFromPlatform` before removing it.
    /// - parameter module: The module to remove.
    public func removeModule(_ module: PoqModule) {
        guard let index = modules.index(where: { $0 === module }) else {
            Log.error("Unable find and remove the specified module.")
            return
        }
        
        module.willRemoveFromPlatform()
        modules.remove(at: index)
    }
    
    /// Notifies all modules that the application should be setup.
    public func setupApplication() {
        modules.forEach({ $0.setupApplication() })
    }
    
    /// Notifies all modules that the application should be reset.
    public func resetApplication() {
        modules.forEach({ $0.resetApplication() })
    }
    
    /// Returns the view controller for the specified name from the first module that is able to create it.
    /// Resolves through modules in order of the `PoqPlatform.shared.modules` array.
    /// - parameter name: The name of the view controller to return.
    /// - returns: The view controller corresponding to the specified name, or nil if not found.
    public func resolveViewController(byName name: String) -> UIViewController? {
        for module in modules {
            if let viewController = module.createViewController(forName: name) {
                return viewController
            }
        }
        
        Log.error("Unable to resolve ViewController for name: '\(name)'.")
        return nil
    }
}

// MARK: - Application Lifecycle Forwarding
extension PoqPlatform {
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        return modules.forEach({ $0.application(application, willFinishLaunchingWithOptions: launchOptions) })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        return modules.forEach({ $0.application(application, didFinishLaunchingWithOptions: launchOptions) })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return !modules.filter({ $0.application(app, open: url, options: options) }).isEmpty
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        modules.reduceAsync(false, timeout: PoqPlatform.forwardingTimeout, resultCombiner: { (groupResult, nextPartialResult) in
            nextPartialResult ? nextPartialResult : groupResult
        }, body: { (module, completion) in
            module.application(application, performActionFor: shortcutItem, completionHandler: completion)
        }, completion: { (result, timeoutResult) in
            if timeoutResult == .timedOut {
                Log.error("PoqPlatform forwarding `application(:performActionFor:completionHandler:)` timed out.")
                Log.error("To avoid timeout make sure to call completionHandler within `PoqPlatform.forwardingTimeout`.")
            }
            
            completionHandler(result)
        })
    }
    
}

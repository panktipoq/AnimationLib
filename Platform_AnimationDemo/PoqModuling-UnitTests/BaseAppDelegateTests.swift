//
//  BaseAppDelegateTests.swift
//  PoqModuling-UnitTests
//
//  Created by Joshua White on 31/05/2018.
//

import UserNotifications
import XCTest
@testable import PoqModuling

class BaseAppDelegateTests: XCTestCase {
    
    func testApplicationWillFinishLaunchingForwarding() {

        class MockAppDelegate: BaseAppDelegate {

            let module: PoqModule
            
            init(module: PoqModule) {
                self.module = module
            }
            
            override func setupModules() {
                super.setupModules()
                PoqPlatform.shared.addModule(module)
            }
        }
        
        class MockModule: PoqModule {

            var isRegisteredAndLaunched = false
            
            func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
                isRegisteredAndLaunched = true
            }
        }
        
        let module = MockModule()
        let appDelegate = MockAppDelegate(module: module)
        
        _ = appDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil)
        XCTAssertTrue(module.isRegisteredAndLaunched)
    }
    
    func testApplicationDidFinishLaunchingForwarding() {

        class MockModule: PoqModule {

            var isFinishedLaunching = false
            
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
                isFinishedLaunching = true
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let module = MockModule()
        PoqPlatform.shared.addModule(module)
        
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertTrue(module.isFinishedLaunching)
    }
    
    func testApplicationOpenUrlForwarding() {

        class MockModule: PoqModule {

            var url: URL?
            var isValid = true
            
            func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
                self.url = url
                return isValid
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let module = MockModule()
        PoqPlatform.shared.addModule(module)
        
        let url = URL(string: "test")!
        let validResult = appDelegate.application(UIApplication.shared, open: url)
        XCTAssertEqual(module.url, url)
        XCTAssertTrue(validResult)
        
        module.isValid = false
        let invalidResult = appDelegate.application(UIApplication.shared, open: url)
        XCTAssertFalse(invalidResult)
    }
    
    func testApplicationPerformActionForwarding() {

        class MockModule: PoqModule {

            let handledShortcutItem = UIApplicationShortcutItem(type: "Handled", localizedTitle: "Handled")
            
            func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
                completionHandler(shortcutItem == handledShortcutItem)
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let handlerModule = MockModule()
        let emptyModule = DefaultAppModule()
        PoqPlatform.shared.addModule(handlerModule)
        PoqPlatform.shared.addModule(emptyModule)
        
        let handledExpectation = XCTestExpectation(description: "Action forwarded and handled.")
        appDelegate.application(UIApplication.shared, performActionFor: handlerModule.handledShortcutItem) { (handled) in
            if handled {
                handledExpectation.fulfill()
            }
        }
        
        let unhandledShortcutItem = UIApplicationShortcutItem(type: "Unhandled", localizedTitle: "Unhandled")
        let unhandledExpectation = XCTestExpectation(description: "Action forwarded and not handled.")
        appDelegate.application(UIApplication.shared, performActionFor: unhandledShortcutItem) { (handled) in
            if !handled {
                unhandledExpectation.fulfill()
            }
        }
        
        wait(for: [handledExpectation, unhandledExpectation], timeout: 5)
    }
    
    func testApplicationDidRegisterForRemoteNotificationsForwarding() {

        class MockHandler: PoqUserNotificationHandler {

            var deviceToken: Data?
            
            func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                self.deviceToken = deviceToken
            }
            
            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let handler = MockHandler()
        PoqUserNotificationCenter.shared.addHandler(handler)
        
        let deviceToken = Data(repeating: 0, count: 1)
        appDelegate.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        XCTAssertEqual(handler.deviceToken, deviceToken)
    }
    
    func testApplicationDidFailToRegisterForRemoteNotificationsForwarding() {

        class MockHandler: PoqUserNotificationHandler {

            var error: NSError?
            
            func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
                self.error = error as NSError
            }
            
            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let handler = MockHandler()
        PoqUserNotificationCenter.shared.addHandler(handler)
        
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        appDelegate.application(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: error as Error)
        XCTAssertEqual(handler.error, error)
    }
    
    func testApplicationDidReceiveRemoteNotificationForwarding() {

        class MockHandler: PoqUserNotificationHandler {

            let result: UIBackgroundFetchResult
            
            init(result: UIBackgroundFetchResult) {
                self.result = result
            }
            
            func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
                completionHandler(result)
            }
            
            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
            }
        }
        
        let appDelegate = BaseAppDelegate()
        let handlerHandler = MockHandler(result: .newData)
        PoqUserNotificationCenter.shared.addHandler(handlerHandler)
        
        let newDataExpectation = XCTestExpectation(description: "Action forwarded and handled with new data.")
        appDelegate.application(UIApplication.shared, didReceiveRemoteNotification: [:]) { (result) in
            if result == .newData {
                newDataExpectation.fulfill()
            }
        }
        
        let failedHandler = MockHandler(result: .failed)
        PoqUserNotificationCenter.shared.addHandler(failedHandler)
        
        let failedExpectation = XCTestExpectation(description: "Action forwarded and handled with failure.")
        appDelegate.application(UIApplication.shared, didReceiveRemoteNotification: [:]) { (result) in
            if result == .failed {
                failedExpectation.fulfill()
            }
        }
        
        wait(for: [newDataExpectation, failedExpectation], timeout: 2)
    }
}

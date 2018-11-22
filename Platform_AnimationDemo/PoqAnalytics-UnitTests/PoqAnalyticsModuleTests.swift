//
//  PoqAnalyticsModuleTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Joshua White on 07/06/2018.
//

import XCTest
import PoqModuling
@testable import PoqAnalytics

class PoqAnalyticsModuleTests: XCTestCase {
    
    let module = PoqAnalyticsModule()
    
    override func setUp() {
        super.setUp()
        module.didAddToPlatform()
    }
    
    override func tearDown() {
        module.willRemoveFromPlatform()
        super.tearDown()
    }
    
    func testAppLaunchDirect() {
        module.appLaunchMethod = .shortcut
        
        NotificationCenter.default.post(name: .UIApplicationWillEnterForeground, object: nil)
        XCTAssertEqual(module.appLaunchMethod, .direct)
    }
    
    func testAppLaunchFromDeeplink() {
        let url = URL(string: "TestURL")!
        let handled = module.application(UIApplication.shared, open: url)
        XCTAssertFalse(handled)
        XCTAssertEqual(module.appLaunchMethod, .deeplink)
        XCTAssertEqual(module.appLaunchData, "TestURL")
    }
    
    func testAppLaunchFromShortcut() {
        let expectation = XCTestExpectation(description: "Module should call completion.")
        let shortcut = UIApplicationShortcutItem(type: "Test", localizedTitle: "Test")
        module.application(UIApplication.shared, performActionFor: shortcut) { (handled) in
            XCTAssertFalse(handled)
            XCTAssertEqual(self.module.appLaunchMethod, .shortcut)
            XCTAssertEqual(self.module.appLaunchData, "Test")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testAppLaunchFromPush() {
        let expectation = XCTestExpectation(description: "Module should call completion.")
        module.application(UIApplication.shared, didReceiveRemoteNotification: ["push_id": "TestID"]) { (result) in
            XCTAssertEqual(result, .noData)
            XCTAssertEqual(self.module.appLaunchMethod, .push)
            XCTAssertEqual(self.module.appLaunchData, "TestID")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
}

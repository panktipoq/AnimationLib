//
//  PoqUserNotificationCenterTests.swift
//  PoqModuling-UnitTests
//
//  Created by Joshua White on 31/05/2018.
//

import UserNotifications
import XCTest
@testable import PoqModuling

class PoqUserNotificationCenterTests: XCTestCase {
    
    func testAddHandler() {
        class MockHandler: PoqUserNotificationHandler {
            var isAddedToNotificationCenter = false
            
            func didAddToNotificationCenter() {
                isAddedToNotificationCenter = true
            }
            
            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
            }
        }
        
        let notificationCenter = PoqUserNotificationCenter()
        
        let handler1 = MockHandler()
        notificationCenter.addHandler(handler1)
        XCTAssertTrue(handler1.isAddedToNotificationCenter)
        XCTAssertEqual(notificationCenter.handlers.count, 1)
        XCTAssert(notificationCenter.handlers.first === handler1)
        
        let handler2 = MockHandler()
        notificationCenter.addHandler(handler2)
        XCTAssertEqual(notificationCenter.handlers.count, 2)
        XCTAssert(notificationCenter.handlers.first === handler2)
    }
    
    func testRemoveHandler() {
        class MockHandler: PoqUserNotificationHandler {
            var isRemovedFromNotificationCenter = false
            
            func willRemoveFromNotificationCenter() {
                isRemovedFromNotificationCenter = true
            }
            
            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                completionHandler()
            }
        }
        
        let notificationCenter = PoqUserNotificationCenter()
        
        let handler = MockHandler()
        notificationCenter.addHandler(handler)
        XCTAssertEqual(notificationCenter.handlers.count, 1)
        
        notificationCenter.removeHandler(handler)
        XCTAssertTrue(handler.isRemovedFromNotificationCenter)
        XCTAssertEqual(notificationCenter.handlers.count, 0)
    }
    
}

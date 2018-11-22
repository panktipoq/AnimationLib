//
//  PoqTrackingV2Tests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Manuel Marcos Regalado on 28/11/2017.
//

import XCTest
@testable import PoqAnalytics

class PoqTrackingV2Tests: XCTestCase {
    
    class MockTrackingProvider: PoqAdvancedTrackable {
        func initProvider() {
            print("initProvider")
        }
        
        func logEvent(_ name: String, params: [String: Any]?) {
            print("logEvent")
        }
    }
    
    func testAddRemoveProvider() {
        let tracker = PoqTrackerV2()
        let provider = MockTrackingProvider()
        
        tracker.addProvider(provider)
        XCTAssertEqual(tracker.providers.count, 1)
        
        tracker.removeProvider(provider)
        XCTAssertEqual(tracker.providers.count, 0)
    }
    
    func testTrackerFilterWithoutEmail() {
        let tracker = PoqTrackerV2()
        
        let someString = "Someth@ng"
        let filteredSomeString = tracker.filter(string: someString)
        XCTAssertEqual(filteredSomeString, someString, "The start string and filtered string do not match, but should not have been filtered.")
    }
    
    func testTrackerFilterWithEmail() {
        let tracker = PoqTrackerV2()
        
        let emailString = "something@somewhere.so.domain"
        XCTAssertTrue(emailString.isValidEmail(), "The test string is not a valid email.")
        
        let filteredString = tracker.filter(string: emailString)
        XCTAssertFalse(filteredString.contains(emailString) == true, "The filtered string should not contain the email.")
        XCTAssertFalse(filteredString.isValidEmail()  == true, "The filtered string should not contain a valid email.")
    }
    
    func testTrackerFilterWithEmailUrl() {
        let tracker = PoqTrackerV2()
        
        let emailString = "something@somewhere.so.domain"
        let altEmailString = "awesome@someone.co.ok"
        let emailUrlString = "www.somepage.some.where/some-page/something?email=\(emailString)&someOtherEmail=\(altEmailString)&=page=2"
        XCTAssertTrue(emailUrlString.isValidEmail(), "The second test string does not contain a valid email.")
        
        let filteredUrlString = tracker.filter(string: emailUrlString)
        XCTAssertFalse(filteredUrlString.contains(emailString) == true, "The filtered string should not contain the email.")
        XCTAssertFalse(filteredUrlString.contains(altEmailString) == true, "The filtered string should not contain the alt email.")
        XCTAssertFalse(filteredUrlString.isValidEmail() == true, "The filtered string should not contain a valid email.")
    }
    
    func testTrackerFilterParametersWithEmail() {
        let tracker = PoqTrackerV2()
        
        let emailKey = "email"
        let emailString = "something@somewhere.so.domain"
        let emailParams: [String: String] = [emailKey: emailString]
        XCTAssertTrue(emailParams[emailKey]?.isValidEmail() == true, "The test string is not a valid email.")
        
        let filteredParams = tracker.filter(parameters: emailParams)
        XCTAssertFalse((filteredParams[emailKey] as? String)?.contains(emailString) == true, "The filtered string should not contain the email.")
        XCTAssertFalse((filteredParams[emailKey] as? String)?.isValidEmail() == true, "The filtered string should not contain a valid email.")
    }
    
    func testLogSimpleEventWithEmail() {
        let tracker = PoqTrackerV2()
        tracker.addProvider(MockTrackingProvider())
        tracker.logSimpleEvent("Event", value: "something@somewhere.so.domain")
    }
    
    func testLogAdvancesEventWithEmail() {
        let tracker = PoqTrackerV2()
        tracker.addProvider(MockTrackingProvider())
        tracker.logAdvancedEvent("Event", params: ["email": "something@somewhere.so.domain"])
    }
}

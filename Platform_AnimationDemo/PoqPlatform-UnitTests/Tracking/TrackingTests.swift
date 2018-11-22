//
//  TrackingTests.swift
//  PoqDemoApp-UnitTests
//
//  Created by Joshua White on 17/08/17.
//
//

import XCTest

@testable import PoqPlatform
@testable import PoqModuling

private class TrackingProviderMock: PoqTrackingProtocol {

    func trackInitOrder(_ trackingOrder: PoqTrackingOrder) {}
    func trackCompleteOrder(_ trackingOrder: PoqTrackingOrder) {}
    
    func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double, extraParams: [String: String]?) {
        XCTAssertFalse(label.isValidEmail(), "The label should not contain a valid email.")
        extraParams?.forEach({ XCTAssertFalse($0.value.isValidEmail(), "The value for '\($0.key)' should not contain a valid email.") })
    }
    
    func trackScreenName(_ screenName: String) {}
    func trackCheckoutAction(_ step: Int, option: String) {}
    func trackProductDetails(for product: PoqTrackingProduct) {}
    func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct,  products: [PoqTrackingProduct]) {}
    func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {}
}

class TrackingTests: XCTestCase {
    
    func testTrackerFilterWithoutEmail() {
        let tracker = PoqTracker()
        
        let someString = "Someth@ng"
        let filteredSomeString = tracker.filter(string: someString)
        XCTAssertEqual(filteredSomeString, someString, "The start string and filtered string do not match, but should not have been filtered.")
    }
    
    func testTrackerFilterWithEmail() {
        let tracker = PoqTracker()
        
        let emailString = "something@somewhere.so.domain"
        XCTAssertTrue(emailString.isValidEmail(), "The test string is not a valid email.")
        
        let filteredString = tracker.filter(string: emailString)
        XCTAssertFalse(filteredString.contains(emailString), "The filtered string should not contain the email.")
        XCTAssertFalse(filteredString.isValidEmail(), "The filtered string should not contain a valid email.")
    }
    
    func testTrackerFilterWithEmailUrl() {
        let tracker = PoqTracker()
        
        let emailString = "something@somewhere.so.domain"
        let altEmailString = "awesome@someone.co.ok"
        let emailUrlString = "www.somepage.some.where/some-page/something?email=\(emailString)&someOtherEmail=\(altEmailString)&=page=2"
        XCTAssertTrue(emailUrlString.isValidEmail(), "The second test string does not contain a valid email.")
        
        let filteredUrlString = tracker.filter(string: emailUrlString)
        XCTAssertFalse(filteredUrlString.contains(emailString), "The filtered string should not contain the email.")
        XCTAssertFalse(filteredUrlString.contains(altEmailString), "The filtered string should not contain the alt email.")
        XCTAssertFalse(filteredUrlString.isValidEmail(), "The filtered string should not contain a valid email.")
    }
    
    func testTrackerFilterParametersWithEmail() {
        let tracker = PoqTracker()
        
        let emailKey = "email"
        let emailString = "something@somewhere.so.domain"
        let emailParams: [String: String] = [emailKey: emailString]
        XCTAssertTrue(emailParams[emailKey]?.isValidEmail() == true, "The test string is not a valid email.")
        
        let filteredParams = tracker.filter(parameters: emailParams)
        XCTAssertFalse(filteredParams[emailKey]?.contains(emailString) == true, "The filtered string should not contain the email.")
        XCTAssertFalse(filteredParams[emailKey]?.isValidEmail() == true, "The filtered string should not contain a valid email.")
    }
    
    func testTrackerLogAnalyticsEventWithEmail() {
        let tracker = PoqTracker()
        tracker.trackingProviders = [TrackingProviderMock()]
        tracker.logAnalyticsEvent("Event", action: "Action", label: "something@somewhere.so.domain", extraParams: ["email": "something@somewhere.so.domain"])
    }
}


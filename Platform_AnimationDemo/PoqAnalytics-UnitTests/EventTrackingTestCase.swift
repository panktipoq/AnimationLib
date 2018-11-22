//
//  EventTrackingTestCase.swift
//  PoqAnalytics-UnitTests
//
//  Created by Manuel Marcos Regalado on 29/11/2017.
//

import XCTest
@testable import PoqAnalytics

class EventTrackingTestCase: XCTestCase {
    
    class MockTrackingProvider: PoqAdvancedTrackable, PoqBagTrackable, PoqCatalogueTrackable, PoqCheckoutTrackable, PoqContentTrackable, PoqLoyaltyTrackable, PoqMyAccountTrackable {
        var expectation: XCTestExpectation?
        
        func initProvider() {
        }
        
        func logEvent(_ name: String, params: [String: Any]?) {
            expectation?.fulfill()
        }
    }
    
    var provider: MockTrackingProvider?
    
    override func setUp() {
        super.setUp()
        
        if provider == nil {
            let provider = MockTrackingProvider()
            PoqTrackerV2.shared.addProvider(provider)
            self.provider = provider
        }
        
        provider?.expectation = expectation(description: "Expected events logged.")
    }
    
    override func tearDown() {
        if let provider = provider {
            PoqTrackerV2.shared.removeProvider(provider)
        }
    }
    
}

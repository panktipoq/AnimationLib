//
//  XCTestCaseExtension.swift
//  PoqTesting
//
//  Created by Joshua White on 27/09/2017.
//

import XCTest

extension XCTestCase {
    
    /// Convenience function for debugging to delay for an expectation whilst using a dispatch after that duration.
    /// Otherwise we fail usually because there is something hogging the main thread.
    /// - parameter duration: Approximate sleeping time interval to wait for; in most situations this will be 0.3 or higher.
    final func wait(forDuration duration: TimeInterval = 0.3) {
        let timeExpectation = expectation(description: "Wait for \(duration).")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            timeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: duration + 0.7) { (error: Error?) in
            XCTAssertNil(error, "Fantastic timeout, we sleep on main thread?")
        }
    }
    
}

extension XCTestCase: MockProvider {
    
    open var resourcesBundleName: String {
        return String(describing: type(of: self))
    }
    
}

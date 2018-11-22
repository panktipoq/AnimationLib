//
//  ArrayAsyncTests.swift
//  PoqModuling-UnitTests
//
//  Created by Joshua White on 01/06/2018.
//

import XCTest
@testable import PoqModuling

class ArrayAsyncTests: XCTestCase {
    
    static let integers = [1, 3, 3, 1, 8]
    static let sum = 16
    
    func testForEachAsync() {
        var sum = 0
        
        let expectation = XCTestExpectation(description: "Should call completion.")
        ArrayAsyncTests.integers.forEachAsync(timeout: 1, body: { (integer, completion) in
            sum += integer
            completion()
        }, completion: { (timeoutResult) in
            XCTAssertEqual(sum, ArrayAsyncTests.sum)
            
            if timeoutResult == .success {
                expectation.fulfill()
            }
        })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testForEachAsyncTimeout() {
        let timeoutExpectation = XCTestExpectation(description: "The function should complete after 1s.")
        let pretimeoutExpectation = XCTestExpectation(description: "Should timeout at 1s not before.")
        pretimeoutExpectation.isInverted = true
        
        // Purposely don't call completion in body.
        ArrayAsyncTests.integers.forEachAsync(timeout: 1, body: { (_, _) in }, completion: { (timeoutResult) in
            pretimeoutExpectation.fulfill()
            timeoutExpectation.fulfill()
        })
        
        wait(for: [pretimeoutExpectation], timeout: 0.8)
        wait(for: [timeoutExpectation], timeout: 1.2)
    }
    
    func testReduceAsync() {
        let additionExpectation = XCTestExpectation(description: "Should add all numbers together.")
        ArrayAsyncTests.integers.reduceAsync(0, timeout: 1, resultCombiner: { $0 + $1 }, body: { (integer, completion) in
            completion(integer)
        }, completion: { (result, timeoutResult) in
            XCTAssertEqual(result, ArrayAsyncTests.sum)
            
            if timeoutResult == .success {
                additionExpectation.fulfill()
            }
        })
        
        wait(for: [additionExpectation], timeout: 1)
    }
    
    func testReduceAsyncTimeout() {
        let timeoutExpectation = XCTestExpectation(description: "The function should complete after 1s.")
        let pretimeoutExpectation = XCTestExpectation(description: "Should timeout at 1s not before.")
        pretimeoutExpectation.isInverted = true
        
        // Purposely don't call completion in body.
        ArrayAsyncTests.integers.reduceAsync(0, timeout: 1, resultCombiner: { $0 + $1 }, body: { (_, _) in }, completion: { (result, timeoutResult) in
            pretimeoutExpectation.fulfill()
            timeoutExpectation.fulfill()
        })
        
        wait(for: [pretimeoutExpectation], timeout: 0.8)
        wait(for: [timeoutExpectation], timeout: 1.2)
    }
    
}

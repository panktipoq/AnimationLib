//
//  DelegateCallbackTests.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/4/17.
//
//

import ObjectMapper
import Swifter
import XCTest

@testable import PoqNetworking

class DelegateCallbackTests: XCTestCase {
    
    /// Create request and check that it return ptoper type and proper parsed value
    func testSuccessCallback() {
        let delegate = MockNetworkTaskDelegate()
        let testValueString = "123TestMe"
        
        MockServer.shared["testApiCall"] = { (request: HttpRequest) in
            let jsonString = "{ \"testValue\":  \"\(testValueString)\"}"
            let data = jsonString.data(using: .utf8)!
            
            return .raw(200, "OK", [:], { (writer: HttpResponseBodyWriter) in
                try! writer.write(data)
            })
        }
        
        let networkRequest = PoqNetworkRequest(networkTaskType: TestTaskType.theOnly, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<TestResponse>>(request: networkRequest, networkTaskDelegate: delegate)
        networkRequest.setAppIdPath(format: "/testApiCall")
        NetworkRequestsQueue.addOperation(networkTask)
        
        let responseExpectation = expectation(description: "Response expectation")
        
        delegate.didCompleteBlock = { (type: PoqNetworkTaskTypeProvider, result: [Any]?) in
            XCTAssert(type.type == TestTaskType.theOnly.type, "Wrong type")
            
            if let testValue = result?.first as? TestResponse {
                XCTAssert(testValue.testValue == testValueString, "Wrong value in test response")
            } else {
                XCTAssert(false, "Return wrong type")
            }
            
            responseExpectation.fulfill()
        }

        wait(for: [responseExpectation], timeout: 2)
    }
    
}


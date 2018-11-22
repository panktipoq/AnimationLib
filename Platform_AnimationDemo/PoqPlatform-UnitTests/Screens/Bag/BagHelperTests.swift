//
//  BagHelperTests.swift
//  PoqPlatform-UnitTests
//
//  Created by Balaji Reddy on 22/08/2018.
//

import Foundation
import XCTest

@testable import PoqNetworking
@testable import PoqPlatform

class MockBagNetworkDelegate: PoqNetworkTaskDelegate {
    
    let expectation: XCTestExpectation
    let taskType: PoqNetworkTaskType
    
    init(with expectation: XCTestExpectation, taskType: PoqNetworkTaskType) {
        self.expectation = expectation
        self.taskType = taskType
    }
    
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        XCTAssertEqual(networkTaskType.type, taskType.rawValue, "Wrong network task type")
        
        expectation.fulfill()
    }
    
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        XCTFail("Something wrong with the test setup")
    }
    
}

class BagHelperTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "BagUnitTests"
    }
    
    func testAddToCart() {
        
        BagHelper.usesCartApi = true
        
        MockServer.shared["/cart/items"] = response(forJson: "CartItems", inBundle: "BagUnitTests")
        
        guard let bagItem = responseObject(forJson: "BagItems", ofType: PoqBagItem.self) else {
            
            XCTFail("Something wrong with the test setup")
            return
        }
        
        guard let product = bagItem.product, let selectedSizeID = product.productSizes?[0].id else {
            
            XCTFail("Something wrong with the test setup")
            return
        }
        
        let addToCartExpectation = expectation(description: "AddToCartExpectation")
        let mockBagDelegate = MockBagNetworkDelegate(with: addToCartExpectation, taskType: .postCartItems)
        
        BagHelper.addToBag(delegate: mockBagDelegate, selectedSizeId: selectedSizeID, in: product)
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if error != nil {
                XCTFail("We didn't got response")
            }
        }
    }
    
    func testPostBag() {
        
        BagHelper.usesCartApi = false
        
        MockServer.shared["/BagItems/*/*"] = response(forJson: "BagItems", inBundle: "BagUnitTests")
        
        guard let bagItem = responseObject(forJson: "BagItems", ofType: PoqBagItem.self) else {
            
            XCTFail("Something wrong with the test setup")
            return
        }
        
        guard let product = bagItem.product, let selectedSizeID = product.productSizes?[0].id else {
            
            XCTFail("Something wrong with the test setup")
            return
        }
        
        let addToCartExpectation = expectation(description: "PostBagExpectation")
        let mockBagDelegate = MockBagNetworkDelegate(with: addToCartExpectation, taskType: .postBag)
        
        BagHelper.addToBag(delegate: mockBagDelegate, selectedSizeId: selectedSizeID, in: product)
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if error != nil {
                XCTFail("We didn't got response")
            }
        }
    }
}

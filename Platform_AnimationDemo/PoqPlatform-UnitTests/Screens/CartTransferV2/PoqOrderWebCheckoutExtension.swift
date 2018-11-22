//
//  PoqOrderWebCheckoutExtension.swift
//  PoqPlatform-UnitTests
//
//  Created by Balaji Reddy on 14/11/2018.
//

import XCTest

@testable import PoqNetworking
@testable import PoqPlatform

class PoqOrderWebCheckoutExtensionTests: XCTestCase {
    
    func testSpecialPrice() {
        
        guard let startCartTransferResponseOrder = responseObject(forJson: "StartCartTransferResponse", ofType: StartCartTransferResponse.self)?.order, let orderItems = startCartTransferResponseOrder.items, !orderItems.isEmpty else {
            
            XCTFail("Unable to read test data")
            return
        }
        
        XCTAssertEqual(orderItems[0].price, 39.99, "Test data is wrongly setup")
        XCTAssertEqual(orderItems[0].specialPrice, 14.99, "Test data is wrongly setup")
        
        let poqOrderItem = PoqOrderItem(orderItem: orderItems[0])
        
        XCTAssertEqual(poqOrderItem.price, 14.99, "Special price not considered for PodOrderItem")
    }
}

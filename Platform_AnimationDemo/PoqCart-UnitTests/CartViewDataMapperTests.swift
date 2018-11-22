//
//  CartViewDataMapperTests.swift
//  PoqCart-UnitTests
//
//  Created by Balaji Reddy on 02/07/2018.
//

import Foundation
import XCTest

@testable import PoqCart

public class CartViewDataMapperTests: XCTestCase {
    
    var cart: CartDomainModel?

    override public func setUp() {

        cart = CartTestDataProvider.cart
    }
    
    func testSuccesfulViewDataMapping() {
        
        let viewDataMapper = CartViewDataMapper()
        
        guard let cart = cart else {
            XCTFail("Cart not initialised")
            return
        }
        
        let viewData = viewDataMapper.mapToViewData(cart)
        
        XCTAssertEqual(viewData.numberOfCartItems, 2, "Wrong value for numberOfCartItems")

        XCTAssertEqual(viewData.total, "$270.00", "Wrong total")
        
        XCTAssertEqual(viewData.contentBlocks.count, 2, "Wrong number of content blocks")
        
        let cartItemContentBlockCount = viewData.contentBlocks.reduce(0, {
            
            if case CartContentBlocks.cartItemCard = $1 {
                return $0 + 1
            }
            
            return $0
        })
        
        XCTAssertEqual(cartItemContentBlockCount, 2, "Wrong number of Cart Item Content Blocks")
    }
}

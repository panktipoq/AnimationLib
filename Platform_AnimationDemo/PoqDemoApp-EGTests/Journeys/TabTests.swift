//
//  TabTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Nikolay Dzhulay on 6/12/17.
//

import EarlGrey

class TabTests: EGTestCase {
    
    override func setUp() {
        super.setUp()
        
        insertInitialResponses()
        insertInitialViewController()
    }
    
    func testHomeTab() {
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func testShopTab() {
        EarlGrey.selectElement(with: grey_text("Shop")).assert(with: grey_sufficientlyVisible())
    }
    
    func testBagTab() {
        EarlGrey.selectElement(with: grey_text("Bag")).assert(with: grey_sufficientlyVisible())
    }
    
    func testWishlistTab() {
        EarlGrey.selectElement(with: grey_text("Wishlist")).assert(with: grey_sufficientlyVisible())
    }
    
    func testMoreTab() {
        EarlGrey.selectElement(with: grey_text("More")).assert(with: grey_sufficientlyVisible())
    }
}

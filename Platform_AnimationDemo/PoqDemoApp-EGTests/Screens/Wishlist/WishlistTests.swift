//
//  WishlistTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Rokas Jovaisa on 13/11/2018.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class WishlistTests: EGTestCase {
    
    private var firstPoduct: PoqProduct?
    private var lastProduct: PoqProduct?
    
    override var resourcesBundleName: String {
        return "WishlistTests"
    }
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared["/wishlist/*/*/"] = response(forJson: "WishlistResults")
        let products = responseObjects(forJson: "WishlistResults", ofType: PoqProduct.self)
        firstPoduct = products?.first
        lastProduct = products?.last
        insertWishlistViewController()
    }
    
    func testFirstProductTitleExistsInWishList() {
        testTitleExists(title: firstPoduct?.title)
    }
    
    func testFirstProductPriceExistsInWishList() {
        testPriceLabelExists(product: firstPoduct)
    }
    
    func testLastProductTitleExistsInWishList() {
        swipeUp()
        testTitleExists(title: lastProduct?.title)
    }
    
    func testLastProductPriceExistsInWishList() {
        swipeUp()
        testPriceLabelExists(product: lastProduct)
    }
    
    private func insertWishlistViewController() {
        let wishlistViewController = WishlistViewController(nibName: "WishlistView", bundle: nil)
        insertNavigationController(withViewController: wishlistViewController)
    }
    
    private func swipeUp() {
        EarlGrey.selectElement(with: grey_kindOfClass(WishListTableViewCell.self))
            .atIndex(2)
            .perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.5)
    }
    
    private func testTitleExists(title: String?) {
        guard let titleUnwrapped = title else {
            GREYAssert(false, "Could not get the title of the product from response. Check Mock")
            return
        }
        
        EarlGrey.elementExists(with: grey_text(titleUnwrapped))
    }
    
    private func testPriceLabelExists(product: PoqProduct?) {
        func hasStringAttributes(_ expectedStringAttributes: NSAttributedString) -> GREYAssertionBlock {
            return GREYAssertionBlock(name: "Assert String Has Given Attributes") { (element, _) in
                guard let label = element as? UILabel else {
                    return false
                }
                
                return label.attributedText == expectedStringAttributes
            }
        }
        
        let expectedStringAttributes = LabelStyleHelper.initPriceLabel(product?.price,
                                                                       specialPrice: product?.specialPrice,
                                                                       isGroupedPLP: false,
                                                                       priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                                                                       priceFontStyle: AppTheme.sharedInstance.wishlistPriceFont,
                                                                       specialPriceFontStyle: AppTheme.sharedInstance.wishlistSpecialPriceFont)
        
        EarlGrey.selectElement(with: grey_text(expectedStringAttributes.string)).assert(hasStringAttributes(expectedStringAttributes))
    }
}

//
//  ProductListTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Balaji Reddy on 15/12/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class ProductListTests: EGTestCase {
    var firstProduct: PoqProduct?
    var productWithoutSpecialPrice: PoqProduct?
    var lastProduct: PoqProduct?

    let hasStringAttributes = { (expectedStringAttributes: NSAttributedString) -> GREYAssertionBlock in
        return GREYAssertionBlock.assertion(withName: "Assert String Has Given Attributes",
                                            assertionBlockWithError: { (element: Any?, errorOrNil: UnsafeMutablePointer<NSError?>?) -> Bool in
                                                guard let label = element as? UILabel else {
                                                    let errorInfo = [NSLocalizedDescriptionKey:
                                                        NSLocalizedString("Element is not a UILabel",
                                                                          comment: "")]
                                                    errorOrNil?.pointee =
                                                        NSError(domain: kGREYInteractionErrorDomain,
                                                                code: 2,
                                                                userInfo: errorInfo)
                                                    return false
                                                }
                                                return label.attributedText == expectedStringAttributes
        })
    }

    override func setUp() {
        super.setUp()

        MockServer.shared["/products/filter/*"] = response(forJson: "ProductListTests")
        let filterResult = responseObjects(forJson: "ProductListTests", ofType: PoqFilterResult.self)?.first
        firstProduct = filterResult?.products?.first
        productWithoutSpecialPrice = filterResult?.products?.first(where: { $0.specialPrice == 0 })
        lastProduct = filterResult?.products?.last

    }

    override func tearDown() {
        super.tearDown()
    }

    func insertProductListViewController() {
        let productListViewController = ProductListViewController(nibName: "ProductListView", bundle: nil)
        productListViewController.selectedCategoryId = 1111
        productListViewController.selectedCategoryTitle = "Test Category"
        productListViewController.source = "Test Category"
        insertNavigationController(withViewController: productListViewController)
    }

    func testFirstProductExistsInProductList() {
        insertProductListViewController()
        guard let firstProductTitle = firstProduct?.title else {
            GREYAssert(true, "Could not get the title of the first product from response. Check Mock")
            return
        }
        guard EGHelpers.wait(forMatcher: grey_text(firstProductTitle), timeout: 2.0) else {
            GREYFail("Expected a firstProductTitle.")
            return
        }
    }

    func testLastProductExistsInProductList() {
        insertProductListViewController()
        EarlGrey.selectElement(with: grey_kindOfClass(ProductListViewCell.self)).atIndex(2)
        .perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.4)

        guard let lastProductTitle = lastProduct?.title else {
            GREYAssert(true, "Could not get the title of the last product from response. Check Mock")
            return
        }
        EarlGrey.elementExists(with: grey_text(lastProductTitle))
    }

    func testProducPriceWithSpecialPrice() {

        insertProductListViewController()

        let expectedStringAttributes = LabelStyleHelper.initPriceLabel(firstProduct?.price,
                                                                       specialPrice: firstProduct?.specialPrice,
                                                                       isGroupedPLP: false,
                                                                       priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                                                                       priceFontStyle: AppTheme.sharedInstance.plpPriceFont,
                                                                       specialPriceFontStyle: AppTheme.sharedInstance.plpSpecialPriceFont)

        EarlGrey.selectElement(with: grey_text(expectedStringAttributes.string)).assert(hasStringAttributes(expectedStringAttributes))
    }

    func testProducPriceWithoutSpecialPrice() {
        insertProductListViewController()

        let expectedStringAttributes = LabelStyleHelper.initPriceLabel(productWithoutSpecialPrice?.price,
                                                                       specialPrice: productWithoutSpecialPrice?.specialPrice,
                                                                       isGroupedPLP: false,
                                                                       priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                                                                       priceFontStyle: AppTheme.sharedInstance.plpPriceFont,
                                                                       specialPriceFontStyle: AppTheme.sharedInstance.plpSpecialPriceFont)

        EarlGrey.selectElement(with: grey_text(expectedStringAttributes.string)).assert(hasStringAttributes(expectedStringAttributes))
    }
}

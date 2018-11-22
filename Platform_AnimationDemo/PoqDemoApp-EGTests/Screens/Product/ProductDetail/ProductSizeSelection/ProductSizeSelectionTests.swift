//
//  ProductSizeSelectionTests.swift
//  PoqPlatform
//
//  Created by Rachel McGreevy on 20/12/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class ProductSizeSelectionTests: EGTestCase {

    var product: PoqProduct?

    /// MARK: - Set up functions

    override func setUp() {
        super.setUp()

        MockServer.shared["/products/detail/*/*"] = response(forJson: "ProductWithMultipleSizes")
        MockServer.shared["/BagItems/*/*"] = response(forJson: "AddToBagSuccessfulResponse")
    }

    override func tearDown() {
        super.tearDown()
    }

    func insertProductDetailViewController(with productJsonFile: String) {
        let productDetailViewController = ModularProductDetailViewController(nibName: "ModularProductDetailView", bundle: nil)

        product = responseObject(forJson: productJsonFile, ofType: PoqProduct.self)
        productDetailViewController.selectedProductId = product?.id
        productDetailViewController.selectedProductExternalId = product?.externalID

        insertNavigationController(withViewController: productDetailViewController)
    }

    func addProductToBag() {
        EarlGrey.selectElement(with: grey_accessibilityID(AccessibilityLabels.pdpAddToBag)).perform(grey_tap())
    }

    func updateMBSettingsToClassicSizeSelector() {
        AppLocalization.sharedInstance.pdpSelectSizeHeaderText = "Size Selector"
        AppSettings.sharedInstance.pdpSizeSelectorType = ProductSizeSelectorType.classic.rawValue
        AppLocalization.sharedInstance.pdpSizesOneSizeText = "one size"
    }

    func updateMBSettingsToSheetSizeSelector() {
        AppLocalization.sharedInstance.pdpSelectSizeHeaderText = "Pick your size"
        AppSettings.sharedInstance.pdpSizeSelectorType = ProductSizeSelectorType.sheet.rawValue
        AppLocalization.sharedInstance.pdpSizesOneSizeText = "one size"
        AppSettings.sharedInstance.isLowStockEnabledOnSizeSelector = true
        AppSettings.sharedInstance.lowStockProductLevel = 8
    }

    /// MARK: - Classic Size Selector tests

    func testClassicSizeSelectorDoesShow() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToClassicSizeSelector()
        addProductToBag()
        EarlGrey.elementExists(with: grey_text("Size Selector"))
    }

    func testClassicSizeSelectorDoesClose() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToClassicSizeSelector()
        addProductToBag()
        EarlGrey.selectElement(with: grey_text("Size Selector")).perform(grey_swipeFastInDirection(.down))
        EarlGrey.selectElement(with: grey_text("Size Selector")).assert(with: grey_nil())
    }

    func testClassicSizeSelectorShowsCorrectSizes() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToClassicSizeSelector()
        addProductToBag()
        let productSizes = product?.productSizes
        let countOfTableViewCells = EGHelpers.count(matcher: grey_kindOfClass(ProductSizeTableViewCell.self))
        GREYAssertEqual(productSizes?.count, countOfTableViewCells)
    }

    func testClassicSizeSelectorDoesNotShowForOneSizeProduct() {
        MockServer.shared["/products/detail/*/*"] = response(forJson: "ProductWithOneSize")
        insertProductDetailViewController(with: "ProductWithOneSize")
        updateMBSettingsToClassicSizeSelector()
        addProductToBag()
        EarlGrey.selectElement(with: grey_text("Size Selector")).assert(with: grey_nil())
    }

    /// MARK: - Sheet Size Selector tests

    func testSheetSizeSelectorDoesShow() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToSheetSizeSelector()
        addProductToBag()
        EarlGrey.elementExists(with: grey_accessibilityID(SheetNavigationControllerViewAccessibilityIdentifier))
    }

    func testSheetSizeSelectorDoesClose() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToSheetSizeSelector()
        addProductToBag()
        EarlGrey.selectElement(with: grey_accessibilityID(SheetContainerViewAccessibilityIdentifier)).perform(grey_tap())
        EarlGrey.selectElement(with: grey_text("Pick your size")).assert(with: grey_nil())
    }

    func testSheetSizeSelectorShowsCorrectSizes() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToSheetSizeSelector()
        addProductToBag()
        let productSizes = product?.productSizes
        let countOfTableViewCells = EGHelpers.count(matcher: grey_kindOfClass(ProductSizeTableViewCell.self))
        GREYAssertEqual(productSizes?.count, countOfTableViewCells)
    }

    func testSheetSizeSelectorDoesNotShowForOneSizeProduct() {
        MockServer.shared["/products/detail/*/*"] = response(forJson: "ProductWithOneSize")
        insertProductDetailViewController(with: "ProductWithOneSize")
        updateMBSettingsToSheetSizeSelector()
        addProductToBag()
        EarlGrey.selectElement(with: grey_accessibilityID(SheetNavigationControllerViewAccessibilityIdentifier)).assert(with: grey_nil())
    }
    
    func testSheetSizeSelectorShowsLowStockLabel() {
        insertProductDetailViewController(with: "ProductWithMultipleSizes")
        updateMBSettingsToSheetSizeSelector()
        addProductToBag()
        
        guard let productSizes = product?.productSizes else {
            GREYFail("product sizes equal to nil")
            return
        }
        
        var countOfLowStockProducts = 0
        for size in productSizes {
            if let quantity = size.quantity, Double(quantity) <= AppSettings.sharedInstance.lowStockProductLevel {
                countOfLowStockProducts += 1
            }
        }
        
        let countOfLowStockLabels = EGHelpers.countVisible(matcher: grey_accessibilityID(AccessibilityLabels.lowStock))
        GREYAssertEqual(countOfLowStockProducts, countOfLowStockLabels)
    }
}

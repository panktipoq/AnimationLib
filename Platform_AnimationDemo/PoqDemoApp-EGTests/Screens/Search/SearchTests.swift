//
//  PredictiveSearchTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Gabriel Sabiescu on 11/02/2018.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class SearchTests: EGTestCase {
    
    // Mark: - Predictive search tests
    // _________________________
    
    func insertPredictiveHomeViewControllerWithPredictiveSearch(forJson file: String) {
        // Initialise the App from the splash screen since we load the AppSettings in there
        MockServer.shared["/splash/ios/*/3"] = response(forJson: file, inBundle: "PredictiveSearchTests")
        MockServer.shared["/search/apps/*/predictions"] = response(forJson: "PredictiveSearchTests")
        mockPredictiveSearchEndpointResponse()
        insertInitialViewController()
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func mockPredictiveSearchEndpointResponse() {
        MockServer.shared["/search/apps/*/predictions"] = response(forJson: "ValidResponse", inBundle: "PredictiveSearchTests")
    }
    
    func testPredictiveBothIconsDisabled() {
        insertPredictiveHomeViewControllerWithPredictiveSearch(forJson: "BothSearchBarButtonsDisabled")
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_notVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_notVisible())
    }
    
    func testPredictiveBarcodeIconEnabled() {
        insertPredictiveHomeViewControllerWithPredictiveSearch(forJson: "OnlyBarcodeScannerEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_notVisible())
    }
    
    func testPredictiveVisualSearchIconEnabled() {
        insertPredictiveHomeViewControllerWithPredictiveSearch(forJson: "OnlyVisualSearchEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_notVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
    }
    
    func testPredictiveBothIconsEnabled() {
        insertPredictiveHomeViewControllerWithPredictiveSearch(forJson: "BothSearchBarButtonsEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
    }
    
    func testTypedSearchWordInTopCell() {
        insertPredictiveHomeViewControllerWithPredictiveSearch(forJson: "BothSearchBarButtonsDisabled")
        EarlGrey.selectElement(with: grey_accessibilityID(AccessibilityLabels.search)).type("tees")
        EarlGrey.selectElement(with: grey_allOf([grey_kindOfClass(UICollectionView.self), grey_descendant(grey_text("tees"))])).assert(with: grey_sufficientlyVisible())
    }
    // Mark: - Non-predictive search tests
    // _________________________
    
    func insertHomeViewControllerWithClassicSearch(forJson file: String) {
        // Initialise the App from the splash screen since we load the AppSettings in there
        MockServer.shared["/splash/ios/*/3"] = response(forJson: file, inBundle: "ClassicSearchTests")
        insertInitialViewController()
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func testClassicBothIconsDisabled() {
        insertHomeViewControllerWithClassicSearch(forJson: "BothSearchBarButtonsDisabled")
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_notVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_notVisible())
    }
    
    func testClassicBarcodeIconEnabled() {
        insertHomeViewControllerWithClassicSearch(forJson: "OnlyBarcodeScannerEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_notVisible())
    }
    
    func testClassicVisualSearchIconEnabled() {
        insertHomeViewControllerWithClassicSearch(forJson: "OnlyVisualSearchEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_notVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
    }
    
    func testClassicBothIconsEnabled() {
        insertHomeViewControllerWithClassicSearch(forJson: "BothSearchBarButtonsEnabled")
        EarlGrey.selectElement(with: grey_accessibilityID(visualSearchButtonAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
        EarlGrey.selectElement(with: grey_accessibilityID(barcodeScannerAccessibilityIdentifier)).assert(with: grey_sufficientlyVisible())
    }
    
    func testClassicSearchForPredictiveSearchResults() {
        insertHomeViewControllerWithClassicSearch(forJson: "BothSearchBarButtonsEnabled")
        let searchField = EarlGrey.selectElement(with: grey_accessibilityID(AccessibilityLabels.search))
        searchField.assert(with: grey_sufficientlyVisible())
        searchField.type("Shirt")
        var error: NSError? = nil
        EarlGrey.selectElement(with: grey_textFieldValue("Shirts in Men")).atIndex(0).assert(with: grey_nil(), error: &error)

        if error != nil {
            GREYFail("The search result was not found")
        }
    }
}

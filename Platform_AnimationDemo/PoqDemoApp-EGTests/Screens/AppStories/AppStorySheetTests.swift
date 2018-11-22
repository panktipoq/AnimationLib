//
//  AppStorySheetTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Nikolay Dzhulay on 9/19/17.
//

import EarlGrey
import UIKit

@testable import PoqNetworking
@testable import PoqPlatform

class AppStorySheetTests: EGTestCase {
    
    override var resourcesBundleName: String {
        return "AppStoriesTests"
    }
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared["app173/11176197-1.png"] = response(forResource: "11176197-1", ofType: "png")
        MockServer.shared["app173/11158308-1.jpg"] = response(forResource: "11158308-1", ofType: "jpg")
        MockServer.shared["9749086-540.jpg"] = response(forResource: "9749086-540", ofType: "jpg")
        MockServer.shared["app173/11158306-thumb.png"] = response(forResource: "11158306-thumb", ofType: "png")
        
        MockServer.shared["products/by_external_ids/*?externalIds=*"] = response(forJson: "Products")
        MockServer.shared["products/detail/*/*"] = response(forJson: "ProductDetail")
        
        // Dismiss happens on next run loop, which lead to issues with view controllers hierarchy
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: false)
        // So we dismiss and wait a little bit
        wait(forDuration: 0.1)
    }
    
    func testSheetAndPlp() {
        let stories = responseObject(forJson: "Autoplay.Disabled", ofType: PoqAppStoryResponse.self)?.stories ?? []
        GREYAssertEqual(stories.count, 3)
        
        let viewController = AppStoryViewController(with: stories[1], cardAt: 0)         
        UIApplication.shared.delegate?.window??.rootViewController = viewController
        
        let storyBottomOverlayMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCardBottomOverlayAccessibilityIdentifier)
        let tap = GREYActions.actionForTap()
        EarlGrey.selectElement(with: storyBottomOverlayMatcher).atIndex(0).perform(tap)
        
        // check tht sheet presented
        let sheetContainerMatcher = GREYMatchers.matcher(forAccessibilityID: SheetContainerViewAccessibilityIdentifier)
        EarlGrey.elementExists(with: sheetContainerMatcher)
        
        let navigationControllerMatcher = GREYMatchers.matcher(forAccessibilityID: SheetNavigationControllerViewAccessibilityIdentifier)
        EarlGrey.elementExists(with: navigationControllerMatcher)
    }

    /// Test flow:
    /// 1. Open app stories
    /// 2. Open products plp in sheet
    /// 3. Select product
    /// 4. Check Pdp info presented
    /// 5. Close product and sheet
    func testProductsNavigation() {
        
        // Present sheet
        let stories = responseObject(forJson: "Autoplay.Disabled", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let viewController = AppStoryViewController(with: stories[1], cardAt: 0)         
        UIApplication.shared.delegate?.window??.rootViewController = viewController
        
        let storyBottomOverlayMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCardBottomOverlayAccessibilityIdentifier)
        let tap = GREYActions.actionForTap()
        EarlGrey.selectElement(with: storyBottomOverlayMatcher).atIndex(0).perform(tap)
        
        // Check that cells are presented
        let firstProductCellId = GREYMatchers.matcher(forAccessibilityID: carouselCellBaseAccessibilityIdentifier + "427")
        EarlGrey.elementExists(with: firstProductCellId)
        
        let secondProductCellId = GREYMatchers.matcher(forAccessibilityID: carouselCellBaseAccessibilityIdentifier + "426")
        EarlGrey.selectElement(with: secondProductCellId).perform(tap)
        
        // check tah PDP loaded and it hase close button and back
        let pdpInfoViewIdMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoryProductInfoViewAccessibilityIdentifier)
        let backPdpInfoViewIdMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoryProductInfoBackButtonAccessibilityIdentifier)
        
        EarlGrey.elementExists(with: pdpInfoViewIdMatcher)
        EarlGrey.elementExists(with: backPdpInfoViewIdMatcher)
        
        // Close sheet
        let closePdpInfoViewIdMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoryProductInfoCloseButtonAccessibilityIdentifier)
        EarlGrey.selectElement(with: closePdpInfoViewIdMatcher).perform(tap)
        
        EarlGrey.selectElement(with: pdpInfoViewIdMatcher).assert(grey_nil())
        let sheetContainerMatcher = GREYMatchers.matcher(forAccessibilityID: SheetContainerViewAccessibilityIdentifier)
        EarlGrey.selectElement(with: sheetContainerMatcher).assert(grey_nil())
    }
    
}

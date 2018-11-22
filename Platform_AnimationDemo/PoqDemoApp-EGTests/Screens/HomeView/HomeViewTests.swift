//
//  HomeViewTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Manuel Marcos Regalado on 22/09/2018.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform
@testable import PoqDemoApp
@testable import PoqModuling

class HomeViewTests: EGTestCase {
    let appStoryCarouselMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoriesCarouselAccessibilityId)

    override func setUp() {
        super.setUp()
        HomeViewController.isSkeletonsEnabled = true
    }
    
    func insertHomeViewController(shouldSetupNetworkResponses: Bool = false) {
        if shouldSetupNetworkResponses {
            MockServer.shared["banners/*"] = response(forJson: "Banners")
            MockServer.shared["appstories/apps/*/home"] = response(forJson: "Stories")
        }
        insertInitialViewController()
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func testScrollableBannersAfterSkeletons() {
        insertHomeViewController(shouldSetupNetworkResponses: true)
        scrollableCell(type: BannerCell.self)
    }
    
    func testScrollableAppStoriesAfterSkeletons() {
        PoqDemoModule.appStoryCarouselType = .card
        AppSettings.sharedInstance.isStoriesCarouselOnHomeEnabled = true
        insertHomeViewController(shouldSetupNetworkResponses: true)
        scrollableCell(type: AppStoryCarouselCardCell.self)
    }
    
    func scrollableCell(type: AnyClass) {
        EarlGrey.elementExists(with: grey_kindOfClass(type))
        EarlGrey.selectElement(with: grey_kindOfClass(type)).atIndex(0).perform(grey_swipeFastInDirection(.up))
    }
    
    func testTappableBannersAfterSkeletons() {
        insertHomeViewController(shouldSetupNetworkResponses: true)
        tappableCell(type: BannerCell.self)
    }
    
    func testTappableAppStoriesAfterSkeletons() {
        insertHomeViewController(shouldSetupNetworkResponses: true)
        tappableCell(type: AppStoryCarouselCardCell.self)
    }
    
    func tappableCell(type: AnyClass) {
        EarlGrey.elementExists(with: grey_kindOfClass(type))
        EarlGrey.selectElement(with: grey_kindOfClass(type)).atIndex(0).tap()
    }
}

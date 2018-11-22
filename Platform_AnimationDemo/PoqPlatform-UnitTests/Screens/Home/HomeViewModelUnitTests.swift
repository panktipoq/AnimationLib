//
//  HomeViewModelUnitTests.swift
//  PoqDemoApp-UnitTests
//
//  Created by Nikolay Dzhulay on 7/28/17.
//
//

import Swifter
import XCTest

@testable import PoqDemoApp
@testable import PoqNetworking
@testable import PoqPlatform

private class HomePresenterMock: HomeViewPresenter, ViewOwner {
    var storyCarouselType: StoryCarouselType = .card
    
    let expectation: XCTestExpectation
    init(withExpectation expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    var view: UIView! = UIView()

    func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        XCTAssert(Thread.isMainThread, "Should be called only on main thread, since will make some UI work")
        if networkTaskType == PoqNetworkTaskType.appStories || networkTaskType == PoqNetworkTaskType.homeBanner {
            expectation.fulfill()
        }
    }
    
    func showErrorMessage(_ networkError: NSError?) {
        XCTAssert(false, "Here we should not get any error")
    }
}

class HomeViewModelUnitTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "HomeTests"
    }
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared["banners/*"] = response(forJson: "Banners")
        
        // This UnitTest is making the assumption that AppStories are enabled in the frontend. Therefore, the frontend flag `isStoriesCarouselOnHomeEnabled` to fetch and display App Stories should be enable
        AppSettings.sharedInstance.isStoriesCarouselOnHomeEnabled = true
        // Make sure sign in home banner won't appears
        AppSettings.sharedInstance.displayFirstTimeBanner = false
    }
    
    func testNonEmptyUserStories() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Stories")
        
        let homeBannerExpectation = expectation(description: "HomeBannerExpectation")
        let mockPresenter = HomePresenterMock(withExpectation: homeBannerExpectation)
        let homeViewModel = HomeViewModel(presenter: mockPresenter)
        
        homeViewModel.fetchAppStories()
        
        waitForExpectations(timeout: 3) { 
            (error: Error?) in
            if error != nil {
                XCTFail("We didn't got response")
            }
        }
        
        print("homeViewModel.homeBannerItems.count = \(homeViewModel.homeContentItems.count)")
        XCTAssertEqual(homeViewModel.homeContentItems.count, 1)
        if let storiesBanner = homeViewModel.homeContentItems.first,
            let bannerItem = storiesBanner.bannerItem {
            switch bannerItem.type {
            case .stories(_):
                break
            default:
                XCTFail("First banner should be stories, but we got: \(bannerItem.type)")
            }
        }
    }
    
    func testEmptyUserStories() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Stories.Empty")
        
        let homeBannerExpectation = expectation(description: "HomeBannerExpectation")
        let mockPresenter = HomePresenterMock(withExpectation: homeBannerExpectation)
        let homeViewModel = HomeViewModel(presenter: mockPresenter)
        
        homeViewModel.fetchAppStories()
        
        waitForExpectations(timeout: 3) { 
            (error: Error?) in
            if error != nil {
                XCTAssert(false, "We didn't got response")
            }
        }
        XCTAssertEqual(homeViewModel.homeContentItems.count, 0)
    }
    
    func testHomeBanners() {
        let homeBannerExpectation = expectation(description: "HomeBannerExpectation")
        let mockPresenter = HomePresenterMock(withExpectation: homeBannerExpectation)
        let homeViewModel = HomeViewModel(presenter: mockPresenter)
        
        homeViewModel.fetchBanners()
        
        waitForExpectations(timeout: 3) { 
            (error: Error?) in
            if error != nil {
                XCTAssert(false, "We didn't got response")
            }
        }
        
        XCTAssertEqual(homeViewModel.homeContentItems.count, 16)
    }
}

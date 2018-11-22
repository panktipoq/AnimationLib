//
//  PoqContentTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Rachel McGreevy on 1/19/18.
//

import XCTest
import PoqNetworking
import PoqPlatform
@testable import PoqAnalytics
@testable import PoqPlatform

class PoqContentTrackableTests: EventTrackingTestCase {
    
    func testOnboardingBeginTracking() {
        
        PoqTrackerV2.shared.onboarding(action: "begin")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testOnboardingCompleteTracking() {
        
        PoqTrackerV2.shared.onboarding(action: "complete")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAppOpenTracking() {
        
        PoqTrackerV2.shared.appOpen(method: "appOpenTest", campaign: "Test")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testBannerTapTracking() {
        
        PoqTrackerV2.shared.bannerTap(bannerTitle: "testBanner", bannerType: "testImage")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testLookbookTapTracking() {
        
        PoqTrackerV2.shared.lookbookTap(lookbookTitle: "testLookbook", type: "test", productId: 12345, screenNumber: 1)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testStoreFinderTracking() {
        
        PoqTrackerV2.shared.storeFinder(action: "testDetails", storeName: "testStore")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testAppStoriesTracking() {
        
        PoqTrackerV2.shared.appStories(action: "testOpen", storyTitle: "testStory", cardTitle: "testCard")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    /// MARK: - Tests to confirm custom provider recieves calls from code
    
    func testOnboardingBeginEventTracked() {
        
        let onboardingViewController = OnboardingViewController(nibName: "OnboardingView", bundle: nil)
        _ = onboardingViewController.view
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testOnboardingCompleteEventTracked() {
        
        let onboardingViewController = OnboardingViewController(nibName: "OnboardingView", bundle: nil)
        _ = onboardingViewController.view
        resetProviderExpectation()
        onboardingViewController.completeButtonAction(WhiteButton())
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// Can't test the appOpen event currently as the tracking call isn't reach if we're running tests
    
    func testBannerTapEventTracked() {

        let homeViewController = HomeViewController(nibName: "HomeView", bundle: nil)
        let homeBanner = HomeContent(identifier: BannerCell.poqReuseIdentifier, bannerItem: HomeBannerItem(type: .imageBanner, poqHomeBanner: PoqHomeBanner()))
        homeViewController.viewModel.homeContentItems = [homeBanner]
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        homeViewController.bannersCollectionView = collectionView
        
        guard let bannersCollectionView = homeViewController.bannersCollectionView else {
            XCTFail("Banner collection view is empty")
            return
        }
        
        homeViewController.collectionView(bannersCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testLookbookTapProductEventTracked() {
        
        let lookbookImageView = LookbookImageView.createLookbookImageView()
        lookbookImageView?.lookbookImage = PoqLookbookImage()
        lookbookImageView?.lookbookImageProducts = [PoqProduct()]
        lookbookImageView?.lookbookTitle = "testLookbook"
        lookbookImageView?.screenNumber = 1
        
        lookbookImageView?.lookbookButtonClicked(UIButton())
                
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testStoreFinderDetailsEventTracked() {
        
        NavigationHelper.sharedInstance.loadStoreDetail(12345, storeTitle: "testStore")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testStoreFinderPhoneCallEventTracked() {
        
        let storePhoneDetail = StoreDetailViewModel()
        storePhoneDetail.callButtonClicked()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// Can't test store finder Directions event due to alertSheet
    
    func testAppStoriesOpenEventTracked() {
        let stories = responseObject(forJson: "Stories", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let appStoryViewController = AppStoryViewController(with: stories[0], cardAt: 0)
        _ = appStoryViewController.view
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAppStoriesDismissEventTracked() {
        let stories = responseObject(forJson: "Stories", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let appStoryViewController = AppStoryViewController(with: stories[0], cardAt: 0)
        _ = appStoryViewController.view
        resetProviderExpectation()
        appStoryViewController.dismissAppStory(animated: false)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAppStoriesPDPSwipeEventTracked() {
        let stories = responseObject(forJson: "Stories", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let appStoryViewController = AppStoryViewController(with: stories[0], cardAt: 2)
        appStoryViewController.bottomOverlayTapRecognizerAction(sender: UITapGestureRecognizer())

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAppStoriesPLPSwipeEventTracked() {
        let stories = responseObject(forJson: "Stories", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let appStoryViewController = AppStoryViewController(with: stories[0], cardAt: 3)
        appStoryViewController.bottomOverlayTapRecognizerAction(sender: UITapGestureRecognizer())

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAppStoriesWebviewSwipeEventTracked() {
        let stories = responseObject(forJson: "Stories", ofType: PoqAppStoryResponse.self)?.stories ?? []
        let appStoryViewController = AppStoryViewController(with: stories[0], cardAt: 0)
        appStoryViewController.bottomOverlayTapRecognizerAction(sender: UITapGestureRecognizer())

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Helper Functions
    
    /// Use this method to reset expectation after the initial expectation has already been fulfilled
    func resetProviderExpectation() {
        provider?.expectation = expectation(description: "ContentExpectation")
    }
}

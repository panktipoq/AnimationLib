//
//  ReviewsTests.swift
//  PoqDemoApp-EGTests
//
//  Created by GabrielMassana on 26/10/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class ReviewsTests: EGTestCase {

    // MARK: - Accessors
    
    var productID: Int?
    var firstReview: PoqProductReview?
    var lastReview: PoqProductReview?

    // MARK: - TestSuiteLifecycle

    override func setUp() {
        
        super.setUp()
        
        productID = 001170
        firstReview = responseObjects(forJson: "Reviews", ofType: PoqProductReview.self)?.first
        lastReview = responseObjects(forJson: "Reviews", ofType: PoqProductReview.self)?.last
        
        MockServer.shared["/productreviews/*/*"] = response(forJson: "Reviews")
    }
    
    override func tearDown() {
        
        productID = nil
        firstReview = nil
        lastReview = nil
        
        super.tearDown()
    }
    
    func insertReviews(isModal: Bool = false) {
        let reviewsController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
        reviewsController.productId = productID
        reviewsController.isModal = isModal
        insertNavigationController(withViewController: reviewsController)
    }
    
    func insertReviews() {
        let reviewsController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
        reviewsController.productId = productID
        insertNavigationController(withViewController: reviewsController)
    }
    
    func test_navigationBarTitle() {
        insertReviews()
        EarlGrey.selectElement(with: grey_accessibilityLabel("Ratings & Reviews"))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem_Presented() {
        insertReviews()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem_Modal() {
        insertReviews(isModal: true)
        EarlGrey.selectElement(with: grey_kindOfClass(CloseButton.self))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem_tap() {
        insertReviews()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .perform(grey_tap())
            .assert(with: grey_enabled())
    }

    func test_fisrtReview_reviewtext() {
        insertReviews()
        let reviewText = firstReview?.reviewText
        EarlGrey.elementExists(with: grey_text(reviewText!))
    }
    
    func test_fisrtReview_username() {
        insertReviews()
        let username = firstReview?.username
        EarlGrey.elementExists(with: grey_text(username!))
    }
    
    func test_fisrtReview_title() {
        insertReviews()
        let title = firstReview?.title
        EarlGrey.elementExists(with: grey_text(title!))
    }
    
    func test_lastReview_reviewtext() {
        insertReviews()
        
        EarlGrey.selectElement(with: grey_kindOfClass(UITableView.self))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.4)
        
        let reviewText = lastReview?.reviewText
        _ = EGHelpers.wait(forMatcher: grey_text(reviewText!), timeout: 2.0)
    }
    
    func test_lastReview_username() {
        insertReviews()
        
        EarlGrey.selectElement(with: grey_kindOfClass(UITableView.self))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.4)
        
        let username = lastReview?.username
        EarlGrey.elementExists(with: grey_text(username!))
    }
    
    func test_lastReview_title() {
        insertReviews()
        
        EarlGrey.selectElement(with: grey_kindOfClass(UITableView.self))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
            .perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.4)
        
        let title = lastReview?.title
        EarlGrey.elementExists(with: grey_text(title!))
    }
    
    func test_starRating_exists() {
        insertReviews()
        EarlGrey.elementExists(with: grey_kindOfClass(StarRatingView.self))
    }
}

//
//  AppStoriesTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Nikolay Dzhulay on 8/15/17.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform
@testable import PoqDemoApp

class AppStoriesTests: EGTestCase {
    
    override func setUp() {
        super.setUp()
        // Disable Skeleton views in App Stories because they are shown before the mock networking is done and earlgrey 
        HomeViewController.isSkeletonsEnabled = false
        MockServer.shared["app173/11176197-1.png"] = response(forResource: "11176197-1", ofType: "png")
        MockServer.shared["app173/11158308-1.jpg"] = response(forResource: "11158308-1", ofType: "jpg")
        MockServer.shared["app173/11158306-thumb.png"] = response(forResource: "11158306-thumb", ofType: "png")
    }
    
    func insertHomeViewControllerWithAppStories() {
        // Initialise the App from the splash screen since we load the AppSettings in there
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "AppStoriesEnabled")
        PoqDemoModule.appStoryCarouselType = .card
        insertInitialViewController()
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func setupCircularAppStories() {
        
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "ManyStoriesList")
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "AppStoriesEnabled")
        
        PoqDemoModule.appStoryCarouselType = .circular
        insertInitialViewController()
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
    }
    
    func testCircularAppStoriesAreCircular() {
      
        setupCircularAppStories()

        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let storyElementAccessibilityId = AppStoryCarouselCircularCellImageContainerViewIdBase + firstStoryId
        
        let circularStoryMatcher = GREYMatchers.matcher(forAccessibilityID: storyElementAccessibilityId)
        
        let circularAssertion =  GREYAssertionBlock(name: "Check Story is Circular") { (element: Any?, _) in
            guard let storyCircleImageContainerView = element as? UIView else {
                return false
            }
            
            if storyCircleImageContainerView.frame.width != storyCircleImageContainerView.frame.height {
                
                return false
            }
            
            if storyCircleImageContainerView.layer.cornerRadius != storyCircleImageContainerView.frame.width/2 {
                
                return false
            }
            
            return true
            
        }
        
        EarlGrey.selectElement(with: circularStoryMatcher).assert(circularAssertion)
    }
    
    func testStoryTitleShownForCircularStories() {
        
        setupCircularAppStories()
        
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let storyElementTitleAccessibilityId = AppStoryCarouselCircularCellStoryTitleViewIdBase + firstStoryId
        
        let circularStoryTitleMatcher = GREYMatchers.matcher(forAccessibilityID: storyElementTitleAccessibilityId)
        
        EarlGrey.selectElement(with: circularStoryTitleMatcher).assertIsVisible()
        
        EarlGrey.selectElement(with: circularStoryTitleMatcher).assertText(matches: "Accessories")
    }
    
    func testCircularAppStoriesHasBorder() {
        
        setupCircularAppStories()
        
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let storyElementAccessibilityId = AppStoryCarouselCircularCellImageContainerViewIdBase + firstStoryId
        
        let circularStoryMatcher = GREYMatchers.matcher(forAccessibilityID: storyElementAccessibilityId)
        
        let hasGradientBorderAssertion = GREYAssertionBlock(name: "Check App Story Has Border") { (element: Any?, _) in
           
            guard let storyCircleImageContainerView = element as? UIView else {
                return false
            }
            
            var hasCircularBorder = false
            storyCircleImageContainerView.layer.sublayers?.forEach { layer in
                if layer is CAGradientLayer && layer.frame.width == layer.frame.height {
                    
                    hasCircularBorder = true
                }
            }
            
            return hasCircularBorder
        }
        
        EarlGrey.selectElement(with: circularStoryMatcher).assert(hasGradientBorderAssertion)
    }
    
    func testCircularAppStoriesBorderChangesColorOnViewing() {
        
        // First clear stories so when we create the view controller no stories have been seen yet
        PoqDataStore.store?.deleteAll(forObjectType: ViewedAppStory(), completion: nil)
        // Delete operation might take time
        wait(forDuration: 1)
        setupCircularAppStories()
        
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let storyElementAccessibilityId = AppStoryCarouselCircularCellImageContainerViewIdBase + firstStoryId
        
        let circularStoryMatcher = GREYMatchers.matcher(forAccessibilityID: storyElementAccessibilityId)
        
        var gradientBorderColorsToAssert = AppStoryCarouselCircularCell.unViewedStoryBorderGradientColors.map { $0.cgColor }
        let hasGradientBorderAssertion = GREYAssertionBlock(name: "Check App Story Changes Color On Viewing") { (element: Any?, _) in
            
            guard let storyCircleImageContainerView = element as? UIView else {
                return false
            }
            
            var hasUnViewedGradientColors = false
            storyCircleImageContainerView.layer.sublayers?.forEach { layer in
                if let gradientLayer = layer as? CAGradientLayer, let gradientBorderColors = gradientLayer.colors as? [CGColor] {
                    
                    hasUnViewedGradientColors = gradientBorderColors == gradientBorderColorsToAssert
                }
            }
            
            return hasUnViewedGradientColors
        }
        
        EarlGrey.selectElement(with: circularStoryMatcher).assert(hasGradientBorderAssertion)
        
        EarlGrey.selectElement(with: circularStoryMatcher).tap()
        let storyCloseButtonMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCloseButtonAccessibilityIdentifier)
        EarlGrey.selectElement(with: storyCloseButtonMatcher).tap()

        gradientBorderColorsToAssert = AppStoryCarouselCircularCell.viewedStoryBorderGradientColors.map { $0.cgColor }
        EarlGrey.selectElement(with: circularStoryMatcher).assert(hasGradientBorderAssertion)
    }
    
    func testCircularAppStoryAlignedLeftAfterViewing() {
        
        setupCircularAppStories()
        
        let thirdStoryId = "45230714-8ee6-42e2-8c92-e3d3f18b6877"
        let storyElementAccessibilityId = AppStoryCarouselCircularAccessibilityIdBase + thirdStoryId
        
        let circularStoryMatcher = GREYMatchers.matcher(forAccessibilityID: storyElementAccessibilityId)
        
        EarlGrey.selectElement(with: circularStoryMatcher).tap()
        let storyCloseButtonMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCloseButtonAccessibilityIdentifier)
        EarlGrey.selectElement(with: storyCloseButtonMatcher).tap()
        
        checkCircleIsLeftAligned(withId: thirdStoryId)
    }
    
    func testAppStoriesFlag() {
        // App Stories frontend setting flag is enabled in the splash screen response
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "AppStoriesEnabled")
        
        insertInitialViewController()
        
        _ = EGHelpers.wait(forMatcher: grey_text("Home"), timeout: 5.0)
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
        let carouselMatcherEnabled = GREYMatchers.matcher(forAccessibilityID: AppStoriesCarouselAccessibilityId)
        // App Stories should NOT appear on screen
        EarlGrey.selectElement(with: carouselMatcherEnabled).assert(grey_notNil())
    }
    
    func testAppStoriesDisabled() {
        // App Stories frontend setting flag is disable in the splash screen response
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "AppStoriesDisabled")
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        
        insertInitialViewController()
        
        EarlGrey.selectElement(with: grey_text("Home")).assert(with: grey_sufficientlyVisible())
        let carouselMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoriesCarouselAccessibilityId)
        // App Stories should appear on screen
        EarlGrey.selectElement(with: carouselMatcher).assert(grey_nil())
    }

    /// - Tap on right story
    /// - Close story with close button
    /// - Check that second story, now on center
    /// - Open story again
    /// - Close story with swipe down
    func testStoryOpenAndClose() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        // 1. Check stories carousel
        let carouselCell = findCarousel()
        
        // 2. Check right card and tap
        let secondStoryId = "d915b34c-27d3-4f30-bcd5-90c82f3e9992"
        let secondCardId = AppStoryCarouselCardAccessibilityIdBase + secondStoryId
        let secondCardMatcher = GREYMatchers.matcher(forAccessibilityID: secondCardId)
        
        let rightCardAssertion = GREYAssertionBlock(name: "Check Right Card") { (element: Any?, _) in
            guard let rightCardView = element as? UIView, let carousel = carouselCell else {
                return false
            }
            
            let convertedCenter = carousel.convert(rightCardView.center, from: rightCardView.superview)
            return abs(convertedCenter.x - carousel.center.x) > 20
        }
        
        let tap = grey_tap()
        EarlGrey.selectElement(with: secondCardMatcher).assert(rightCardAssertion).perform(tap)
        
        // 3. Check that story VC presented and close
        let storyCloseButtonMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCloseButtonAccessibilityIdentifier)

        let buttonFound = UIView.view(withIdentifier: appStoryCloseButtonAccessibilityIdentifier) != nil
        GREYAssert(buttonFound, "We can't close view without button")
        
        EarlGrey.selectElement(with: storyCloseButtonMatcher).perform(tap)
        
        // 4. Check that second card in center
        let centerCardAssertion = GREYAssertionBlock(name: "Check center Card") { (element: Any?, _) in
            guard let secondCardView = element as? UIView, let carousel = carouselCell else {
                return false
            }
            
            let convertedCenter = carousel.convert(secondCardView.center, from: secondCardView.superview)
            return abs(convertedCenter.x - carousel.center.x) < 3
        }
        
        EarlGrey.selectElement(with: secondCardMatcher).assert(centerCardAssertion)
        
        // 5. open and close with swipe
        EarlGrey.selectElement(with: secondCardMatcher).perform(tap)
        EarlGrey.elementExists(with: storyCloseButtonMatcher)
        
        let storyViewMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryViewAccessibilityIdentifier)
        let swipeDown = GREYActions.actionForSwipeFast(in: .down)
        
        EarlGrey.selectElement(with: storyViewMatcher).perform(swipeDown)
        EarlGrey.selectElement(with: secondCardMatcher).assert(centerCardAssertion)
    }
    
    // Sometimes works

//    func testxAutoplay() {
//        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Enabled")
//        insertHomeViewControllerWithAppStories()
//
//        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
//        let firstCarouselCardMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoryCarouselCardAccessibilityIdBase + firstStoryId)
//        EarlGrey.selectElement(with: firstCarouselCardMatcher).perform(grey_tap())
//
//        // WARNING: Because of timer on this screen, we have to search views manually!!!!!!!
//
//        let firstCardAccssibilityId = AppStoryCardViewAccessibilityIdBase + "f222f8fb-5717-4d78-b8e7-818f14449595"
//        let firstCardViewFound = UIView.view(withIdentifier: firstCardAccssibilityId) != nil
//        GREYAssert(firstCardViewFound, "First card view wan't loaded at all")
//
//        wait(forDuration: 4.0)
//
//        let secondCardAccssibilityId = AppStoryCardViewAccessibilityIdBase + "18e9de75-5aee-451d-a073-bb51c228b9f7"
//        let secondCardViewFound = UIView.view(withIdentifier: secondCardAccssibilityId) != nil
//        GREYAssert(secondCardViewFound, "Autoplay didn't switch card")
//    }

//    // Never works, even being exactly the same code than testAutoplay()
//    func testxxAutoplay() {
//
//        GREYTestHelper.enableFastAnimation()
//
//        let storyId = AppStoryCarouselCardAccessibilityIdBase + "4b268b62-da05-43ce-8dff-a29c3da9f166"
//        let firstCardId = AppStoryCardViewAccessibilityIdBase + "f222f8fb-5717-4d78-b8e7-818f14449595"
//        let secondCardId = AppStoryCardViewAccessibilityIdBase + "18e9de75-5aee-451d-a073-bb51c228b9f7"
//
//        // Load Home with the stories present in the JSON file 'Autoplay.Enabled'
//        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Enabled")
//        insertHomeViewControllerWithAppStories()
//
//        // click the first story
//        onView(with: .accessibilityIdentifier(storyId)).tap()
//
//        for cardId in [firstCardId, secondCardId] {
//            guard EGHelpers.wait(forMatcher: grey_accessibilityID(cardId), timeout: 5.0) else {
//                GREYFail("Card \(cardId) didn’t show up")
//                return
//            }
//        }
//    }
    
    /// FIXME: - This test is failing because we are trying to assert for a view
    /// That’s buried under 3 other views and EG doesn’t find the view we’re looking for
    /// This test needs to be fixed!
//    func testAutoplay() {
//
//        GREYTestHelper.enableFastAnimation()
//
//        // Load Home with the stories present in the JSON file 'Autoplay.Enabled'
//        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Enabled")
//        insertHomeViewControllerWithAppStories()
//
//        // click the first story
//        let firstStoryId = AppStoryCarouselCardAccessibilityIdBase + "4b268b62-da05-43ce-8dff-/a29c3da9f166"
//        onView(with: .accessibilityIdentifier(firstStoryId)).tap()
//
//        // wait for first card
//        let firstCard = AppStoryCardViewAccessibilityIdBase + "f222f8fb-5717-4d78-b8e7-818f14449595"
//        guard EGHelpers.wait(forMatcher: grey_accessibilityID(firstCard), timeout: 5.0) else {
//            GREYFail("Card \(firstCard) didn’t show up")
//            return
//        }
//
//        // wait for second card
//        let secondCard = AppStoryCardViewAccessibilityIdBase + "18e9de75-5aee-451d-a073-bb51c228b9f7"
//        guard EGHelpers.wait(forMatcher: grey_accessibilityID(secondCard), timeout: 5.0) else {
//            GREYFail("Card \(secondCard) didn’t show up")
//            return
//        }
//    }
    
    /// - Open first story
    /// - Check that it has icon
    /// - Check that is has title
    /// - Check that it has 4 dashes on top
    func testOverlayElements() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        let stories = responseObject(forJson: "Autoplay.Disabled", ofType: PoqAppStoryResponse.self)?.stories ?? []
        GREYAssertEqual(stories.count, 3)
        
        guard let carousel = findCarousel() as? AppStoriesCarouselCell else {
            GREYFail("Carousel must be presented")
            return
        }
        
        let storiesViewController = AppStoryNavigationController(appStories: stories, selectedIndex: 0)
        storiesViewController?.carouselDelegate = carousel
        storiesViewController?.navigateToStory(at: 0, presentedCard: .first)
        
        guard let storiesViewControllerUnwrapped = storiesViewController else {
            GREYFail("smth wrong with stories")
            return
        }
        
        guard let windowOrNil: UIWindow? = UIApplication.shared.delegate?.window, let window = windowOrNil else {
            GREYFail("Window is required for any iOS app")
            return
        }
        
        window.rootViewController?.present(storiesViewControllerUnwrapped, animated: true)
        
        // wait for animations
        wait(forDuration: 0.25)
        
        let firstCardAccessibilityId = AppStoryCardViewAccessibilityIdBase + "f222f8fb-5717-4d78-b8e7-818f14449595"
        let firstCardViewFound = window.recursivelyTest { (view: UIView) in
            return view.accessibilityIdentifier == firstCardAccessibilityId 
        }
        
        GREYAssert(firstCardViewFound, "View controller wasn't presented")
        
        let titleLabel = window.view(withIdentifier: appStoryTitleLabelAccessibilityIdentifier) as? UILabel
        GREYAssertEqual(titleLabel?.text, "Accessories")
        
        let iconImageView = window.view(withIdentifier: appStoryIconImageViewAccessibilityIdentifier) as? UIImageView
        GREYAssertNotNil(iconImageView?.image)
        
        let progresBars: [AppStoryCardProgressView] = window.recursivelyFind()
        GREYAssertEqual(progresBars.count, stories[0].cards.count)
    }
    
    /// - Test that single card non-autoplay story hide progress bar
    func testSingleCardOverlayElements() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        let stories = responseObject(forJson: "Autoplay.Disabled", ofType: PoqAppStoryResponse.self)?.stories ?? []
        GREYAssertEqual(stories.count, 3)
        
        guard let carousel = findCarousel() as? AppStoriesCarouselCell else {
            GREYFail("Carousel must be presented")
            return
        }
        
        // Load second story: which has only 1 card
        let storiesViewController = AppStoryNavigationController(appStories: stories, selectedIndex: 1)
        storiesViewController?.carouselDelegate = carousel
        storiesViewController?.navigateToStory(at: 1, presentedCard: .first)
        
        guard let storiesViewControllerUnwrapped = storiesViewController else {
            GREYFail("smth wrong with stories")
            return
        }
        
        guard let windowOrNil: UIWindow? = UIApplication.shared.delegate?.window, let window = windowOrNil else {
            GREYFail("Window is required for any iOS app")
            return
        }
        
        window.rootViewController?.present(storiesViewControllerUnwrapped, animated: true)
        
        // wait for animations
        wait(forDuration: 0.25)
        
        let countView = window.view(withIdentifier: appStoryCardCountViewAccessibilityIdentifier)
        GREYAssert(countView?.isHidden == true)
    }
    
    /// - Check that stories carousel is left aligned for first card
    /// - Check that stories carousel is center aligned for second card
    /// - Check that stories carousel is right aligned for third/last card
    func testLeftRightStoriesCraouselAligment() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        // 1. Check left card and swipe left
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let elementInteraction = checkCardIsLeftAligned(withId: firstStoryId)
        let swipeLeft = GREYActions.actionForSwipeSlow(in: GREYDirection.left)
        _ = elementInteraction?.perform(swipeLeft)
        
        // 2. check centered card and swipe
        let secondStoryId = "d915b34c-27d3-4f30-bcd5-90c82f3e9992"
        let secondElementInteraction = checkCardIsCentered(withId: secondStoryId)
        _ = secondElementInteraction?.perform(swipeLeft)
        
        // 3. Check left card and swipe left
        let thirdStoryId = "45230714-8ee6-42e2-8c92-e3d3f18b6877"
        checkCardIsRightAligned(withId: thirdStoryId)        
    }
    
    /// - Check that stories carousel is center aligned for single story response
    func testSingleStoriesCarouselAligment() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Story.Single")
        insertHomeViewControllerWithAppStories()
        
        // 1. Check left card and swipe left
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        checkCardIsCentered(withId: firstStoryId)
    }
    
    func testProductsOverlayOnStory() {
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        // Find second story
        let cardId = AppStoryCarouselCardAccessibilityIdBase + "d915b34c-27d3-4f30-bcd5-90c82f3e9992"
        let cardMatcher = GREYMatchers.matcher(forAccessibilityID: cardId)
        
        let tap = GREYActions.actionForTap()
        EarlGrey.selectElement(with: cardMatcher).perform(tap)
        
        // Check bottom overlay
        let storyBottomOverlayMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCardBottomOverlayAccessibilityIdentifier)
        EarlGrey.elementExists(with: storyBottomOverlayMatcher)
        
        let textMatcher = GREYMatchers.matcher(forText: "Test Action Label")
        EarlGrey.elementExists(with: textMatcher)
    }

    func testWebView() {
        let stories = responseObject(forJson: "WebLink", ofType: PoqAppStoryResponse.self)?.stories ?? []
        GREYAssertEqual(stories.count, 2)
        
        let viewController = AppStoryViewController(with: stories[0], cardAt: 0)
        UIApplication.shared.delegate?.window??.rootViewController = viewController
        
        let storyBottomOverlayMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCardBottomOverlayAccessibilityIdentifier)
        EarlGrey.selectElement(with: storyBottomOverlayMatcher).atIndex(0).perform(grey_tap())
        
        // check that the webview is presented
        EarlGrey.elementExists(with: grey_accessibilityID(poqWebViewAccessibilityIdentifier))
    }
    
    func testVideo() {
        let stories = responseObject(forJson: "WebLink", ofType: PoqAppStoryResponse.self)?.stories ?? []
        GREYAssertEqual(stories.count, 2)
        
        let viewController = AppStoryViewController(with: stories[1], cardAt: 0)
        UIApplication.shared.delegate?.window??.rootViewController = viewController
        
        let storyBottomOverlayMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryCardBottomOverlayAccessibilityIdentifier)
        EarlGrey.selectElement(with: storyBottomOverlayMatcher).assert(grey_notNil()).perform(grey_tap())
        
        // check that the video is presented
        EarlGrey.elementExists(with: grey_accessibilityID(appStoryFullScreenVideoViewAccessibilityIdentifier))
    }
    
    /// - Check that unviewed story label is showing on unviewed story
    func testUnviewedAppStoryLabelIsShowingOnUnviewedStory() {
        // Clear seen stories storage before initialising home view controller
        PoqDataStore.store?.deleteAll(forObjectType: ViewedAppStory(), completion: nil)
        // Delete operation might take time
        wait(forDuration: 1)
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Enabled")
        insertHomeViewControllerWithAppStories()
        
        // Check first 2 stories have their 'new' label displayed
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let firstStoryUnviewedStoryLabel = findUnviewedStoryLabel(firstStoryId)
        GREYAssert(firstStoryUnviewedStoryLabel?.isHidden == false)
        
        let secondStoryId = "d915b34c-27d3-4f30-bcd5-90c82f3e9992"
        let secondStoryUnviewedStoryLabel = findUnviewedStoryLabel(secondStoryId)
        GREYAssert(secondStoryUnviewedStoryLabel?.isHidden == false)
    }
    
    /// - Check that unviewed story label doesn't show on viewed story
    func testUnviewedAppStoryLabelIsNotShowingOnViewedStory() {
        // Clear seen stories storage before initialising home view controller
        PoqDataStore.store?.deleteAll(forObjectType: ViewedAppStory(), completion: nil)
        // Delete operation might take time
        wait(forDuration: 1)
        MockServer.shared["appstories/apps/*/home"] = response(forJson: "Autoplay.Disabled")
        insertHomeViewControllerWithAppStories()
        
        // Open first story card
        let firstStoryId = "4b268b62-da05-43ce-8dff-a29c3da9f166"
        let firstCardId = AppStoryCarouselCardAccessibilityIdBase + firstStoryId
        let firstCardMatcher = GREYMatchers.matcher(forAccessibilityID: firstCardId)
        let tap = GREYActions.actionForTap()
        EarlGrey.selectElement(with: firstCardMatcher).perform(tap)
        
        // Wait for a second then close story
        wait(forDuration: 1)
        
        let storyViewMatcher = GREYMatchers.matcher(forAccessibilityID: appStoryViewAccessibilityIdentifier)
        let swipeDown = GREYActions.actionForSwipeFast(in: .down)
        EarlGrey.selectElement(with: storyViewMatcher).perform(swipeDown)
        
        // Find 'new' label on first story card and check that it's hidden now first story has been viewed
        let unviewedStoryLabel = findUnviewedStoryLabel(firstStoryId)
        GREYAssert(unviewedStoryLabel?.isHidden == true)
        
        // Check the second story still has its 'new' label displayed
        let secondStoryId = "d915b34c-27d3-4f30-bcd5-90c82f3e9992"
        let secondStoryUnviewedStoryLabel = findUnviewedStoryLabel(secondStoryId)
        GREYAssert(secondStoryUnviewedStoryLabel?.isHidden == false)
    }
    
    /// Checks that specific card in carousel is centered.
    /// - returns: Element for any addition actions and checks
    @discardableResult
    fileprivate func checkCardIsCentered(withId storyId: String) -> GREYElementInteraction? {
        let cardId = AppStoryCarouselCardAccessibilityIdBase + storyId
        let cardMatcher = GREYMatchers.matcher(forAccessibilityID: cardId)
        
        guard let carousel = self.findCarousel() else {
            GREYFail("Carousel must be presented")
            return nil
        }
        
        let centerCardAssertion = GREYAssertionBlock(name: "Check Center Card") { (element: Any?, _) in
            guard let cardView = element as? UIView else {
                return false
            }
            
            let convertedCenter = carousel.convert(cardView.center, from: cardView.superview)
            return abs(convertedCenter.x - carousel.center.x) < 20
        }
        
        let element = EarlGrey.selectElement(with: cardMatcher).assert(centerCardAssertion)
        return element
    }
    
    /// Checks that specific card in carousel is left aligned.
    /// - returns: Element for any addition actions and checks
    @discardableResult
    fileprivate func checkCardIsLeftAligned(withId storyId: String) -> GREYElementInteraction? {
        let cardId = AppStoryCarouselCardAccessibilityIdBase + storyId
        let cardMatcher = GREYMatchers.matcher(forAccessibilityID: cardId)
        
        guard let carousel = self.findCarousel() else {
            GREYFail("Carousel must be presented")
            return nil
        }

        let leftCardAssertion = GREYAssertionBlock(name: "Check Left Card") { (element: Any?, _) in
            guard let cardView = element as? UIView else {
                return false
            }
            
            let convertedOrigin = carousel.convert(cardView.frame.origin, from: cardView.superview)
            return abs(convertedOrigin.x) < 20
        }
        
        let element = EarlGrey.selectElement(with: cardMatcher).assert(leftCardAssertion)
        return element
    }
    
    /// Checks that specific card in carousel is right aligned.
    /// - returns: Element for any addition actions and checks
    @discardableResult
    fileprivate func checkCardIsRightAligned(withId storyId: String) -> GREYElementInteraction? {
        let cardId = AppStoryCarouselCardAccessibilityIdBase + storyId
        let cardMatcher = GREYMatchers.matcher(forAccessibilityID: cardId)
        
        guard let carousel = self.findCarousel() else {
            GREYFail("Carousel must be presented")
            return nil
        }
        
        let rightCardAssertion = GREYAssertionBlock(name: "Check Right Card") { (element: Any?, _) in
            guard let cardView = element as? UIView else {
                return false
            }
            
            let convertedFrame = carousel.convert(cardView.frame, from: cardView.superview)
            return abs(convertedFrame.maxX - carousel.frame.width) < 20
        }
        
        let element = EarlGrey.selectElement(with: cardMatcher).assert(rightCardAssertion)
        return element
    }
    
    /// Checks that specific card in carousel is right aligned.
    /// - returns: Element for any addition actions and checks
    @discardableResult
    fileprivate func checkCircleIsLeftAligned(withId storyId: String) -> GREYElementInteraction? {
        let cardId = AppStoryCarouselCircularAccessibilityIdBase + storyId
        let circularCellMatcher = GREYMatchers.matcher(forAccessibilityID: cardId)
        
        guard let carousel = self.findCarousel() else {
            GREYFail("Carousel must be presented")
            return nil
        }
        
        let leftCircleAssertion = GREYAssertionBlock(name: "Check Left Card") { (element: Any?, _) in
            guard let cardView = element as? UIView else {
                return false
            }
            
            let convertedOrigin = carousel.convert(cardView.frame.origin, from: cardView.superview)
            return abs(round(convertedOrigin.x)) == 0
        }
        
        return EarlGrey.selectElement(with: circularCellMatcher).assert(leftCircleAssertion)
    }
    
    fileprivate func findCarousel() -> UIView? {
        let carouselMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoriesCarouselAccessibilityId)
        
        var carouselView: UIView?
        let assertion = GREYAssertionBlock(name: "Check existence") { (element: Any?, error: UnsafeMutablePointer<NSError?>?) in
            carouselView = element as? UIView
            error?.pointee = nil
            return element != nil
        }
        
        EarlGrey.selectElement(with: carouselMatcher).assert(assertion)
        return carouselView
    }
    
    fileprivate func findUnviewedStoryLabel(_ storyId: String) -> UIView? {
        let unviewedLabelMatcher = GREYMatchers.matcher(forAccessibilityID: AppStoryCarouselCardUnviewedLabelAccessibilityIdBase + storyId)
        
        var unviewedStoryLabel: UIView?
        let assertion = GREYAssertionBlock(name: "Check existance") { (element: Any?, error: UnsafeMutablePointer<NSError?>?) in
            unviewedStoryLabel = element as? UIView
            error?.pointee = nil
            return element != nil
        }
        
        EarlGrey.selectElement(with: unviewedLabelMatcher).assert(assertion)
        return unviewedStoryLabel
    }
}

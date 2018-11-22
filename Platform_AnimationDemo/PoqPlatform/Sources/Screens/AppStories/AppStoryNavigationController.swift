//
//  AppStoryNavigationController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/4/17.
//
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

public protocol AppStoryCarouselPresenter: AnyObject {
    
    func storyWasPresented(at index: Int)
}

public protocol AppStoryNavigationControllerDelegate: AnyObject {
    
    func appStoryNavigationControllerDidNavigateToStory(atIndex index: IndexPath)
}

open class AppStoryNavigationController: UINavigationController {
    
    public let appStories: [PoqAppStory]
    open var selectedIndex: Int
    
    public weak var carouselDelegate: AppStoryNavigationControllerDelegate?
    public weak var storyCarouselPresenter: AppStoryCarouselPresenter?
    
    public var topAppStoryCardGradientLocations: [Double]?
    public var topAppStoryCardGradientColors: [UIColor]?
    
    public var bottomAppStoryCardGradientLocations: [Double]?
    public var bottomAppStoryCardGradientColors: [UIColor]?
    
    fileprivate var storyCarouselType: StoryCarouselType?
    
    /// To create AppStoriesNavigationController we need:
    ///      1. `selectedIndex` must be in range 0..<appStories.count
    ///      2. appStories.count > 1
    ///      3. storyCarouselType - card type by default. Set to circular for circular stories.
    public init?(appStories: [PoqAppStory], selectedIndex: Int, storyCarouselType: StoryCarouselType = .card) {
        
        let range = 0..<appStories.count
        
        guard appStories.count > 0, range.contains(selectedIndex) else {
            Log.error("Input parameters do not satisfy retquirements")
            return nil
        }
        
        self.appStories = appStories
        self.selectedIndex = selectedIndex
        
        self.storyCarouselType = storyCarouselType
        
        super.init(nibName: nil, bundle: nil)
        
        isNavigationBarHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        /// Story cards might disable this timer. So as failover scenrio, lets turn it on
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /// Navigate to next story if possible. If not - dismiss AppStoryNavigationController
    public func navigateToNextStory(autoOpen: Bool) {
        guard selectedIndex < appStories.count - 1 else {
            dismiss(animated: true)
            return
        }
        // Track user plays a story
        let titleOfSelectedStory = appStories[selectedIndex + 1].title
        PoqTrackerHelper.trackAutoplayAppStory(storyTitle: titleOfSelectedStory ?? "")
        navigateToStory(at: selectedIndex + 1, presentedCard: .first, storyAutoOpened: autoOpen)
    }
    
    /// Navigate to prev story if possible. If not - dismiss AppStoryNavigationController
    public func navigateToPrevStory() {
        guard selectedIndex > 0 else {
            navigateToStory(at: 0, presentedCard: .first)
            return
        }
        
        navigateToStory(at: selectedIndex - 1, presentedCard: .last)
    }
    
    // MARK: - Private
    
    public enum StoryPresentedCard {
        case first
        case last
    }
    
    /// Push new AppStoryViewController and update `selectedIndex`
    open func navigateToStory(at index: Int, presentedCard: StoryPresentedCard, storyAutoOpened: Bool = false) {
        Log.verbose("Navigate to story at index \(index)")
        guard index < appStories.count, appStories[index].cards.count > 0 else {
            Log.error("Trying open story with invalid index: \(index)")
            return
        }

        selectedIndex = index
        storyCarouselPresenter?.storyWasPresented(at: selectedIndex)
        
        let appStory = appStories[selectedIndex]
        carouselDelegate?.appStoryNavigationControllerDidNavigateToStory(atIndex: IndexPath(row: selectedIndex, section: 0))
        
        let startIndex: Int
        switch presentedCard {
        case .first:
            startIndex = 0
        case .last:
            startIndex = appStory.cards.count - 1 
        }
        
        let appStoryViewController = AppStoryViewController(with: appStory, cardAt: startIndex, storyCarouselType: storyCarouselType ?? .card)
        
        if let topAppStoryCardGradientLocationsUnwrapped = topAppStoryCardGradientLocations {
            appStoryViewController.topAppStoryCardGradientLocations = topAppStoryCardGradientLocationsUnwrapped
        }
        
        if let topAppStoryCardGradientColorsUnwrapped = topAppStoryCardGradientColors {
            appStoryViewController.topAppStoryCardGradientColors = topAppStoryCardGradientColorsUnwrapped
        }
        
        if let bottomAppStoryCardGradientLocationsUnwrapped = bottomAppStoryCardGradientLocations {
            appStoryViewController.bottomAppStoryCardGradientLocations = bottomAppStoryCardGradientLocationsUnwrapped
        }
        
        if let bottomAppStoryCardGradientColorsUnwrapped = bottomAppStoryCardGradientColors {
            appStoryViewController.bottomAppStoryCardGradientColors = bottomAppStoryCardGradientColorsUnwrapped
        }
        
        appStoryViewController.storyCardOpenMethod = storyAutoOpened ? .autoOpen : .userPrompted
        viewControllers = [appStoryViewController]
    }
}

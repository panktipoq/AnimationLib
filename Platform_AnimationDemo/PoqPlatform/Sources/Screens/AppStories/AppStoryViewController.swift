//
//  AppStoryViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/4/17.
//
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit
import AVKit

/// Accessiblity identifiers
let appStoryCloseButtonAccessibilityIdentifier = "AppStoryCloseButtonAccessibilityIdentifier"
let appStoryViewAccessibilityIdentifier = "AppStoryViewAccessibilityIdentifier"
let appStoryTitleLabelAccessibilityIdentifier = "AppStoryTitleLabelAccessibilityIdentifier"
let appStoryIconImageViewAccessibilityIdentifier = "AppStoryIconImageViewAccessibilityIdentifier"
let appStoryCardCountViewAccessibilityIdentifier = "AppStoryCardCountViewAccessibilityIdentifier"
let appStoryCardBottomOverlayAccessibilityIdentifier = "AppStoryCardBottomOverlayAccessibilityIdentifier"
let appStoryFullScreenVideoViewAccessibilityIdentifier = "AppStoryFullScreenVideoViewAccessibilityIdentifier"

public protocol AppStoryCardPresenter: AnyObject {
    
    func cardDidLoadMedia(_ card: PoqAppStoryCard)
}

public enum CardOpenType: String {
    case userPrompted = "open"
    case autoOpen = "autoOpen"
}

/**
 This view controller is container for story cards.
 Main responsibility is handle navigation between card in single story
 Including auto play and auto switch between stories after timer fire
 */
open class AppStoryViewController: PoqBaseViewController, AppStoryCardPresenter, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var eventHandlingView: UIView?
    @IBOutlet open weak var closeButton: UIButton?
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer?
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer?
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer?
    @IBOutlet weak var touchGestureRecognizer: TouchGestureRecognizer?
    
    @IBOutlet weak var cardOverlayView: UIView?
    @IBOutlet weak var gradientView: GradientView?
    @IBOutlet open weak var storyIconImageView: PoqAsyncImageView?
    @IBOutlet open weak var storyTitleLabel: UILabel?

    @IBOutlet weak var cardBottomOverlayView: UIView?
    @IBOutlet weak var bottomGradientView: GradientView?
    @IBOutlet weak var bottomCTAImageView: UIImageView?
    @IBOutlet open weak var bottomCTALabel: UILabel?
    @IBOutlet weak var bottomOverlayTapRecognizer: UITapGestureRecognizer?
    
    @IBOutlet weak var cardCounterView: AppStoryCardCountOverlayView?
    
    public let story: PoqAppStory
    public var storyCardOpenMethod = CardOpenType.userPrompted
    
    public var topAppStoryCardGradientLocations: [Double] = [0, 0.5, 1]
    public var topAppStoryCardGradientColors: [UIColor] = [UIColor.black.colorWithAlpha(0.3), UIColor.black.colorWithAlpha(0.2), UIColor.clear]
    
    public var bottomAppStoryCardGradientLocations: [Double] = [0, 0.5, 1]
    public var bottomAppStoryCardGradientColors: [UIColor] = [UIColor.clear, UIColor.black.colorWithAlpha(0.2), UIColor.black.colorWithAlpha(0.3)]
    
    public let viewModel: AppStoryViewModel
    
    fileprivate let storyCarouselType: StoryCarouselType?
    
    let playerViewController = AVPlayerViewController()

    /// Creates controller with story, and presents ard at `index` on screen
    public init(with story: PoqAppStory, cardAt index: Int = 0, storyCarouselType: StoryCarouselType = .card) {
        self.story = story
        viewModel = AppStoryViewModel(with: story)
        self.storyCarouselType = storyCarouselType
        
        super.init(nibName: AppStoryViewController.XibName, bundle: nil)

        currentIndex = index
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCounterView?.numberOfCards = story.cards.count
        
        if story.cards.count < 2, !story.shouldAutoplay {
            cardCounterView?.isHidden = true
        }
        
        navigateToCard(at: currentIndex)
        
        gradientView?.colors = topAppStoryCardGradientColors
        gradientView?.locations = topAppStoryCardGradientLocations
        
        if let storyIconImageViewUnwrapped = storyIconImageView {
            
            switch storyCarouselType ?? .card {
                
            case .card:
                
                let imageSizedRatio = CGFloat(AppSettings.sharedInstance.appStoriesCarouselImageRatio)
                let ratioContsraint = storyIconImageViewUnwrapped.widthAnchor.constraint(equalTo: storyIconImageViewUnwrapped.heightAnchor, multiplier: imageSizedRatio)
                ratioContsraint.isActive = true
                
            case .circular:
               // For circular stories we need width equal to height
                storyIconImageViewUnwrapped.widthAnchor.constraint(equalTo: storyIconImageViewUnwrapped.heightAnchor, multiplier: 1).isActive = true
                storyIconImageViewUnwrapped.contentMode = .scaleAspectFill
            }
        }
        
        storyIconImageView?.fetchImage(from: story.imageUrl, showLoading: false)
        
        storyTitleLabel?.text = story.title
        storyTitleLabel?.font = AppTheme.sharedInstance.appStoryTitleFont
        
        // Configure bottom overlay
        bottomGradientView?.colors = bottomAppStoryCardGradientColors
        bottomGradientView?.locations = bottomAppStoryCardGradientLocations
        
        bottomCTALabel?.font = AppTheme.sharedInstance.appStoryBottomCTALabelFont
        bottomCTALabel?.textColor = AppTheme.sharedInstance.appStoryBottomCTALabelTextColor
        
        bottomCTAImageView?.image = ImageInjectionResolver.loadImage(named: "AppstoryChevron")
        
        closeButton?.isAccessibilityElement = true
        closeButton?.accessibilityIdentifier = appStoryCloseButtonAccessibilityIdentifier
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = appStoryViewAccessibilityIdentifier
        storyIconImageView?.isAccessibilityElement = true
        storyIconImageView?.accessibilityIdentifier = appStoryIconImageViewAccessibilityIdentifier
        storyTitleLabel?.isAccessibilityElement = true
        storyTitleLabel?.accessibilityIdentifier = appStoryTitleLabelAccessibilityIdentifier
        cardCounterView?.isAccessibilityElement = true
        cardCounterView?.accessibilityIdentifier = appStoryCardCountViewAccessibilityIdentifier
        cardBottomOverlayView?.isAccessibilityElement = true
        cardBottomOverlayView?.accessibilityIdentifier = appStoryCardBottomOverlayAccessibilityIdentifier
        playerViewController.isAccessibilityElement = true
        playerViewController.view.accessibilityIdentifier = appStoryFullScreenVideoViewAccessibilityIdentifier
        
        // Declare an observer for when the app gets dissmiss or inactive because a sms, switching Apps, etc
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override open func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        // Make iconImageView rounded if carouselType is circular
        if storyCarouselType == .circular {
            storyIconImageView?.clipsToBounds = true
            storyIconImageView?.layer.cornerRadius = (storyIconImageView?.frame.width ?? 2)/2
        }
    }
    
    @objc func applicationWillResignActive() {
        pauseTimer()
    }
    
    @objc func applicationDidBecomeActive() {
        startAutoplayIfNeeded()
    }
    
    fileprivate var viewAppearenceFinished = false
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = story.shouldAutoplay
        
        viewAppearenceFinished = true
        startAutoplayIfNeeded()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseTimer()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    @IBAction open func closeButtonAction(_ sender: UIButton?) {
        dismissAppStory(animated: true)
    }
    
    func dismissAppStory(animated flag: Bool) {
        let appStoryTitleAnalytics = story.title ?? ""
        let cardAppStoryTitleAnalytics = viewModel.content[currentIndex].card.title ?? ""
        PoqTrackerHelper.trackAppStoryDismiss(storyAndCardTitle: appStoryTitleAnalytics + " - " + cardAppStoryTitleAnalytics)
        PoqTrackerV2.shared.appStories(action: AppStoriesAction.dismiss.rawValue, storyTitle: appStoryTitleAnalytics, cardTitle: cardAppStoryTitleAnalytics)
        dismiss(animated: flag)
    }
    
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended, .cancelled:
            let velocity = panGestureRecognizer?.velocity(in: eventHandlingView)
            let yVelocity = velocity?.y ?? 0
            let minSwipeVelocity: CGFloat = 1000
            if abs(yVelocity) < minSwipeVelocity {
                Log.verbose("yVelocity is less than \(minSwipeVelocity), so ignore it")
                break
            }
            
            // Just in case
            tapGestureRecognizer?.isEnabled = false
            tapGestureRecognizer?.isEnabled = true

            if yVelocity > 1000 {
                // Swipe down
                dismissAppStory(animated: true)
            } else {

                // Swipe up
                execute(action: viewModel.content[currentIndex].swipeUpAction)
            }
            
        default:
            break
        }
    }
    
    @IBAction func bottomOverlayTapRecognizerAction(sender: UITapGestureRecognizer) {
        execute(action: viewModel.content[currentIndex].swipeUpAction)
    }

    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        let location = sender.location(in: eventHandlingView)
        if location.x < 0.3 * view.bounds.width {
            if currentIndex > 0 {
                navigateToCard(at: currentIndex - 1)
            } else {
                appStoryNavigationController?.navigateToPrevStory()
            }
            
        } else {
            nextCardAction(autoOpen: false)
        }
    }
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            panGestureRecognizer?.isEnabled = false
            
        case .cancelled, 
             .ended:
            panGestureRecognizer?.isEnabled = true

        default:
            break
        }
    }
    
    @IBAction func touchRecognizerAction(sender: TouchGestureRecognizer) {
        switch sender.state {
        case .began:
            pauseTimer()
            
        case .cancelled, .ended:
            startAutoplayIfNeeded()
            
        default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let location = gestureRecognizer.location(in: eventHandlingView)
        
        // Lets make dead area abound close button
        if let distance = closeButton?.frame.distance(to: location), distance < 40 {
            Log.verbose("we ignore touch since it is too close to button")
            return false
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - AppStoryCardPresenter
    public final func cardDidLoadMedia(_ card: PoqAppStoryCard) {
        startAutoplayIfNeeded()
    }

    // MARK: - Private
    
    fileprivate var appStoryNavigationController: AppStoryNavigationController? {
        return navigationController as? AppStoryNavigationController
    }
    
    open var currentIndex: Int = 0
    
    open func navigateToCard(at index: Int) {

        Log.verbose("Present card at index \(index)")
        guard index < viewModel.content.count else {
            Log.error("Index is out of range")
            return
        }

        for viewController in childViewControllers {
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()

            if let cardViewController = viewController as? AppStoryCardViewController {
                cardViewController.cardPresenter = nil
            }
        }

        currentIndex = index
        cardCounterView?.currentIndex = currentIndex
        
        let contentItem = viewModel.content[currentIndex]
        
        bottomCTALabel?.text = contentItem.card.actionLabelText
        
        let cardViewController = contentItem.storyCardController
        cardViewController.willMove(toParentViewController: self)

        view.addSubview(cardViewController.view)
        cardViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraintsForView(cardViewController.view, withInsetsInContainer: .zero)
        NSLayoutConstraint.activate(constraints)
        
        addChildViewController(cardViewController)
        
        cardViewController.didMove(toParentViewController: self)
        
        if let gradientViewUnwrapped = gradientView {
            view.bringSubview(toFront: gradientViewUnwrapped)
        }
        
        if let cardOverlayViewUnwrapped = cardOverlayView {
            view.bringSubview(toFront: cardOverlayViewUnwrapped)
        }
        
        if let cardBottomOverlayViewUnwrapped = cardBottomOverlayView {
            view.bringSubview(toFront: cardBottomOverlayViewUnwrapped)
        }
        
        if let eventHandlingViewUnwrapped = eventHandlingView {
            view.bringSubview(toFront: eventHandlingViewUnwrapped)
        }
        
        cardViewController.cardPresenter = self
        
        resetTimer()

        startAutoplayIfNeeded()
        
        if case .none = contentItem.swipeUpAction {
            cardBottomOverlayView?.isHidden = true
        } else {
            cardBottomOverlayView?.isHidden = false
        }
        
        PoqTrackerV2.shared.appStories(action: storyCardOpenMethod.rawValue, storyTitle: story.title ?? "", cardTitle: contentItem.card.title ?? "")
        
        /// Reset open method variable value to userPrompted after tracking event
        storyCardOpenMethod = .userPrompted
    }
    
    /// Should be called when user tapped or timer fires
    /// Will switch to next card, story or dismiss
    fileprivate func nextCardAction(autoOpen: Bool) {
        if currentIndex < (viewModel.content.count - 1) {
            navigateToCard(at: currentIndex + 1)
        } else {
            appStoryNavigationController?.navigateToNextStory(autoOpen: autoOpen)
        }
    }
    
    fileprivate var timer: Timer?
    fileprivate var scheduledFireDate: Date?
    fileprivate var timerLeftTimeInterval: TimeInterval? // If value not nil - timer was paused
    
    /// 1. Invalidate current timer
    /// 2. Check loaded media state and PoqAppStory.shouldAutoplay. If needed starts new timer
    /// 3. If before we pause timer - we will continue with left time
    fileprivate final func startAutoplayIfNeeded() {
        
        let cardViewController = viewModel.content[currentIndex].storyCardController
        guard story.shouldAutoplay, cardViewController.isMediaLoaded else {
            if !story.shouldAutoplay {
                cardCounterView?.updateCurrentProgress(to: 1)
            }
            
            return
        }
        
        guard viewAppearenceFinished else {
            // Wait until viewDidAppeared happens
            return
        }
        
        guard presentedViewController == nil else {
            Log.info("The app story view controller is presenting another view controller modally on top, should not continue autoplay")
            return
        }
        
        guard timer == nil else {
            // We already running time
            return
        }
        
        scheduledFireDate = nil
        
        defer {
            timerLeftTimeInterval = nil
        }

        guard var duration = story.cards[currentIndex].duration else {
            Log.error("We have autoplay story, but crad duration is nil. Timer won't start")
            return
        }
        
        if let lefTimeInterval = timerLeftTimeInterval {
            duration = lefTimeInterval            
        }
        
        scheduledFireDate = Date().addingTimeInterval(duration)

        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(AppStoryViewController.timerAction(_:)), userInfo: nil, repeats: false)
        cardCounterView?.animateAutoplay(with: duration)
    }
    
    /// Pause timer if any scheduled
    fileprivate final func pauseTimer() {
        
        Log.verbose("Pause timer")

        if let scheduledFireDateUnwrapped = scheduledFireDate {
            timerLeftTimeInterval = scheduledFireDateUnwrapped.timeIntervalSince(Date())
        }
        timer?.invalidate()
        timer = nil

        scheduledFireDate = nil
        
        var currentProgress: CGFloat = 1 
        
        if let duration = story.cards[currentIndex].duration, let timerLeftTimeIntervalUnwrapped = timerLeftTimeInterval {
            let currentProgressDouble = (duration - timerLeftTimeIntervalUnwrapped)/duration
            currentProgress = CGFloat(currentProgressDouble) 
        }
        
        cardCounterView?.updateCurrentProgress(to: currentProgress)
    }
    
    @objc
    fileprivate func timerAction(_ timer: Timer) {
        resetTimer()
        storyCardOpenMethod = .autoOpen
        nextCardAction(autoOpen: true)
    }
    
    /// Should be called when we switch cards
    fileprivate func resetTimer() {
        timer?.invalidate()
        timer = nil
        scheduledFireDate = nil
        timerLeftTimeInterval = nil
    }
    
    open func execute(action: SwipeUpAction) {
        let appStoryTitleAnalytics = story.title ?? ""
        let cardAppStoryTitleAnalytics = viewModel.content[currentIndex].card.title ?? ""
        switch action {
        case .pdp(let viewModel):
            let appStoryPDP = AppStoryProductInfoViewController(with: viewModel)
            let sheetContainerViewController = SheetContainerViewController(rootViewController: appStoryPDP)
            present(sheetContainerViewController, animated: true) {
                PoqTrackerHelper.trackAppStoryPDPSwipe(storyAndCardTitle: appStoryTitleAnalytics + " - " + cardAppStoryTitleAnalytics)
                PoqTrackerV2.shared.appStories(action: AppStoriesAction.pdpSwipe.rawValue, storyTitle: appStoryTitleAnalytics, cardTitle: cardAppStoryTitleAnalytics)
            }
        case .plp(let viewModel):
            let appStoryPLP = AppStoryProductListViewController(viewModel: viewModel)
            let sheetContainerViewController = SheetContainerViewController(rootViewController: appStoryPLP)
            present(sheetContainerViewController, animated: true) {
                PoqTrackerHelper.trackAppStoryPLPSwipe(storyAndCardTitle: appStoryTitleAnalytics + " - " + cardAppStoryTitleAnalytics)
                PoqTrackerV2.shared.appStories(action: AppStoriesAction.plpSwipe.rawValue, storyTitle: appStoryTitleAnalytics, cardTitle: cardAppStoryTitleAnalytics)
            }
        case .web(let url):
            PoqTrackerHelper.trackAppStoryWebViewSwipe(storyAndCardTitle: appStoryTitleAnalytics + " - " + cardAppStoryTitleAnalytics)
            PoqTrackerV2.shared.appStories(action: AppStoriesAction.webviewSwipe.rawValue, storyTitle: appStoryTitleAnalytics, cardTitle: cardAppStoryTitleAnalytics)
            NavigationHelper.sharedInstance.openURL(url.absoluteString)
        case .video(let url):
            PoqTrackerHelper.trackAppStoryVideoSwipe(storyAndCardTitle: appStoryTitleAnalytics + " - " + cardAppStoryTitleAnalytics)
            PoqTrackerV2.shared.appStories(action: AppStoriesAction.videoSwipe.rawValue, storyTitle: appStoryTitleAnalytics, cardTitle: cardAppStoryTitleAnalytics)
            playFullScreenVideo(with: url)
        default: 
            break
        }
    }
    
    func playFullScreenVideo(with url: URL) {
        let player = AVPlayer(url: url)
        playerViewController.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerViewController.player?.currentItem)
        present(playerViewController, animated: true) {
            self.playerViewController.player?.play()
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerViewController.player?.currentItem)
        playerViewController.dismiss(animated: true)
    }
}

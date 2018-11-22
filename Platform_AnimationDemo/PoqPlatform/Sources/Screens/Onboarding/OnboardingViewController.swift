//
//  OnboardingViewController.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 12/15/16.
//
//

import UIKit
import PoqAnalytics

open class OnboardingViewController: PoqBaseViewController, PoqOnboardingPresenter, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak public var pagesCollectionView: UICollectionView?
    
    @IBOutlet open weak var completeButton: UIButton?
    @IBOutlet open weak var pageControl: UIPageControl? {
        didSet {
            pageControl?.currentPageIndicatorTintColor = AppTheme.sharedInstance.onboardingCurrentPageIndicatorColor
            pageControl?.pageIndicatorTintColor = AppTheme.sharedInstance.onboardingPageIndicatorColor
        }
    }
    
    lazy public var viewModel: OnboardingService = {
        let service = OnboardingViewModel()
        service.presenter = self
        return service
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchOnboarding()
        
        setupCompleteButton()
        setupCollectionView()

        updatePageControl()
        
        PoqTrackerV2.shared.onboarding(action: OnboardingAction.begin.rawValue)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        OnboardingViewController.shouldShowOnboarding = false
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCellsBottomPadding()
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Actions
    @IBAction func completeButtonAction(_ sender: WhiteButton) {
        
        // Track page dismiss
        if let pageNumber = pageControl?.currentPage {
            PoqTracker.sharedInstance.logAnalyticsEvent("Onboarding", action: "Skip", label: String(pageNumber), extraParams: nil)
        }
        PoqTrackerV2.shared.onboarding(action: OnboardingAction.complete.rawValue)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pageControlAction(_ sender: AnyObject?) {
        guard let pageIndex = pageControl?.currentPage else {
            return
        }
        scrollTo(pageIndex: pageIndex)
    }
    
    // MARK: - PoqOnboardingPresenter
    open func setupCompleteButton() {

        completeButton?.configurePoqButton(withTitle: AppLocalization.sharedInstance.onboardingCompleteButtonTitle,
                                           using: ResourceProvider.sharedInstance.clientStyle?.primaryButtonStyle)
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OnboardingPageCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.update(using: viewModel.pages[indexPath.row], actionDelegate: self)
        if let existedButton = completeButton {
            let overlatHeight = view.frame.size.height - existedButton.frame.minY
            cell.update(bottomPadding: overlatHeight)
        }

        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // We don't need to do any switches while we are animating, this should happens only when we decide direction of animation
        if scrollView.isDragging {
            updatePageControl()
        }
        
        updateBackgroundColor()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updatePageControl()
        
        // Track page swipe
        if let pageNumber = pageControl?.currentPage {
            PoqTracker.sharedInstance.logAnalyticsEvent("Onboarding", action: "Swipe", label: String(pageNumber), extraParams: nil)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl()
    }
}

// MARK: - OnboardingBlockActionDelegate

extension OnboardingViewController: OnboardingBlockActionDelegate {
    
    func openLink(_ link: String) {
        
        guard !link.isEmpty else {
            return
        }

        dismiss(animated: true, completion: {
            NavigationHelper.sharedInstance.openURL(link)
        })
    }
}

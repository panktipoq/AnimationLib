//
//  TinderViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import Koloda
import PoqNetworking
import PoqUtilities
import UIKit

open class TinderViewController: PoqBaseViewController {
    
    override open var screenName: String {
        return "Swipe to Hype Screen"
    }
    
    @IBOutlet open weak var kolodaView: TinderKolodaView!
    @IBOutlet open weak var firstTimeLoadImage: PoqAsyncImageView!
    @IBOutlet open weak var productTitleAndPriceArea: UIView!
    @IBOutlet open weak var likeDislikeButtonsArea: UIView!
    @IBOutlet open weak var swipeLeftButton: UIButton! {
        didSet {
            swipeLeftButton.titleLabel?.text = AppLocalization.sharedInstance.tinderSwipeLeftText
            swipeLeftButton.titleLabel?.font = AppTheme.sharedInstance.tinderSwipeLeftFont
        }
    }
    
    @IBOutlet open weak var swipeRightButton: UIButton! {
        didSet {
            swipeRightButton.titleLabel?.text = AppLocalization.sharedInstance.tinderSwipeRightText
            swipeRightButton.titleLabel?.font = AppTheme.sharedInstance.tinderSwipeRightFont
        }
    }
    
    @IBOutlet open weak var productTitleLabel: UILabel! {
        didSet {
            productTitleLabel.font = AppTheme.sharedInstance.tinderProductTitleLabelFont
        }
    }
    
    @IBOutlet open weak var productPriceLabel: UILabel!
    @IBOutlet open weak var dislikeUnderlineView: UIView!
    @IBOutlet open weak var likeUnderlineView: UIView!
    @IBOutlet open weak var firstTimeLoadImageCTA: WhiteButton? {
        didSet {
            firstTimeLoadImageCTA?.setTitle(AppLocalization.sharedInstance.tinderFirstTimeLoadSkipButtonText, for: .normal)
            firstTimeLoadImageCTA?.fontSize = CGFloat(AppSettings.sharedInstance.tinderFirstTimeLoadSkipButtonFontSize)
        }
    }
    
    open var viewModel = TinderViewModel()
    
    open var isFirstCardSet: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewControllerDelegate = self
        viewModel.setupCloudParameters()
        
        // Hide all for first time setup till network request ends etc.
        hideAll(hide: true)
        
        // Always gets the latest data.
        viewModel.getProductsInCategory()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskWillStart(networkTaskType)
        
        hideAll(hide: true)
        
        // When new items arrive, we need to update the screen with the first product's data
        if networkTaskType == PoqNetworkTaskType.tinderProducts || networkTaskType == PoqNetworkTaskType.tinderProductsInCategory {
            
            isFirstCardSet = false
        }
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
        
        hideAll(hide: false)
        hideFirstTimeLoadImage(hide: true)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskDidComplete(networkTaskType)
        
        if networkTaskType != PoqNetworkTaskType.tinderLike {
            
            hideAll(hide: false)
            
            if viewModel.isFirstTimeLoad() {
                
                setupFirstTimeLoad()
            } else {
                
                setupTinder()
            }
        }
    }
    
    @IBAction open func dislikeDidTap(_ sender: AnyObject) {
        
        kolodaView?.swipe(SwipeResultDirection.left)
        viewModel.sendTrackingTapToDislike()
    }
    
    @IBAction open func likeDidTap(_ sender: AnyObject) {
        
        kolodaView?.swipe(SwipeResultDirection.right)
        viewModel.sendTrackingTapToLike()
    }
}

// MARK: - UI Logic to change the state

extension TinderViewController {
    
    open func setupFirstTimeLoad() {
        
        hideFirstTimeLoadImage(hide: false)
        setupFirstTimeLoadSkipButton()
        viewModel.loadFirstTimeImage(firstTimeLoadImage, firstTimeLoadImageURL: AppSettings.sharedInstance.tinderFirstTimeLoadImageURL)
    }
    
    open func setupFirstTimeLoadSkipButton() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TinderViewController.firstTimeLoadDidTap(_:)))
        firstTimeLoadImageCTA?.addGestureRecognizer(gesture)
    }
    
    @objc open func firstTimeLoadDidTap(_ gesture: UIGestureRecognizer) {
        
        viewModel.setFirstTimeLoad()
        setupTinder()
    }
    
    open func setupTinder() {
        
        hideFirstTimeLoadImage(hide: true)
        setupKolada()
    }
    
    open func hideFirstTimeLoadImage(hide: Bool) {
        
        firstTimeLoadImage.isHidden = hide
        firstTimeLoadImageCTA?.isHidden = hide
        productTitleAndPriceArea.isHidden = !hide
        likeDislikeButtonsArea.isHidden = !hide
        kolodaView?.isHidden = !hide
    }
    
    open func hideAll(hide: Bool) {
        
        firstTimeLoadImage.isHidden = hide
        firstTimeLoadImageCTA?.isHidden = hide
        productTitleAndPriceArea.isHidden = hide
        likeDislikeButtonsArea.isHidden = hide
        kolodaView?.isHidden = hide
    }
    
    open func setupKolada() {
        
        kolodaView?.dataSource = self
        kolodaView?.delegate = self
        kolodaView?.reloadData()
    }
}
// MARK: - KolodaViewDelegate

extension TinderViewController: KolodaViewDelegate {
    
    open func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        switch direction {
            
        case .left:
            Log.verbose("Nah - didn't like it")
            viewModel.sendTrackingSwipeToDislike()
            
        case .right:
            Log.verbose("Love - send to wish list")
            viewModel.sendLikeForIndex(index)
            viewModel.sendTrackingSwipeToLike()
        default:
            Log.verbose("Nothing swiped")
        }
        
        Log.verbose("Remaning cards on deck: \(koloda.countOfCards - koloda.currentCardIndex)")
        
        // Card swiped, so set the labels using the next card's data
        viewModel.updateCardDetailsForIndex(titleLabel: productTitleLabel, priceLabel: productPriceLabel, index: UInt(index.advanced(by: 1)))
        viewModel.updateLastProductIDForIndex(index)
        
        // Reset underlines for like/dislike
        likeUnderlineView.isHidden = true
        dislikeUnderlineView.isHidden = true
    }
    
    private func increment<T: Strideable>(number: T) -> T {
        return number.advanced(by: 1)
    }
    
    open func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        
        // Reset underlines for like/dislike
        likeUnderlineView.isHidden = true
        dislikeUnderlineView.isHidden = true
        
        switch direction {
            
        case .left:
            dislikeUnderlineView.isHidden = false
            
        case .right:
            likeUnderlineView.isHidden = false
        default:
            likeUnderlineView.isHidden = true
            dislikeUnderlineView.isHidden = true
        }
    }
    
    open func kolodaDidResetCard(_ koloda: KolodaView) {
        
        likeUnderlineView.isHidden = true
        dislikeUnderlineView.isHidden = true
    }
    
    open func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        Log.verbose("😭 no more swipe to hype, getting more...")
        viewModel.productFeed = []
        kolodaView?.resetCurrentCardIndex()
        viewModel.getNextSetOfProducts(isRefresh: true)
    }
    
    open func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        viewModel.openProductDetailForIndex(index)
    }
    
    public func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        
        return false
    }
}

// MARK: - KolodaViewDataSource

extension TinderViewController: KolodaViewDataSource {
    
    open func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if !isFirstCardSet {
            // Koloda creates multiple cards in first run. Due to using one label for all,
            // We have to set the labels using first product's data
            // Later swipe actions will update it
            isFirstCardSet = true
            viewModel.updateCardDetailsForIndex(titleLabel: productTitleLabel, priceLabel: productPriceLabel, index: 0)
        }
        
        return viewModel.cardViewForIndex(koloda, index: UInt(index))
    }
    
    open func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return viewModel.productFeed.count
    }
    
    public func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }
}

//
//  ReviewsViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 3/10/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/**
 Instanciate a Reviews View Controller to show a list of reviews for a given product.
 
 ## Usage Example: ##
 ````
 NavigationHelper.sharedInstance.loadReviews(productId)
 ````
 **Note:** Xib file name: "ReviewsViewController"
 
 NavigationHelper Deeplink Route: "\(reviewsURL):product_id"
 */
open class ReviewsViewController: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    
    /// Table view to show the list of reviews.
    @IBOutlet weak public var reviewsTable: UITableView?
    
    /// Product ID related to the reviews to show in the view Controller.
    public var productId: Int?
    
    /// View Model to handle the data to be shown.
    public var viewModel: ReviewViewModel?
    
    /// Autolayout estimatedRowHeight.
    public let estimatedRowHeight: CGFloat = 44.0
    
    /// Boolean to store if the view is presented modally or not.
    public var isModal = false
    
    /// The Screen Name to be tracked through analytics.
    override open var screenName: String {
        return "Product Reviews Screen"
    }
    
    //MARK: - ViewLifeCycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        registerCells()
        
        reviewsTable?.allowsSelection = false
        reviewsTable?.estimatedRowHeight = estimatedRowHeight
        reviewsTable?.rowHeight = UITableViewAutomaticDimension
        reviewsTable?.tableFooterView = UIView()

        viewModel = ReviewViewModel(viewControllerDelegate: self)
        
        guard let productId = productId else {
            Log.error("No productId provided for reviews")
            return
        }
        viewModel?.getProductReviews(productId, isRefresh: false)
        
        PoqTrackerHelper.trackReviewsLoad(String(productId))
        PoqTrackerV2.shared.readReviews(productId: productId, numberOfReviews: viewModel?.reviews?.count ?? 0)
    }

    // MARK: - ViewSetup
    
    /**
     Function register the cells used in the Table View.
     */
    open func registerCells() {
        reviewsTable?.registerPoqCells(cellClasses: [ReviewTableViewCell.self])
    }
    
    /**
     Function to set up the Navigation Bar.
     */
    open func initNavigationBar() {
        title = AppLocalization.sharedInstance.ratingsReviewNavigationTitle
        
        navigationItem.titleView = nil
        
        if isModal {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        } else {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
        
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - CloseButtonDelegate
    
    /**
     CloseButton action delegate callback.
     */
    open override func closeButtonClicked() {
        
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.reviews?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: ReviewTableViewCell = tableView.dequeueReusablePoqCell() else {
            
            return UITableViewCell()
        }
        
        cell.updateView(self.viewModel?.reviews?[indexPath.row])
        
        return cell
    }
    
    // MARK: - Networking
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) { }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        reviewsTable?.reloadData()
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) { }
}

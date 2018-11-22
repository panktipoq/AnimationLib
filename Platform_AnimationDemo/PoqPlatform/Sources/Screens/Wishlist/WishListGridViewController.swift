//
//  WishListGridViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 12/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

class WishListGridViewController: PoqBaseViewController, WishlistCellDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    override open var screenName: String {
        return "WishList Screen"
    }
    
    var viewModel: WishlistViewModel?
    
    // Cell paddings and margin
    var cellLeftPadding = CGFloat(AppSettings.sharedInstance.wishListCellLeftPadding)
    var cellRightPadding = CGFloat(AppSettings.sharedInstance.wishListCellRightPadding)
    var cellTopPadding = CGFloat(AppSettings.sharedInstance.wishListCellTopPadding)
    var cellBottomPadding = CGFloat(AppSettings.sharedInstance.wishListCellBottomPadding)
    var cellBottomMargin: CGFloat = 0
    var cellInterItemMargin: CGFloat = 0
    
    // Navbar edit button
    var editButton = UIBarButtonItem()
    var isInEditingMode: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet var countLabel: UILabel? 
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var statusView: UIView?
    @IBOutlet weak var collectionViewLeftPaddingConstant: NSLayoutConstraint?
    @IBOutlet weak var collectionViewRightPaddingConstant: NSLayoutConstraint?
    @IBOutlet weak var clearAllButton: UIButton?
    
    @IBOutlet weak var wishlistTopViewConstraint: NSLayoutConstraint?
    
    // ___________________________________________________
    
    // MARK: - UI Delegations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init view model for networking
        self.viewModel = WishlistViewModel(viewControllerDelegate: self)
        
        // Init viewcollection
        // Register viewcell

        collectionView?.registerPoqCells(cellClasses: [WishListGridCellView.self, WishListGridEmptyCell.self])

        // Set collection background
        collectionView?.backgroundColor = UIColor.white
        
        // This solution won't work if the collection is not big enough to have an active scrollbar.
        collectionView?.alwaysBounceVertical = true

        // Hide status view
        statusView?.isHidden = true
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor=AppTheme.sharedInstance.mainColor

        refreshControl.addTarget(self, action: #selector(WishListGridViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
        
        wishlistTopViewConstraint?.constant = CGFloat(AppSettings.sharedInstance.wishlistTopViewConstraint)
        
        // Log wishlist screen
        PoqTrackerHelper.trackWishScreenLoaded()
        
        // Load wishlist items
        viewModel?.getWishList()
        
        self.clearAllButton?.titleLabel?.font=AppTheme.sharedInstance.wishListClearAllFont
        self.clearAllButton?.setTitle(AppLocalization.sharedInstance.wishListClearAllText, for: UIControlState())
        
        PoqUserNotificationCenter.shared.setupRemoteNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load wishlist items
        viewModel?.getWishList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Disable editing mode when view is dissappeared
        isInEditingMode = false
        editButton.title = AppLocalization.sharedInstance.wishlistNavigationBarItemText
        collectionView?.reloadData()
    }
    
    func setupNavBar() {
        
        // Setup navigation bar item
        editButton = UIBarButtonItem(title: AppLocalization.sharedInstance.wishlistNavigationBarItemText, style: UIBarButtonItemStyle.plain, target: self, action: #selector(WishListGridViewController.editTable))
        let naviBarItemFontDict = [NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarItemFont,
                                   NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.wishlistNavigationBarItemTextColor] 
        editButton.setTitleTextAttributes(naviBarItemFontDict, for: UIControlState())
        
        // Decide location of the edit button. Hamburger menu icon availability decides
        if AppSettings.sharedInstance.editButtonDirection == "left" {
            
            navigationItem.leftBarButtonItem = editButton
            
        } else if  AppSettings.sharedInstance.editButtonDirection == "right" {
            
            navigationItem.rightBarButtonItem = editButton
        }
    }
    
    // MARK: - WishlistDelegate methods
    func remove(_ listItem: AnyObject, index: Int) {
        guard let item = listItem as? PoqProduct else {
            Log.error("Item was not PoqProduct as expected.")
            return
        }
        
        viewModel?.removeWishlistItem(item) { (removed: Bool) in
            guard removed else {
                return
            }
            
            self.collectionView?.reloadData()
            self.updateTotals()
        }
    }
    
    func addToBagClicked(_ listItem: AnyObject, index: Int) {
        // This view doesn't support adding items to bag
    }
    
    // Toggle edit mode
    @objc func editTable() {
        
        // Toggle status and button text
        isInEditingMode = !isInEditingMode
        editButton.title = isInEditingMode ? "DONE".localizedPoqString : AppLocalization.sharedInstance.wishlistNavigationBarItemText
        collectionView?.reloadData()
    }
    
    // Pull-down-to refresh listener
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        viewModel?.getWishList(true)
        refreshControl.endRefreshing()
    }
    
    // Update number of items
    func updateTotals() {
        if let wishlist = viewModel?.wishListItems {
            
            let count = wishlist.count
            
            let single = String(format: AppLocalization.sharedInstance.wishListCountSingleText, count)
            let plural = String(format: AppLocalization.sharedInstance.wishListCountMultipleText, count)
            countLabel?.text = count == 1 ? single : plural
            
            if let wishListItems = viewModel?.wishListItems {
                BadgeHelper.updateWishBadgeTotal(wishListItems)
            }
        } else {
            
            countLabel?.text = String(format: AppLocalization.sharedInstance.wishListCountSingleText, 0)
        }
        
        statusView?.isHidden = false
    }
    
    @IBAction func clearAllClicked(_ sender: AnyObject) {
        
        let validAlertController = UIAlertController.init(
            title: "CONFIRMATION".localizedPoqString,
            message: "CLEAR_ALL_WISHLIST_ITEMS".localizedPoqString,
            preferredStyle: UIAlertControllerStyle.alert)
        
        validAlertController.addAction(UIAlertAction.init(title: "CANCEL".localizedPoqString, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
            
        }))
        
        validAlertController.addAction(UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            
            // Clear all of the wishlist button
            self.viewModel?.removeAllWishlistItems()
            self.collectionView?.reloadData()
        }))

        self.present(validAlertController, animated: true) { 
            // Completion handler once everything is dismissed
        }
    }
    
    // ___________________________________________________
    
    // MARK: - Collection View Data Delegations
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 1
        }
        return viewModel.hasWishListItems() ? viewModel.wishListItems.count : 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let wishListItems = viewModel?.wishListItems, wishListItems.count == 0 {
            
            // Setup cell
            let cell: WishListGridEmptyCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
            
            cell.label.font = AppTheme.sharedInstance.noItemsLabelFont
            cell.label.textColor = AppTheme.sharedInstance.noItemsLabelColor
            cell.label.text = AppLocalization.sharedInstance.wishListNoItemsText
            return cell
        }
        
        if let wishListItems = viewModel?.wishListItems, indexPath.row < wishListItems.count {
            
            if let wishListItemPictureURLString = wishListItems[indexPath.row].pictureURL, let wishListItemPictureURL = URL(string: wishListItemPictureURLString) {
                
                // Setup cell
                
                let cell: WishListGridCellView = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
                
                cell.imageView?.getImageFromURL(wishListItemPictureURL, isAnimated: false)
                cell.isInEditingMode = isInEditingMode
                cell.wishListItem = wishListItems[indexPath.row]
                cell.index = indexPath.row
                cell.delegate = self
                cell.updateView()
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    // ___________________________________________________
    
    // MARK: - Collection View Layout Delegations
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let leftPadding: CGFloat = collectionViewLeftPaddingConstant?.constant ?? 0
        let rightPadding: CGFloat = collectionViewRightPaddingConstant?.constant ?? 0
        
        // Get half of the collectionView width for two column
        let bounds: CGRect = UIScreen.main.bounds
        let width: CGFloat = bounds.width - (leftPadding + rightPadding)
        var size = CGSize(width: width, height: width)
        let numberOfColumns: CGFloat = 2
        let numberOfColumnsRatio = CGFloat(1) / numberOfColumns
        
        // No items label cell should occupy the whole colleciton view
        if let wishListItems = viewModel?.wishListItems, let existedCollectionView: UICollectionView = self.collectionView, wishListItems.count == 0 {
            
            return CGSize(width: existedCollectionView.bounds.width, height: existedCollectionView.bounds.height)
        }
        
        // {numberOfColumns} collection view cell size
        if let wishListItems = viewModel?.wishListItems, indexPath.row < wishListItems.count {
            
            if let wishListItemPictureWidth = wishListItems[indexPath.row].thumbnailWidth, let wishListItemPictureHeight = wishListItems[indexPath.row].thumbnailHeight {
                
                // Calculate ratio to fit the image in half of the screen
                let ratio = (width * numberOfColumnsRatio) / CGFloat(wishListItemPictureWidth)
                let cellWidth = CGFloat(wishListItemPictureWidth) * ratio
                let cellHeight = CGFloat(wishListItemPictureHeight) * ratio
                size = CGSize(width: cellWidth, height: cellHeight)
            }
        }
        
        // Each thumbnail to cover half of the screen in width and height
        return size
    }
    
    // Cell view padding
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: cellTopPadding, left: cellLeftPadding, bottom: cellBottomPadding, right: cellRightPadding)
      // Return UIEdgeInsetsZero
    }
    
    // Cell line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return cellBottomMargin
    }
    
    // Cell column spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return cellInterItemMargin
    }
    
    // ___________________________________________________
    
    // MARK: - Network Delegations
    
    /**
    Called from view model when a network operation starts
    */
    override func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        super.networkTaskWillStart(networkTaskType)
        editButton.isEnabled = false
        
        // Hide status (items, clear all) and collection view for the first load
        if networkTaskType == PoqNetworkTaskType.getWhishList {
            
            if let count = viewModel?.wishListItems.count, count == 0 {
                
                collectionView?.isHidden = true
                statusView?.isHidden = true
            }
        }
    }
    
    /**
    Called from view model when a network operation ends
    */
    override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        editButton.isEnabled = true
        collectionView?.isHidden = false
       
        collectionView?.reloadData()
        updateTotals()
        
        if let count = viewModel?.wishListItems.count, count == 0 {
            
            statusView?.isHidden = true
            
            // Hide edit button
            if AppSettings.sharedInstance.editButtonDirection == "left" {
                
                navigationItem.leftBarButtonItem = nil
                
            } else if  AppSettings.sharedInstance.editButtonDirection == "right" {
                
                navigationItem.rightBarButtonItem = nil
            }
            
        } else {
            
            if !isInEditingMode {
            
                setupNavBar()
            }
        }
    }
    
    /**
    Called from view model when a network operation fails
    */
    override func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        super.networkTaskDidFail(networkTaskType, error: error)
    }
}

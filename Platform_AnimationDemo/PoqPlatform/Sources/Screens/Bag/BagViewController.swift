//
//  BagViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import PoqUtilities
import PoqAnalytics
import UIKit

open class BagViewController: PoqBaseBagViewController {

    override open var screenName: String {
        return "Shopping Bag Screen"
    }
    
    // MARK: - IBOutlets
    // ____________________

    @IBOutlet open var bagTable: UITableView? {
        
        didSet {
            
            bagTable?.allowsMultipleSelectionDuringEditing = false
            bagTable?.allowsSelectionDuringEditing = false
            
            bagTable?.registerPoqCells(cellClasses: [BagItemTableViewCell.self, NoItemsCell.self])
            bagTable?.separatorStyle = AppSettings.sharedInstance.bagViewTableHasSeparator ? UITableViewCellSeparatorStyle.singleLine : UITableViewCellSeparatorStyle.none
            bagTable?.tableFooterView = UIView(frame: CGRect.zero)
            
            bagTable?.rowHeight = UITableViewAutomaticDimension
            bagTable?.estimatedRowHeight = CGFloat(AppSettings.sharedInstance.bagProductCellHeight)
        }
    }
    
    @IBOutlet var bagTableTopConstraint: NSLayoutConstraint? {
        didSet {
            let isNavBarTranslucent = navigationController?.navigationBar.isTranslucent ?? false
            let isExtendedToTop = edgesForExtendedLayout.contains(.top)
            
            if isNavBarTranslucent && isExtendedToTop && !automaticallyAdjustsScrollViewInsets {
                let navigationAndStatusBarHeight = UIApplication.shared.statusBarFrame.height + CGFloat(navigationController?.navigationBar.frame.size.height ?? 0)
                bagTableTopConstraint?.constant = navigationAndStatusBarHeight
            }
        }
    }
    
    @IBOutlet open var itemsCountLabel: UILabel! {
        
        didSet {
            
            itemsCountLabel.font = AppTheme.sharedInstance.bagItemsCountLabelFont
        }
    }
    
    @IBOutlet open var totalCostLabel: UILabel! {
        
        didSet {
            
            totalCostLabel.attributedText = LabelStyleHelper.initGrandTotalLabel(singleItemCount)
        }
    }
    
    @IBOutlet open var checkoutButton: CheckoutButton?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        
        // Set base ui elements for extensions
        baseTableView = bagTable
        baseItemsLabel = self.itemsCountLabel
        baseTotalLabel = self.totalCostLabel
        baseCheckoutButton = self.checkoutButton

        super.viewDidLoad()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // A requirement stays from HoF's custom middle tabbar button (bag button)
        setTabBarMiddleButton()
    }
    
    // MARK: post order to checkout

    open func handleCheckoutButtonClicked() {

        PoqTrackerV2.shared.beginCheckout(voucher: "", currency: CurrencyProvider.shared.currency.code, value: CheckoutHelper.getBagItemsTotal(viewModel.bagItems), method: CheckoutMethod.web.rawValue)
        PoqTrackerHelper.trackBagScreenCheckout()
        
        if !isNetworkOperationProcessing {

            transferCart()
        }
    }
    
    private func transferCart() {
        
        guard let order = viewModel.createOrder() else {
            Log.error("Checkout attempted with invalid order")
            return
        }
        
        switch CartTransferVersion.currentVersion {
            
        case .v1:
            viewModel.postOrder(order)
            
        case .v2:
            NavigationHelper.sharedInstance.openCartTransfer()
            
        }
        
        PoqTrackerHelper.trackSecureCheckout(String(describing: order.totalPrice?.toPriceString()))
        
        // For Tune to log checkout items in checkout
        PoqTracker.sharedInstance.trackInitOrder(PoqTrackingOrder(order: order))
    }
    
    @IBAction public func checkoutButtonClicked(_ sender: Any) {
        handleCheckoutButtonClicked()
    }

    fileprivate func setTabBarMiddleButton() {
        NavigationHelper.sharedInstance.defaultTabBar?.setMiddleButtonSelected()
    }
    
    override open func createBagViewModel() -> BagViewModel {
        let bagViewModel: BagViewModel = BagViewModel(viewControllerDelegate: self)
        return bagViewModel
    }
}

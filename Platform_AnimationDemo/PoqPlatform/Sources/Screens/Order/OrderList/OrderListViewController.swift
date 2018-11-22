//
//  OrderListViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import PoqUtilities
import UIKit

/**
 Instanciate a Orders History View Controller to show a list of orders of the current user.
 
 ## Usage Example: ##
 ````
 NavigationHelper.sharedInstance.loadOrderHistory()
 ````
 **Note:** Xib file name: "OrderListViewController"
 
 NavigationHelper Deeplink Route: "\(orderHistoryURL)"
 */
open class OrderListViewController: PoqBaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables

    /// The Screen Name to be tracked through analytics.
    override open var screenName: String {
        return "Order History List Screen"
    }
    
    /// Table view to show the list of orders.
    @IBOutlet open var orderListTable: UITableView? {
        didSet {
            
            orderListTable?.registerPoqCells(cellClasses: [NoItemsCell.self, OrderListViewCell.self])
            orderListTable?.tableFooterView = UIView(frame: CGRect.zero)
            orderListTable?.alpha = 0
        }
    }
    
    /// ??
    @IBOutlet var countLabel: UILabel? {
        didSet {
            countLabel?.font = AppTheme.sharedInstance.orderCountLabelFont
            countLabel?.textColor = AppTheme.sharedInstance.orderCountLabelTextColor
            
            countLabel?.text = AppLocalization.sharedInstance.orderHistoryTitleText
        }
    }
    
    /// ??
    @IBOutlet weak var totalItemsViewHeight: NSLayoutConstraint? {
        didSet {
            if !AppSettings.sharedInstance.isOrderHistoryTitleListShown {
                totalItemsViewHeight?.constant = 0
            }
        }
    }
    
    /// ??
    @IBOutlet var informationView: UIView? {
        didSet {
            informationView?.backgroundColor = AppTheme.sharedInstance.orderInfoViewBackgroundcolor
        }
    }

    /// View Model to handle the data to be shown.
    open var viewModel: OrderListViewModel?
    
    // MARK: - ViewLifeCycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO-GABI change name setUpNavigationBar() to setupView()
        // TODO-GABI registerCells()
        
        viewModel = OrderListViewModel(viewControllerDelegate: self)
        viewModel?.getorderList()
        setUpNavigationBar()

        // Log orderlist screen
        PoqTrackerHelper.trackOrderListLoaded()
        
        setUpPullToRefresh(orderListTable)
    }
    
    // MARK: - ViewSetup

    /**
     Function to set up the View.
     */
    open func setUpNavigationBar() {
        setUpBackButtonForNavigationBar()
        setUpSwipeFromEdgeToGoBack()
        setUpNavigationBarTitle()
    }
    
    /**
     Function to set up the Navigation Bar back button.
     */
    func setUpBackButtonForNavigationBar() {
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil
    }
    
    /**
     Function to set up the swipe from edge.
     */
    func setUpSwipeFromEdgeToGoBack() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /**
     Function to set up the Navigation Bar Title.
     */
    func setUpNavigationBarTitle() {
        navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.myProfileOrderHistoryNavigationTitleText)
    }
    
    /**
     Setup aUIRefreshControl to allow refresh the TableView.
     
     - Parameter tableView: the UITableView to add the refresh control.
     */
    open func setUpPullToRefresh(_ tableView: UITableView?) {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(startRefresh), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    // MARK: - UIRefreshControl
    
    /**
     Event to handle the pull to refresh action by the user.
     
     - Parameter refreshControl: the UIRefreshControl that triggers the event.
     */
    @objc fileprivate func startRefresh(_ refreshControl: UIRefreshControl ) {
        viewModel?.getorderList(true)
        refreshControl.endRefreshing()
    }
    
    // MARK: -

    /// ??
    func updateTotals() {
        if let viewModel = viewModel {
            let count = viewModel.getItemsCount()
            countLabel?.text = count == 1 ? String(format: "NUMBER_ORDER".localizedPoqString, count) : String(format: "NUMBER_ORDERS".localizedPoqString, count)
            countLabel?.isHidden = count == 0
        }
    }
    
    // MARK: - UITableViewDataSource

    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        return viewModel.orderListItems.count == 0 ? 1 : viewModel.orderListItems.count
    }

    @objc open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let viewModel = viewModel, viewModel.orderListItems.count > 0 {
            let cell: OrderListViewCell = tableView.dequeueReusablePoqCell()!
            cell.setUpData(viewModel.orderListItems[indexPath.row])
            return cell
        }
        
        let cell: NoItemsCell = tableView.dequeueReusablePoqCell()!
        cell.setUp(EmptyCellType.orderHistory)
        cell.goShoppingButton?.setTitle(AppLocalization.sharedInstance.myProfileGoToShoppingText, for: .normal)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    @objc open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel else {
            Log.warning("I’m returning height 0 because ViewModel is not set, which means there won’t be any items to show.")
            return 0
        }
        return viewModel.orderListItems.count != 0 ? AppSettings.sharedInstance.orderHistoryListCellHeight : tableView.frame.height
    }
    
    // MARK: - UITableViewDelegate
    
    @objc open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check the list items
        if (viewModel?.orderListItems.count ?? 0) > 0 {
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            if let selectedOrderKey = viewModel?.orderListItems[indexPath.row].orderKey, let externalOrderId = viewModel?.orderListItems[indexPath.row].externalOrderId {
                NavigationHelper.sharedInstance.loadOrderSummary(selectedOrderKey, externalOrderId: externalOrderId)
            }
        }
        
        // Dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Networking

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        orderListTable?.alpha = 1

        orderListCheck()
        orderListTable?.reloadData()
        
        if AppSettings.sharedInstance.shouldShowOrderCount {
            updateTotals()
        }
    }
    
    // MARK: - ErrorHandler

    /**
     Presents an Alert Controller with the errorMessage from the server.
     The Alert Controller will allow the user to navigate to Sign In
     
     - Parameter errorMessage: Error message string from the server to be showed to the user.
     */
    func popUpSyncError(_ errorMessage: String) {
        
        let okText = "OK".localizedPoqString
        let logoutText = "SIGN_IN".localizedPoqString
        
        let validAlertController = UIAlertController.init(title: "", message: errorMessage.localizedPoqString, preferredStyle: UIAlertControllerStyle.alert)

        alertController = validAlertController
        
        validAlertController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
        }))
        
        validAlertController.addAction(UIAlertAction.init(title: logoutText, style: UIAlertActionStyle.destructive, handler: { (_: UIAlertAction) in
            self.backButtonClicked()
            LoginHelper.clear()
            NavigationHelper.sharedInstance.loadLogin()
            return
        }))

        present(validAlertController, animated: true) {
        }
    }
    
    /**
     Checks if the orders data from backend is coming with errors to be showed to the user.
     If the error status code is not 200 and a message it is in place, the view will clean all orders and show an error.
     */
    func orderListCheck() {
        
        // This is used when bag view first load when all bag items are called
        if let orderListItems = viewModel?.orderListItems,
            orderListItems.count > 0,
            let firstOrder = viewModel?.orderListItems[0],
            let statusCode = firstOrder.statusCode,
            statusCode != 200,
            let errormessage = firstOrder.message {
            
                viewModel?.orderListItems = []
                orderListTable?.reloadData()
                popUpSyncError(errormessage)
        }
    }
}

// MARK: - NoItemsCellDelegate

extension OrderListViewController: NoItemsCellDelegate {
    
    public func noItemsContinueShoppinClicked() {
        NavigationHelper.sharedInstance.continueShopping()
    }
}

// MARK: - SignButtonDelegate

extension OrderListViewController: SignButtonDelegate {
    
    public func signButtonClicked(_ sender: Any?) {
        NavigationHelper.sharedInstance.loadHome()
    }
}

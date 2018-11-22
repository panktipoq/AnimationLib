//
//  OrderDetailViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/**
 Instanciate an Order Detail View Controller to show a single order.
 
 ## Usage Example: ##
 ````
 NavigationHelper.sharedInstance.loadOrderSummary(_ orderKey: String, externalOrderId: String)
 ````
 **Note:** Xib file name: "OrderDetailViewController"
 
 NavigationHelper Deeplink Route: "\(orderSummaryURL):orderKey"
 */
open class OrderDetailViewController: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables

    override open var screenName: String {
        return "Order History Details Screen"
    }

    @IBOutlet open weak var orderSummaryTableView: UITableView?

    /// View Model to handle the data to be shown.
    open var viewModel: OrderDetailViewModel?

    /// Order Key as ID of to the order to show in the view Controller.
    open var orderKey: String?

    /// Not used
    let basicInfoCellId = "orderBasicInfo"
    /// Not used
    let productInfoCellId = "orderProductInfo"
    /// Not used
    let giftCellId = "orderGiftMessage"
    /// Not used
    let totalCellId = "orderTotal"

    /// Fixed gift cell height
    let giftCellHeight: CGFloat = 130.00

    /// Store if the cell got a gift message.
    open var hasGiftMessage: Bool = false

    /// Stor the total number of Orders.
    open var totalNoOfOrders: Int = 0

    // MARK: - ViewLifeCycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        // TODO-GABI setUpView()
        // TODO-GABI registerCells()

        // Do any additional setup after loading the view.
        viewModel = OrderDetailViewModel(viewControllerDelegate: self)

        orderSummaryTableView?.registerPoqCells(cellClasses: [OrderDetailBasicViewCell.self, OrderDetailProductViewCell.self, OrderDetailGiftViewCell.self, OrderDetailTotalViewCell.self])

        if let orderKey = orderKey {
            viewModel?.getOrderDetails(orderKey)
        }

        setUpView()
        // Do any additional setup after loading the view.
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor=AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(OrderDetailViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        orderSummaryTableView?.addSubview(refreshControl)

        // Hide empty cells
        orderSummaryTableView?.tableFooterView = UIView(frame: CGRect.zero)

        // Remove the extra lines.
        orderSummaryTableView?.tableFooterView = UIView(frame: CGRect.zero)

        setUpPullToRefresh(orderSummaryTableView)
    }

    // MARK: - ViewSetup

    /**
     Function to set up the View.
     */
    func setUpView() {
        // TODO-GABI setUpBackButtonForNavigationBar()
        // TODO-GABI setUpSwipeFromEdgeToGoBack()
        // TODO-GABI setUpNavigationBarTitle()

        // Set up the back button
        // Set up back button
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil

        // Enable edge swipe back
        navigationController?.interactivePopGestureRecognizer?.isEnabled=true

        // Set title
        title = AppLocalization.sharedInstance.orderNaviTitle
        navigationItem.titleView = nil
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
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {

        if let orderKey = orderKey {
            viewModel?.getOrderDetails(orderKey, isRefresh: true)
        }

        refreshControl.endRefreshing()
    }

    // MARK: - Networking

    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) { }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        if networkTaskType == PoqNetworkTaskType.getOrderSummary {

            orderDetailCheck()

            if let orderKey = viewModel?.order?.orderKey {
                PoqTrackerHelper.trackOrderSummaryLoaded(orderKey)
            }

            if let giftMessage = viewModel?.order?.giftMessage {
                hasGiftMessage = !giftMessage.isEmpty
            } else {
                hasGiftMessage = false
            }

            if let orderItems = viewModel?.order?.orderItems {
                totalNoOfOrders = orderItems.count
            } else {
                totalNoOfOrders = 0
            }

            orderSummaryTableView?.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalNoOfOrders == 0 { return 0 }

        // Init row numbers = number of items + basic info + total
        let numberOfRows = totalNoOfOrders + 2

        return hasGiftMessage ? numberOfRows + 1 : numberOfRows
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return CGFloat(AppSettings.sharedInstance.orderDetailsBasicInfoCellHeight)

        } else if indexPath.row == totalNoOfOrders + 1 {
            // Gift message
            let totalCellHeight = CGFloat(AppSettings.sharedInstance.orderDetailsTotalInfoCellHeight)
            return hasGiftMessage ? getGiftMessageHeight() : totalCellHeight
        } else if indexPath.row == totalNoOfOrders + 2 {
            // If gift message, then it will reach total
            return CGFloat(AppSettings.sharedInstance.orderDetailsTotalInfoCellHeight)
        } else {
            return CGFloat(AppSettings.sharedInstance.orderDetailsProductInfoCellHeight)
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {

            let cell: OrderDetailBasicViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
            cell.setUpData(viewModel?.order)
            return cell
        } else if indexPath.row == totalNoOfOrders + 1 {

            if hasGiftMessage {

                let cell: OrderDetailGiftViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

                cell.setUpData(viewModel?.order?.giftMessage)
                return cell
            } else {

                let cell: OrderDetailTotalViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

                cell.setUpData(viewModel?.order)
                return cell
            }
        } else if indexPath.row == totalNoOfOrders + 2 {

            let cell: OrderDetailTotalViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

            cell.setUpData(viewModel?.order)
            return cell
        } else {

            let cell: OrderDetailProductViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

            cell.setUpData(viewModel?.order?.orderItems, index: indexPath.row-1)
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            return false
    }

    // MARK: -

    /**
     Calculate the Gift MEssage cell height in case there is a message to show.
     
     - returns: the calculated height for the cell.
     */
    fileprivate func getGiftMessageHeight() -> CGFloat {
        if let message = viewModel?.order?.giftMessage {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 200))
            label.text = message
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            label.sizeToFit()

            return 50 + label.frame.height
        } else {
            return giftCellHeight
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
            _ = self.navigationController?.popToRootViewController(animated: true)
            LoginHelper.clear()
            NavigationHelper.sharedInstance.loadLogin()
            return
        }))

        present(validAlertController, animated: true) {
        }
    }

    /**
     Checks if the order data from backend is coming with an error to be showed to the user.
     If the error status code is not 200 and a message it is in place, the view will show an error.
     */
    func orderDetailCheck() {
        // This is used when bag view first load when all bag items are called
        if let order = viewModel?.order,
            let statusCode = order.statusCode,
            statusCode != 200,
            let errormessage = order.message {

            popUpSyncError(errormessage)
        }
    }
}

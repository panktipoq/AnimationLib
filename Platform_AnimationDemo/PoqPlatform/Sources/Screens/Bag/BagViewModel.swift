//
//  BagViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/22/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import CoreLocation
import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics

public enum BagState {
    case normal
    case loading
    case editing
}

public enum NetworkTaskStatus {
    case started
    case failed
    case completed
}

protocol BagViewModelProtocol {
    
    func getBag(_ isRefresh: Bool)
    var bagItems: [PoqBagItem] { get set }
}

open class BagViewModel: BaseViewModel, BagViewModelProtocol {
    
    public typealias OrderType = PoqOrder<PoqOrderItem>
    
    // MARK: - Attributes
    // __________________
    
    open var bagItems = [PoqBagItem]()
    open var message = PoqMessage()
    open var order = OrderType()
    open var cartTransferURL: String?
    
    open var deletableItems = [PoqBagItem]()
    open var total: Double = 0.0
    open var totalItems: Int = 0
    open var bagItemsTask: PoqNetworkTask<JSONResponseParser<PoqBagItem>>?
    
    open private(set) var state: BagState = .normal
    
    open var locationManager: CLLocationManager?
    
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    public override init() {
        
        super.init()
        initLocationTracking()
        configureObservers()
    }
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
        initLocationTracking()
        configureObservers()
    }
    
    open func initLocationTracking() {
        
        if PermissionHelper.checkLocationAccess() == true {
            
            locationManager = CLLocationManager()
            
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager?.requestWhenInUseAuthorization()
            
            locationManager?.startUpdatingLocation()
        }
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogin), name: NSNotification.Name(rawValue: PoqUserDidLoginNotification), object: nil)
    }
    
    @objc open func handleUserLogin() {
        // Refresh the bag
        getBag(true)
    }
    
    // MARK: - Basic network task callbacks
    // ___________________________
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if networkTaskType == PoqNetworkTaskType.getBag {
            
            if let networkResult: [PoqBagItem] = result as? [PoqBagItem], networkResult.count > 0 {
                
                bagItems = networkResult
            } else {
                
                bagItems = []
            }
            
            BadgeHelper.setNumberOfBagItems(bagItems)
        } else if networkTaskType == PoqNetworkTaskType.order {
            
            if let networkResult: [PoqMessage] = result as? [PoqMessage], networkResult.count > 0 {
                
                parsePoqMessageToPoqOrder(networkResult[0], order: order)
                
                loadCookiesFromPoqMessage(networkResult[0])
                
                openCartViewController()
            }
        } else if networkTaskType == PoqNetworkTaskType.updateOrder {
            
            // There is nothing to do for now
            // Later we will parse some information, for example ID
        } else if networkTaskType == PoqNetworkTaskType.postBag {
            
            if let networkResult: [PoqMessage] = result as? [PoqMessage], networkResult.count > 0 {
                
                message = networkResult[0]
            }
            getBag(true)
        }
        
        deletableItems = []
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        if networkTaskType == PoqNetworkTaskType.deleteBagItem {
            deletableItems = []
        }
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    open func parsePoqMessageToPoqOrder(_ message: PoqMessage, order: OrderType) {
        
        if let cartURL: String = message.message, let key: String = message.key, let identifier: Int = message.id {
            
            order.orderKey = key
            order.id = identifier
            order.isCompleted = false
            
            if let storeName: String = message.storeName {
                order.nearestStoreName = storeName
            }
            
            cartTransferURL = cartURL
        }
    }
    
    open func loadCookiesFromPoqMessage(_ message: PoqMessage) {
        
        CookiesHelper.clearCookies()
        
        // Set cookie values for the user
        if let cookies = message.cookies {
            for cookie in cookies {
                
                guard let cookieName = cookie.name, let cookieValue = cookie.value else {
                    continue
                }
                
                // TODO: we do it from few places. Make it central or helper for it. May be cookie helper for all cookie work
                let cookieProperties: [HTTPCookiePropertyKey: Any] = [
                    HTTPCookiePropertyKey.name: cookieName as AnyObject,
                    HTTPCookiePropertyKey.value: cookieValue as AnyObject,
                    HTTPCookiePropertyKey.originURL: AppSettings.sharedInstance.clientDomain as AnyObject,
                    HTTPCookiePropertyKey.domain: AppSettings.sharedInstance.clientDomain,
                    HTTPCookiePropertyKey.path: "/",
                    HTTPCookiePropertyKey.expires: Date(timeIntervalSinceNow: 1432233446145.0/1000.0)
                ]
                
                if let httpCookie = HTTPCookie(properties: cookieProperties) {
                    HTTPCookieStorage.shared.setCookie(httpCookie)
                }
            }
        }
    }
    
    open func getCartIdForProductSizeId(_ productSizeId: Int, bagItems: [PoqBagItem]?) -> String? {
        
        guard let checkoutBagItems = bagItems else {
            return nil
        }
        
        for checkoutBagItem in checkoutBagItems {
            
            if let psid = checkoutBagItem.productSizeId, psid == productSizeId {
                
                return checkoutBagItem.cartId
            }
        }
        
        return nil
    }
    
    open func setupPullToRefresh(_ tableView: UITableView?) {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(BagViewModel.startRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    // Private selectors are not recognized so @objc solves this bug!
    @objc fileprivate func startRefresh(_ refreshControl: UIRefreshControl) {
        
        getBag(true)
        refreshControl.endRefreshing()
    }
    
    @objc open func triggerEdit() {
        guard let validViewControllerDelegate = self.viewControllerDelegate as? PoqBaseBagViewController else {
            return
        }
        validViewControllerDelegate.perform( #selector(PoqBaseBagViewController.editButtonClicked))
    }
    
    open func setNavigationItemPositionForModal(_ editButton: UIBarButtonItem?) {
        
        // NavigationItems: X ______________ Edit
        if let closeButtonDelegate: CloseButtonDelegate = viewControllerDelegate {
            viewControllerDelegate?.navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(closeButtonDelegate)
        }
        viewControllerDelegate?.navigationItem.rightBarButtonItem = editButton
    }
    
    open func setNavigationItemPosition(_ editButton: UIBarButtonItem?) {
        
        if AppSettings.sharedInstance.editButtonDirection == BagEditButtonDirection.Left.rawValue {
            
            viewControllerDelegate?.navigationItem.leftBarButtonItem = editButton
        } else {
            
            viewControllerDelegate?.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    open func updateBag(for newState: BagState, bagTableView: UITableView?, editButton: UIBarButtonItem?, checkoutButton: UIButton?, confirmEditing: Bool = false) {
        
        var editButtonTitle: String
        var enableButtons: (edit: Bool, checkout: Bool)
        
        switch newState {
            
        case .normal:
            editButtonTitle = AppLocalization.sharedInstance.bagNavigationBarItemText
            bagTableView?.setEditing(false, animated: true)
            enableButtons = (hasBagItems(), hasBagItems())
            // Update table items
            bagTableView?.reloadData()
            
        case .editing:
            editButtonTitle = AppLocalization.sharedInstance.bagViewDoneButtonText
            // If tableView is already in editing mode, set editing to false to close any delete actions before re-setting editing mode
            if let tableViewIsEditing = bagTableView?.isEditing, tableViewIsEditing {
                bagTableView?.setEditing(false, animated: true)
            }
            bagTableView?.setEditing(true, animated: true)
            enableButtons = (true, false)
            // Update table items
            bagTableView?.reloadData()
            
        case .loading:
            editButtonTitle = AppLocalization.sharedInstance.bagNavigationBarItemText
            bagTableView?.setEditing(false, animated: true)
            enableButtons = (false, false)
        }
        
        // Update Edit button title accordingly
        if let button = editButton?.customView as? UIButton {
            button.setTitle(editButtonTitle, for: UIControlState())
        } else {
            editButton?.title = editButtonTitle
        }
        
        // Set interaction availability
        editButton?.isEnabled = enableButtons.edit
        checkoutButton?.isEnabled = enableButtons.checkout
        
        // Send Bag items update confirmation
        if confirmEditing {
            updateAllBagItems()
            PoqTrackerV2.shared.bagUpdate(totalQuantity: CheckoutHelper.getNumberOfBagItems(bagItems), totalValue: CheckoutHelper.getBagItemsTotal(bagItems))
        }
        // Persist the new state
        state = newState
    }
    
    // MARK: - Order Operations
    // ______________________
    
    public func createOrder() -> OrderType? {
        
        guard hasBagItems() else {
            
            return nil
        }
        
        let order = OrderType(bagItems: bagItems)
        
        if PermissionHelper.checkLocationAccess() == true {
            
            order.updateOderWithUserLocation(locationManager?.location)
        }
        
        return order
    }
    
    open func getEANFromProductByProductSizeId(_ productSizeId: Int?, product: PoqProduct?) -> String? {
        // Find sku in productSize
        if let product = product, let identifier = product.id, let productSizes = product.productSizes {
            for productSize in productSizes where identifier == productSizeId {
                return productSize.ean
            }
        }
        return nil
    }
    
    // MARK: - TableView Operations
    // ____________________________
    
    open func getCellRowHeight(_ tableView: UITableView) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    open func getNumberOfRowsForTableView( _ tableView: UITableView ) -> Int {
        return bagItems.count > 0 ? bagItems.count : 1
    }
    
    open func getCellForIndexPath(_ tableView: UITableView, indexPath: IndexPath, delegate: AnyObject) -> UITableViewCell {
        
        if hasBagItems(), let parsedDelegate = delegate as? BagItemTableViewCellDelegate {
            
            return getBagItemTableViewCell(tableView, indexPath: indexPath, delegate: parsedDelegate)
            
        } else if let noItemDelegate = delegate as? NoItemsCellDelegate {
            
            return getBagNoItemsTableViewCell(tableView, indexPath: indexPath, delegate: noItemDelegate)
        }
        
        return UITableViewCell()
    }
    
    open func loadProductDetailForRow(_ row: Int) {
        
        if hasBagItems() {
            
            let productIdAndExternalIdValidation = hasValidProductIdAndExternalIdForRow(row)
            
            if productIdAndExternalIdValidation.valid {
                
                NavigationHelper.sharedInstance.loadProduct(productIdAndExternalIdValidation.productId, externalId: productIdAndExternalIdValidation.externalProductId, isModal: false, isViewAnimated: true, source: ViewProductSource.bag.rawValue, productTitle: bagItems[row].product?.title ?? "")
            }
        }
    }
    
    open func loadProductDetailsForRowFromModal(_ row: Int) {
        
        if hasBagItems() {
            
            let productIdAndExternalIdValidation = hasValidProductIdAndExternalIdForRow(row)
            
            if productIdAndExternalIdValidation.valid {
                
                NavigationHelper.sharedInstance.loadProduct(productIdAndExternalIdValidation.productId, externalId: productIdAndExternalIdValidation.externalProductId, topViewController: viewControllerDelegate, source: ViewProductSource.modalBag.rawValue, productTitle: bagItems[row].product?.title ?? "")
            }
        }
    }
    
    // MARK: - Network Operations
    // __________________________
    
    open func getBag(_ isRefresh: Bool = false) {
        
        if let validBagItemTask = bagItemsTask {
            validBagItemTask.cancel()
            bagItemsTask = nil
        }
        
        bagItemsTask = PoqNetworkService(networkTaskDelegate: self).getUsersBagItems(User.getUserId(), isRefresh: isRefresh)
    }
    
    public func updateBagItems(_ bagItemPostBody: PoqBagItemPostBody) {
        
        PoqNetworkService(networkTaskDelegate: self).updateUsersBagItems(User.getUserId(), postBody: bagItemPostBody)
    }
    
    open func postOrder(_ order: OrderType) {
        
        self.order = order
        
        PoqNetworkService(networkTaskDelegate: self).postOder(order)
    }
    
    public func postCompletedOrder(_ order: OrderType) {
        
        PoqNetworkService(networkTaskDelegate: self).postCompletedOrder(order)
    }
    
    public func removeBagItems() {
        
        PoqNetworkService(networkTaskDelegate: self).deleteUsersAllBagItems(User.getUserId())
    }
    
    public func removeSingleBagItem(poqBagItem: PoqBagItem) {
        let item = poqBagItem.constructPoqBagItemPost()
        item.quantity = 0 // This way we tell backend to remove this item
        let postBody = PoqBagItemPostBody()
        postBody.items?.append(item)
        PoqNetworkService(networkTaskDelegate: self).deleteUsersBagItem(User.getUserId(), postBody: postBody)
        
        deletableItems = [PoqBagItem]()
    }
    
    // MARK: - BagSync Checks
    // ______________________
    
    open func checkBagItemsStatus(_ tableView: UITableView?) {
        
        if hasBagItems() {
            
            let firstItem: PoqBagItem = bagItems[0]
            
            // This is used when bag view first load when all bag items are called
            if !BagHelper.isStatusCodeOK(firstItem.statusCode) {
                
                resetTableAndShowErrorPopup(tableView, errorMessage: firstItem.message)
            }
        }
    }
    
    open func checkBagStatus(_ tableView: UITableView?) {
        
        // This is to check while updating and deleting bag items as methods returns message
        if !BagHelper.isStatusCodeOK(message.statusCode) {
            
            resetTableAndShowErrorPopup(tableView, errorMessage: message.message)
        }
    }
    
    // MARK: - Bag Operations
    // ______________________
    
    open func deleteBagItem(at index: Int, isSwipeDelete: Bool = false, completion: ((_ removed: Bool) -> Void)?) {
        guard isIndexValid(index) else {
            Log.error("Index of item to delete '\(index)' is not valid.")
            completion?(false)
            return
        }
        
        let item = bagItems[index]
        guard canDeleteItem(item) else {
            completion?(false)
            return
        }
        
        item.quantity = 0
        bagItems.remove(at: index)
        deletableItems.append(item)
        
        if isSwipeDelete {
            removeSingleBagItem(poqBagItem: item)
        } else if !hasBagItems() {
            updateAllBagItems()
        }
        
        completion?(true)
    }
    
    public func deleteBagItem(_ item: PoqBagItem, isSwipeDelete: Bool = false, completion: ((_ removed: Bool) -> Void)?) {
        guard let index = bagItems.index(where: { $0 === item }) else {
            Log.error("Unable to find index to delete bag item.")
            completion?(false)
            return
        }
        
        deleteBagItem(at: index, isSwipeDelete: isSwipeDelete, completion: completion)
    }
    
    open func hasBagItems() -> Bool {
        
        return bagItems.count != 0
    }
    
    open func hasValidProductIdAndExternalIdForRow(_ row: Int) -> (valid: Bool, productId: Int, externalProductId: String) {
        
        if let selectedProductId = bagItems[row].product?.id, let selectedExternalId = bagItems[row].product?.externalID {
            
            return (valid: true, productId: selectedProductId, externalProductId: selectedExternalId)
        } else {
            
            return (valid: false, productId: 0, externalProductId: "")
        }
    }
    
    open func isIndexValid(_ index: Int) -> Bool {
        
        return index < bagItems.count
    }
    
    // Only external products are eligable for deletion.
    open func canDeleteItem(_ item: PoqBagItem) -> Bool {
        if let isExternal = item.isExternal, isExternal {
            return true
        }
        
        if let productSizeId = item.productSizeId, productSizeId > 0 {
            return true
        }
        
        return false
    }
    
    open func canSelectCell(atRow row: Int) -> Bool {
        guard isIndexValid(row) else {
            Log.error("Index of item to select '\(row)' is not valid.")
            return false
        }
        
        let item = bagItems[row]
        
        // Cannot select external items.
        guard item.isExternal != true else {
            return false
        }
        
        // Cannot select invalid items.
        guard item.product?.id != nil, item.product?.externalID != nil else {
            return false
        }
        
        return true
    }
    
    open func updateAllBagItems() {
        let bagItemPostBody: PoqBagItemPostBody = BagViewModel.createBagItemPostBody(bagItems, deletedItems: deletableItems)
        updateBagItems(bagItemPostBody)
        
        // Clean removed items array, since we post infor to sever, nothing else we can do
        deletableItems = [PoqBagItem]()
    }
    
    // MARK: - Private
    
    fileprivate class func createBagItemPostBody(_ existedBagItems: [PoqBagItem], deletedItems: [PoqBagItem]) -> PoqBagItemPostBody {
        
        let bagItemPostBody = PoqBagItemPostBody()
        
        let allItems = existedBagItems + deletedItems
        
        for bagItem in allItems {
            let bagItemPostBodyItem = bagItem.constructPoqBagItemPost()
            bagItemPostBody.items?.append(bagItemPostBodyItem)
        }
        
        return bagItemPostBody
    }
    
    fileprivate func openCartViewController() {
        
        guard let cartURL: String = cartTransferURL, let orderId = order.id, orderId > 0 else {
            Log.error("We can't opne cart transfer controller. Issue with url( \(String(describing: cartTransferURL)) ) or order.id( \(String(describing: order.id)) ) ")
            return
        }
        
        let cartTransferView = CartTransferViewController(nibName: "CartTransferView", bundle: nil)
        cartTransferView.cartURL = cartURL
        cartTransferView.order = order
        
        // We need to wrap CartTransferViewController with PoqNavigationViewController for close button in modal view
        let navigationController = PoqNavigationViewController(rootViewController: cartTransferView)
        viewControllerDelegate?.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func getBagItemTableViewCell(_ tableView: UITableView, indexPath: IndexPath, delegate: BagItemTableViewCellDelegate) -> BagItemTableViewCell {
        
        let cell: BagItemTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.delegate = delegate
        if indexPath.row < bagItems.count {
            // We got crash while there is no check. Cell will be configured inproperly, but app won't crash
            cell.setCellData(bagItems[indexPath.row], isEditing: state == .editing)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessibilityIdentifier = AccessibilityLabels.addtoBag
        
        return cell
    }
    
    fileprivate func getBagNoItemsTableViewCell(_ tableView: UITableView, indexPath: IndexPath, delegate: NoItemsCellDelegate) -> NoItemsCell {
        
        if let cell: NoItemsCell = tableView.dequeueReusablePoqCell() {
            cell.setUp(EmptyCellType.bagItems)
            cell.delegate = delegate
            return cell
        } else {
            return NoItemsCell()
        }
    }
    
    fileprivate func resetTableAndShowErrorPopup(_ tableView: UITableView?, errorMessage: String?) {
        message = PoqMessage()
        bagItems = []
        tableView?.reloadData()
        
        popUpSyncError(errorMessage)
    }
    
    fileprivate func popUpSyncError(_ errorMessage: String?) {
        
        let errorMessageContent = errorMessage ?? "Error Bag Sync"
        let okText = "OK".localizedPoqString
        
        let alertController = UIAlertController(title: "", message: errorMessageContent.localizedPoqString, preferredStyle: .alert)
        
        if !LoginHelper.isLoggedIn() {
            let loginText = "SIGN_IN".localizedPoqString
            
            alertController.addAction(UIAlertAction(title: loginText, style: .destructive) { _ in
                self.message = PoqMessage()
                LoginHelper.clear()
                NavigationHelper.sharedInstance.loadLogin()
                return
            })
        }
        
        alertController.addAction(UIAlertAction(title: okText, style: .default))
        
        viewControllerDelegate?.present(alertController, animated: true)
    }
}

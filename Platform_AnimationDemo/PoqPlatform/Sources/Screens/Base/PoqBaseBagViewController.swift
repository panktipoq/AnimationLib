//
//  PoqBaseBagViewController.swift
//  PoqPlatform
//
//  Created by Mahmut Canga on 08/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PassKit
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics

/// The base bag view controller, housing shared bag functionality between different bag view styles.
/// These include the animation and updating of the info panel, the handling of data from the view controller...
/// TODO: Rename baseViewProperties to viewProperties and use them in subclasses.
/// TODO: Move apple pay parts out of the base bag view controller and into `CheckoutBagViewController` or protocol.
open class PoqBaseBagViewController: PoqBaseViewController {
    
    public static let editButtonAccessibilityId = "editButtonAccessibilityId"
    
    /// The underlying view model that drives the data behind the bag view controller.
    /// TODO: Remove force unwrap.
    open var viewModel: BagViewModel!
    
    /// Whether the bag view should be setup modally or not.
    /// This affects how the navigation bar is setup and transition animation when navigating away from this view.
    /// TODO: Replace with existing view controller functions for whether this is modal or not.
    open var isModal = false
    
    /// Used by the CheckoutBagViewController and the BagViewController to initialize the total labels.
    /// TODO: Remove this, it is meaningless.
    open var singleItemCount: Double = 0
    
    /// Whether there is a current ongoing network task or not.
    /// Whilst true, this disables some table view interaction to prevent conflicts when handling responses.
    /// TODO: This is a network state flag that should be moved to the view model.
    open var isNetworkOperationProcessing = false
    
    /// The edit bag button if present on the navigation bar.
    open var editButton: UIBarButtonItem? {
        didSet {
            editButton?.isAccessibilityElement = true
            editButton?.accessibilityIdentifier = PoqBaseBagViewController.editButtonAccessibilityId
        }
    }
    
    /// The main bag items table view.
    @IBOutlet open var baseTableView: UITableView? {
        didSet {
            baseTableView?.tableFooterView = UIView(frame: .zero)
        }
    }
    
    /// Height constraint for the bag view bottom panel containing the checkout button and total values.
    /// By default this constraint is forced to 0 when set and animated to `originalTotalInfoPanelHeight` when the bag is not empty.
    @IBOutlet open var totalInfoPanelHeight: NSLayoutConstraint? {
        didSet {
            // Initially we force the panel's height to 0.
            // Later when `bagItems > 0` we animate this to the `originalTotalInfoPanelheight`.
            totalInfoPanelHeight?.constant = 0
        }
    }
    @IBOutlet var checkoutButtonBottomConstraint: NSLayoutConstraint?
    
    /// The desired height for the info panel; used when the bag is not empty and we are not using vouchers.
    open var originalTotalInfoPanelHeight: CGFloat = 110
    
    /// The desired height for the info panel; used with vouchers and logged in, whilst the bag is not empty.
    /// By default the voucher bars height would be 44, defaulting the total height to 154.
    open var voucherTotalInfoPanelHeight: CGFloat = AppSettings.sharedInstance.voucherTotalInfoPanelHeight
    
    /// The item count label.
    /// By default it is displayed on the left of the bag's info panel, above the checkout button.
    @IBOutlet open var baseItemsLabel: UILabel?
    
    /// The total price label.
    /// By default it is displayed to the right of the item count label in the bag's info panel.
    @IBOutlet open var baseTotalLabel: UILabel?
    
    /// The checkout button.
    /// By default it is displayed at the bottom of the info panel.
    @IBOutlet open var baseCheckoutButton: CheckoutButton?
    
    /// The apple pay button for native checkout.
    /// Currently this is set programatically and located next to the checkout button.
    open weak var applePayButton: UIButton?
    
    /// Constraint that, when active, allows the apple pay button to sit next to the checkout button.
    /// TODO: This should be replaced with a stack view.
    @IBOutlet open var applePayButtonWidthAvailableConstraint: NSLayoutConstraint?
    
    /// Constraint that, when active, makes the checkout button take up the full width.
    /// TODO: This should be replaced with a stack view.
    @IBOutlet open var applePayButtonWidthUnavailableConstraint: NSLayoutConstraint?
    
    /// Unecessary container view for the apple pay button; the applePayButtonWidth constraints apply to this view.
    /// TODO: This should be replaced with one button container horizontal stack view.
    @IBOutlet open weak var applePayButtonContainer: UIView?

    // MARK: - UIViewController: Common functionality and overrides
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        viewModel = createBagViewModel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = createBagViewModel()
    }
    
    /// Called by `init`, this is used to create this view controller's view model.
    /// Subclasses should overrride this method if the need their own custom view model.
    /// - result: A `BagViewModel` to use as this view controller's view model.
    open func createBagViewModel() -> BagViewModel {
        return BagViewModel(viewControllerDelegate: self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.setupPullToRefresh(baseTableView)
        
        // Setup the navigation bar edit button to change bag states.
        let editButtonTitle = AppLocalization.sharedInstance.bagNavigationBarItemText
        editButton = NavigationBarHelper.createButtonItem(withTitle: editButtonTitle, target: self, action: #selector(editButtonClicked))
        editButton?.setTitleTextAttributes([.font: AppTheme.sharedInstance.naviBarItemFont, .foregroundColor: AppTheme.sharedInstance.bagNavigationBarItemTextColorActive], for: .normal)
        editButton?.setTitleTextAttributes([.font: AppTheme.sharedInstance.naviBarItemFont, .foregroundColor: AppTheme.sharedInstance.bagNavigationBarItemTextColorDisable], for: .disabled)
        
        if isModal {
            viewModel.setNavigationItemPositionForModal(editButton)
        } else {
            viewModel.setNavigationItemPosition(editButton)
        }
        
        if AppSettings.sharedInstance.hideRightNavigationMenuOnBag {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        updateTotals()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PoqUserNotificationCenter.shared.setupRemoteNotifications()
        handleViewWillAppear()
    }
    
    /// Handles additional viewWillAppear setup that can be overriden without needing to call super.
    /// By default this sets the table view and chekout buttons alpha to 0 for handling empty bag animation.
    open func handleViewWillAppear() {
        // Hide base table view when reloading
        baseTableView?.alpha = 0
        baseCheckoutButton?.alpha = 0
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleViewDidAppear()
    }
    
    /// Handles additional viewDidAppear setup that can be overriden without needing to call super.
    /// By default this updates the bag's editing state to normal and fetches bag data.
    open func handleViewDidAppear() {
        viewModel.updateBag(for: .normal, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton)
        viewModel.getBag()
    }
    
    // MARK: - Bag functionality
    
    /// Displays the bag table view.
    /// By default this animates in the table view's alpha, and checkout button's alpha (if the bag is not empty).
    open func showTableView() {
        UIView.animate(withDuration: 0.3) {
            self.baseTableView?.alpha = 1
            if self.viewModel.hasBagItems() {
                self.baseCheckoutButton?.alpha = 1
            }
        }
    }
    
    /// Shows or hides the info panel based on the item count. If the bag is not empty (the specified count is > 0) the info panel will show.
    /// - parameter totalItemCount: The number of items in the bag, used for deciding whether to show or hide the panel.
    /// TODO: This function should be named better or a broken into two functions one for deciding based on the count the second for performing.
    open func showHideTotalInfoPanel(_ totalItemCount: Int) {
        let heightWithItems = LoginHelper.isLoggedIn() ? voucherTotalInfoPanelHeight : originalTotalInfoPanelHeight
        let heightToHidePanel: CGFloat = 0
        let totalInfoPanelHeight = totalItemCount > 0 ? heightWithItems : heightToHidePanel
        
        view.layoutIfNeeded()
        checkoutButtonBottomConstraint?.isActive = totalItemCount > 0
        
        UIView.animate(withDuration: 0.3) {
            self.totalInfoPanelHeight?.constant = totalInfoPanelHeight
            self.view.layoutIfNeeded()
        }
    }
    
    /// Updates the item count and total price and reloads the table view.
    /// - parameter tableView: The table view to reload.
    /// TODO: This should be removed in favour of the table view property.
    open func updateTotalAndReloadTable(_ tableView: UITableView?) {
        updateTotals()
        tableView?.reloadData()
    }
    
    // MARK: - ApplePay functionality
    
    /// Creates and returns a UIButton for ApplePay for the `applePayButton`.
    /// - result: Optional button to use for ApplePay payment.
    open func createApplePayButton() -> UIButton? {
        let button = PKPaymentButton()
        return button
    }
    
    /// Returns whether the view should include the ApplePay button or not; by default this returns false.
    /// Subclasses should override this and return true if they wish to show the ApplePay button.
    /// TODO: Rename this to a better name and turn it into a property.
    /// - result: Whether the view should include the ApplePay button.
    open func shouldPresentApplePayButton() -> Bool {
        return false
    }
    
    /// Updates the constraints for the `applePayButton` container (setting up and adding the button if its is enabled within the app).
    /// By default this positions the ApplePay button to the right of the checkout button.
    open func updateApplePayElements () {
        guard shouldPresentApplePayButton() else {
            applePayButton?.removeFromSuperview()
            
            // Set constraints to hide the `applePayButton`.
            applePayButtonWidthAvailableConstraint?.isActive = false
            applePayButtonWidthUnavailableConstraint?.isActive = true
            
            return
        }
        
        // Set constraints to show the `applePayButton`.
        applePayButtonWidthUnavailableConstraint?.isActive = false
        applePayButtonWidthAvailableConstraint?.isActive = true
        
        // If the `applePayButton` has not already been setup then we set it up below.
        if let containerView = applePayButtonContainer, applePayButton == nil {
            if let applePayButton = createApplePayButton() {
                applePayButton.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.addSubview(applePayButton)
                
                let viewsDictionary = ["applePayButton": applePayButton]
                
                let metrics = ["horizontalButtonsIndent": 8]
                let horContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-horizontalButtonsIndent-[applePayButton]|", options: [], metrics: metrics, views: viewsDictionary)
                let vertContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[applePayButton]|", options: [], metrics: metrics, views: viewsDictionary)
                
                containerView.addConstraints(horContraints)
                containerView.addConstraints(vertContraints)
                applePayButton.addTarget(self, action: #selector(applePayButtonAction), for: .touchUpInside)
                
                self.applePayButton = applePayButton
            }
        }
        
        applePayButton?.isHidden = false
    }
    
    // MARK: - Action handling
    
    /// Action handler for the `closeButton`.
    /// Dismisses the view controller if its modal.
    override open func closeButtonClicked() {
        if isModal {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Action handler for the `editButton`.
    /// Alternates the bag's state between edit bag and normal.
    @objc open func editButtonClicked() {
        switch viewModel.state {
        case .normal:
            viewModel.updateBag(for: .editing, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton)
            
        case .editing:
            viewModel.updateBag(for: .normal, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton, confirmEditing: true)
            
        case .loading:
            break // Should never enter this case - editing is disabled while loading
        }
    }
    
    /// Action handler for the `applePayButton`.
    /// Subclass this to provide ApplePay functionality; by default this does nothing.
    /// - parameter sender: The UIButton that fired this function, usually `applePayButton`.
    @objc open func applePayButtonAction(_ sender: UIButton) {
    }
    
    // MARK: - PoqNetworkTaskDelegate: Network task handling
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
            self.updateView(for: .started)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        if networkTaskType == PoqNetworkTaskType.deleteBagItem {
            BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagSwipeToDeleteNetworkErrorMessage, isSuccess: false, displayInterval: 2)
        }
        
        // Need to update tableview state if api call gets failed
        viewModel.updateBag(for: .normal, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton)
        self.updateView(for: .failed)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.deleteBagItem {
            BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagSwipeToDeleteSuccessMessage, isSuccess: true)
        }
        
        // No need to update ui when postbag called, next call to getBag will update ui
        // This will fix twise realoding of tableview issue
        if networkTaskType != .postBag {
            viewModel.updateBag(for: .normal, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton)
        }
        self.updateView(for: .completed)
    }
    
    private func updateView(for status: NetworkTaskStatus) {
        switch status {
        case .started:
            // Disable the checkout button and user interaction to prevent the user starting async actions that rely on the same state.
            isNetworkOperationProcessing = true
            baseTableView?.isUserInteractionEnabled = false
            viewModel.updateBag(for: .loading, bagTableView: baseTableView, editButton: editButton, checkoutButton: baseCheckoutButton)
        case .failed:
            baseTableView?.isUserInteractionEnabled = true
            isNetworkOperationProcessing = false
            showTableView()
        case .completed:
            // Reenable user interaction as the network task has finished.
            baseTableView?.isUserInteractionEnabled = true
            isNetworkOperationProcessing = false
            showTableView()
            
            // Reset the table view and show an error if necessary for bag sync.
            viewModel.checkBagItemsStatus(baseTableView)
            viewModel.checkBagStatus(baseTableView)
            
            // Update the view incase the state has changed due to POST_BAG.
            updateTotalAndReloadTable(baseTableView)
        }
    }
    
}

// MARK: - BagItemTableViewCellDelegate: Protocol conformance
extension PoqBaseBagViewController: BagItemTableViewCellDelegate {
    
    @objc open func updateTotals() {
        guard isViewLoaded else {
            // Interface is not yet loaded so there is nothing to update.
            return
        }
        
        let count = CheckoutHelper.getNumberOfBagItems(viewModel.bagItems)
        
        if count == 0 && AppSettings.sharedInstance.enableHideCountLabelOnBag {
            baseItemsLabel?.text = ""
        } else if count == 1 {
            baseItemsLabel?.text = String(format: AppLocalization.sharedInstance.bagCountSingleText, count)
        } else {
            baseItemsLabel?.text = String(format: AppLocalization.sharedInstance.bagCountMultipleText, count)
        }
        
        let grandTotal = CheckoutHelper.getBagItemsTotal(viewModel.bagItems)
        self.baseTotalLabel?.attributedText = LabelStyleHelper.initGrandTotalLabel(grandTotal)
        
        BadgeHelper.updateBagBadgeTotal(viewModel.bagItems)
        
        showHideTotalInfoPanel(count)
    }
    
    public func removeBagItem(_ item: PoqBagItem) {
        removeBagItem(item, isSwipeDelete: false)
    }
    
    /// Removes the specified `PoqBagItem`'s row from the table view with an optional completion.
    /// Shows a confirmation if `AppSettings.sharedInstance.bagEnableDeleteConfirmation` is enabled.
    /// - parameter item: The item to remove from the bag.
    /// - parameter isSwipeDelete: If true delete is carried out in a different way, using the table view's `deleteRows` or `reloadRows` with a fade animation.
    /// - parameter completion: Optional completion handler with whether the item was successfully removed or not.
    public func removeBagItem(_ item: PoqBagItem, isSwipeDelete: Bool, shouldUpdateView: Bool = true, completion: ((_ removed: Bool) -> Void)? = nil) {
        if AppSettings.sharedInstance.bagEnableDeleteConfirmation {
            confirmRemove(item, isSwipeDelete: isSwipeDelete, shouldUpdateView: shouldUpdateView, completion: completion)
        } else {
            remove(item, isSwipeDelete: isSwipeDelete, shouldUpdateView: shouldUpdateView, completion: completion)
        }
    }
    
    /// Private function, called by `removeBagItem`, which shows a confirmation alert for the removal of the specified item.
    /// - parameter item: The item to remove from the bag.
    /// - parameter isSwipeDelete: If true delete is carried out in a different way, using the table view's `deleteRows` or `reloadRows` with a fade animation.
    /// - parameter completion: Optional completion handler with whether the item was successfully removed or not.
    private func confirmRemove(_ item: PoqBagItem, isSwipeDelete: Bool, shouldUpdateView: Bool, completion: ((_ removed: Bool) -> Void)?) {
        let message = item.product?.title.flatMap({ String(format: AppLocalization.sharedInstance.bagRemoveItemsText, $0) }) ?? ""
        let alertController = UIAlertController(title: "Confirm".localizedPoqString, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "CANCEL".localizedPoqString, style: .cancel, handler: { _ in
            completion?(false)
        }))
        
        alertController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: .default, handler: { [weak self] _ in
            self?.remove(item, isSwipeDelete: isSwipeDelete, shouldUpdateView: shouldUpdateView, completion: completion)
        }))
        
        self.alertController = alertController
        present(alertController, animated: true)
    }
    
    /// Private function which handles removing the specified `PoqBagItem` from the bag.
    /// - parameter item: The item to remove from the bag.
    /// - parameter isSwipeDelete: If true delete is carried out in a different way, using the table view's `deleteRows` or `reloadRows` with a fade animation.
    /// - parameter completion: Optional completion handler with whether the item was successfully removed or not.
    private func remove(_ item: PoqBagItem, isSwipeDelete: Bool, shouldUpdateView: Bool, completion: ((_ removed: Bool) -> Void)?) {
        guard let viewModel = viewModel else {
            return
        }
        
        let event = isSwipeDelete ? PoqTrackerEventType.RemoveFromBagSwiping : PoqTrackerEventType.RemoveFromBag
        PoqTracker.sharedInstance.logAnalyticsEvent(event, action: event, label: "", extraParams: nil)
        
        let index = viewModel.bagItems.index(where: { $0 === item })
        viewModel.deleteBagItem(item, isSwipeDelete: isSwipeDelete) { [weak self] (removed: Bool) in
            if removed {
                PoqTrackerV2.shared.removeFromBag(productId: item.productSizeId ?? 0, productTitle: item.product?.title ?? "")
                
                if !viewModel.hasBagItems() {
                    PoqTrackerV2.shared.clearBag()
                }
            }
            
            if shouldUpdateView, let strongSelf = self, let indexPath = index.flatMap({ IndexPath(row: $0, section: 0) }) {
                if viewModel.hasBagItems() {
                    strongSelf.baseTableView?.deleteRows(at: [indexPath], with: .fade)
                } else {
                    strongSelf.baseTableView?.reloadRows(at: [indexPath], with: .fade)
                }
            }
            
            completion?(removed)
        }
    }
}

// MARK: - UITableViewDataSource: Protocol conformance
extension PoqBaseBagViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsForTableView = viewModel.getNumberOfRowsForTableView( tableView )
        return numberOfRowsForTableView
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return viewModel.getCellForIndexPath(tableView, indexPath: indexPath, delegate: self)
    }
}

// MARK: - UITableViewDelegate: Protocol conformance
extension PoqBaseBagViewController: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getCellRowHeight(tableView)
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isNetworkOperationProcessing
    }
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard AppSettings.sharedInstance.isBagSwipeToDeleteEnabled else {
            return .none
        }
        
        guard let viewModel = viewModel, viewModel.state != .editing, indexPath.row < viewModel.bagItems.count else {
            return .none
        }
        
        return .delete
    }
    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard AppSettings.sharedInstance.isBagSwipeToDeleteEnabled else {
            return nil
        }
        
        guard let viewModel = viewModel, viewModel.state != .editing, indexPath.row < viewModel.bagItems.count else {
            return nil
        }
        
        // The new destructive style handles the delete from bag when swiping.
        let deleteItem = viewModel.bagItems[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (_: UIContextualAction, _: UIView, completion: @escaping (Bool) -> Void) in
            if let strongSelf = self {
               return strongSelf.removeBagItem(deleteItem, isSwipeDelete: true, shouldUpdateView: false, completion: completion)
            }
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard viewModel.canSelectCell(atRow: indexPath.row) else {
            return
        }
        
        if isModal {
            viewModel.loadProductDetailsForRowFromModal(indexPath.row)
        } else {
            viewModel.loadProductDetailForRow(indexPath.row)
        }
    }
}

// MARK: - NoItemsCellDelegate: Protocol conformance
extension PoqBaseBagViewController: NoItemsCellDelegate {
    
    open func noItemsContinueShoppinClicked() {
        if AppSettings.sharedInstance.bagViewInNavigation {
            navigationController?.dismiss(animated: true) {
                NavigationHelper.sharedInstance.continueShopping()
            }
        } else {
            NavigationHelper.sharedInstance.continueShopping()
        }
    }
}

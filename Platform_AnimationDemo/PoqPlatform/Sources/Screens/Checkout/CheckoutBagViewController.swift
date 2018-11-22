//
//  CheckoutBagViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 01/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import BoltsSwift
import Foundation
import ObjectMapper
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import Stripe

/// TODO: remove all this chains and use NSOperationQueus
enum RequestsChain: String {
    case shippingAddress = "ShippingAddress"
    case shippingMethod = "ShippingMethod"
    case payment = "Payment"
}

typealias ApplePayCompletion = () -> Void

/// Subclass of `PoqBaseBagViewController`
/// It includes Apple Pay functionality as well as voucher functionality.
open class CheckoutBagViewController: PoqBaseBagViewController {
    
    public static let totalQuantityAccessibilityId = "totalQuantityAccessibilityId"
    public static let totalCostAccessibilityId = "totalCostAccessibilityId"

    /// Aliases for generic clases used for apple pay network calls.
    typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>
    typealias OrderType = PoqOrder<PoqOrderItem>
    typealias PlaceOrderResponseType = PoqPlaceOrderResponse<PoqOrderItem>

    /// TODO: Remove this, super class `PoqBaseViewController` already implements this generically
    override open var screenName: String {
        return "Native Bag Screen"
    }

    /// During apple pay payment we can't present anything, using modal.
    /// So this closure will be fired after PKPaymentAuthorizationViewController dismisses.
    /// It is used to update user with failed payment status or redirect user to order screen.
    var applePayCompletion: ApplePayCompletion?
    
    /// ViewModel responsible for network calls and data provided to this view controller.
    var applePayModelView: CheckoutApplePayBagViewModel?

    /// An dictionary of payment methods and related providers that are used in a specific app target.
    /// TODO: This should belong to view model.
    let paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider] = ParsePaymentProvidersMap()

    // MARK: - IBOutlets
    
    /// Presents the list of items added to bag.
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.allowsMultipleSelectionDuringEditing = false
            tableView.allowsSelectionDuringEditing = false

            // Hide empty cells
            tableView.tableFooterView = UIView(frame: CGRect.zero)

            tableView.registerPoqCells(cellClasses: [BagItemTableViewCell.self, NoItemsCell.self])

            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = CGFloat(AppSettings.sharedInstance.bagProductCellHeight)
        }
    }

    /// Displays number of bag items.
    /// TODO: Rename to something more understandable like ex: numberOfItemsLabel, countItemsLabel.
    @IBOutlet weak var itemsLabel: UILabel! {
        didSet {
            itemsLabel.font = AppTheme.sharedInstance.bagItemsCountLabelFont
            itemsLabel.text = ""
            itemsLabel.isAccessibilityElement = true
            itemsLabel.accessibilityIdentifier = CheckoutBagViewController.totalQuantityAccessibilityId
        }
    }

    /// Displays total price.
    /// TODO: Rename to ex: 'totalPriceLabel'
    @IBOutlet weak var totalLabel: UILabel! {
        didSet {
            totalLabel.attributedText = LabelStyleHelper.initGrandTotalLabel(singleItemCount)
            totalLabel.isAccessibilityElement = true
            totalLabel.accessibilityIdentifier = CheckoutBagViewController.totalCostAccessibilityId
        }
    }

    /// Displays checkout button in logged out state.
    /// On tap it opens Login screen.
    @IBOutlet weak var checkoutButton: CheckoutButton?

    /// Displays checkout button during logIn state.
    /// On tap it proceeds user to checkout summary screen.
    @IBOutlet weak var payWithCard: BlackButton? {
        didSet {
            payWithCard?.setTitle(AppLocalization.sharedInstance.checkoutPayWithCardText, for: .normal)
            payWithCard?.fontSize = CGFloat(AppSettings.sharedInstance.checkoutPayWithCardFontSize)
            payWithCard?.accessibilityIdentifier = AccessibilityLabels.checkoutButton
        }
    }
    
    /// Display voucher Code copy text.
    @IBOutlet weak var voucherCodeLabel: UILabel? {
        didSet {
            voucherCodeLabel?.font = AppTheme.sharedInstance.bagVoucherCodeFont
            voucherCodeLabel?.textColor = AppTheme.sharedInstance.bagVoucherCodeTextColor
        }
    }
    
    /// Displays voucher discount amount.
    @IBOutlet weak var voucherAmountLabel: UILabel! {
        didSet {
            voucherAmountLabel.font = AppTheme.sharedInstance.bagVoucherCodeFont
            voucherAmountLabel.textColor = AppTheme.sharedInstance.bagVoucherCodeTextColor
        }
    }
    
    /// UIView which displays an voucher panel.
    /// It has 2 states controlled:
    ///  - Apply voucher code state.
    ///  - Remove voucher code.
    @IBOutlet weak var voucherPanel: AddVoucherView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(CheckoutBagViewController.applyVoucherClicked(_:)))
            voucherPanel.addGestureRecognizer(gesture)
            voucherPanel.closeButton?.addTarget(self, action: #selector(applyVoucherClicked), for: .touchUpInside)
        }
    }
    
    /// Container that holds payButtons (Pay with card and Apple Pay).
    /// It's been displayed based on login state.
    @IBOutlet weak var payButtonsContainerView: UIView!

    /// VoucherPanel' height constraint use to show/hide voucherPanel.
    /// TODO: Remove this as we already use isHidden property of voucherPanel to hide it.
    @IBOutlet weak var applyVoucherHeight: NSLayoutConstraint!
    
    /// It is use to set voucherPanel height.
    /// TODO: Remove this const together with `applyVoucherHeight`.
    final let textfieldHeight: CGFloat = 44.0
    
    // MARK: - Subclass override
    
    /// Called by `init`, this is used to create this view controller's view model.
    /// - return: A `BagViewModel` use as this view controller's view model.
    override open func createBagViewModel () -> BagViewModel {
        return CheckoutBagViewModel(viewControllerDelegate: self)
    }

    // MARK: - UIViewController Delegates

    override open func viewDidLoad() {
        // Set base ui elements for extensions
        baseTableView = tableView
        baseItemsLabel = itemsLabel
        baseTotalLabel = totalLabel
        baseTotalLabel?.accessibilityIdentifier = AccessibilityLabels.checkoutBagTotalLabel

        baseCheckoutButton = checkoutButton

        // Log bag screen load
        PoqTrackerHelper.trackBagScreenLoaded(PoqTrackerEventType.NativeBagScreen)

        // Make sure any modal or push is shown above self
        // NavigationHelper.sharedInstance.topMostViewController = self

        updateApplePayElements()
        voucherPanel?.isHidden = isBagEmpty

        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.ReviewBag.step, option: CheckoutActionType.ReviewBag.option)

        super.viewDidLoad()
    }
    
    /// Calls super method to fetch bag data.
    /// Updates UI elements based on login state.
    open override func handleViewDidAppear() {
        super.handleViewDidAppear()

        updateViewsForLoggedInStatus(LoginHelper.isLoggedIn())
        updateApplePayElements()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Reset the top vc so the modals and navigation goes back to normal
        NavigationHelper.sharedInstance.clearTopMostViewController()
    }

    /// Updates UI elements based on login state.
    /// TODO: There is to many state changes, we need to refactor it by reducing nr of IBOutles in use, wrap them into one container.
    /// TODO: `payButtonsContainerView` already contains `payWithCard`. Remove `payWithCard?.isEnabled` state change lines.
    fileprivate func updateViewsForLoggedInStatus(_ loggedIn: Bool) {

        if loggedIn {
            // Hide secure checkout
            checkoutButton?.isHidden = true

            // Show voucher + pay buttons
            payButtonsContainerView?.isHidden = false

            voucherPanel?.isHidden = isBagEmpty
            applyVoucherHeight?.constant = textfieldHeight
            
            if let checkoutBagViewModel = viewModel as? CheckoutBagViewModel {
                payWithCard?.isEnabled = checkoutBagViewModel.isAllItemsInStockAndAvailable()
            }

        } else {

            // Show secure checkout
            checkoutButton?.isHidden = false

            // Show voucher + pay buttons
            payButtonsContainerView?.isHidden = true

            voucherPanel?.isHidden = true
            applyVoucherHeight?.constant = 0
        }
    }
    
    /// Updates Total price also changes state of voucherPanel, payWithCard views.
    override open func updateTotalAndReloadTable(_ tableView: UITableView?) {
        
        super.updateTotalAndReloadTable(tableView)
        
        guard let checkoutBagViewModel = viewModel as? CheckoutBagViewModel else {
            Log.error("Failed to downcast to CheckoutBagViewModel!")
            return
        }
        
        if LoginHelper.isLoggedIn() {
            
            if checkoutBagViewModel.getCheckoutSubtotal() == checkoutBagViewModel.getCheckoutTotal() {
                totalLabel?.attributedText = LabelStyleHelper.initGrandTotalLabel(checkoutBagViewModel.getCheckoutTotal())
            } else {
                totalLabel?.attributedText = LabelStyleHelper.initGrandTotalLabel(checkoutBagViewModel.getCheckoutSubtotal(), discountedTotal: checkoutBagViewModel.getCheckoutTotal())
            }
            
            if let voucherCode = checkoutBagViewModel.getVoucherCode(), let voucherAmount = checkoutBagViewModel.getVoucherAmount() {
                
                voucherCodeLabel?.text = voucherCode
                voucherAmountLabel?.text = voucherAmount
                voucherPanel?.showCloseButton(true)
                
            } else {
                voucherCodeLabel?.text = AppLocalization.sharedInstance.applyVoucherTextFieldPlaceholder
                voucherAmountLabel?.text = ""
                voucherPanel?.showCloseButton(false)
            }
            
            let count = CheckoutHelper.getNumberOfBagItems(viewModel.bagItems)
            let single = String(format: AppLocalization.sharedInstance.bagCountSingleText, count)
            let plural = String(format: AppLocalization.sharedInstance.bagCountMultipleText, count)
            let itemCountText: String = count == 1 ? single : plural
            
            itemsLabel?.text = count == 0 ? "" : itemCountText
            
            payWithCard?.setNeedsDisplay()
            
            voucherPanel?.isHidden = isBagEmpty
            
            tableView?.reloadData()
        }
        payWithCard?.isEnabled = checkoutBagViewModel.isAllItemsInStockAndAvailable()
    }
    
    /// Returns whether the view should include the ApplePay button or not; by default this returns false.
    /// Subclasses should override this and return true if they wish to show the ApplePay button.
    /// TODO: Rename this to a better name and turn it into a property.
    /// - result: Whether the view should include the ApplePay button.
    override open func shouldPresentApplePayButton() -> Bool {
        return CheckoutApplePayBagViewModel.isApplePayAvailableAndConfigured(paymentProvidersMap[.ApplePay] )
    }

    /// Checkout button has been clicked, Login screen is showed
    @IBAction func checkoutButtonClicked(_ sender: AnyObject) {

        if let checkoutViewModel = viewModel as? CheckoutBagViewModel {
            checkoutViewModel.loadLoginOptions()
        }
    }

    /// Return true if 0 items in bag
    /// TODO: decrease number of usage and overlaped code. Looks like we already have viewModel.hasBagItems
    fileprivate final var isBagEmpty: Bool {
        return  CheckoutHelper.getNumberOfBagItems(viewModel.bagItems) == 0
    }
    
    /// Action handler for the `applePayButton`.
    /// Review required data(item in bag, no out of stock items) before starting apple pay transaction, if there are some missing requirements, user is presented with error log.
    /// Start apple pay transaction if data has been validated.
    
    override open func applePayButtonAction(_ sender: UIButton) {
        guard let checkoutViewModel: CheckoutBagViewModel = viewModel as? CheckoutBagViewModel,
            let checkoutItem: PoqCheckoutItem = checkoutViewModel.checkoutItem, !isBagEmpty else {
                return
        }

        if !viewModel.hasBagItems() {
            let errorMessage = "BAG_NO_ITEMS".localizedPoqString
            showErrorAlert(errorMessage)

            return
        }

        let isEditing = baseTableView?.isEditing ?? false
        // Check we are not editing
        if isEditing {
            let errorMessage = "CANNOT_USE_APPLE_WHILE_EDIT".localizedPoqString
            showErrorAlert(errorMessage)
            return
        }

        if !checkoutViewModel.isAllItemsInStockAndAvailable() {
            let errorMessage = "CANNOT_USE_APPLE_UNAVAILABLE_ITEM".localizedPoqString
            showErrorAlert(errorMessage)
            return
        }

        guard let applePayPaymentProvider: PoqPaymentProvider = paymentProvidersMap[.ApplePay] else {
            showErrorAlert(nil)
            return
        }
        
        var coupon: String? = nil
        if let orderVouchers = checkoutItem.vouchers, orderVouchers.count > 0 {
            coupon = orderVouchers[0].voucherCode
        }
        
        PoqTrackerV2.shared.beginCheckout(voucher: coupon ?? "", currency: CurrencyProvider.shared.currency.code, value: checkoutItem.totalPrice ?? 0, method: CheckoutMethod.applePay.rawValue)

        applePayModelView = CheckoutApplePayBagViewModel(viewControllerDelegate: self, checkoutItem: checkoutItem, applePayPaymentProvider: applePayPaymentProvider)
        applePayModelView?.locationManager = viewModel?.locationManager
        applePayModelView?.startApplePayTransaction()
    }
}

// MARK: - UIGesture recognizers

extension CheckoutBagViewController {

    /// Action handler for the tap `voucherPanel`.
    /// This method displays `apply voucher` or `Remove voucher` modal based on voucherPanel displayed state.
    /// VoucherPanel state is returned by `voucherPanel.removeState()` method.
    @objc open func applyVoucherClicked(_ gesture: UIGestureRecognizer) {
        guard !isBagEmpty else {
            return
        }

        if let voucherPanelUnwrapped = voucherPanel {
            if voucherPanelUnwrapped.removeState() {
                showAlert()
            } else if let viewModelUnwrapped = viewModel as? CheckoutBagViewModel {
                viewModelUnwrapped.loadApplyVoucher()
            }
        }
    }
    
    /// This method is called on voucherPanel tap in Remove Voucher state.
    /// Method displays modaly an AlertViewController with Remove or Cancel action.
    /// TODO: Rename method to be more specific.
    fileprivate func showAlert() {

        let message = AppLocalization.sharedInstance.removeVoucherAlertMessage
        let cancelText = "CANCEL".localizedPoqString
        let removeText = "REMOVE".localizedPoqString

        let validAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

        self.alertController = validAlertController
        validAlertController.addAction(UIAlertAction(title: cancelText, style: .cancel))
        validAlertController.addAction(UIAlertAction(title: removeText, style: .default) { _ in

            if let checkoutViewModel = self.viewModel as? CheckoutBagViewModel {
                checkoutViewModel.deleteVoucher()
            }
        })

        self.present(validAlertController, animated: true)
    }
}

// MARK: - PAY WITH CARD BlackButtonDelegate Implementation
// ___________________________

extension CheckoutBagViewController: BlackButtonDelegate {

    /// Action handler used by `payWithCard` button.
    /// Opens a deeplink to CheckoutOrderSummaryViewController if bag is not empty.
    @IBAction public func blackButtonClicked(_ sender: Any?) {
        guard !isBagEmpty else {
            return
        }
        
        if let checkoutViewModel = viewModel as? CheckoutBagViewModel, let order = checkoutViewModel.checkoutItem {
            
            var coupon: String? = nil
            if let orderVouchers = order.vouchers, orderVouchers.count > 0 {
                coupon = orderVouchers[0].voucherCode
            }
            
            PoqTrackerV2.shared.beginCheckout(voucher: coupon ?? "", currency: CurrencyProvider.shared.currency.code, value: order.totalPrice ?? 0, method: CheckoutMethod.card.rawValue)
        }
        
        NavigationHelper.sharedInstance.openURL(NavigationHelper.sharedInstance.checkoutOrderSummaryURL)
    }
}

// MARK: - Apple Pay

extension CheckoutBagViewController: PKPaymentAuthorizationViewControllerDelegate {

    /// Apple Pays Delegate
    /// Sent when the user has selected a new payment card.
    /// This delegate provoides a callback in order to update the summary items in response to the card type changing (for example, applying credit card surcharges)
    /// Send checkout action analytics.
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {

        guard let viewModel = applePayModelView else {
            DispatchQueue.main.async {
                completion([])
            }

            return
        }

        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.PaymentOptions.step, option: CheckoutActionType.PaymentOptions.option)

        let paymentSummaryItems = viewModel.createPaymentSummaryItems()

        DispatchQueue.main.async {
            completion(paymentSummaryItems)
        }
    }
    
    /// Apple Pays Delegate.
    /// Sent when the user has selected a new shipping address.
    /// Due to an api restriction we populate shippingAddress, billingAddress with the new address shipping address and make a post request.
    /// Send checkout action analytics.
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {

        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.ShippingAddress.step, option: CheckoutActionType.ShippingAddress.option)
        
        // API restriction - we need send both addresses so populate with the same value
        let address = PoqAddress(contact: contact)
        let postAddress = PoqPostAddress()
        postAddress.shippingAddress = address
        postAddress.billingAddress = address

        postSelectedShippingAddress(postAddress, completion: completion)
    }
    
    /// Apple Pays Delegate.
    /// Sent when the user has selected a new shipping method.
    /// Make Post request with new delivery option, on request completion it makes a request to checkoutDetails in order to update checkout items.
    /// If checkout items are valid, they are added to apple pay callback with `.success` param.
    /// On invalid payment details an error message is sent with param `.invalidShippingPostalAddress`.
    /// Send checkout action analytics.
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {

        guard let viewModel = applePayModelView else {
            DispatchQueue.main.async {
                completion(.invalidShippingPostalAddress, [])
            }

            return
        }

        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.DeliveryOptions.step, option: CheckoutActionType.DeliveryOptions.option)

        let task = viewModel.postDeliveryOption(shippingMethod, requestChainKey: RequestsChain.shippingMethod.rawValue)

        task.continueWithTask { _ in
            viewModel.updateCheckoutItem(RequestsChain.shippingMethod.rawValue)
        }.continueWith { [weak self] (task: Task) in
            let checkoutItem = (task.result as? [CheckoutItemType])?.first
            viewModel.updateStateWithCheckoutItem(checkoutItem)

            let paymentSummaryItems = viewModel.createPaymentSummaryItems()

            if viewModel.checkoutItem.deliveryOption != nil {
                completion(.success, paymentSummaryItems)
            } else {
                self?.applePayCompletion = self?.createApplePayCompletion(withErrorMessage: AppLocalization.sharedInstance.checkoutError)
                completion(.invalidShippingPostalAddress, [])
            }
        }
    }
    
    /// Private method helper used in apple pay delegate `didSelectShippingContact` which does chain requests to update selected shipping address.
    /// Method params:
    /// `completion` - apple pay completition closure sent from apple pay delegate `didSelectShippingContact`.
    /// `postAddress` - new selected address.
    /// First request  posts provided new address `postAddress`.
    /// Request to update checkout details.
    /// Set updated checkout items  `completion`.
    fileprivate func postSelectedShippingAddress(_ postAddress: PoqPostAddress, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {

        guard let viewModel = applePayModelView else {
            DispatchQueue.main.async {
                completion(.invalidShippingPostalAddress, [], [])
            }

            return
        }

        postAddress.shippingAddress?.isApplePay = true

        // TODO: now our network tasks are operation, so we should chain them here, stop using bolts
        let task = viewModel.postDeliveryAddress(postAddress, requestChainKey: RequestsChain.shippingAddress.rawValue)

        task.continueWithTask { (task) -> Task<TaskResult> in
            let deliveryOptions = task.result as? [PoqDeliveryOption] ?? []
            viewModel.updateStateWithDeliveryOtions(deliveryOptions)

            if viewModel.deliveryOptions.isEmpty {
                return viewModel.errorTask()
            }

            return viewModel.postDeliveryOption(nil, requestChainKey: RequestsChain.shippingAddress.rawValue)
        }.continueWithTask { _ in
            viewModel.updateCheckoutItem(RequestsChain.shippingAddress.rawValue)
        }.continueWith { (task: Task) in
            let checkoutItem = (task.result as? [CheckoutItemType])?.first
            viewModel.updateStateWithCheckoutItem(checkoutItem)

            let paymentSummaryItems = viewModel.createPaymentSummaryItems()
            let shippingMethods = viewModel.createShippingMethod()
            let status: PKPaymentAuthorizationStatus = viewModel.checkoutItem.deliveryOption != nil ? .success : .invalidShippingPostalAddress

            completion(status, shippingMethods, paymentSummaryItems)
        }
    }

    /// Send checkout action analytics.
    /// This is final apple pay delegate which is fired after user authorizes by touch id or passcode.
    /// Makes a request `createApplePayToken` to obtain a payment token. If token is not received a error message is returned inside completition.
    /// Received valid token and payment of type `PKPayment` is posted to `placeOrderWithApplePayPayment`.
    /// The response from this post order request is anyalized for errors like:
    /// Misssing order `externalId`.
    /// StatusCode different then 200.
    /// Once response is considered valid apple completition is passed with `.success` param. Otherwise `.failure` is apssed to completition.
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {

        guard let applePayPaymentProvider: PoqPaymentProvider = paymentProvidersMap[.ApplePay] else {
            Log.error("No payment provider to handle Apple Pay token")
            completion(.failure)
            return
        }

        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.Payment.step, option: CheckoutActionType.Payment.option)

        applePayPaymentProvider.createApplePayToken(forPayment: payment) { [weak self] (token: String?, error: NSError?) in
            guard let viewModel = self?.applePayModelView, let validToken = token else {
                self?.applePayCompletion = self?.createApplePayCompletion(withErrorMessage: error?.localizedDescription)

                DispatchQueue.main.async {
                    completion(.failure)
                }

                return
            }

            let task = viewModel.placeOrderWithApplePayPayment(payment, applePayPaymentSourceToken: validToken, requestChainKey: RequestsChain.payment.rawValue)

            task.continueWith { (task: Task) in
                var externalId: String?
                var errorString: String?
                var order: OrderType?

                if let placeOrderResponse = task.result?.first as? PlaceOrderResponseType, let statusCode = placeOrderResponse.statusCode {
                    if let magentoMessage = placeOrderResponse.magentoMessage, statusCode == HTTPResponseCode.OK {
                        externalId = magentoMessage
                    }

                    order = placeOrderResponse.order

                    if let externalIdUnwrapped = externalId, externalIdUnwrapped.isNullOrEmpty() || externalId == nil {
                        errorString = placeOrderResponse.message ?? "TRY_AGAIN".localizedPoqString
                    }
                }

                if let externalId = externalId {
                    self?.applePayCompletion = { [applePayViewModel = viewModel] in
                        applePayViewModel.completeCheckout(externalId, order: order)
                    }

                    if let checkoutViewModel = self?.viewModel as? CheckoutBagViewModel {
                        checkoutViewModel.checkoutItem = nil
                        checkoutViewModel.bagItems = []
                    }

                    self?.updateTotalAndReloadTable(self?.tableView)

                    completion(.success)
                } else {
                    let errorMessage = errorString ?? task.error?.localizedDescription ?? "TRY_AGAIN".localizedPoqString
                    self?.applePayCompletion = self?.createApplePayCompletion(withErrorMessage: errorMessage)

                    completion(.failure)
                }
            }
        }
    }

    /// This is final apple pay delegate which is received once we complete payment succefully
    /// Any remaining request are canceled and apple pay view controller is dissmised.
    /// In dissmiss completition, apple pay closure and viewModel is set to nil and update checkout details request called to update the screen.
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {

        if let viewModel = applePayModelView {
            viewModel.cancelAllRequestChains()
        }
        
        dismiss(animated: true) { [weak self] in
            self?.applePayCompletion?()

            self?.applePayCompletion = nil
            self?.applePayModelView = nil

            if let checkoutViewModel = self?.viewModel as? CheckoutBagViewModel {
                checkoutViewModel.getBag(true)
            }
        }
    }
}

// MARK: - Error handling
extension CheckoutBagViewController {
    
    /// Error helper which handles apple pay and back end request error messages and presents an `UIAlertController` modal to the user.
    fileprivate final func showErrorAlert(_ message: String?) {
        let message = message ?? "TRY_AGAIN".localizedPoqString
        let cancel = "OK".localizedPoqString

        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: cancel, style: .cancel))

        self.alertController = alertController
        present(alertController, animated: true)
    }
    
    /// This method helper returns a closure that presents to user provided error message.
    /// Closure is returned because it is passed as a callback to apple pay delegates in case of any payment errors occurs during checkout.
    fileprivate final func createApplePayCompletion(withErrorMessage message: String?) -> ApplePayCompletion {
        return { [weak self] in
            self?.showErrorAlert(message)
        }
    }
}

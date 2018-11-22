//
//  CheckoutOrderSummaryViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 21/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import Stripe
import Braintree

/// We need separate steps in sections. FOr some flows section may have header
/// So kets use such presentation of section. for V1, just will ignore sections

open class CheckoutOrderSummaryViewModel<CFC: CheckoutFlowController>: BaseViewModel, OrderConfirmationPresenter {

    // MARK: - Type declarations
    public typealias OrderItemType = CFC.OrderItemType
    public typealias CheckoutItemType = CFC.CheckoutItemType
    public typealias CheckoutFlowViewController = CFC
    
    public typealias CheckoutCellSection = (header: String?, steps: [StepType])
    
    // TODO: with swift 4 put here `& TableCheckoutFlowStep`
    public typealias StepType = CheckoutFlowStep<CFC> /* & TableCheckoutFlowStep */
    
    /// For V2 we introduce headers, so UI should understand how configure cells
    public enum CheckoutSummaryItemType {
        case stepCell
        case headerCell
    }

    /// Combine all needed fields for all CheckoutSummaryItemType
    public struct ItemStruct<CFC: CheckoutFlowController> {
        public let type: CheckoutSummaryItemType
        public let step: CheckoutFlowStep<CFC>?
        public let cellIndex: Int?
        public let text: String?
        
        // Separator inset
        public let leftSeparatorIndent: CGFloat?
    }
    
    public typealias Item = ItemStruct<CheckoutFlowViewController>

    // MARK: - Ivars
    let rowHeight = CGFloat(60)
    var allBagItemsRowIndex: Int = 0
    
    public var checkoutItem: CheckoutItemType?
    var modalAnimator: ModalTransitionAnimator?
    
    /// CheckoutSteps - is a section of steps
    var checkoutSteps: [CheckoutCellSection]

    // FIXME: looks like must be private?
    public var _checkoutItems = [Item]()
    
    /// Ready-to-use array of items, allow directly get item for cell
    public var checkoutItems: [Item] {
        return _checkoutItems
    }

    // Just all steps, ignoring sections
    public var allCheckoutSteps: [CheckoutFlowStep<CheckoutFlowViewController>] {
        return checkoutSteps.flatMap({ return $0.steps })
    }
    
    public var paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider]
    
    /// Frustrating state variable to keep getCheckoutItems behaviour whilst not waiting for the order to go through.
    var isOrdering = false
    
    // MARK: - Init
    // ________________________
    
   public init(paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider], checkoutSteps: [CheckoutCellSection]) {
        self.paymentProvidersMap = paymentProvidersMap
        self.checkoutSteps = checkoutSteps
        super.init()
    }
    
    // MARK: - NETWORK
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskWillStart(networkTaskType)
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        if networkTaskType == PoqNetworkTaskType.getCheckoutDetails {
            
            if let existedCheckout = result?.first as? CheckoutItemType {

                checkoutItem = existedCheckout
                
                if checkoutSteps.count == 0 {
                    checkoutSteps = CheckoutOrderSummaryViewModel.createCheckoutSteps(paymentProvidersMap)
                }
                
                for step in allCheckoutSteps {
                    step.update(existedCheckout)
                }
                
                regenerateCheckoitItems()
            }
        } else if networkTaskType == PoqNetworkTaskType.postOrder {
            
            isOrdering = false
            
            if let placeOrderResponse = result?.first as? PoqPlaceOrderResponse<OrderItemType> {
                
                // TODO: check - may be this exists in bag BagHelper, andmay it should be there
                if isStatusCodeOK(placeOrderResponse.statusCode), let externalOrderId = placeOrderResponse.magentoMessage, !externalOrderId.isEmpty {

                    completeTransactionSuccess(externalOrderId, order: placeOrderResponse.order)
                    PoqTracker.sharedInstance.logAnalyticsEvent("Native Checkout - Success", action: "Paid by Card", label: externalOrderId, extraParams: nil)
                } else {
                    var errorMessage = "CHECKOUT_ERROR".localizedPoqString
                    // Log error mesage for checkout error
                    if let error = placeOrderResponse.message {
                        errorMessage = error
                    }
                    showErrorAlertWithMessage(errorMessage)
                    
                    PoqTrackerHelper.trackNativeCheckout(errorMessage)
                    PoqTrackerV2.shared.orderFailed(error: errorMessage)
                }
            } else {
                showErrorAlertWithMessage("CHECKOUT_ERROR".localizedPoqString )
            }
        }
        
        super.networkTaskDidComplete(networkTaskType, result: nil)
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
        // Need to do this after as we need to update the view controller before trying to do more async code.
        if networkTaskType == PoqNetworkTaskType.braintreeGenerateNonce {
            if let nonce = result?.first as? PoqBraintreeNonce {
                begin3DSecure(withNonce: nonce)
            }
        }
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        if networkTaskType == PoqNetworkTaskType.postOrder {
            isOrdering = false
            showErrorAlertWithMessage("CHECKOUT_ERROR".localizedPoqString)
        }
        
        super.networkTaskDidFail(networkTaskType, error: error)
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

    // MARK: - SUCCESSFUL TRANSCATION
    func completeTransactionSuccess(_ externalOrderId: String, order: PoqOrder<OrderItemType>?) {

        // Tracking order
        if let checkoutOrder = checkoutItem {
            
            // Update transactionId with externalOrderId
            // Otherwise Transcation is not going to be tracked via Google Analytics
            checkoutOrder.orderKey = externalOrderId
            
            // Convert order to tracking order
            let trackingOrder = PoqTrackingOrder(checkoutItem: checkoutOrder)
            
            // Send transaction to the providers (GA, Fb etc.)
            PoqTracker.sharedInstance.trackCompleteOrder(trackingOrder)
            PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.OrderCompleted.step, option: CheckoutActionType.OrderCompleted.option)
            
            PoqTrackerV2.shared.orderSuccessful(voucher: order?.voucherCode ?? "", currency: order?.currency ?? "", value: order?.totalPrice ?? 0, tax: order?.totalVAT ?? 0, delivery: order?.deliveryOption ?? "", orderId: order?.id ?? 0, userId: User.getUserId(), quantity: order?.totalQuantity ?? 0, rrp: order?.subtotalPrice ?? 0)
        }

        presentOrderConfirmation(viewControllerDelegate, externalOrderId: externalOrderId, checkoutItem: checkoutItem, order: order)
        
        Log.verbose("Looks like all is ok with place order!")
        // After we completed order, we reset it to 0
        BagHelper().saveOrderId(0)
    }
    
    func isStatusCodeOK(_ statusCode: Int?) -> Bool {
        
        if let code: Int = statusCode, code != HTTPResponseCode.OK {
            
            return false
        } else {
            
            return true
        }
    }
    
    func setPrice(_ priceValue: Double?, label: UILabel?) {
        
        guard let price = priceValue else {
            
            label?.text = 0.toPriceString()
            return
        }
        
        label?.text = price.toPriceString()
    }
    
    /**
     Place order. Order will be created from data in 'checkoutSteps'
     - returns: true if request was send to place order
    */
    public func placeOrder() -> Bool {
        guard let checkoutItem = checkoutItem else {
            showErrorAlertWithMessage("COMPLETE_ALL_REQURED_FIELDS".localizedPoqString)
            return false
        }
        
        // Validate that all steps have been completed.
        let steps = allCheckoutSteps
        for step in steps {
            switch step.status {
            case .completed:
                continue
                
            case .notCompleted(let message):
                showAlert(message)
                return false
            }
        }
        
        // Populate the checkout item with the input from all steps.
        for step in steps {
            step.populateCheckoutItem(checkoutItem)
        }
        
        // Additional validation for shipping address.
        guard checkoutItem.shippingAddress != nil, let paymentToken = checkoutItem.paymentOption?.paymentMethodToken else {
            showErrorAlertWithMessage("COMPLETE_ALL_REQURED_FIELDS".localizedPoqString)
            return false
        }
        
        // Since most likely billing will have 0 id, lets just nil both of address
        checkoutItem.billingAddress?.id = 0
        checkoutItem.shippingAddress?.id = 0
        
        let service = PoqNetworkService(networkTaskDelegate: self)
        if AppSettings.sharedInstance.enable3DSecure, let paymentOption = checkoutItem.paymentOption, paymentOption.paymentType == PoqPaymentProviderType.Braintree.rawValue, paymentOption.paymentMethod != PoqPaymentMethod.PayPal.rawValue {
            service.generateBraintreeNonce(paymentToken)
        } else if let paymentOption = checkoutItem.paymentOption, paymentOption.paymentMethod == PoqPaymentMethod.Klarna.rawValue && paymentOption.paymentType == PoqPaymentProviderType.Stripe.rawValue {
            // Work in progress web flow
        } else {
            let _: PoqNetworkTask<PoqNetworkService.PlaceOrderResponse<OrderItemType>> = service.postCheckoutOrder(checkoutItem)
        }
        
        return true
    }
    
    func showKlarnaWebValidation(token: String) {
        guard let validTopViewController = viewControllerDelegate else {
            return
        }
        NavigationHelper.sharedInstance.openKlarnaWeb(token: token, topViewController: validTopViewController)
    }
    
    func upateKlarnaPaymentSource() {
        // TODO: Add networkservice
    }
    
    func begin3DSecure(withNonce paymentNonce: PoqBraintreeNonce) {
        guard let nonce = paymentNonce.nonce, let braintreeClient = BraintreeHelper.sharedInstance.braintreeClient, let braintreePresenterDelegate = viewControllerDelegate as? BTViewControllerPresentingDelegate else {
            Log.error("Braintree client or 3d secure delegate not set, or 3D secure nonce is empty")
            return
        }
        
        let paymentFlowDriver = BTPaymentFlowDriver(apiClient: braintreeClient)
        paymentFlowDriver.viewControllerPresentingDelegate = braintreePresenterDelegate
        
        guard let orderTotal = checkoutItem?.totalPrice else {
            Log.error("Checkout item doesn't have total price")
            return
        }
        
        // Round the amount to 2 decimal places to avoid floating precision error.
        // By rounding to 2 decimal places we cannot send currencies such as Jordanian Dinar.
        let amount = NSDecimalNumber(decimal: Decimal(orderTotal))
        let roundingHandler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedAmount = amount.rounding(accordingToBehavior: roundingHandler)
        
        let request = BTThreeDSecureRequest()
        request.amount = roundedAmount
        request.nonce = nonce
        
        // Workaround to let view controller know to update state.
        let networkTaskType = PoqNetworkTaskType.braintreeHandle3DSecurePayment
        networkTaskWillStart(networkTaskType)
        
        paymentFlowDriver.startPaymentFlow(request) { [weak self] (result: BTPaymentFlowResult?, error: Error?) in
            guard let strongSelf = self else {
                Log.error("Braintree Payment Flow (3D Secure) has no reference to self.")
                return
            }
            
            guard let result = result as? BTThreeDSecureResult, let tokenizedCard = result.tokenizedCard else {
                if let errorDescription = error?.localizedDescription {
                    strongSelf.showErrorAlertWithMessage(errorDescription)
                }
                
                strongSelf.networkTaskDidFail(networkTaskType, error: error as NSError?)
                return
            }
            
            strongSelf.networkTaskDidComplete(networkTaskType, result: nil)
            strongSelf.checkoutItem?.paymentOption?.paymentVerificationNonce = tokenizedCard.nonce
            strongSelf.postCheckoutOrder()
        }
    }
    
    open class func createCheckoutSteps(_ paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider]) -> [CheckoutCellSection] {
        
        let section1Steps: [StepType] = [CheckoutOrderItemsStep<CheckoutFlowViewController>()]
        let section1 = CheckoutCellSection(header: AppLocalization.sharedInstance.checkoutOrderDetailHeaderTitle, steps: section1Steps)
        
        let deliveryStep = CheckoutAddressStep<CFC>(addressType: AddressType.Delivery)
        let paymentStep = CheckoutPaymentMethodStepWithBillingAddress<CheckoutFlowViewController>(paymentsConfiguration: paymentProvidersMap, deliveryAddressStep: deliveryStep)
        
        let section2Steps: [StepType] = [paymentStep,
                                         deliveryStep,
                                         CheckoutDeliveryStep<CheckoutFlowViewController>(),
                                         CheckoutVoucherStep<CheckoutFlowViewController>()]
        
        // I do here pure literal enumeration, since we don't set to first 3 or all, we do for specific steps
        for index in 0..<section2Steps.count {
            guard let tableBasedStep = section2Steps[index] as? TableCheckoutFlowStep else {
                assert(false, "All steps in second section Must be confirmed to table based chaeckout")
                continue
            }
            tableBasedStep.stepNumber = index + 1
        }
        
        let section2 = CheckoutCellSection(header: AppLocalization.sharedInstance.checkoutStepsHeaderTitle, steps: section2Steps)
        
        return [section1, section2]
    }
    
    // MARK: - Network Requests
    // ________________________
    
    public func getCheckoutItems(_ isRefresh: Bool = false) {
        guard !isOrdering else {
            return
        }
        
        let orderId = BagHelper().getOrderId()
        let service = PoqNetworkService(networkTaskDelegate: self)
        let _: PoqNetworkTask<JSONResponseParser<CheckoutItemType>> = service.getCheckoutDetails(orderId, isRefresh: isRefresh)
    }
    
    func postCheckoutOrder() {
        
        if let orderItem = checkoutItem {
            let service = PoqNetworkService(networkTaskDelegate: self)
            let _: PoqNetworkTask<PoqNetworkService.PlaceOrderResponse<OrderItemType>> = service.postCheckoutOrder(orderItem)
            
            isOrdering = true
        }

        PoqTrackerHelper.trackCheckoutPostOrder(checkoutItem)
    }
    
    /// Should be called when we need just reload cells, add/remove, without really update checkout item
    public func regenerateCheckoitItems() {
        // Recreate section items
        _checkoutItems = CheckoutOrderSummaryViewModel.createCheckoutItems(fromSections: checkoutSteps)
    }

    // MARK: - Error handling
    // ________________________
    
    public func showErrorAlertWithMessage(_ errorMessage: String) {
       
        let errorTitle: String = "ERROR".localizedPoqString
        showAlert(errorTitle, message: errorMessage)
    }
    
    public func showAlert(_ title: String, message: String? = nil) {
        
        let cancelTitle: String = "OK".localizedPoqString
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction.init(title: cancelTitle, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
        }))
        
        self.viewControllerDelegate?.present(alertController, animated: true, completion: { 
            // Completion handler once everything is dismissed
        })
    }

    // MARK: - CreateCardPaymentMethodDelegate
    // ________________________

    // TODO: move it to usual delegate approach

    func cardPaymentController(didAddedPaymentSource paymentSource: PoqPaymentSource) {
         reloadViewControllerTableView()
    }

    // MARK: - Private

    fileprivate final func reloadViewControllerTableView () {
        guard let viewController = viewControllerDelegate as? CheckoutOrderSummaryViewController<CheckoutItemType, OrderItemType> else {
            return
        }
        viewController.tableView?.reloadData()
    }
    
    public final class func createCheckoutItems(fromSections sections: [CheckoutCellSection]) -> [Item] {
        var res = [Item]()
        
        for i in 0..<sections.count {
            let section: CheckoutCellSection = sections[i]
            
            if let headetTitle = section.header {
                
                let header = Item(type: .headerCell, step: nil, cellIndex: nil, text: headetTitle, leftSeparatorIndent: 0)
                res.append(header)
            }
            
            for i in 0..<section.steps.count {
                
                let step = section.steps[i]
                
                guard let tableViewBasedStep = step as? TableCheckoutFlowStep else {
                    assert(false, "For proper work of this view controller ALL steps must be `TableCheckoutFlowStep`")
                    continue
                }
                
                let numberOfCells: Int = tableViewBasedStep.numberOfCellInOverviewSection()
                if numberOfCells > 0 {
                    for jIndex in 0..<numberOfCells {
                        
                        let isLastSectionCell: Bool = (i == (section.steps.count - 1)) && (jIndex == (numberOfCells - 1))
                        let leftSeparatorIndent: CGFloat? = isLastSectionCell ? 0 : nil
                        let stepItem = Item(type: .stepCell, step: step, cellIndex: jIndex, text: nil, leftSeparatorIndent: leftSeparatorIndent)
                        res.append(stepItem)
                    }
                }
            }
        }
        
        return res
    }
}

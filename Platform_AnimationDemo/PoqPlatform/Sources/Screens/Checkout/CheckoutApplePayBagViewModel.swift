//
//  CheckoutApplePayBagViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 07/03/2016.
//
//

import BoltsSwift
import CoreLocation
import ObjectMapper
import PassKit
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

public typealias TaskResult = Array<Mappable>

private let errorDomain: String = "CheckoutApplePayError"

/// Assume that this implementation of apple pay will works only on platform default objects
/// For proper usege, apple pay must be part of checkout, as payment option, not as separated 'Checkout Type'
public class CheckoutApplePayBagViewModel: BaseViewModel, OrderConfirmationPresenter {

    public typealias OrderItemType = PoqOrderItem
    public typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>
    public typealias OrderType = PoqOrder<OrderItemType>

    // CheckoutItem.deliveryOption != nil means we are ready to go
    public var checkoutItem: CheckoutItemType
    
    // First item must be equal to checkoutItem.deliveryOption, if last one exists
    public var deliveryOptions: [PoqDeliveryOption] = []
    
    /// Apple Pay payment provider
    public let paymentProvider: PoqPaymentProvider

    public var taskSources = [String: TaskCompletionSource<TaskResult>]()
    
    // We will use this location manager if app which need closest store will start using native checkout + Apple Pay
    public var locationManager: CLLocationManager?

    public init(viewControllerDelegate: PoqBaseViewController, checkoutItem: CheckoutItemType, applePayPaymentProvider: PoqPaymentProvider) {
        
        self.checkoutItem = checkoutItem
        self.paymentProvider = applePayPaymentProvider
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    deinit {
        cancelAllRequestChains()
    }
    
    public func startApplePayTransaction() {

        guard let checkoutBagViewController: CheckoutBagViewController = viewControllerDelegate as? CheckoutBagViewController, CheckoutApplePayBagViewModel.isApplePayAvailableAndConfigured(paymentProvider) else {
                
                presentApplePayUnavailableAlert()
                
                return
        }
        
        let paymentRequest: PKPaymentRequest = createPaymentRequest()
        
        // Final check, for price in total
        guard let lastItem: PKPaymentSummaryItem = paymentRequest.paymentSummaryItems.last, lastItem.amount.floatValue > 0 else {
            presentApplePayUnavailableAlert()
            
            return
        }
        
        let viewController: PKPaymentAuthorizationViewController? = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        
        guard let existedController: PKPaymentAuthorizationViewController = viewController else {
            
            presentApplePayUnavailableAlert()
            
            return
        }
        
        existedController.delegate = checkoutBagViewController
        checkoutBagViewController.present(existedController, animated: true) {
            
            PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.OrderSummary.step, option: CheckoutActionType.OrderSummary.option)
        }
    }
    
    // Create payment items based on self.checkoutItem
    public func createPaymentSummaryItems() -> [PKPaymentSummaryItem] {
        
        var paymentSummaryItems = [PKPaymentSummaryItem]()
        
        let bagItems: [PoqBagItem] = checkoutItem.bagItems 
        
        for bagItem in bagItems {
            
            let productTitle: String = bagItem.product?.title ?? ""
            
            let productTotal: Double = CheckoutHelper.getBagItemsTotal([bagItem])
            let productPrice = NSDecimalNumber(value: productTotal as Double)
            
            let paymentSummaryItem = PKPaymentSummaryItem(label: productTitle, amount: productPrice)
            
            paymentSummaryItems.append(paymentSummaryItem)
        }
        
        if let existedDeliveryOption: PoqDeliveryOption = checkoutItem.deliveryOption {
            let shippingMethod: PKShippingMethod = shippingMethodFromDeliveryOption(existedDeliveryOption)
            paymentSummaryItems.append(shippingMethod)
        }
        
        if let existedVouchers: PoqVoucher = checkoutItem.vouchers?.first {
            
            let voucherTitle: String = existedVouchers.voucherCode ?? ""
            
            let voucherTotal: Double = existedVouchers.value ?? 0
            let voucherPrice = NSDecimalNumber(value: voucherTotal as Double)
            
            let voucherSummaryItem = PKPaymentSummaryItem(label: voucherTitle, amount: voucherPrice)
            
            paymentSummaryItems.append(voucherSummaryItem)
        }
        
        let totalCost: Double = checkoutItem.totalPrice ?? 0
        
        let totalItem = PKPaymentSummaryItem(label: AppSettings.sharedInstance.displayMerchantName, amount: NSDecimalNumber(value: totalCost as Double))
        
        paymentSummaryItems.append(totalItem)

        return paymentSummaryItems
    }
    
    // Create shipping methods, based on deliveryOptions
    public func createShippingMethod() -> [PKShippingMethod] {
        
        guard let _: PoqDeliveryOption = checkoutItem.deliveryOption else {
            return []
        }

        var shippingMethods = [PKShippingMethod]()

        for deliveryOption: PoqDeliveryOption in deliveryOptions {
            let shippingMethod: PKShippingMethod = shippingMethodFromDeliveryOption(deliveryOption)
            shippingMethods.append(shippingMethod)
        }
        
        return shippingMethods
    }
    
    public func updateStateWithDeliveryOtions(_ possibleDeliveryOptions: [PoqDeliveryOption]) {
        
        var goodDeliveryOptions = [PoqDeliveryOption]()

        for deliveryOption in possibleDeliveryOptions {
            if let message = deliveryOption.message, !message.isNullOrEmpty() {
                // Bad option
                continue
            }
            
            goodDeliveryOptions.append(deliveryOption)
        }
        
        deliveryOptions = goodDeliveryOptions

        updateDeliverOptionsOrderAndCheckoutItem()
    }
    
    public func updateStateWithCheckoutItem(_ reponseCheckoutItem: CheckoutItemType?) {
        
        guard let existedResponseCheckoutItem: PoqCheckoutItem = reponseCheckoutItem else {
            checkoutItem.deliveryOption = nil
            return
        }
        
        checkoutItem = existedResponseCheckoutItem
        
        updateDeliverOptionsOrderAndCheckoutItem()
    }
    
    // Reorder delivery options or remove selected delivery option
    fileprivate func updateDeliverOptionsOrderAndCheckoutItem() {
        // Check that existed option exists in list
        if let selectedDeliveryOption: PoqDeliveryOption = checkoutItem.deliveryOption {
            
            let index: Int? = deliveryOptions.index(where: { (deliveryOption: PoqDeliveryOption) -> Bool in
                return deliveryOption.code == selectedDeliveryOption.code
            })
            
            if let existedIndex: Int = index {
                
                deliveryOptions.remove(at: existedIndex)
                deliveryOptions.insert(selectedDeliveryOption, at: 0)
                
            } else {
                checkoutItem.deliveryOption = nil
            }
        }
    }

    public func findExistedDeliveryOption(_ shippingMethod: PKShippingMethod) -> PoqDeliveryOption? {
        
        for deliverOption: PoqDeliveryOption in deliveryOptions {
            if deliverOption.code == shippingMethod.identifier {
                return deliverOption
            }
        }
        
        return nil
    }
    
    public func completeCheckout(_ externalOrderId: String, order: OrderType?) {

        presentOrderConfirmation(viewControllerDelegate, externalOrderId: externalOrderId, checkoutItem: checkoutItem, order: order)

        // Track order
        let completedOrder: OrderType = PoqOrder(checkoutItem: checkoutItem)

        if PermissionHelper.checkLocationAccess() == true {
            completedOrder.updateOderWithUserLocation(locationManager?.location)
        }
        completedOrder.orderKey = externalOrderId
        
        // Convert order to tracking order
        let trackingOrder = PoqTrackingOrder(order: completedOrder)
        trackingOrder.affiliation += " - APPLE PAY"
        
        // Send transaction to the providers (GA, Fb etc.)
        PoqTracker.sharedInstance.trackCompleteOrder(trackingOrder)
        
        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.OrderCompleted.step, option: CheckoutActionType.OrderCompleted.option)
        
        PoqTrackerV2.shared.orderSuccessful(voucher: order?.voucherCode ?? "", currency: order?.currency ?? "", value: order?.totalPrice ?? 0, tax: order?.totalVAT ?? 0, delivery: order?.deliveryOption ?? "", orderId: order?.id ?? 0, userId: User.getUserId(), quantity: order?.totalQuantity ?? 0, rrp: order?.subtotalPrice ?? 0)
        
        BagHelper().saveOrderId(0)
        let emptyBagItems = Array<CheckoutItemType.BagItemType>()
        BadgeHelper.setNumberOfBagItems(emptyBagItems)
    }
}

public extension CheckoutApplePayBagViewModel {
    /// Parse AppSettings.applePayAvailablePaymentNetworks and create array of valid constants
    public static var availablePKPaymentNetworks: [PKPaymentNetwork] {
        let strings: [String] = AppSettings.sharedInstance.applePayAvailablePaymentNetworks.components(separatedBy: ",")
        
        var res = [PKPaymentNetwork]()
        for rawValue: String in strings {
            guard let paymentNetwork = PoqCardNetwork(rawValue: rawValue) else {
                Log.error("Can't parse one of values in \(strings)(AppSettings.applePayAvailablePaymentNetworks), specifically this one: \(rawValue)")
                continue
            }
            
            res.append(paymentNetwork.pkPaymentNetwork)
        }
        
        return res
    }
    
    /// One place to check Apple Pay availability. Also check that we have sutable payment provider for it, which also configured
    public static func isApplePayAvailableAndConfigured(_ applePayPaymentProvider: PoqPaymentProvider?) -> Bool {
        
        let canUseApplePay = PKPaymentAuthorizationViewController.canMakePayments()
        
        let paymentNetworks = CheckoutApplePayBagViewModel.availablePKPaymentNetworks
        let canUseApplePayWithNetworks = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
        
        let hasMerchantId = AppSettings.sharedInstance.applePayMerchantId.isNullOrEmpty() == false
        
        let applePayProviderExists: Bool = applePayPaymentProvider != nil
        
        return canUseApplePay && canUseApplePayWithNetworks && hasMerchantId && applePayProviderExists
    }
}

// MARK: - Operation based request

public extension CheckoutApplePayBagViewModel {

    public func postDeliveryAddress(_ postAddress: PoqPostAddress, requestChainKey: String) -> Task<TaskResult> {

        let orderid: Int = BagHelper().getOrderId() ?? 0
        let orderIdString: String = "\(orderid)"

        let taskSource = TaskCompletionSource<TaskResult>()
        taskSources[requestChainKey] = taskSource

        PoqNetworkService(networkTaskDelegate: taskSource).postCheckoutAddress(orderIdString, postAddress: postAddress)

        return taskSource.task
    }

    public func postDeliveryOption(_ shippingMethod: PKShippingMethod?, requestChainKey: String) -> Task<TaskResult> {

        // 1. If we have selected shipping method - post it
        // 2. If we can, try to save current selected option
        // 3. We need selection in any case, so try first one
        var deliveryOption: PoqDeliveryOption?
        if let existedShippingMethod: PKShippingMethod = shippingMethod {
            deliveryOption = findExistedDeliveryOption(existedShippingMethod)
        } else {
            
            if let existedSelectedDeliveryOption: PoqDeliveryOption = checkoutItem.deliveryOption {
                let index: Int? = deliveryOptions.index(where: { (deliveryOption: PoqDeliveryOption) -> Bool in
                    return deliveryOption.code == existedSelectedDeliveryOption.code
                })
                
                if let _: Int = index {
                    deliveryOption = checkoutItem.deliveryOption
                }
            }
            
            if deliveryOption == nil {
                deliveryOption = deliveryOptions.first
            }
        }

        guard let postDeliveryOption: PoqDeliveryOption = deliveryOption else {
            return errorTask()
        }

        let taskSource = TaskCompletionSource<TaskResult>()
        taskSources[requestChainKey] = taskSource

        postDeliveryOption.orderId = BagHelper().getOrderId()
        PoqNetworkService(networkTaskDelegate: taskSource).postDeliveryOption(postDeliveryOption)

        return taskSource.task
    }
    
    public func updateCheckoutItem(_ requestChainKey: String) -> Task<TaskResult> {
        
        let taskSource = TaskCompletionSource<TaskResult>()
        taskSources[requestChainKey] = taskSource

        let service = PoqNetworkService(networkTaskDelegate: taskSource)
        let _: PoqNetworkTask<JSONResponseParser<CheckoutItemType>> = service.getCheckoutDetails(BagHelper().getOrderId(), isRefresh: true)

        return taskSource.task
    }
    
    /// Create task with request inside, which post order with information from payment
    public func placeOrderWithApplePayPayment(_ payment: PKPayment, applePayPaymentSourceToken: String, requestChainKey: String) -> Task<TaskResult> {
        
        guard let _: PoqDeliveryOption = checkoutItem.deliveryOption else {
            Log.error("can't place order - checkoutItem.deliveryOption is nil")
            return self.errorTask()
        }

        var canPlaceOrder: Bool = true

        if let billingContact = payment.billingContact {
            checkoutItem.billingAddress = PoqAddress(contact: billingContact)
        } else {
            canPlaceOrder = false
            Log.error("payment.billingContact is nil")
        }
        
        if let shippingContact = payment.shippingContact {
            checkoutItem.shippingAddress = PoqAddress(contact: shippingContact)
        } else {
            canPlaceOrder = false
            Log.error("payment.shippingContact is nil")
        }
        
        let paymentOption = PoqPaymentOption()
        paymentOption.paymentMethodToken = applePayPaymentSourceToken
        paymentOption.paymentType = paymentProvider.paymentProviderType.rawValue
        checkoutItem.paymentOption = paymentOption
        
        // We need check that we have all what we need
        guard canPlaceOrder else {
            Log.error("can't place order")
            return self.errorTask()
        }
        
        let taskSource = TaskCompletionSource<TaskResult>()
        taskSources[requestChainKey] = taskSource
        
        let service = PoqNetworkService(networkTaskDelegate: taskSource)
        let _: PoqNetworkTask<PoqNetworkService.PlaceOrderResponse<OrderItemType>> = service.postCheckoutOrder(checkoutItem)
        return taskSource.task
    }
    
    public func errorTask() -> Task<TaskResult> {
        let error = NSError(domain: errorDomain, code: -1, userInfo: nil)
        
        return Task<TaskResult>(error: error)
    }
    
    public func cancelAllRequestChains() {
        
        for (_, taskSource): (String, TaskCompletionSource<TaskResult>) in taskSources {
            taskSource.tryCancel()
        }

        taskSources.removeAll()
    }
}

// MARK: - Private
public extension CheckoutApplePayBagViewModel {
    
    fileprivate func presentApplePayUnavailableAlert() {
        
        if let existedControllerDelegate: PoqBaseViewController = viewControllerDelegate {
            let errorMessage: String = "APPLE_PAY_UNAVAILABLE_ERROR".localizedPoqString
            presentErrorAlertConstroller(existedControllerDelegate, messages: errorMessage)
        }
    }
    
    fileprivate func createPaymentRequest() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.supportedNetworks = CheckoutApplePayBagViewModel.availablePKPaymentNetworks
        request.countryCode = AppSettings.sharedInstance.storeISOCountryCode
        request.currencyCode = CurrencyProvider.shared.currency.code
        request.merchantIdentifier = AppSettings.sharedInstance.applePayMerchantId
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        
        request.requiredBillingAddressFields = PKAddressField.all
        request.requiredShippingAddressFields = PKAddressField.all
        
        // We start apple pay process - so we reset selected info
        deliveryOptions = []
        
        request.paymentSummaryItems = createPaymentSummaryItems()
        
        return request
    }
    
    fileprivate func shippingMethodFromDeliveryOption(_ deliveryOption: PoqDeliveryOption) -> PKShippingMethod {
        
        let optionsTitle: String = deliveryOption.title ?? ""
        
        let optionPrice: Double = deliveryOption.price ?? 0
        let optionPriceNumber = NSDecimalNumber(value: optionPrice as Double)
        
        let shippingMethod = PKShippingMethod(label: optionsTitle, amount: optionPriceNumber)
        
        shippingMethod.identifier =  deliveryOption.code ?? ""
        shippingMethod.detail =  deliveryOption.message ?? ""
        
        return shippingMethod
    }

    // MARK: - Error handling
    // If messages is nil - default message will be resented. localized "TRY_AGAIN"
    fileprivate func presentErrorAlertConstroller(_ presenter: UIViewController, messages: String?) {
        
        let errorMessage: String = messages ?? "TRY_AGAIN".localizedPoqString
        
			let okText = "OK".localizedPoqString
        
        let validAlertController = UIAlertController.init(title: errorMessage, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        validAlertController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: { (alertaction: UIAlertAction) in
            
        }))
        
        self.viewControllerDelegate?.present(validAlertController, animated: true, completion: {
            // Completion handler once everything is dismissed
        })
    }
}

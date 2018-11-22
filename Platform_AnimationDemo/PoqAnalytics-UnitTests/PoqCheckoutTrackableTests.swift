//
//  PoqCheckoutTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Rachel McGreevy on 1/23/18.
//

import XCTest
import PoqNetworking
@testable import PoqAnalytics
@testable import PoqPlatform

class PoqCheckoutTrackableTests: EventTrackingTestCase {
    
    func testBeginCheckoutTracking() {
        
        PoqTrackerV2.shared.beginCheckout(voucher: "12345", currency: "USD", value: 49.99, method: "web")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCheckoutUrlChangeTracking() {
        
        PoqTrackerV2.shared.checkoutUrlChange(url: "www.poqcommerce.com/testcheckout")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCheckoutAddressTracking() {
        
        PoqTrackerV2.shared.checkoutAddress(type: "billing", userId: "12345")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCheckoutPaymentTracking() {
        
        PoqTrackerV2.shared.checkoutPayment(type: "card", userId: "paypal")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testOrderFailedTracking() {
        
        PoqTrackerV2.shared.orderFailed(error: "braintree error")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testOrderSuccessfulTracking() {
        
        PoqTrackerV2.shared.orderSuccessful(voucher: "34567", currency: "USD", value: 49.99, tax: 7.81, delivery: "delivery", orderId: 23456, userId: "12345", quantity: 2, rrp: 54.98)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Tests to confirm custom provider recieves calls from code
    
    func testBeginCheckoutEventTracked() {
        
        let bagViewController = BagViewController(nibName: "BagView", bundle: nil)
        bagViewController.handleCheckoutButtonClicked()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCheckoutUrlChangeEventTracked() {
        
        let cartTransferController = CartTransferViewController(nibName: "CartTransferView", bundle: nil)
        
        guard let url = URL(string: "www.testUrlChange.com") else {
            XCTFail("Checkout change url test returned empty URL")
            return
        }
        
        _ = cartTransferController.webView(UIWebView(), shouldStartLoadWith: URLRequest(url: url), navigationType: .linkClicked)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCheckoutAddressEventTracked() {
        
        let checkoutViewModel = CheckoutSelectAddressViewModel(viewControllerDelegate: PoqBaseViewController(), existedBillinAddress: PoqAddress())
        checkoutViewModel.addressType = AddressType.Billing
        checkoutViewModel.postAddress(PoqAddress())
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// Can't test checkoutpayment event tracking at the moment
    /// The saveButtonAction() function in CreateCardPaymentMethodViewController
    /// Will never pass it's guard statment checking the provider is valid
    
    func testOrderFailedEventTracked() {
        
        typealias ViewControllerType = CheckoutOrderSummaryViewController<PoqCheckoutItem<PoqBagItem>, PoqOrderItem>
        typealias ViewModel = CheckoutOrderSummaryViewModel<ViewControllerType>
        
        let paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider] = [.Card: StripeHelper()]
        
        let checkoutOrderSummaryViewModel = ViewModel(paymentProvidersMap: paymentProvidersMap, checkoutSteps: ViewModel.createCheckoutSteps(paymentProvidersMap))
        
        typealias ResultType = PoqPlaceOrderResponse<PoqOrderItem>
        checkoutOrderSummaryViewModel.networkTaskDidComplete(PoqNetworkTaskType.postOrder, result: [ResultType()])
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testOrderSuccessfulEventTracked() {
        
        let order = PoqOrder<PoqOrderItem>()
        order.isTrackingSent = false
        order.totalPrice = 14.99
        
        let cartTransferController = CartTransferViewController(nibName: "CartTransferView", bundle: nil)
        cartTransferController.order = order
        cartTransferController.sendOrderCompleteTransaction()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

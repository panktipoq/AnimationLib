//
//  NativeCheckoutSummaryTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Nikolay Dzhulay on 10/12/17.
//

import Foundation
import EarlGrey
import Locksmith

@testable import PoqNetworking
@testable import PoqPlatform

class NativeCheckoutSummaryTests: EGTestCase {
    
    let paymentProvider = PaymentProviderMock()
    
    // MARK: MockProvider 
    
    override var resourcesBundleName: String {
        return "NativeCheckoutTests"
    }
    
    override func setUp() {
        super.setUp()

        BagHelper().saveOrderId(33636875)
    }
    
    func insertCheckoutSummary() {

        typealias ViewControllerType = CheckoutOrderSummaryViewController<PoqCheckoutItem<PoqBagItem>, PoqOrderItem>
        typealias ViewModel = CheckoutOrderSummaryViewModel<ViewControllerType>

        let paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider] = [.Card: paymentProvider]

        let viewModel = ViewModel(paymentProvidersMap: paymentProvidersMap, checkoutSteps: ViewModel.createCheckoutSteps(paymentProvidersMap))
        let viewController = ViewControllerType(viewModel: viewModel)
        insertNavigationController(withViewController: viewController)
    }
    
    /// Check screen after we got response from API with 2 items in bag and have no saved payment info
    func testEmptyState() {
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.Empty")
        paymentProvider.customer = nil
        insertCheckoutSummary()
        
        let backButtonMatcher = GREYMatchers.matcher(forAccessibilityID: AccessibilityLabels.backButton)
        EarlGrey.selectElement(with: backButtonMatcher).assert(grey_nil())
        
        let payButtonMatcher = GREYMatchers.matcher(forText: "Pay £118.00")
        EarlGrey.selectElement(with: payButtonMatcher).assert(grey_notNil())
        
        // one by one check every cell in table view
        let productCellsMatcher = GREYMatchers.matcher(forAccessibilityID: AccessibilityLabels.checkoutProductCell)
        EarlGrey.selectElement(with: productCellsMatcher).atIndex(1).assert(grey_notNil())
        // unfortunatelly can check that only 2 matches, and not 3
        
        let swipeUp = GREYActions.actionForSwipeFast(in: .up)
        EarlGrey.selectElement(with: GREYMatchers.matcherForKeyWindow()).perform(swipeUp)
        
        let emptyPaymentMethodMatcher = GREYMatchers.matcher(forText: "Select Payment Method")
        EarlGrey.selectElement(with: emptyPaymentMethodMatcher).assert(grey_notNil())
        
        let emptyDeliveryAddressMatcher = GREYMatchers.matcher(forText: "Select Delivery Address")
        EarlGrey.selectElement(with: emptyDeliveryAddressMatcher).assert(grey_notNil())
        
        let emptyDeliveryOptionMatcher = GREYMatchers.matcher(forText: "Select Delivery Options")
        EarlGrey.selectElement(with: emptyDeliveryOptionMatcher).assert(grey_notNil())
    }
    
    /// See empty payment source
    /// Go to empty list -> auto navigation to create card source
    /// Add card
    /// See that info populate summary
    /// See added card in payment iptions list
    func testPaymentsList() {
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.Empty")
        MockServer.shared["checkout/addresses/*/*"] = response(forJson: "AddressesList")
        MockServer.shared["checkout/SaveAddressToOrder/*/*/*"] = response(forJson: "SaveAddressToOrder.NoReturnId")
        
        paymentProvider.customer = nil

        insertCheckoutSummary()

        let emptyPaymentMethodMatcher = GREYMatchers.matcher(forText: "Select Payment Method")
        EarlGrey.selectElement(with: emptyPaymentMethodMatcher).perform(GREYActions.actionForTap())
        
        // at this moment we should be on - add card payment step 
        let cardTextFieldMatcher = GREYMatchers.matcher(forAccessibilityID: StripeCardDetailTextFieldAccessibilityIdentifier)
        let cardNumberTypeAction = GREYActions.action(forTypeText: "4111111111111111")
        let expireDateTypeAction = GREYActions.action(forTypeText: "1235")
        let cvvTypeAction = GREYActions.action(forTypeText: "123")
        EarlGrey.selectElement(with: cardTextFieldMatcher).perform(cardNumberTypeAction).perform(expireDateTypeAction).perform(cvvTypeAction)
        
        let addressTextMatcher = GREYMatchers.matcher(forText: "Billing address")
        EarlGrey.selectElement(with: addressTextMatcher).perform(GREYActions.actionForTap())
        
        let officeAddressMatcher = GREYMatchers.matcher(forText: "POQ, 21 Garden Walk\nLondon, EC2A 3EQ\nUnited Kingdom")
        EarlGrey.selectElement(with: officeAddressMatcher).atIndex(0).perform(GREYActions.actionForTap())
        
        let saveButtonMatcher = GREYMatchers.matcher(forText: "Save")
        EarlGrey.selectElement(with: saveButtonMatcher).perform(GREYActions.actionForTap())

        let cardInfoMatcher = GREYMatchers.matcher(forText: "VISA **** 1111 | Ec2A 3Eq")
        EarlGrey.selectElement(with: cardInfoMatcher).perform(GREYActions.actionForTap())

        // Check that list have "add card" and added card
        
        EarlGrey.selectElement(with: cardInfoMatcher).assert(grey_notNil())

        let addCardTextMatcher = GREYMatchers.matcher(forText: "Add new card")
        EarlGrey.selectElement(with: addCardTextMatcher).assert(grey_notNil())

        let cardsHeaderMatcher = GREYMatchers.matcher(forText: "Add new card")
        EarlGrey.selectElement(with: cardsHeaderMatcher).assert(grey_notNil())

    }
    
    /// Start from screen with seleced payment option and empty delivery address and and delivery option
    /// Select delivery address cell
    /// Select address
    /// Check that address was selected
    func testDeliveryAddressSelection() {
        
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.Empty")
        MockServer.shared["checkout/addresses/*/*"] = response(forJson: "AddressesList")
        MockServer.shared["checkout/SaveAddressToOrder/*/*/*"] = response(forJson: "SaveAddressToOrder.NoReturnId")
        
        paymentProvider.customer = PaymentCustomerMock()
        
        insertCheckoutSummary()

        // check initial state of screen
        let cardInfoMatcher = GREYMatchers.matcher(forText: "VISA **** 1111 | Ec2A 3Eq")
        EarlGrey.selectElement(with: cardInfoMatcher).assert(grey_notNil())
        
        // select address
        let emptyDeliveryAddressMatcher = GREYMatchers.matcher(forText: "Select Delivery Address")
        EarlGrey.selectElement(with: emptyDeliveryAddressMatcher).perform(grey_tap())
        
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.ShippingAddress")
        let officeAddressMatcher = GREYMatchers.matcher(forText: "POQ, 21 Garden Walk\nLondon, EC2A 3EQ\nUnited Kingdom")
        EarlGrey.selectElement(with: officeAddressMatcher).atIndex(0).perform(GREYActions.actionForTap())
        
        // check that with new response we got new data in cell
        let swipeUp = GREYActions.actionForSwipeFast(in: .up)
        EarlGrey.selectElement(with: GREYMatchers.matcherForKeyWindow()).perform(swipeUp)
        let addressText = "POQ, 21 Garden Walk\nLondon, EC2A 3EQ, United Kingdom\n07500000000"
        let summaryAddressMatcher = GREYMatchers.matcher(forText: addressText)
        EarlGrey.selectElement(with: summaryAddressMatcher).atIndex(0).assert(grey_notNil())

    }
    
    /// Try select delivery options while delivery address  was not selected
    /// Alert should be presented to user
    func testDeliveryOptionSelectionWithoutDeliveryAddress() {
        
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.Empty")
        MockServer.shared["checkout/addresses/*/*"] = response(forJson: "AddressesList")
        MockServer.shared["checkout/SaveAddressToOrder/*/*/*"] = response(forJson: "SaveAddressToOrder.NoReturnId")
        
        paymentProvider.customer = PaymentCustomerMock()
        
        insertCheckoutSummary()
        
        let swipeUp = GREYActions.actionForSwipeFast(in: .up)
        EarlGrey.selectElement(with: GREYMatchers.matcherForKeyWindow()).perform(swipeUp)

        let emptyDeliveryOptionMatcher = GREYMatchers.matcher(forText: "Select Delivery Options")
        EarlGrey.selectElement(with: emptyDeliveryOptionMatcher).perform(grey_tap())
        
        let alertTextMatcher = GREYMatchers.matcher(forText: "Please select delivery address")
        EarlGrey.selectElement(with: alertTextMatcher).assert(grey_notNil())
        
        let alertOkButtonMatcher = GREYMatchers.matcher(forText: "OK")
        EarlGrey.selectElement(with: alertOkButtonMatcher).perform(grey_tap())

    }
    
    /// On summary we have delivery address
    /// tap on delivery options cell
    /// Select delivery option
    /// Check that checjout fully populated
    func testDeliveryOptionSelection() {
        
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.ShippingAddress")
        MockServer.shared["checkout/addresses/*/*"] = response(forJson: "AddressesList")
        MockServer.shared["checkout/SaveAddressToOrder/*/*/*"] = response(forJson: "SaveAddressToOrder.NoReturnId")
        MockServer.shared["checkout/PostAddresses/*/*/*"] = response(forJson: "DeliveryOptions")
        MockServer.shared["checkout/postdeliveryoption/*/*"] = response(forJson: "PostDeliveryOptionResponse")
        
        paymentProvider.customer = PaymentCustomerMock()
        
        insertCheckoutSummary()
        
        let swipeUp = GREYActions.actionForSwipeFast(in: .up)
        EarlGrey.selectElement(with: GREYMatchers.matcherForKeyWindow()).perform(swipeUp)
        
        let emptyDeliveryOptionMatcher = GREYMatchers.matcher(forText: "Select Delivery Options")
        EarlGrey.selectElement(with: emptyDeliveryOptionMatcher).perform(grey_tap())
        
        // select delivery option
        MockServer.shared["checkout/details/*/*/*"] = response(forJson: "CheckoutDetail.Full")
        let saverOptionMatcher = GREYMatchers.matcher(forText: "Saver")
        EarlGrey.selectElement(with: saverOptionMatcher).perform(grey_tap())
        
        /// Should be on summary screen
        EarlGrey.selectElement(with: GREYMatchers.matcherForKeyWindow()).perform(swipeUp)
        let cardInfoMatcher = GREYMatchers.matcher(forText: "VISA **** 1111 | Ec2A 3Eq")
        EarlGrey.selectElement(with: cardInfoMatcher).assert(grey_notNil())
        EarlGrey.selectElement(with: saverOptionMatcher).assert(grey_notNil())
    }

}

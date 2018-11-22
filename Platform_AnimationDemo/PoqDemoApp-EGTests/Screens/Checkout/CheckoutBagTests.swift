//
//  CheckoutBagTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Rachel McGreevy on 20/12/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class CheckoutBagTests: EGTestCase {

    var checkoutItem: PoqCheckoutItem<PoqBagItem>?

    override func setUp() {
        super.setUp()

        MockServer.shared["/checkout/details/*/*/*"] = response(forJson: "CheckoutBagItemWithNoVoucherApplied")
    }

    override func tearDown() {
        super.tearDown()
    }

    func insertCheckoutBagViewController(with productJsonFile: String) {

        let checkoutBagViewController = CheckoutBagViewController(nibName: "CheckoutBagView", bundle: nil)

        checkoutItem = responseObject(forJson: productJsonFile, ofType: PoqCheckoutItem.self)

        insertNavigationController(withViewController: checkoutBagViewController)
    }

    func setUpLoggedInStatus() {
        let account = PoqAccount()
        account.firstName = "Tester"
        account.lastName = "Testerson"
        account.email = "test@testemail.com"
        account.encryptedPassword = "password123"

        LoginHelper.updateAccountDetails(account)
    }

    func testTotalPriceWithoutVoucher() {
        setUpLoggedInStatus()
        insertCheckoutBagViewController(with: "CheckoutBagItemWithNoVoucherApplied")
        EarlGrey.elementExists(with: grey_accessibilityID(AccessibilityLabels.checkoutBagTotalLabel))
        let labelText = "Total: \(String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, checkoutItem!.totalPrice!))"
        EarlGrey.elementExists(with: grey_text(labelText))
    }

    func testTotalPriceWithVoucher() {
        MockServer.shared["/checkout/details/*/*/*"] = response(forJson: "CheckoutBagItemWithVoucherApplied")
        setUpLoggedInStatus()
        insertCheckoutBagViewController(with: "CheckoutBagItemWithVoucherApplied")
        EarlGrey.elementExists(with: grey_accessibilityID(AccessibilityLabels.checkoutBagTotalLabel))
        let labelText = "Total: \(String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, checkoutItem!.subTotalPrice!)) \(String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, checkoutItem!.totalPrice!))"
        EarlGrey.elementExists(with: grey_text(labelText))
    }

}

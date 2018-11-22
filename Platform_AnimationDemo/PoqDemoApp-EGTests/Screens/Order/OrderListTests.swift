//
//  OrderListTests.swift
//  PoqDemoApp-EGTests
//
//  Created by GabrielMassana on 26/10/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class OrderListTests: EGTestCase {

    // MARK: - Accessors
    
    public typealias OrderItemType = PoqOrder<PoqOrderItem>
    var firstOrder: OrderItemType?

    // MARK: - TestSuiteLifecycle

    override func setUp() {
        
        super.setUp()

        firstOrder = responseObjects(forJson: "Orders", ofType: OrderItemType.self)?.first
        MockServer.shared["/orders/*/*"] = response(forJson: "Orders")
    }
    
    func insertOrdersList() {
        let orderListViewController = OrderListViewController(nibName: "OrderListViewController", bundle: nil)
        insertNavigationController(withViewController: orderListViewController)
    }
    
    // MARK: - Response

    func test_navigationBarTitle() {
        insertOrdersList()
        EarlGrey.selectElement(with: grey_accessibilityLabel("Your order history"))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem() {
        insertOrdersList()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem_tap() {
        insertOrdersList()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .perform(grey_tap())
            .assert(with: grey_enabled())
    }
    
    func test_fisrtOrder_externalOrderId() {
        insertOrdersList()
        let order = firstOrder?.externalOrderId
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_fisrtOrder_totalPriceString() {
        insertOrdersList()
        let order = firstOrder?.totalPriceString
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_fisrtOrder_orderStatus() {
        insertOrdersList()
        let order = firstOrder?.orderStatus
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_fisrtOrder_orderDate() {
        insertOrdersList()
        let order = firstOrder?.orderDate
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_fisrtOrder_() {
        insertOrdersList()
        let order = firstOrder?.externalOrderId
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_tableView_exists() {
        insertOrdersList()
        EarlGrey.elementExists(with: grey_kindOfClass(UITableView.self))
    }
    
    func test_tableView_UIRefreshControl_exists() {
        insertOrdersList()
        EarlGrey.elementExists(with: grey_kindOfClass(UIRefreshControl.self))
    }
    
    func test_tableView_errorStatusCode200_noAlertView() {
        insertOrdersList()
        let index = responseObjects(forJson: "Orders", ofType: OrderItemType.self)!.count - 1

        EarlGrey.selectElement(with: grey_kindOfClass(UITableViewCell.self)).atIndex(UInt(index)).assert(with: grey_notNil())
    }
    
    // MARK: - ResponseEmpty

    func test_emptyTableView_exists() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersEmpty")
        insertOrdersList()
        EarlGrey.elementExists(with: grey_kindOfClass(UITableView.self))
    }
   
    func test_emptyTableView_message() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersEmpty")
        insertOrdersList()
        EarlGrey.elementExists(with: grey_text("Order history empty"))
    }
    
    // MARK: - ResponseError

    func test_errorTableView_exists() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersError")
        insertOrdersList()
        EarlGrey.elementExists(with: grey_kindOfClass(UITableView.self))
    }
    
    func test_errorTableView_errorMessage() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersError")
        let firstOrderError = responseObjects(forJson: "OrdersError", ofType: OrderItemType.self)?.first
        
        insertOrdersList()
        let order = firstOrderError?.message
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_errorTableView_okButton() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersError")
        let okText = "OK".localizedPoqString

        insertOrdersList()
        EarlGrey.elementExists(with: grey_text(okText))
    }
    
    func test_errorTableView_SignInButton() {
        MockServer.shared["/orders/*/*"] = response(forJson: "OrdersError")
        let logoutText = "SIGN_IN".localizedPoqString
        
        insertOrdersList()
        EarlGrey.elementExists(with: grey_text(logoutText))
    }
}

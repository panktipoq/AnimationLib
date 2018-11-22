//
//  OrderDetailTests.swift
//  PoqDemoApp
//
//  Created by GabrielMassana on 17/11/2017.
//

import EarlGrey

@testable import PoqNetworking
@testable import PoqPlatform

class OrderDetailTests: EGTestCase {
    
    // MARK: - Accessors
    
    public typealias OrderItemType = PoqOrder<PoqOrderItem>
    var firstOrder: OrderItemType?
    var order: OrderItemType?
    
    var priceString: String?
    var productTitle: String?
    var externalID: String?
    var totalPriceString: String?
    var deliveryCostString: String?
    var dwOrderStatus: String?
    var dwOrderDate: String?
    var dwPaymentMethod: String?
    var dwDeliveryOption: String?
    var dwGiftMessage: String?

    override var resourcesBundleName: String {
        return "OrderListTests"
    }
    
    // MARK: - TestSuiteLifecycle
    
    override func setUp() {
        super.setUp()
        
        firstOrder = responseObjects(forJson: "Orders", ofType: OrderItemType.self)?.first
        MockServer.shared["/order/*/*"] = response(forJson: "Order")
        
        priceString = "£16.67"
        productTitle = "Luscious Lemon Yellow Mesh Stripe Midi Skirt"
        externalID = "56306"
        totalPriceString = "£32.50"
        deliveryCostString = "£2.08"
        dwOrderStatus = "Order Recieved"
        dwOrderDate = "Order Date: 21 November 2017"
        dwPaymentMethod = "Native App Payment"
        dwDeliveryOption = "Shipping - Saver"
        dwGiftMessage = "A present to you my love"
    }
    
    func insertOrdersDetail() {
        
        let orderListViewController = OrderDetailViewController(nibName:"OrderDetailViewController", bundle:nil)
        let orderKey = firstOrder?.orderKey
        orderListViewController.orderKey = orderKey
        
        insertNavigationController(withViewController: orderListViewController)
    }
    
    // MARK: - Response
    
    func test_leftBarButtonItem() {
        insertOrdersDetail()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .assertAnyExist()
    }
    
    func test_leftBarButtonItem_tap() {
        insertOrdersDetail()
        EarlGrey.selectElement(with: grey_kindOfClass(BackButton.self))
            .perform(grey_tap())
            .assert(with: grey_enabled())
    }
    
    func test_orderDetail_priceString() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(priceString!))
    }
    
    func test_orderDetail_productTitle() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(productTitle!))
    }
    
    func test_orderDetail_externalID() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(externalID!))
    }
    
    func test_orderDetail_totalPriceString() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(totalPriceString!))
    }
    
    func test_orderDetail_deliveryCostString() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(deliveryCostString!))
    }
    
    func test_orderDetail_dwOrderStatus() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(dwOrderStatus!))
    }
    
    func test_orderDetail_dwOrderDate() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(dwOrderDate!))
    }
    
    func test_orderDetail_dwPaymentMethod() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(dwPaymentMethod!))
    }
    
    func test_orderDetail_dwDeliveryOption() {
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(dwDeliveryOption!))
    }
    
    func test_orderDetail_dwGiftMessage() {
        insertOrdersDetail()
        let message = String(format:"\"%@\"", dwGiftMessage!)
        EarlGrey.elementExists(with: grey_text(message))
    }
    
    // MARK: - ResponseError

    func test_errorTableView_exists() {
        MockServer.shared["/order/*/*"] = response(forJson: "OrderError")
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_kindOfClass(UITableView.self))
    }
    
    func test_errorTableView_errorMessage() {
        MockServer.shared["/order/*/*"] = response(forJson: "OrderError")
        let firstOrderError = responseObjects(forJson: "OrdersError", ofType: OrderItemType.self)?.first
        
        insertOrdersDetail()
        let order = firstOrderError?.message
        EarlGrey.elementExists(with: grey_text(order!))
    }
    
    func test_errorTableView_okButton() {
        MockServer.shared["/order/*/*"] = response(forJson: "OrderError")
        let okText = "OK".localizedPoqString
        
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(okText))
    }
    
    func test_errorTableView_SignInButton() {
        MockServer.shared["/order/*/*"] = response(forJson: "OrderError")
        let logoutText = "SIGN_IN".localizedPoqString
        
        insertOrdersDetail()
        EarlGrey.elementExists(with: grey_text(logoutText))
    }
}

//
//  CartViewTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Balaji Reddy on 14/07/2018.
//

import EarlGrey

@testable import PoqCart
@testable import PoqDemoApp

class CartViewTests: EGTestCase {
    
    let testCartItemId1 = "61669731"
    let testCartItemId2 = "61669741"
    
    let checkoutPanelViewMatcher = GREYMatchers.matcher(forAccessibilityID: CheckoutPanelView.accessibilityId)
    let cancelButtonMatcher = GREYMatchers.matcher(forAccessibilityID: CartViewController.cartCancelEditButtonAccessibilityId)
    let editButtonMatcher = GREYMatchers.matcher(forAccessibilityID: CartViewController.cartEditButtonAccessiblityId)
    let cartContentTableMatcher = GREYMatchers.matcher(forAccessibilityID: CartView.cartContentTableAccessibilityId)
    lazy var bagItemMatcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.accessibilityIdentifierPrefix + testCartItemId1)
    lazy var bagItem2Matcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.accessibilityIdentifierPrefix + testCartItemId2)
    lazy var productInfoViewMatcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.productInfoViewAccessibilityIdentifierPrefix + testCartItemId1)

    lazy var priceLabelMatcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.priceLabelAccessibilityIdentifierPrefix + testCartItemId1)
    
    lazy var stockMessageLabelMatcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.stockMessageLabelAccessibilityIdentifierPrefix + testCartItemId1)

    lazy var quantityViewMatcher = GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.quantityInfoViewAccessibilityIdentifierPrefix + testCartItemId1)
    
    func assertButtonInEnabledState(_ enabledState: Bool) -> GREYAssertionBlock {
        
       return GREYAssertionBlock(name: "Button Is Enabled Assertion") { (element, errorOrNil) in
            
            guard let button = element as? UIButton else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a UIButton")
                return false
            }
            
            return button.isEnabled == enabledState
        }
    }
    
    func assertCartInEditMode(_ editMode: Bool) -> GREYAssertionBlock {
       
        return GREYAssertionBlock(name: "TableView in Edit mode assertion") { (element, errorOrNil) in
        
            guard let cartContentTableView = element as? UITableView else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a UITableView")
                return false
            }
            
            return cartContentTableView.isEditing == editMode
        }
    }
    
    func assertCartItemCell(id: String, isVisible: Bool) -> GREYAssertionBlock {
        
        return GREYAssertionBlock(name: "CartItemCell Visibility Assertion", assertionBlockWithError: { (element, errorOrNil) in
            
            guard let cartContentTableView = element as? UITableView else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a UITableView")
                return false
            }
            
            let deletedCartItemCellIsVisible =  cartContentTableView.visibleCells.contains(where: { $0.accessibilityIdentifier == CartItemTableViewCell.accessibilityIdentifierPrefix + id })
            
            return isVisible ? deletedCartItemCellIsVisible : !deletedCartItemCellIsVisible
        })
    }
    
    func quantityEditButtonMatcher(for cartItemId: String, increase: Bool) -> GREYElementMatcherBlock {
      
        return GREYElementMatcherBlock(matchesBlock: { element in
            
            guard let button = element as? UIButton else {
               
                return false
            }
            
            guard button.superview?.accessibilityIdentifier == CartItemTableViewCell.quantityInfoViewAccessibilityIdentifierPrefix + cartItemId else {
               
                return false
            }
            
            return button.accessibilityIdentifier == (increase ? QuantityView.increaseButtonAccessibilityId : QuantityView.decreaseButtonAccessibilityId)
            
        }, descriptionBlock: { _ in })
    }
    
    func quantityAssertion(_ quantity: String) -> GREYAssertionBlock {
        
        return GREYAssertionBlock(name: "Quantity Field Assertion" ) { (element, errorOrNil) in
            
            guard let quantityView = element as? QuantityView else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a QuantityView")
                
                return false
            }
            
            return quantityView.quantityTextField?.text == quantity
        }
    }
    
    func quantityViewAssertion(quantityString: String) -> GREYAssertionBlock {
        
        return GREYAssertionBlock(name: "QuantityView quantity label") { (element, errorOrNil) in
        
            guard let quantityView = element as? QuantityView else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a QuantityView")
                return false
            }
            
            return quantityView.quantityLabel?.text == quantityString
        }
    }
    
    func insertCartViewController() {
        
        insertNavigationController(withViewController: CartBuilder().withService(MockCartDataService(testDataJsonFileName: "CartItems")).build())
    }
    
    func testCheckoutPanel() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: checkoutPanelViewMatcher).assertIsVisible()
        
        let numberOfItemsLabelMatcher = GREYMatchers.matcher(forAccessibilityID: CheckoutPanelView.numOfItemsLabelAccessibilityId)
        EarlGrey.selectElement(with: numberOfItemsLabelMatcher).assertIsVisible()
        EarlGrey.selectElement(with: numberOfItemsLabelMatcher).assertText(matches: "2 Items")
        
        let totalPriceLabelMatcher = GREYMatchers.matcher(forAccessibilityID: CheckoutPanelView.totalPriceLabelAccessibilityId)
        EarlGrey.selectElement(with: totalPriceLabelMatcher).assertIsVisible()
        EarlGrey.selectElement(with: totalPriceLabelMatcher).assertText(matches: "Total: $270.00")
    }
    
    fileprivate func greyInteractionError(_ errorOrNil: UnsafeMutablePointer<NSError?>?, description: String) {
      
        if errorOrNil != nil {
            
            let errorInfo = [NSLocalizedDescriptionKey: NSLocalizedString(description, comment: "")]
            errorOrNil?.pointee = NSError(domain: kGREYInteractionErrorDomain, code: 2, userInfo: errorInfo)
        }
    }
    
    /// Test if CartItemView displays the right title information, price and quantity
    func testCartItem() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: bagItemMatcher).assertIsVisible()
        
        // Assert Product Info
        EarlGrey.selectElement(with: productInfoViewMatcher).assertIsVisible()
        
        let productInfoAssertion = GREYAssertionBlock(name: "ProductInfoView has product title, brand and size assertion") { (element, errorOrNil) in
            
            guard let productInfoView = element as? ProductInfoView else {
                
                self.greyInteractionError(errorOrNil, description: "Element is not a ProductInfoView")
                
                return false
            }
            
            let titleLabelAssert = productInfoView.titleLabel.text == "Tori Tank"
            let brandLabelAssert = productInfoView.brandLabel?.text == "Gucci"
            let sizeLabelAssert = productInfoView.sizeLabel?.text == "XL"
            let colorLabelAssert = productInfoView.colorLabel?.text == "Blue"
            
            return titleLabelAssert && brandLabelAssert && sizeLabelAssert && colorLabelAssert
        }
        
        EarlGrey.selectElement(with: productInfoViewMatcher).assert(productInfoAssertion)

        EarlGrey.selectElement(with: priceLabelMatcher).assertText(matches: "$60.00")
        
        EarlGrey.selectElement(with: quantityViewMatcher).assert(quantityViewAssertion(quantityString: "1 X $60.00"))
        
        EarlGrey.selectElement(with: stockMessageLabelMatcher).assertText(matches: "Currently out of stock")
    }
    
    func swipeToDeleteItem(cartItemId: String) {
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.accessibilityIdentifierPrefix + cartItemId)).swipeFastLeft()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Delete")).assertIsVisible()
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Delete")).tap()
    }
    
    /// Assert If CartItemCell is not visible after swipe-to-delete
    func testSwipeToDeleteCartItem() {
        
        insertCartViewController()
        
        swipeToDeleteItem(cartItemId: testCartItemId1)
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CartView.cartContentTableAccessibilityId)).assert(assertCartItemCell(id: testCartItemId1, isVisible: false))
    }
    
    /// Assert If CartItemCell is not visible after MoveToWishlist is tapped
    func testMoveToWishlist() {
        
        let cartViewController = CartBuilder().withService(MockCartDataService(testDataJsonFileName: "CartItems")).build(shouldShowMoveToWishlistAction: true)
        
        insertNavigationController(withViewController: cartViewController)
        
        EarlGrey.selectElement(with: bagItemMatcher).swipeFastLeft()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Move To Wishlist")).assertIsVisible()
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Move To Wishlist")).tap()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CartView.cartContentTableAccessibilityId)).assert(assertCartItemCell(id: testCartItemId1, isVisible: false))
    }
    
    /// Edit button should move the cart content table to edit mode
    func testEditButton() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: editButtonMatcher).assertIsVisible()
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartInEditMode(false))
        
        EarlGrey.selectElement(with: editButtonMatcher).tap()
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartInEditMode(true))
    }
    
    /// Assert if quantity increases and decreases as quantity increase/decrease button are tapped
    func testQuantityEdit() {
        
        insertCartViewController()

        EarlGrey.selectElement(with: editButtonMatcher).tap()

        EarlGrey.selectElement(with: quantityEditButtonMatcher(for: testCartItemId1, increase: true)).assertIsVisible()
        
        let increaseButtonMatcher = quantityEditButtonMatcher(for: testCartItemId1, increase: true)
        let decreaseButtonMatcher = quantityEditButtonMatcher(for: testCartItemId1, increase: false)
        
        EarlGrey.selectElement(with: quantityViewMatcher).assert(quantityAssertion("1"))
        
        EarlGrey.selectElement(with: increaseButtonMatcher).assertIsVisible()
        EarlGrey.selectElement(with: increaseButtonMatcher).tap()
        
        EarlGrey.selectElement(with: quantityViewMatcher).assert(quantityAssertion("2"))
        
        EarlGrey.selectElement(with: decreaseButtonMatcher).assertIsVisible()
        EarlGrey.selectElement(with: decreaseButtonMatcher).tap()
        
        EarlGrey.selectElement(with: quantityViewMatcher).assert(quantityAssertion("1"))
        
        EarlGrey.selectElement(with: decreaseButtonMatcher).assert(assertButtonInEnabledState(false))
    }
    
    /// Cancel button should only be visible in edit mode
    func testCancelButtonAppearsOnlyInEditMode() {

        insertCartViewController()
        
        // Assert that cancel button does not exist when not in edit mode
        EarlGrey.elementDoesNotExist(with: cancelButtonMatcher)
    
        EarlGrey.selectElement(with: editButtonMatcher).tap()
        
        EarlGrey.selectElement(with: cancelButtonMatcher).assertIsVisible()
    }
    
    /// Cancel button should only be enabled after an edit and tapping cancel should cancel the edits and toggle edit mode
    func testCancelButtonCancelsEditMode() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: editButtonMatcher).tap()
        
        EarlGrey.selectElement(with: cancelButtonMatcher).assert(assertButtonInEnabledState(false))
        
        EarlGrey.selectElement(with: quantityEditButtonMatcher(for: testCartItemId1, increase: true)).tap()
        
        EarlGrey.selectElement(with: cancelButtonMatcher).assert(assertButtonInEnabledState(true))
        
        EarlGrey.selectElement(with: cancelButtonMatcher).tap()

        EarlGrey.elementDoesNotExist(with: cancelButtonMatcher)
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartInEditMode(false))
    }
    
    func testEmptyCartScreenIsShownWhenCartEmpty() {
        
        insertCartViewController()
        
        swipeToDeleteItem(cartItemId: testCartItemId1)
        
        swipeToDeleteItem(cartItemId: testCartItemId2)
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.accessibilityID)).assertIsVisible()
        
        EarlGrey.selectElement(with: editButtonMatcher).assert(assertButtonInEnabledState(false))
    }
    
    func testEmptyCartScreenNotShownWhenCartNotEmpty() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.accessibilityID)).assert(grey_notVisible())
    }
    
    func testPullToRefresh() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        let cartItemIdAddedOnRefresh = "cbf66765-ee7d-41f9-abc4-8de3e8323e5d"
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartItemCell(id: cartItemIdAddedOnRefresh, isVisible: false))
        
        mockDataService.testDataJsonFileName = "ActionableMessageCellTests"
        
        EarlGrey.selectElement(with: cartContentTableMatcher).perform(GREYActions.actionForSwipeFast(in: GREYDirection.down))

        EarlGrey.selectElement(with: GREYMatchers.matcherForKind(of: UIRefreshControl.self)).assertAnyExist()
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartItemCell(id: cartItemIdAddedOnRefresh, isVisible: true))
    }
    
    func testPullToRefreshOnEmptyCartView() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "EmptyCart")
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.elementDoesNotExist(with: bagItemMatcher)
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.accessibilityID)).assertIsVisible()
        
        mockDataService.testDataJsonFileName = "CartItems"
        
        EarlGrey.selectElement(with: cartContentTableMatcher).perform(GREYActions.actionForSwipeFast(in: GREYDirection.down))
        
        EarlGrey.selectElement(with: GREYMatchers.matcherForKind(of: UIRefreshControl.self)).assertAnyExist()
     
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartItemCell(id: testCartItemId1, isVisible: true))
    }
    
    func testErrorView() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        mockDataService.dispatchErrors = true
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "OK")).tap()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.accessibilityID)).assertIsVisible()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.messageLabelAccessibilityID)).assertIsVisible()
        
        EarlGrey.selectElement(with: checkoutPanelViewMatcher).assert(grey_notVisible())
    }
    
    func testPullToRefreshOnErrorView() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        mockDataService.dispatchErrors = true
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "OK")).tap()
        
        mockDataService.dispatchErrors = false
        
        EarlGrey.selectElement(with: cartContentTableMatcher).perform(GREYActions.actionForSwipeFast(in: GREYDirection.down))
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartItemCell(id: testCartItemId1, isVisible: true))
    }
    
    func testErrorViewRetry() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        mockDataService.dispatchErrors = true
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "OK")).tap()
        
        mockDataService.dispatchErrors = false
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Retry")).tap()
        
        EarlGrey.selectElement(with: cartContentTableMatcher).assert(assertCartItemCell(id: testCartItemId1, isVisible: true))
    }
    
    func testErrorInEditMode() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: editButtonMatcher).tap()
        
        EarlGrey.selectElement(with: quantityEditButtonMatcher(for: testCartItemId1, increase: true)).tap()
        
        mockDataService.dispatchErrors = true
        
        EarlGrey.selectElement(with: editButtonMatcher).tap()
        
        mockDataService.dispatchErrors = false
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Retry")).tap()

        EarlGrey.selectElement(with: quantityViewMatcher).assert(quantityViewAssertion(quantityString: "2 X $60.00"))
    }
    
    func testOutOfStockAlert() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CheckoutPanelView.checkoutButtonAccessibilityId)).tap()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Items Out Of Stock")).assertIsVisible()
    }
    
    func testWishlistActionAdded() {
 
        let cartViewController = CartBuilder().withService(MockCartDataService(testDataJsonFileName: "CartItems")).build(shouldShowMoveToWishlistAction: true)
     
        insertNavigationController(withViewController: cartViewController)
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.accessibilityIdentifierPrefix + testCartItemId1)).swipeFastLeft()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Move To Wishlist")).assertIsVisible()
    }
    
    func testWishlistActionNotAddedByDefault() {
        
        insertCartViewController()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: CartItemTableViewCell.accessibilityIdentifierPrefix + testCartItemId1)).swipeFastLeft()
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forText: "Move To Wishlist")).assert(grey_notVisible())
    }
    
    func test404NoContent() {
        
        let mockDataService = MockCartDataService(testDataJsonFileName: "CartItems")
        mockDataService.dispatchErrors = true
        mockDataService.errorToDispatch = NetworkError.urlError(code: 404, description: "No Content")
        
        insertNavigationController(withViewController: CartBuilder().withService(mockDataService).build())
        
        EarlGrey.selectElement(with: GREYMatchers.matcher(forAccessibilityID: EmptyCartView.accessibilityID)).assertIsVisible()
    }
}

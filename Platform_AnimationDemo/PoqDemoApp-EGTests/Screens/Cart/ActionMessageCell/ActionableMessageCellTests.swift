//
//  ActionableMessageCellTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Balaji Reddy on 15/07/2018.
//

import EarlGrey

@testable import PoqCart
@testable import PoqDemoApp

class ActionableMessageCellTests: EGTestCase {
    
    public static let promotionBannerTestString = "Free Shipping on all orders above £4.20!"
    public static let testAlertAccessibilityId = "ActionableMessageCellTestAlert"
    
    func insertCartViewController(isMessageCellActionable: Bool = false) {
        
        insertNavigationController(withViewController: CartBuilder().withService(MockCartDataService(testDataJsonFileName: "ActionableMessageCellTests")).withViewDataMapper(MockCartViewDataMapper()).withCellBuilder(MockCartTableViewCellBuilder(isMessageCellActionable: isMessageCellActionable)).build())
    }
    
    func testActionableMessageCellExists() {
        
        insertCartViewController()
        
        let actionableCellMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageTableViewCell.accessibilityIdTag + String(ActionableMessageCellTests.promotionBannerTestString.hashValue))
        EarlGrey.selectElement(with: actionableCellMatcher).assertIsVisible()
    }
    
    func testMessageLabel() {
        
        insertCartViewController()
        
        let messageLabelMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageTableViewCell.messageLabelAccessibilityIdTag + String(ActionableMessageCellTests.promotionBannerTestString.hashValue))
        EarlGrey.selectElement(with: messageLabelMatcher).assertIsVisible()
        EarlGrey.selectElement(with: messageLabelMatcher).assertText(matches: ActionableMessageCellTests.promotionBannerTestString)
    }

    func testActionIndicator() {
        
        insertCartViewController(isMessageCellActionable: true)
        
        let actionIndicatorMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageTableViewCell.actionIndicatorAccessibilityTag + String(ActionableMessageCellTests.promotionBannerTestString.hashValue))
        EarlGrey.selectElement(with: actionIndicatorMatcher).assertIsVisible()
    }
    
    func testAction() {
        
        insertCartViewController(isMessageCellActionable: true)
        
        let actionableCellMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageTableViewCell.accessibilityIdTag + String(ActionableMessageCellTests.promotionBannerTestString.hashValue))
        EarlGrey.selectElement(with: actionableCellMatcher).tap()

        let alertMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageCellTests.testAlertAccessibilityId)
        EarlGrey.selectElement(with: alertMatcher).assertIsVisible()
        
        let testAlertMatcher = GREYMatchers.matcher(forText: "Test Alert")
        
        EarlGrey.selectElement(with: testAlertMatcher).assertIsVisible()
    }
    
    func testActionNotTriggeredForMessageOnlyCell() {
        
        insertCartViewController(isMessageCellActionable: false)
        
        let actionableCellMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageTableViewCell.accessibilityIdTag + String(ActionableMessageCellTests.promotionBannerTestString.hashValue))
        EarlGrey.selectElement(with: actionableCellMatcher).tap()
        
        wait(forDuration: 0.3)

        let alertMatcher = GREYMatchers.matcher(forAccessibilityID: ActionableMessageCellTests.testAlertAccessibilityId)
        EarlGrey.selectElement(with: alertMatcher).assert(grey_nil())
    }
}

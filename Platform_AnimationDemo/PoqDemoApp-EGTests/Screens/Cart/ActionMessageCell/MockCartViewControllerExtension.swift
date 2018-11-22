//
//  MockCartViewControllerExtension.swift
//  PoqDemoApp-EGTests
//
//  Created by Balaji Reddy on 17/07/2018.
//

import UIKit

@testable import PoqCart

extension CartViewController: ActionableMessagePresenter {
    
    public func performActionForCell(with message: String) {
        
        if message == ActionableMessageCellTests.promotionBannerTestString {
            
            let alertController = UIAlertController(title: "Test Alert", message: "This is a test alert!", preferredStyle: .alert)
            alertController.view.accessibilityIdentifier = ActionableMessageCellTests.testAlertAccessibilityId
            present(alertController, animated: true)
        }
    }
}

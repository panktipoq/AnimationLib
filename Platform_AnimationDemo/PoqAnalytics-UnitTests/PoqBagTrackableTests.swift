//
//  PoqBagTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Rachel McGreevy on 1/18/18.
//

import XCTest
import PoqPlatform
import PoqNetworking
@testable import PoqAnalytics

class PoqBagTrackableTests: EventTrackingTestCase {
    
    func testRemoveFromBagTracking() {
        
        PoqTrackerV2.shared.removeFromBag(productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testBagUpdateTracking() {
        
        PoqTrackerV2.shared.bagUpdate(totalQuantity: 3, totalValue: 29.99)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testRemoveFromWishlistTracking() {
        
        PoqTrackerV2.shared.removeFromWishlist(productId: 12345)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testClearWishlistTracking() {
        
        PoqTrackerV2.shared.clearWishlist()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testApplyVoucherTracking() {
        
        PoqTrackerV2.shared.applyVoucher(voucher: "50OFF")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testApplyStudentDiscountTracking() {
        
        PoqTrackerV2.shared.applyStudentDiscount(voucher: "12345")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Tests to confirm custom provider recieves calls from code
    
    func testRemoveFromBagEventTracked() {
        MockServer.shared["/BagItems/Update/*/*"] = response(forJson: "RemoveFromBag")
        
        let mockBagItem = PoqBagItem()
        mockBagItem.isExternal = true
        
        let mockBagItem2 = PoqBagItem()
        mockBagItem2.isExternal = true
        
        let bagViewController = PoqBaseBagViewController(nibName: nil, bundle: nil)
        bagViewController.viewModel.bagItems = [mockBagItem, mockBagItem2]
        bagViewController.removeBagItem(mockBagItem)
 
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testClearBagEventTracked() {
        MockServer.shared["/BagItems/Update/*/*"] = response(forJson: "RemoveFromBag")
        
        // Removed event and clear bag event...
        provider?.expectation?.expectedFulfillmentCount = 2
        
        let mockBagItem = PoqBagItem()
        mockBagItem.isExternal = true
        
        let bagViewController = PoqBaseBagViewController(nibName: nil, bundle: nil)
        bagViewController.viewModel.bagItems = [mockBagItem]
        bagViewController.removeBagItem(mockBagItem)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testBagUpdateEventTracked() {
        
        let bagViewModel = BagViewModel()
        bagViewModel.updateBag(for: .normal, bagTableView: nil, editButton: nil, checkoutButton: nil, confirmEditing: true)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testApplyCouponEventTracked() {
        MockServer.shared["/checkout/applyvoucher/*/*"] = response(forJson: "ApplyVoucher")

        let voucherViewController = ApplyVoucherViewController(nibName: nil, bundle: nil)
        voucherViewController.orderId = 12345
        voucherViewController.voucherCodeTextField = FloatLabelTextFieldWithState()
        voucherViewController.voucherCodeTextField.text = "50OFF"
        voucherViewController.blackButtonClicked(UIButton())

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testApplyStudentDiscountEventTracked() {
        MockServer.shared["/checkout/ApplyStudentDiscount/*/*"] = response(forJson: "ApplyVoucher")

        let voucherViewController = ApplyVoucherViewController(nibName: nil, bundle: nil)
        voucherViewController.orderId = 12345
        voucherViewController.voucherCodeTextField = FloatLabelTextFieldWithState()
        voucherViewController.changeVoucherType()
        voucherViewController.voucherCodeTextField.text = "12345"

        voucherViewController.blackButtonClicked(UIButton())

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

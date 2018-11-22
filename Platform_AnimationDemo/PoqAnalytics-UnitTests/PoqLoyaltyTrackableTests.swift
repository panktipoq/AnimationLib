//
//  PoqLoyaltyTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Rachel McGreevy on 1/19/18.
//

import XCTest
@testable import PoqAnalytics

class PoqLoyaltyTrackableTests: EventTrackingTestCase {
    
    func testLoyaltyVoucherTracking() {
        
        PoqTrackerV2.shared.loyaltyVoucher(action: "test", voucherId: 12345)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Tests to confirm custom provider recieves calls from code
    
//    func testLoyaltyVoucherDetailsEventTracked() {
//        MockServer.shared["/apps/*/vouchers/detail/*"] = response(forJson: "LoyaltyViewDetails")
//
//        let voucherDetailViewController = VoucherDetailViewController()
//        voucherDetailViewController.voucherId = 12345
//        _ = voucherDetailViewController.view
//
//        waitForExpectations(timeout: 1) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
//    }
    
//    func testLoyaltyVoucherApplyToBagEventTracked() {
//        MockServer.shared["/checkout/applyvoucher/%/%"] = response(forJson: "LoyaltyApplyToBag")
//
//        let voucherDetailViewController = VoucherDetailViewController()
//        voucherDetailViewController.service.voucher = PoqVoucherV2()
//        voucherDetailViewController.voucherId = 12345
//        voucherDetailViewController.applyToBagButtonClicked(UIButton())
//
//        waitForExpectations(timeout: 1) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
//    }
}

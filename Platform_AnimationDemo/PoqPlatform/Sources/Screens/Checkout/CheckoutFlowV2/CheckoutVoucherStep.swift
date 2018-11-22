//
//  CheckoutVoucherStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 15/07/2016.
//
//

import Foundation
import PoqNetworking

private let CellReuseIdentifier: String = "CheckoutVoucherStep"

public class CheckoutVoucherStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC> {
    
    public var stepNumber: Int?

    weak public var tableViewOwner: CheckoutTableViewOwner?
    
    var voucher: PoqVoucher?
    
    // MARK: CheckoutFlowStep override
    
    public override var checkoutStep: CheckoutStep {
        return .voucher
    }
    
    public override var status: StepStatus {
        return .completed
    }
    
    public override func update(_ checkoutItem: CheckoutItemType) {
        voucher = checkoutItem.vouchers?.first
    }
    
    public override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        // we really need nothing to fill, since this infor server generated. User select nothing here
    }
}

extension CheckoutVoucherStep: TableCheckoutFlowStep {
    
    public func numberOfCellInOverviewSection() -> Int {
        return voucher == nil ? 0 : 1
    }
    
    public func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {

        let cell = configureCheckoutStepCell(tableView, atIndexPath: indexPath)

        return cell
    }
}

extension CheckoutVoucherStep: CheckoutStep3LinePresentation {
    
    public var firstLine: String? { return nil }
    public var secondLine: String? { return AppLocalization.sharedInstance.checkoutOrderSummaryDiscount }
    public var thirdLine: String? { return nil }
    
    public var rightDetailText: String? { return voucher?.value?.toPriceString() }
}

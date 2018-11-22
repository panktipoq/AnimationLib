//
//  CheckoutTotalPriceStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 15/07/2016.
//
//

import Foundation
import PoqNetworking

private let CellReuseIdentifier: String = "CheckoutTotalPriceStep"

public class CheckoutTotalPriceStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC> {

    public var stepNumber: Int?
    
    weak public var tableViewOwner: CheckoutTableViewOwner?

    var checkoutItem: CheckoutItemType?
    
    // MARK: CheckoutFlowStep override
    public override var checkoutStep: CheckoutStep {
        return .totalPrice
    }
    
    public override var status: StepStatus {
        return .completed
    }
    
    public override func update(_ checkoutItem: CheckoutItemType) {
        self.checkoutItem = checkoutItem
    }
    
    public override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        // we really need nothing to fill, since this infor server generated. User select nothing here
    }
}


extension CheckoutTotalPriceStep: TableCheckoutFlowStep {
    
    public func numberOfCellInOverviewSection() -> Int {
        return checkoutItem == nil ? 0 : 1
    }
    
    public func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: CellReuseIdentifier)
        cell.textLabel?.text = AppLocalization.sharedInstance.checkoutOrderSummaryTotal
        cell.textLabel?.font = AppTheme.sharedInstance.checkoutOrderSummeryTotalLabelFont
        cell.detailTextLabel?.font = AppTheme.sharedInstance.checkoutOrderSummeryTotalDetailLabelFont
        cell.detailTextLabel?.textColor = AppTheme.sharedInstance.checkoutOrderSummeryTotalDetailLabelColor
        cell.isUserInteractionEnabled = false
        
        let price: Double = checkoutItem?.totalPrice ?? 0.0
        cell.detailTextLabel?.text = price.toPriceString()
        
        
        return cell
    }
}



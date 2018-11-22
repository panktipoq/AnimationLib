//
//  CheckoutSummaryHeaderCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 13/09/2016.
//
//

import UIKit

open class CheckoutSummaryHeaderCell: UITableViewCell, TableCheckoutFlowStepOverViewCell {
    
    public static let reuseIdentifier: String = "CheckoutSummaryHeaderCell"
    public static let nibName: String = "CheckoutSummaryHeaderCell"

    @IBOutlet public weak var titleLabel: UILabel?
}

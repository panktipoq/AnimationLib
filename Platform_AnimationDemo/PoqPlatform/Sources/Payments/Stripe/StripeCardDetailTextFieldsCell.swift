//
//  StripeCardDetailTextFieldsCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 17/08/2016.
//
//

import Foundation
import Stripe

let StripeCardDetailTextFieldAccessibilityIdentifier = "StripeCardDetailTextFieldAccessibilityIdentifier" 

class StripeCardDetailTextFieldsCell: UITableViewCell {
    
    static let ReuseIdentifier: String = "StripeCardDetailTextFieldsCell"
    
    var stripeCardFom: STPPaymentCardTextField?
    
    
    init() {
        super.init(style: .default, reuseIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier)
        setupCell()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }
}

// MARK: API
extension StripeCardDetailTextFieldsCell {
    
    override func resignFirstResponder() -> Bool {
        guard let validCardForm = stripeCardFom else {
            return true
        }
        
        return validCardForm.resignFirstResponder()
    }
}

// MARK: Private

extension StripeCardDetailTextFieldsCell {
    
    fileprivate final func setupCell() {
        
        guard stripeCardFom == nil else {
            return
        }
        
        let cardForm = STPPaymentCardTextField()
        
        cardForm.borderColor = UIColor.clear
        cardForm.font = AppTheme.sharedInstance.addPaymentMethodCardInfoTextFieldFont
        
        contentView.addSubview(cardForm)
        cardForm.frame = contentView.bounds
        cardForm.translatesAutoresizingMaskIntoConstraints = false
        let cardViewConstraints = NSLayoutConstraint.constraintsForView(cardForm, withInsetsInContainer: UIEdgeInsets.zero)
        contentView.addConstraints(cardViewConstraints)
        
        // height always 44
        let cardViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: cardForm, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44.0)
        contentView.addConstraint(cardViewHeightConstraint)
        
        selectionStyle = .none
        
        stripeCardFom = cardForm
        
        cardForm.accessibilityIdentifier = StripeCardDetailTextFieldAccessibilityIdentifier
    }
}

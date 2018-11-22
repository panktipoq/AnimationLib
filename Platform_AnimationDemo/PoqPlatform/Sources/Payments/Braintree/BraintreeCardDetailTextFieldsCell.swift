//
//  BraintreeCardDetailTextFieldsCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 20/07/2016.
//
//

import Braintree
import Foundation
import UIKit

open class BraintreeCardDetailTextFieldsCell: UITableViewCell {

    static let ReuseIdentifier: String = "CheckoutSelectPaymentOptionCell"
    
    var braintreeCardForm: BTUICardFormView?
    
    init() {
        super.init(style: .default, reuseIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier)
        setupCell()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier)
        setupCell()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }
}

// MARK: - API
extension BraintreeCardDetailTextFieldsCell {
    
    override open func resignFirstResponder() -> Bool {
        guard let existedCardForm = braintreeCardForm else {
            return true
        }
        
        // We know structure. UITextFields is second level subviews. So for in for
        for subviewL1: UIView in existedCardForm.subviews {
            for subviewL2: UIView in subviewL1.subviews where subviewL2.isFirstResponder {
                    return subviewL2.resignFirstResponder()
            }
        }
        return true
    }
}

// MARK: - Private

public extension BraintreeCardDetailTextFieldsCell {
    
    fileprivate final func setupCell() {
        
        guard braintreeCardForm == nil else {
            return
        }
        
        let cardForm = BTUICardFormView()
        
        cardForm.optionalFields = [.cvv]
        
        contentView.addSubview(cardForm)
        cardForm.frame = contentView.bounds
        cardForm.translatesAutoresizingMaskIntoConstraints = false
        let cardViewConstraints = NSLayoutConstraint.constraintsForView(cardForm, withInsetsInContainer: UIEdgeInsets.zero)
        contentView.addConstraints(cardViewConstraints)
        
        selectionStyle = .none
        
        braintreeCardForm = cardForm
    }
}

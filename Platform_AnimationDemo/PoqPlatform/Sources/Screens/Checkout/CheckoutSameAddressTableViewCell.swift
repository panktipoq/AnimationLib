//
//  CheckoutSameAddressTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/14/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import UIKit

public enum AddressSameAs {
    case billing
    case shipping
}

public protocol ChooseSameAddressDelegate: AnyObject {
    func isSameAddressChangeValue(_ sameAs: AddressSameAs, isSame: Bool)
}

open class CheckoutSameAddressTableViewCell: UITableViewCell {
    
    var sameAs: AddressSameAs = .billing

    @IBOutlet public weak var useSameAddressSwitch: UISwitch?
    @IBOutlet weak var title: UILabel? {
        didSet {
            title?.font = AppTheme.sharedInstance.checkoutOrderSummarySameAddressTitleFont
            title?.textColor = AppTheme.sharedInstance.checkoutOrderSummarySameAddressTitleTextColor
        }
    }
    
    static let XibName: String = "CheckoutSameAddressTableViewCell"

    weak var delegate: ChooseSameAddressDelegate?

    @IBAction func switchValueChange(_ sender: UISwitch) {
        delegate?.isSameAddressChangeValue(sameAs, isSame: sender.isOn)
    }
    
    public func setUp(_ sameAsAddress: AddressSameAs, sameAddressdelegate: ChooseSameAddressDelegate?, titleText: String?) {
        sameAs = sameAsAddress
        delegate = sameAddressdelegate
        title?.text = titleText
    }
    
    func setUpSwitch(_ value: Bool?) {
        guard let switchValue = value else {
            return
        }
        useSameAddressSwitch?.isOn = switchValue
    }
}

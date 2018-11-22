//
//  AddVoucherView.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/29/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

open class AddVoucherView: UIView {

    @IBOutlet open var closeButton: CloseButton?
    
    @IBOutlet open var addVoucherButton: DisclosureIndicator?

    override open func awakeFromNib() {
        super.awakeFromNib()
        closeButton?.isHidden = true
    }
    
    ///TODO: Refactor by using a computed property ex: 'applyVoucherEnabled: Bool' and change state inside Property Observers.
    open func showCloseButton(_ shown: Bool){
        closeButton?.isHidden = !shown
        addVoucherButton?.isHidden = shown
    }
    
    //TODO: This can be removed and instead use computed property described in above Todo.
    open func removeState() -> Bool{
        guard let button = closeButton else {
            return false
        }
        return !button.isHidden
    }
}

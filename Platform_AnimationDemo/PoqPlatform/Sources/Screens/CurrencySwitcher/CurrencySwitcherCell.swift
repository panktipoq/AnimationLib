//
//  CurrencySwitcherCell.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 09/05/2018.
//

import Foundation
import UIKit
import PoqUtilities

class CurrencySwitcherCell: UITableViewCell, CurrencySwitcherView {
    
    @IBOutlet var currencyLabel: UILabel?
    @IBOutlet var flagImage: UIImageView?
    
    public func setup(currency: Currency) {
        currencyLabel?.text = "\(currency.countryName)" + " (\(currency.code))"
        let imageName = "flag_\(currency.countryCode)"
        flagImage?.image = ImageInjectionResolver.loadImage(named: imageName)
    }
}

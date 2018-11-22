//
//  PriceLabelFormatter.swift
//  PoqCart
//
//  Created by Balaji Reddy on 23/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import UIKit
import PoqUtilities

/**
  This protocol represents a type that can format price and special price labels
 */
protocol PriceLabelFormattable {
    func format(priceLabels: (priceLabel: UILabel, wasPriceLabel: UILabel?), priceInfo: (nowPrice: String, wasPrice: String?))
}

/**
  The concrete platform implementation of the PriceLabelFormattable procotol
  The platform formatting of the price labes shows the price string with a strikethrough if a valid special price exists
 */
struct PriceLabelFormatter: PriceLabelFormattable {
    
    func attributedPriceString(priceString: String) -> NSAttributedString {
        
        let priceAttributedString = NSMutableAttributedString(string: priceString)
        priceAttributedString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: priceAttributedString.length))
        
        return priceAttributedString
    }
    
    func format(priceLabels: (priceLabel: UILabel, wasPriceLabel: UILabel?), priceInfo: (nowPrice: String, wasPrice: String?)) {
    
        if let wasPrice = priceInfo.wasPrice {
            
            priceLabels.wasPriceLabel?.textColor = UIColor.gray
            priceLabels.wasPriceLabel?.attributedText = attributedPriceString(priceString: wasPrice)
            
            priceLabels.wasPriceLabel?.text = priceInfo.wasPrice
            
        }
            
        priceLabels.priceLabel.text = priceInfo.nowPrice
        
    }
}

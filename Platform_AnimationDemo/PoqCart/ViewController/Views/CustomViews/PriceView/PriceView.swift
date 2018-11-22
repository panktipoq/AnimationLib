//
//  PriceView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/06/2018.
//

import Foundation
import UIKit

/**
 
    This protocol represents a type that can present the Price of a product
 */
protocol PriceViewPresentable {
    
    func setup(with price: (nowPrice: String, wasPrice: String?))
}

/**
 
    This the concrete platform implementation of the PriceViewPresentable protocol
 
    It displays a price label and a special price label if a special price is applicable and available
 */
public class PriceView: UIView, PriceViewPresentable {
    
    var nowPriceLabel: UILabel
    var wasPriceLabel: UILabel
    let decorator: PriceViewDecoratable
    let formatter: PriceLabelFormattable
    
    /// The designated initialiser for the PriceView
    ///
    /// - Parameters:
    ///   - frame: The frame for the view
    ///   - decorator: The decorator that lays out the constraints for the PriceView
    ///   - formatter: The formatter for the price and special price labels
    init(frame: CGRect, decorator: PriceViewDecoratable = PoqPriceViewDecorator(), formatter: PriceLabelFormattable = PriceLabelFormatter()) {
        
        self.decorator = decorator
        self.formatter = formatter
        
        nowPriceLabel = UILabel(frame: CGRect.zero)
        wasPriceLabel = UILabel(frame: CGRect.zero)
        
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setPriceLabelStyle(nowPriceLabel)
        addSubview(nowPriceLabel)
        
        setSpecialPriceLabelStyle(wasPriceLabel)
        addSubview(wasPriceLabel)
        
        decorator.layout(priceView: self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This method sets the style of the Price Label
    ///
    /// - Parameter priceLabel: The price label whose style is to be set
    open func setPriceLabelStyle(_ priceLabel: UILabel) {
        nowPriceLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        nowPriceLabel.textAlignment = .left
    }
    
    /// This method sets the style of the special price label
    ///
    /// - Parameter specialPriceLabel: The special price label whose style is to be set
    open func setSpecialPriceLabelStyle(_ specialPriceLabel: UILabel) {
        specialPriceLabel.textAlignment = .left
        specialPriceLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
    }
    
    /// This method sets up the Price View
    ///
    /// - Parameter priceInfo: A tuple that passes the price and special price
    func setup(with priceInfo: (nowPrice: String, wasPrice: String?)) {
        
        nowPriceLabel.text = nil
        nowPriceLabel.textColor = UIColor.black
        wasPriceLabel.text = nil
        
        formatter.format(priceLabels: (nowPriceLabel, wasPriceLabel), priceInfo: (priceInfo.nowPrice, priceInfo.wasPrice))
    }
}

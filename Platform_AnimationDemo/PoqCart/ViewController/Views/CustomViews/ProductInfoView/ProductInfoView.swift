//
//  ProductInfoView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/06/2018.
//

import Foundation
import UIKit
import Cartography

public struct ProductTitleInfo {
    var productTitle: String
    var brand: String?
    var color: String?
    var size: String?
}

/**
    This protocol represents a type that can present a Product's title, brand, color and size information
 */
public protocol ProductInfoViewPresentable {
    
    func setup(with productTitleInfo: ProductTitleInfo)
}

/**
    This is the concrete platform implementation of the ProductInfoViewPresentable protocol
 
    It displays the product title, brand, color and size.
 */
public class ProductInfoView: UIView, ProductInfoViewPresentable {
    
    var brandLabel: UILabel? = UILabel(frame: CGRect.zero)
    var titleLabel = UILabel(frame: CGRect.zero)
    var colorLabel: UILabel? = UILabel(frame: CGRect.zero)
    var sizeLabel: UILabel? = UILabel(frame: CGRect.zero)
    
    var decorator: ProductInfoViewDecoratable?
    
    fileprivate func addSubviews() {
        
        addSubview(titleLabel)
        
        if let brandLabel = brandLabel {
            
            addSubview(brandLabel)
        }
        if let colorLabel = colorLabel, let sizeLabel = sizeLabel {
            addSubview(colorLabel)
            addSubview(sizeLabel)
        }
    }
    
    /// The designated initialiser for the ProductInfoView
    ///
    /// - Parameters:
    ///   - frame: The frame of the view
    ///   - decorator: The decorator that lays out the constraints for the ProductInfoView
    init(frame: CGRect, decorator: ProductInfoViewDecoratable = ProductInfoViewDecorator()) {
        
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setStyles()
        
        addSubviews()
        
        self.decorator = decorator
        
        self.decorator?.layout(productInfoView: self)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This method sets up the ProductInfoViwe
    ///
    /// - Parameter productInfo: This is a tuple that provides the product title, brand, color and size strings
    open func setup(with productInfo: ProductTitleInfo) {
        
        titleLabel.text = productInfo.productTitle
        brandLabel?.text = productInfo.brand
        colorLabel?.text = productInfo.color
        sizeLabel?.text = productInfo.size
    }
    
    /// This method sets the styles of the labels in ProductInfoView
    open func setStyles() {
        
        brandLabel?.textAlignment = .left
        brandLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 15.0)
        titleLabel.numberOfLines = 0
        
        colorLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        colorLabel?.textColor = UIColor.gray
        
        sizeLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        sizeLabel?.textColor = UIColor.gray
    }
}

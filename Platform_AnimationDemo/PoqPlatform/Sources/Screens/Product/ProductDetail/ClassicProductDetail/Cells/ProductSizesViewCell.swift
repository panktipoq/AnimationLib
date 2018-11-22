//
//  ProductSizesViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

open class ProductSizesViewCell: UITableViewCell {
    
    //MARK: - IBOutlet

    @IBOutlet public weak var sizesLabel: UILabel? {
        didSet{
            sizesLabel?.font = AppTheme.sharedInstance.pdpSizesLabelFont
        }
    }
    
    @IBOutlet public weak var sizesTitleLabel: UILabel? {
        didSet {
            sizesTitleLabel?.text = AppLocalization.sharedInstance.pdpSizesTitleLabelText
            sizesTitleLabel?.font = AppTheme.sharedInstance.pdpSizesTitleLabelFont
        }
    }
    
    //MARK: - ClassVariables
    
    public var product: PoqProduct?
    
    //MARK: - Setup
    
    open func setup(using product: PoqProduct) {
        
        self.product = product

        var sizes:[String] = []
        
        // Extract size info as product size name
        if let productSizes = product.productSizes {
            
            for productSize in productSizes {
                
                if let productSizeName = productSize.size, !productSizeName.isEmpty {
                    
                    sizes.append(productSizeName.uppercased())
                }
            }
        }
        
        // Show list of product sizes with comma seperated
        sizesLabel?.text = sizes.joined(separator: ", ")
    }
}

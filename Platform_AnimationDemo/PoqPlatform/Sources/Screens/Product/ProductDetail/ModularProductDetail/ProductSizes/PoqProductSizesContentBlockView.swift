//
//  PoqProductSizesContentBlockView.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/22/17.
//
//

import Foundation
import PoqNetworking
import UIKit

open class PoqProductSizesContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell {
    
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var sizesLabel: UILabel?  {
        didSet {
            sizesLabel?.isAccessibilityElement = true
            sizesLabel?.accessibilityIdentifier = AccessibilityLabels.pdpSizes
        }
    }
    @IBOutlet public weak var separator: SolidLine?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        sizesLabel?.font = AppTheme.sharedInstance.pdpSizesLabelFont

        titleLabel?.text = AppLocalization.sharedInstance.pdpSizesTitleLabelText
        titleLabel?.font = AppTheme.sharedInstance.pdpSizesTitleLabelFont
    }
    
    // MARK: PoqProductDetailCell
    public weak var presenter: PoqProductBlockPresenter?
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {

        var sizes: [String] = []
        
        // Extract size info as product size name
        if let productSizes = product?.productSizes {
            
            for productSize in productSizes {
                
                guard let productSizeName = productSize.size, !productSizeName.isEmpty else {
                    continue
                }
                
                sizes.append(productSizeName.uppercased())
            }
        }
        
        sizesLabel?.text = sizes.joined(separator: ", ")
    }
}

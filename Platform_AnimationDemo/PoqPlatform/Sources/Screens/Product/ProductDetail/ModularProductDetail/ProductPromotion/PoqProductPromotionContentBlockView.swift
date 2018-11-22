//
//  PoqProductPromotionContentBlockView.swift
//  PoqPlatform
//
//  Created by Joshua White on 26/10/2018.
//

import PoqNetworking
import UIKit

// TODO: Refactor to make generic text cell... factoring in how this promotion cell should stand out.
open class PoqProductPromotionContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell {
    
    open weak var presenter: PoqProductBlockPresenter?
        
    @IBOutlet open weak var promotionLabel: UILabel? {
        didSet {
            promotionLabel?.accessibilityIdentifier = AccessibilityLabels.pdpPromotion
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = AppTheme.sharedInstance.promotionAreaColor
        
        promotionLabel?.font = AppTheme.sharedInstance.promotionLabelFont
        promotionLabel?.textColor = AppTheme.sharedInstance.promotionLabelColor
    }
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        promotionLabel?.text = product?.promotion
    }
}

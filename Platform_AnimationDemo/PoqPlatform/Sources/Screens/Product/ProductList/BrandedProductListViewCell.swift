//
//  BrandedProductListViewCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 21/06/2016.
//
//

import Foundation
import PoqNetworking
import UIKit



public final class BrandedProductListViewCell: ProductListViewCell {
    
    @IBOutlet weak var collectionNameLabel: UILabel?
    

    public final override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement =  true
        accessibilityIdentifier = AccessibilityLabels.brandedProductListCell
    }
    
    override public class func cellSize(_ product: PoqProduct, cellInsets: UIEdgeInsets) -> CGSize {
        
        let widthInsets = CGFloat(cellInsets.left + cellInsets.right)
        let heightInsets = CGFloat(cellInsets.top + cellInsets.bottom)

        // Get screen width
        let bounds: CGRect = UIScreen.main.bounds
        let screenWitdh: CGFloat = bounds.size.width

        
        let columns: CGFloat = CGFloat(AppSettings.sharedInstance.brandedPLPColumns)
        let cellWidth  = screenWitdh * 1.0/columns - widthInsets
        let cellHeight = CGFloat(AppSettings.sharedInstance.brandedProductCellImageHeight) + CGFloat(AppSettings.sharedInstance.brandedPLPBottomHeight) - heightInsets

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    final override func updateStyles() {
        // Nothing to do
    }
    
    final override public func updateView(_ product: PoqProduct, isLikeButtonHidden: Bool = false, isBranded: Bool = false ) {
        super.updateView(product, isLikeButtonHidden: isLikeButtonHidden, isBranded: true)
        
        var productTitleLineSpaging = 2
        if DeviceType.IS_IPAD {
            productTitleLineSpaging = 3
        }
        
        var isGroupedProduct = false
        
        if let relatedProductIds = self.product?.relatedProductIDs {
            
            isGroupedProduct = relatedProductIds.count != 0
        }
        
        brandLabel?.text = product.brand?.uppercased()
        brandLabel?.font = AppTheme.sharedInstance.brandedPlpBrandLabelFont
        
        guard let validProducts = product.title else {
            return
        }
        
        OperationQueue.main.addOperation { 
            self.titleLabel?.attributedText = LabelStyleHelper.brandedProductLabel(validProducts, lineSpacing: productTitleLineSpaging)
            self.priceString = LabelStyleHelper.initPriceLabel(product.price,
                specialPrice: product.specialPrice,
                isGroupedPLP: isGroupedProduct,
                priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                priceFontStyle: AppTheme.sharedInstance.brandedPlpPriceFont,
                specialPriceFontStyle: AppTheme.sharedInstance.brandedPlpSpecialPriceFont)
            self.priceLabel?.attributedText = self.priceString
        }
        
        bottomSpaceHeightConstraint?.constant = CGFloat(AppSettings.sharedInstance.brandedPLPBottomHeight)
    }
}



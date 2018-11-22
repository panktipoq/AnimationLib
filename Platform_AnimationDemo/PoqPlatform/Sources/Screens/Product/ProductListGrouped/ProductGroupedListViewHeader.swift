//
//  ProductGroupedListViewHeader.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 26/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

/// TODO: Gabriel Sabiescu documentation
open class ProductGroupedListViewHeader: UICollectionViewCell {
    
    /// TODO: Gabriel Sabiescu documentation
    static let height = AppSettings.sharedInstance.plpHasGroupedProductImage ? 380 : 100

    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productBrand: UILabel?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productTitle: UILabel?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var starRating: StarRatingView?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productReviewCount: UILabel?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productPrice: UILabel?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var specialProductPrice: UILabel?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productImage: PoqAsyncImageView?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productImageContainerViewHeightContraint: NSLayoutConstraint?
    
    /// TODO: Gabriel Sabiescu documentation
    @IBOutlet weak var productImageContainerView: UIView? {
        didSet {
            productImageContainerView?.addBorders([BorderViewPosition.bottom], color: AppTheme.sharedInstance.solidLineColor, width: 0.5)
        }
    }
    
    /// TODO: Gabriel Sabiescu documentation
    var footerSpinner: PoqSpinner?
    
    /// TODO: Gabriel Sabiescu documentation
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        // We check the setting plpHasGroupedProductImage which is a flag stating whether the Group PLP has an image header or not
        if !AppSettings.sharedInstance.plpHasGroupedProductImage {
            productImageContainerViewHeightContraint?.constant = 0
        }
    }
    
    /// 
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setupProgressView()
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameter frame: TODO: Gabriel Sabiescu documentation
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupProgressView()
    }
        
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - productBrandString: TODO: Gabriel Sabiescu documentation
    ///   - productTitleString: TODO: Gabriel Sabiescu documentation
    ///   - productRating: TODO: Gabriel Sabiescu documentation
    ///   - productPriceString: TODO: Gabriel Sabiescu documentation
    ///   - productSpecialPriceString: TODO: Gabriel Sabiescu documentation
    ///   - productImageUrLString: TODO: Gabriel Sabiescu documentation
    func setupView(_ productBrandString: String, productTitleString: String, productRating: Float?, productPriceString: String, productSpecialPriceString: String?, productImageUrLString: String?) {
        
        productBrand?.attributedText = LabelStyleHelper.setupProductTitleLable(brand: productBrandString,
                                                                               title: productTitleString)
        productBrand?.sizeToFit()
        
        productPrice?.text = productPriceString
        productPrice?.textColor = AppTheme.sharedInstance.plpGroupedPriceColor
        productPrice?.font = AppTheme.sharedInstance.plpGroupedPriceFont

        if let productSpecialPriceStringUnwrapped = productSpecialPriceString {
            specialProductPrice?.text = productSpecialPriceStringUnwrapped
            specialProductPrice?.textColor = AppTheme.sharedInstance.plpGroupedSpecialPriceColor
            specialProductPrice?.font = AppTheme.sharedInstance.plpGroupedSpecialPriceFont
        }

        starRating?.numberOfStars = 5
        
        if let productRatingUnwrapped = productRating {
            starRating?.rating = productRatingUnwrapped
            starRating?.fillColor = AppTheme.sharedInstance.starViewFillColor
            starRating?.unfilledColor = AppTheme.sharedInstance.starViewUnfillColor
        }
        
        if let imageURLString = productImageUrLString,
            let imageURL = URL(string: imageURLString),
            AppSettings.sharedInstance.plpHasGroupedProductImage {
            productImage?.getImageFromURL(imageURL, isAnimated: true)
        }
    }
}

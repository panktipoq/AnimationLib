//
//  CarousselProductCell.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi on 15/05/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

let carouselCellBaseAccessibilityIdentifier = "CarouselCellBaseAccessibilityIdentifier_"

open class PoqProductsCarouselCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var productImageView: PoqAsyncImageView?
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var brandLabel: UILabel?
    @IBOutlet open weak var priceLabel: UILabel?
    @IBOutlet open weak var titleLabel: UILabel?
    
    @IBOutlet public weak var likeButton: UIButton? {
        didSet {
            likeButton?.setImage(ImageInjectionResolver.loadImage(named: "LikeButtonImageDefault"), for: .normal)
            likeButton?.setImage(ImageInjectionResolver.loadImage(named: "LikeButtonImagePressed"), for: UIControlState.selected)
        }
    }
    
    public var priceFormat: String = AppSettings.sharedInstance.plpPriceFormat
    
    var product: PoqProduct?
    
    public static var isSkeletonImageEnabled: Bool = true

    open override func awakeFromNib() {
        super.awakeFromNib()
        imageViewBottomConstraint?.constant = CGFloat(AppSettings.sharedInstance.productsCarouselTextAreaHeight)
    }
    
    open func setup(using product: PoqProduct, showLikeButton: Bool = false) {
        
        self.product = product
        
        if let urlString = product.thumbnailUrl, let url = URL(string: urlString) {
            productImageView?.fetchImage(from: url, shouldDisplaySkeleton: PoqProductsCarouselCell.isSkeletonImageEnabled)
        }
        
        let priceString = LabelStyleHelper.initPriceLabel(product.price,
                                                          specialPrice: product.specialPrice,
                                                          isGroupedPLP: false,
                                                          priceFormat: priceFormat,
                                                          singlePriceFont: AppTheme.sharedInstance.productsCarouselSinglePriceFont,
                                                          priceFontStyle: AppTheme.sharedInstance.productsCarouselPriceFont,
                                                          specialPriceFontStyle: AppTheme.sharedInstance.productsCarouselSpecialPriceFont)

        priceLabel?.attributedText = priceString
        priceLabel?.accessibilityIdentifier = AccessibilityLabels.carouselPrice
        
        brandLabel?.text = product.brand
        titleLabel?.text = product.title
        titleLabel?.font = AppTheme.sharedInstance.recentlyViewedCarouselProductTitleFont
        titleLabel?.accessibilityIdentifier = AccessibilityLabels.carouselTitle

        likeButton?.isHidden = !showLikeButton

        updateWishlistIconStatus()
        
        accessibilityIdentifier = carouselCellBaseAccessibilityIdentifier + (product.externalID ?? "")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        productImageView?.prepareForReuse()
    }
    
    func updateWishlistIconStatus() {
        guard let productIdUnwrapped = product?.id else {
            return
        }
        
        likeButton?.isSelected = WishlistController.shared.isFavorite(productId: productIdUnwrapped)
    }
    
    @IBAction public func likeButtonAction(_ sender: UIButton) {

        guard let productUnwrapped = product, let productId = product?.id, let likeButtonUnwrapped = likeButton else {
            Log.error("No product available to add or remove from wishlist")
            return
        }
        
        if !likeButtonUnwrapped.isSelected {

            WishlistController.shared.add(product: productUnwrapped)
            likeButtonUnwrapped.isSelected = true
            productUnwrapped.isFavorite = true
            
            guard let productTitle = productUnwrapped.title, !productTitle.isEmpty else {
                
                Log.error("Product title is missing Couldn't track wishlist operation.")
                return
            }

            let valuePrice: Double = product?.trackingPrice ?? 0.0
            PoqTrackerHelper.trackAddToWishList(productTitle, value: valuePrice, extraParams: ["Screen": "AppStoryProductList"])
        } else {
            
            WishlistController.shared.remove(productId: productId)

            likeButtonUnwrapped.isSelected = false
            productUnwrapped.isFavorite = false
        }
    }
}

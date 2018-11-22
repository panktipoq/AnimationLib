//
//  WishListTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/28/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

@objc public protocol WishlistCellDelegate {
    func remove(_ listItem:AnyObject, index:Int)
    func addToBagClicked(_ listItem:AnyObject, index:Int)
}

open class WishListTableViewCell: UITableViewCell, AddToBagButtonDelegate, CloseButtonDelegate {

    @IBOutlet open var productImage: PoqAsyncImageView!
    @IBOutlet open var brandNameLabel: UILabel?
    @IBOutlet open var productCost: UILabel?
    @IBOutlet open var specialPriceLabel: UILabel?
    @IBOutlet open var addToBagButton: AddToBagButton?
    @IBOutlet open var closeButton: CloseButton?
    
    open var wishListItem: PoqProduct?
    open var index: Int?
    public var delegate: WishlistCellDelegate?
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        if !AppSettings.sharedInstance.enableAddToBagOnWishlist {
            addToBagButton?.removeFromSuperview()
        }
        
        productImage.isAccessibilityElement = true
        productImage.accessibilityLabel = AccessibilityLabels.productImage.localizedPoqString
        productImage.accessibilityTraits = UIAccessibilityTraitImage
        
        closeButton?.isAccessibilityElement = true
        closeButton?.accessibilityLabel = AccessibilityLabels.removeItem.localizedPoqString
        closeButton?.accessibilityIdentifier = AccessibilityLabels.removeItem
        closeButton?.accessibilityTraits = UIAccessibilityTraitButton
        
        addToBagButton?.isAccessibilityElement = true
        addToBagButton?.accessibilityLabel = AccessibilityLabels.addtoBag.localizedPoqString
        addToBagButton?.accessibilityTraits = UIAccessibilityTraitButton
        
        accessibilityElements = [productImage]
        if let nameLabel = brandNameLabel {
            accessibilityElements?.append(nameLabel)
        }
        if let costLabel = productCost {
            accessibilityElements?.append(costLabel)
        }
        if let addToBagButton = addToBagButton {
            accessibilityElements?.append(addToBagButton)
        }
        if let closeButton = closeButton {
           accessibilityElements?.append(closeButton)
        }
        
        addToBagButton?.setTitle(AppLocalization.sharedInstance.wishListAddToBagText, for: .normal)
        if let fontName = addToBagButton?.titleLabel?.font.fontName {
            addToBagButton?.titleLabel?.font = UIFont(name: fontName, size: CGFloat(AppSettings.sharedInstance.wishListAddToBagLabelFontSize))
        }
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Setup
    
    open func setup(using product: PoqProduct) {

        self.wishListItem = product
        // set the image
        
        if let urlString = product.thumbnailUrl,
            let URL = URL(string: urlString) {
            productImage.fetchImage(from: URL, isAnimated: false)
        }
        
        self.brandNameLabel?.attributedText = LabelStyleHelper.setupProductTitleLable(brand: self.wishListItem?.brand,
                                                                                      brandTextColor: AppTheme.sharedInstance.wishlistBrandLabelColor,
                                                                                      brandFont: AppTheme.sharedInstance.wishlistBrandLabelFont,
                                                                                      title: self.wishListItem?.title,
                                                                                      titleTextColor: AppTheme.sharedInstance.wishlistTitleLabelColor,
                                                                                      titleFont: AppTheme.sharedInstance.wishlistTitleLabelFont)
        
        setupPrices(using: product)
        
        // If it is a group PLP item, it cannot be added to bag so hide the button
        if let relatedProductsIDs = product.relatedProductIDs {
            addToBagButton?.isHidden = relatedProductsIDs.count > 0
        }
        
        // Handle out of stock
        if addToBagButton?.isHidden == false {
            if let sizes = product.productSizes {
                addToBagButton?.isEnabled = !sizes.isEmpty
            }
        }
    }

    open func setupPrices(using product: PoqProduct) {
        if let specialPriceLabelUnwrapped = specialPriceLabel {
            
            // Set up Price Label
            let priceText = LabelStyleHelper.createPriceLabelText(product.priceRange, specialPriceRange: product.specialPriceRange, price: product.price, specialPrice: product.specialPrice)
            productCost?.text = priceText
            
            // Set up Special Price Label
            let specialPriceText = LabelStyleHelper.createSpecialPriceLabelText(product.priceRange, specialPriceRange: product.specialPriceRange, price: product.price, specialPrice: product.specialPrice, isClearance: product.isClearance)
            specialPriceLabelUnwrapped.text = specialPriceText
            
        } else {
            productCost?.attributedText = LabelStyleHelper.initPriceLabel(
                self.wishListItem?.price,
                specialPrice: self.wishListItem?.specialPrice,
                isGroupedPLP: false,
                priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                priceFontStyle: AppTheme.sharedInstance.wishlistPriceFont,
                specialPriceFontStyle: AppTheme.sharedInstance.wishlistSpecialPriceFont
            )
        }
    }
    
    @IBAction public func addToBagButtonClicked(_ sender: Any?) {
        if let wishListItemUnwrapped = wishListItem,
            let indexUnwrapped = index {
            self.delegate?.addToBagClicked(wishListItemUnwrapped, index: indexUnwrapped)
        }
    }

    @IBAction public func closeButtonClicked() {
        if let item = wishListItem, let index = index {
            delegate?.remove(item, index: index)
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        productImage.prepareForReuse()
    }
    
}

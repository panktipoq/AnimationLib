//
//  ProductListViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

public protocol ProductListViewCellDelegate: AnyObject {
    
    func toggleExpandedProduct( _ product: PoqProduct )
    func getIsPromoExpanded( _ productId: Int ) -> Bool
}

open class ProductListViewCell: UICollectionViewCell {

    // UI Outlets
    @IBOutlet open weak var brandLabel: UILabel?
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var priceLabel: UILabel?
    @IBOutlet open weak var specialPriceLabel: UILabel?

    @IBOutlet public weak var likeButton: UIButton? {
        didSet {
            likeButton?.setImage(ImageInjectionResolver.loadImage(named: "LikeButtonImageDefault"), for: UIControlState())
            likeButton?.setImage(ImageInjectionResolver.loadImage(named: "LikeButtonImagePressed"), for: UIControlState.selected)
            likeButton?.accessibilityIdentifier = AccessibilityLabels.likeButton
        }
    }

    @IBOutlet open weak var productImage: PoqAsyncImageView! {
        didSet {
            productImage.contentMode = .scaleAspectFit
        }
    }

    @IBOutlet open weak var promotionTextArea: UIView?
    @IBOutlet open weak var promotionTextAreaHeight: NSLayoutConstraint?
    @IBOutlet open weak var promotionTextLabel: UILabel?
    @IBOutlet open weak var moreColors: UIImageView?
    @IBOutlet open weak var moreColorsLabel: UILabel?
    @IBOutlet weak var promotionDetailIndicatorImageView: UIImageView?
    @IBOutlet weak var colorSwatchSelectorView: ColorSwatchSelectorView?
    @IBOutlet weak var verticalSeparator: UIView?
    @IBOutlet weak var horizontalSeparator: UIView?

    @IBOutlet open weak var bottomSpaceHeightConstraint: NSLayoutConstraint?
    var imageContainerRatioConstraint: NSLayoutConstraint?

    open weak var delegate: ProductListViewCellDelegate?

    open weak var colorChangeDelegate: ProductColorsDelegate?

    open var product: PoqProduct?
    open var originalHeight: CGFloat = 0
    open var priceString: NSMutableAttributedString?

    public static var isSkeletonImageEnabled: Bool = true

    lazy var productIdToThumbnailUrl: [Int: String] = [Int: String]()

    open var isPromotionOpen: Bool {

        guard let validProduct = self.product,
            let validProductId = validProduct.id,
            let isPromotionOpen = self.delegate?.getIsPromoExpanded(validProductId) else {
            return false
        }

        return isPromotionOpen
    }

    public class func cellSize(_ product: PoqProduct, cellInsets: UIEdgeInsets) -> CGSize {
        // Get screen width
        let bounds: CGRect = UIScreen.main.bounds
        var width: CGFloat = bounds.size.width

        let columns = DeviceType.IS_IPAD ? AppSettings.sharedInstance.plpColumns_iPad : AppSettings.sharedInstance.plpColumns_iPhone

        // Set size of the cell adaptive to the screen
        width = width * CGFloat(1/columns) - CGFloat(cellInsets.left + cellInsets.right)

        var ratio = CGFloat(AppSettings.sharedInstance.plpProductCellImageContainerRatio)
        if !ratio.isPositive() {
            ratio = 1.0
        }
        let imageContainerHeight: CGFloat = width/ratio

        let fullHeight = CGFloat(AppSettings.sharedInstance.plpProductCellBottomContentHeight) + imageContainerHeight

        return CGSize(width: width, height: fullHeight)
    }

    // Called when the cell is on Screen
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        if let promotextAreaHeight = self.promotionTextAreaHeight {
            originalHeight = promotextAreaHeight.constant
        }

        setUpMoreColours()

        bottomSpaceHeightConstraint?.constant = CGFloat(AppSettings.sharedInstance.plpProductCellBottomContentHeight)

        updateStyles()

        if AppSettings.sharedInstance.isPlpColorSwatchesEnabled {
            colorSwatchSelectorView?.setupView()
        }

        self.layoutIfNeeded()
    }

    func updateStyles() {

        self.brandLabel?.font = AppTheme.sharedInstance.plpBrandLabelFont
        self.brandLabel?.textColor=AppTheme.sharedInstance.plpBrandLabelColor

        self.titleLabel?.font = AppTheme.sharedInstance.plpTitleLabelFont
        self.titleLabel?.textColor = AppTheme.sharedInstance.plpTitleLabelColor
        self.titleLabel?.textAlignment = NSTextAlignment.valueFromString(AppSettings.sharedInstance.plpTitleTextAligment)
        self.titleLabel?.accessibilityIdentifier = AccessibilityLabels.plpCellTitleLabel

        self.priceLabel?.textAlignment = NSTextAlignment.valueFromString(AppSettings.sharedInstance.plpPriceTextAligment)

        self.promotionTextLabel?.font = AppTheme.sharedInstance.promotionLabelFont
        self.promotionTextLabel?.textColor = AppTheme.sharedInstance.promotionLabelColor
    } 

    func setUpMoreColours() {

        moreColors?.image = UIImage(named: AppSettings.sharedInstance.plpMoreColoursIconImageName)
        moreColorsLabel?.font = AppTheme.sharedInstance.moreColorsFont
        moreColorsLabel?.textColor = AppTheme.sharedInstance.moreColorsColor
        moreColorsLabel?.text = AppLocalization.sharedInstance.plpMoreColorText
    }

    open func updateView(_ product: PoqProduct, isLikeButtonHidden: Bool = false, isBranded: Bool = false ) {

        self.product = product

        guard let validProduct = self.product else {
            return
        }

        if !isLikeButtonHidden {

            // Hide like button if product id is 0
            // This is the case for grouped products
            // API returns 0 for grouped product item in PLP
            // Ex: Home > Dining > Linea
            if let productId = validProduct.id {

                likeButton?.isHidden = (productId == 0) || AppSettings.sharedInstance.hidePLPLikeButton
            } else {

                likeButton?.isHidden = true
            }

        } else {

            // Hide like button for lookbook image product
            likeButton?.isHidden = true
        }

        setBrandNameAndTitle()

        updatePrices(with: validProduct, isBranded: isBranded)

        updateWishlistIconStatus(validProduct.id)

        // Show promotion text
        if let promotionText = validProduct.promotion, !promotionText.isEmpty {
            setupPromotionArea(promotionText)
            promotionTextArea?.isHidden = false
            updatePromotionTextContainerHeight()
            promotionDetailIndicatorImageView?.image = isPromotionOpen ? ImageInjectionResolver.loadImage(named: "Minus") : ImageInjectionResolver.loadImage(named: "Plus")
        } else {
            promotionTextArea?.isHidden = true
        }

        if let productColors = product.productColors, AppSettings.sharedInstance.isPlpColorSwatchesEnabled && productColors.count > 1 {
            enableColorSwatchSelection()

        } else {

            // Show/hide more colors icons
            if let hasMoreColors = product.hasMoreColors {

                moreColors?.isHidden = !hasMoreColors
                moreColorsLabel?.isHidden = !hasMoreColors
            }

            setupProductImage(product.thumbnailUrl, animated: true)
        }
    }

    open func setBrandNameAndTitle() {

        brandLabel?.text = product?.brand
        titleLabel?.text = product?.title
        titleLabel?.font = AppTheme.sharedInstance.plpTitleLabelFont
    }

    open func updatePrices(with product: PoqProduct, isBranded: Bool) {

        // If grouped product then the price label should show "From" in front of price line
        var isGroupedProduct = false

        if let relatedProductIds = product.relatedProductIDs {

            isGroupedProduct = isGroupedProduct || (relatedProductIds.count != 0)
        }

        if product.bundleId != nil {
            isGroupedProduct = true
        }

        if let relatedProductIDs = product.relatedProductIDs, !relatedProductIDs.isEmpty, AppSettings.sharedInstance.isGroupPLPWithPriceFormatFrom {

            OperationQueue.main.addOperation {
                self.priceString = LabelStyleHelper.initPriceLabel(product.price,
                                                                   specialPrice: nil,
                                                                   isGroupedPLP: isGroupedProduct,
                                                                   priceFormat: AppSettings.sharedInstance.groupPLPPriceFormat,
                                                                   priceFontStyle: isBranded ?  AppTheme.sharedInstance.brandedPlpPriceFont : AppTheme.sharedInstance.plpPriceFont)

                self.priceLabel?.attributedText = self.priceString
                self.priceLabel?.accessibilityIdentifier = AccessibilityLabels.priceString
            }
        } else if specialPriceLabel != nil {
            // Set up Price Label
            let priceText = LabelStyleHelper.createPriceLabelText(product.priceRange, specialPriceRange: product.specialPriceRange, price: product.price, specialPrice: product.specialPrice)
            setupPriceLabel(priceText)

            // Set up Special Price Label
            let specialPriceText = LabelStyleHelper.createSpecialPriceLabelText(product.priceRange, specialPriceRange: product.specialPriceRange, price: product.price, specialPrice: product.specialPrice, isClearance: product.isClearance)
            setupSpecialPriceLabel(specialPriceText)
        } else {

            OperationQueue.main.addOperation {
                self.priceString = LabelStyleHelper.initPriceLabel(product.price,
                                                                   specialPrice: product.specialPrice,
                                                                   isGroupedPLP: isGroupedProduct,
                                                                   priceFormat: AppSettings.sharedInstance.plpPriceFormat,
                                                                   priceFontStyle: isBranded ?  AppTheme.sharedInstance.brandedPlpPriceFont : AppTheme.sharedInstance.plpPriceFont,
                                                                   specialPriceFontStyle: AppTheme.sharedInstance.plpSpecialPriceFont)

                self.priceLabel?.attributedText = self.priceString
                self.priceLabel?.accessibilityIdentifier = AccessibilityLabels.priceString
            }
        }
    }

    func enableColorSwatchSelection() {

        guard let productUnwrapped = product else {
            return
        }

        setupColorSwatchSelector()

        moreColorsLabel?.isHidden = true
        moreColors?.isHidden = true
        if let productColors = productUnwrapped.productColors, productColors.count > Int(AppSettings.sharedInstance.plpMaxSwatchesToDisplay) {
            moreColorsLabel?.isHidden = false
            moreColors?.isHidden = false
        }

        var thumbnailUrl = productUnwrapped.thumbnailUrl

        if let selectedColorProductID = productUnwrapped.selectedColorProductID {

            colorSwatchSelectorView?.setSelectedSwatch(selectedColorProductID)

            thumbnailUrl = productIdToThumbnailUrl[selectedColorProductID]

            updateWishlistIconStatus(selectedColorProductID)
        } else if let productId = productUnwrapped.id {
            // If a product color hasn't been selected in the past then set the swatch for the base product Id.
            colorSwatchSelectorView?.setSelectedSwatch(productId)
        }

        setupProductImage(thumbnailUrl)
    }

    func setupColorSwatchSelector() {
        guard let productColors = product?.productColors, let productId = product?.id else {
            Log.warning("No product colors recieved to setup swatch selector.")
            return
        }

        colorSwatchSelectorView?.addTarget(self, action: #selector(colorSwatchSelected), for: .valueChanged)

        let swatchButtonTagsToImages = getSwatchButtonTagsToImageUrls(productColors, productId: productId)

        colorSwatchSelectorView?.updateSwatchTagsAndImages(swatchButtonTagsToImages)
    }

    func getSwatchButtonTagsToImageUrls(_ productColors: [PoqProductColor], productId: Int) -> [(Int, String)] {

        var productColors = productColors
        let maxSwatchesToDisplay = Int(AppSettings.sharedInstance.plpMaxSwatchesToDisplay)

        // If the product displayed is not in the startIndex maxSwatchesDispay product colors, move it to the start
        if let indexOfCurrentProduct = productColors.index(where: { $0.productID == productId }), indexOfCurrentProduct > maxSwatchesToDisplay {
            productColors.swapAt(0, indexOfCurrentProduct)
        }

        var swatchButtonTagsToImages = [(Int, String)]()
        let swatchProductColors = Array(productColors.prefix(maxSwatchesToDisplay))
        for swatchProductColor in swatchProductColors {
            if let productId = swatchProductColor.productID,
                let imageUrl = swatchProductColor.imageUrl,
                let thumbnailUrl = swatchProductColor.thumbnailUrl {

                swatchButtonTagsToImages.append((productId, imageUrl))
                productIdToThumbnailUrl[productId] = thumbnailUrl
            }
        }
        return swatchButtonTagsToImages
    }

    @objc func colorSwatchSelected(_ colorSwatchSelector: ColorSwatchSelectorView) {

        if let productId = product?.id,
            let selectedProductId = colorSwatchSelector.selectedSwatchTag,
            let productColor = product?.getProductColor(forProduct: product, productColorProductId: selectedProductId) {

            setupProductImage(productColor.thumbnailUrl, animated: true)

            if let selectedColorProductId = productColor.productID {
                colorChangeDelegate?.colorSelected( productColor.title ?? "", productId: productId, externalId: product?.externalID ?? "", selectedColorProductId: selectedColorProductId)
            }

            updateWishlistIconStatus(productColor.productID)
        }
    }

    func updateWishlistIconStatus(_ productId: Int?) {
        guard let productIdUnwrapped = productId else {
            return
        }

        likeButton?.isSelected = WishlistController.shared.isFavorite(productId: productIdUnwrapped)
    }

    func setupPromotionArea(_ promotionText: String) {

        self.promotionTextLabel?.text = promotionText

        promotionDetailIndicatorImageView?.isHidden = true

        self.promotionTextArea?.backgroundColor = AppTheme.sharedInstance.promotionAreaColor

        // Add click events to promotion text container if it's not a badge
        if !(product?.isBadge ?? false) {
            let promotionTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductListViewCell.promotionTapped(_:)))
            promotionTapGesture.delegate = self
            self.promotionTextArea?.addGestureRecognizer(promotionTapGesture)
            promotionDetailIndicatorImageView?.isHidden = false
        }
    }

    public func setupPriceLabel(_ price: String, font: UIFont = AppTheme.sharedInstance.priceFont, textColor: UIColor = AppTheme.sharedInstance.singlePriceTextColor) {
        priceLabel?.font = font
        priceLabel?.textColor = textColor
        priceLabel?.text = price
        priceLabel?.accessibilityIdentifier = AccessibilityLabels.priceString
    }

    public func setupSpecialPriceLabel(_ specialPrice: String, font: UIFont = AppTheme.sharedInstance.specialPriceFont, textColor: UIColor = AppTheme.sharedInstance.specialPriceTextColor) {
        specialPriceLabel?.font = font
        specialPriceLabel?.textColor = textColor
        specialPriceLabel?.text = specialPrice
    }

    open func setupProductImage(_ thumbnailUrlString: String?, animated: Bool = false) {
        guard let thumbnailUrlStringUnwrapped = thumbnailUrlString, let thumbnailURL = URL(string: thumbnailUrlStringUnwrapped) else {
                Log.warning("Attempt to set image with incorrect image url format \(String(describing: thumbnailUrlString))")
                return
        }
        productImage?.fetchImage(from: thumbnailURL, shouldDisplaySkeleton: ProductListViewCell.isSkeletonImageEnabled, isAnimated: animated, showLoading: false)
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        productImage.prepareForReuse()
        colorSwatchSelectorView?.prepareForReuse()
        specialPriceLabel?.text = nil
        promotionTextArea?.gestureRecognizers?.forEach {
            promotionTextArea?.removeGestureRecognizer($0)
        }
    }

    @objc open func promotionTapped(_ gesture: UIGestureRecognizer) {

        if gesture.view != nil {

            togglePromotionText()
        }
    }

    open func updatePromotionTextContainerHeight() {

        if isPromotionOpen {

            if let promotionTextLabel = promotionTextLabel {

                // Update promotionText container height (+10 to cover padding)
                var newHeight = heightForView(product?.promotion, font: AppTheme.sharedInstance.promotionLabelFont, width: promotionTextLabel.bounds.width)

                let fullHeight = productImage.bounds.size.height + 10

                // If the label height is greater than the full height, then shrink to the full height
                newHeight = newHeight > fullHeight ? fullHeight : newHeight

                promotionTextAreaHeight?.constant = newHeight
            }
        } else {
            // Update promotionText container height
            promotionTextAreaHeight?.constant = originalHeight
        }
    }

    open func togglePromotionText() {

        guard let product = self.product else {
            return
        }
        delegate?.toggleExpandedProduct(product)

        UIView.animate(withDuration: 0.2, animations: {

            self.updatePromotionTextContainerHeight()
            self.promotionTextArea?.superview?.layoutIfNeeded()
            self.promotionTextArea?.layoutIfNeeded()
            self.promotionTextLabel?.layoutIfNeeded()
            }, completion: { done in
                if done {
                    self.promotionDetailIndicatorImageView?.image = self.isPromotionOpen ? ImageInjectionResolver.loadImage(named: "Minus") : ImageInjectionResolver.loadImage(named: "Plus")
                }
        })
    }

    // Heart icon on top left

    @IBAction func likeButtonClicked(_ sender: UIButton) {

        guard let existedLikeButton: UIButton = likeButton else {
            return
        }

        guard let product = product else {
            Log.error("No product available to add or remove from wishlist")
            return
        }

        if !existedLikeButton.isSelected {

            // If Color swatch selection is enabled and the user has picked a color swatch then update with the selectedColor Product Id
            if let selectedColorProductId = product.selectedColorProductID, AppSettings.sharedInstance.isPlpColorSwatchesEnabled {

                WishlistController.shared.add(product: product.getColourProduct(selectedColorProductId))

            } else {

                WishlistController.shared.add(product: product)
            }
            existedLikeButton.isSelected = true
            self.product?.isFavorite = true

            if let productTitle = product.title {
                // Track add to shoppinglist
                
                let valuePrice: Double = product.trackingPrice
                PoqTrackerHelper.trackAddToWishList(productTitle, value: valuePrice, extraParams: ["Screen": "PLP"])
            }
        } else {

             if let selectedColorProductId = product.selectedColorProductID, AppSettings.sharedInstance.isPlpColorSwatchesEnabled {

                WishlistController.shared.remove(productId: selectedColorProductId)

                existedLikeButton.isSelected = false

                product.isFavorite = false

             } else if let productId = product.id {
                WishlistController.shared.remove(productId: productId)

                existedLikeButton.isSelected = false

                product.isFavorite = false
            }
        }
    }
}

extension ProductListViewCell: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

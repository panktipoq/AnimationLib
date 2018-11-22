//
//  BagItemTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/23/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

public protocol BagItemTableViewCellDelegate: AnyObject {
    
    /// Should update the view's total item count and cost.
    /// TODO: Instead, this should be more generic and the cell should not know about this.
    /// TODO: Instead, the cell should notify the controller of an event and the controller should decide what to do.
    func updateTotals()
    
    /// Should remove the specified `PoqBagItem` from the view.
    /// TODO: Instead, the cell should notify that it wants to be removed so that the controller can decide what to do.
    /// - parameter item: The bag item to remove.
    func removeBagItem(_ item: PoqBagItem)
}

open class BagItemTableViewCell: UITableViewCell {
    
    public static let sizeColorLabelAccessibilityId = "sizeColorLabelAccessibilityId"
    public static let titleLabelAccessibilityId = "titleLabelAccessibilityId"
    public static let quantityLabelAccessibilityId = "quantityLabelAccessibilityId"
    public static let plusButtonAccessibilityId = "plusButtonAccessibilityId"
    public static let minusButtonAccessibilityId = "minusButtonAccessibilityId"

    final var productCellHeight = CGFloat(AppSettings.sharedInstance.bagProductCellHeight)
    
    // MARK: - IBOutlets
    @IBOutlet open weak var productImage: PoqAsyncImageView?
    
    @IBOutlet open weak var buyAndCollect: Tick?
    @IBOutlet open weak var ukAndIrelandDelivery: Tick?
    @IBOutlet open weak var internationalDelivery: Tick?
    
    @IBOutlet open weak var brandNameLabel: UILabel?
    @IBOutlet open weak var productNameLabel: UILabel? {
        didSet {
            productNameLabel?.isAccessibilityElement = true
            productNameLabel?.accessibilityIdentifier = BagItemTableViewCell.titleLabelAccessibilityId
        }
    }
    @IBOutlet open weak var sizeColorLabel: UILabel? {
        didSet {
            sizeColorLabel?.isAccessibilityElement = true
            sizeColorLabel?.accessibilityIdentifier = BagItemTableViewCell.sizeColorLabelAccessibilityId
        }
    }
    @IBOutlet open weak var colorLabel: UILabel?
    @IBOutlet open weak var quantityLabel: UILabel? {
        didSet {
            quantityLabel?.isAccessibilityElement = true
            quantityLabel?.accessibilityIdentifier = BagItemTableViewCell.quantityLabelAccessibilityId
        }
    }
    @IBOutlet open weak var subTotalLabel: UILabel?
    @IBOutlet open weak var priceLabel: UILabel?
    @IBOutlet open weak var sizeLabel: UILabel?
    // Buttons
    @IBOutlet open weak var plusButton: PlusButton? {
        didSet {
            plusButton?.isAccessibilityElement = true
            plusButton?.accessibilityIdentifier = BagItemTableViewCell.plusButtonAccessibilityId
        }
    }
    @IBOutlet open weak var minusButton: MinusButton? {
        didSet {
            minusButton?.isAccessibilityElement = true
            minusButton?.accessibilityIdentifier = BagItemTableViewCell.minusButtonAccessibilityId
        }
    }
    @IBOutlet open weak var closeButton: CloseButton? {
        didSet {
            closeButton?.isHidden = true
        }
    }
    
    @IBOutlet weak var buyAndCollectLabel: UILabel?
    @IBOutlet weak var ukAndIrelandDeliveryLabel: UILabel?
    @IBOutlet weak var internationalDeliveryLabel: UILabel?
    
    @IBOutlet weak var unavailableLabel: UILabel? {
        didSet {
            unavailableLabel?.font = AppTheme.sharedInstance.unavailableLabelFont
            unavailableLabel?.textColor = AppTheme.sharedInstance.unavailableLabelTextColor
            sizeLabel?.textColor = AppTheme.sharedInstance.bagSizeColorLabelColor
            sizeLabel?.font = AppTheme.sharedInstance.bagSizeColorLabelFont
        }
    }
    @IBOutlet weak var unavailableLabelHeightConstraint: NSLayoutConstraint?
    
    // MARK: - variables
    public final var quantity: Int = 0
    public final weak var delegate: BagItemTableViewCellDelegate?
    public final var bagItem: PoqBagItem?
    
    public static var UnavailableLabelHeight: CGFloat = 25.0
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addOutOfStockMessageConstraint()
        
        colorLabel?.textColor = AppTheme.sharedInstance.bagSizeColorLabelColor
        colorLabel?.font = AppTheme.sharedInstance.bagSizeColorLabelFont
        
        productImage?.isAccessibilityElement = true
        productImage?.accessibilityLabel = AccessibilityLabels.productImage
        productImage?.accessibilityTraits = UIAccessibilityTraitImage
        
        plusButton?.isAccessibilityElement = true
        plusButton?.accessibilityLabel = AccessibilityLabels.plus
        plusButton?.accessibilityTraits = UIAccessibilityTraitButton
        
        minusButton?.isAccessibilityElement = true
        minusButton?.accessibilityLabel = AccessibilityLabels.minus
        minusButton?.accessibilityTraits = UIAccessibilityTraitButton
    }
    
    open func addOutOfStockMessageConstraint() {
        // Add clear subview with he
        let sizeView = UIView()
        sizeView.backgroundColor = UIColor.clear
        sizeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeView)
        contentView.sendSubview(toBack: sizeView)
        
        // If size of cell depends on available/unavailable
        // We will set it dependence in constraint
        let additionalView: UIView? = unavailableLabelHeightConstraint == nil ? nil : unavailableLabel
        let attribute: NSLayoutAttribute = unavailableLabelHeightConstraint == nil ? NSLayoutAttribute.notAnAttribute : NSLayoutAttribute.height
        
        let constraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsForView(sizeView, withInsetsInContainer: UIEdgeInsets.zero)
        contentView.addConstraints(constraints)
        let cellHeightLayoutConstraint = NSLayoutConstraint(item: sizeView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: additionalView,
            attribute: attribute,
            multiplier: 1,
            constant: productCellHeight)
        contentView.addConstraint(cellHeightLayoutConstraint)
    }
    
    open func setCellData(_ bagItem: PoqBagItem, isEditing: Bool) {
        self.bagItem = bagItem
        
        var unavailableText = bagItem.isUnavailable() ? AppLocalization.sharedInstance.bagUnavailableItemMessage : ""
        unavailableLabel?.text = unavailableText
        unavailableLabelHeightConstraint?.constant = unavailableText.isNullOrEmpty() ? 0 : BagItemTableViewCell.UnavailableLabelHeight
        
        guard let product = bagItem.product else {
            return
        }
        
        if let thumbnailUrl = product.thumbnailUrl.flatMap({ URL(string: $0) }) {
            productImage?.fetchImage(from: thumbnailUrl, isAnimated: false)
        }
        
        if let brandNameLabel = brandNameLabel {
            brandNameLabel.text = product.brand
            brandNameLabel.textColor = AppTheme.sharedInstance.plpBrandLabelColor
            brandNameLabel.font = AppTheme.sharedInstance.plpBrandLabelFont
        }
        
        productNameLabel?.text = product.title
        productNameLabel?.textColor = AppTheme.sharedInstance.bagProductTitleLabelColor
        productNameLabel?.font = AppTheme.sharedInstance.bagProductTitleLabelFont
        
        quantity = bagItem.quantity ?? 0
        quantityLabel?.font = AppTheme.sharedInstance.bagQtyFont
        quantityLabel?.textColor = AppTheme.sharedInstance.bagQtyColor
        
        priceLabel?.isHidden = AppSettings.sharedInstance.bagItemPriceHidden
        priceLabel?.attributedText = LabelStyleHelper.initPriceLabel(bagItem.priceOfOneItem,
            specialPrice: product.specialPrice,
            isGroupedPLP: false,
            priceFormat: AppSettings.sharedInstance.plpPriceFormat,
            priceFontStyle: AppTheme.sharedInstance.bagPriceFont,
            specialPriceFontStyle: AppTheme.sharedInstance.bagSpecialPriceFont
        )
        
        var sizeColorText = CheckoutHelper.getProductSize(bagItem.productSizeId, product: product)
        sizeLabel?.text = sizeColorText
        colorLabel?.text = product.color
        
        if let productColor = product.color {
            sizeColorText = !sizeColorText.isNullOrEmpty() ? sizeColorText + " " + productColor : productColor
        }
        
        sizeColorLabel?.text = sizeColorText
        sizeColorLabel?.textColor = AppTheme.sharedInstance.bagSizeColorLabelColor
        sizeColorLabel?.font = AppTheme.sharedInstance.bagSizeColorLabelFont
        
        if let buyCollectLabel = buyAndCollectLabel {
            buyCollectLabel.text = AppLocalization.sharedInstance.buyAndCollect
            buyCollectLabel.font = AppTheme.sharedInstance.bagDeliveryInfoLabelFont
            buyCollectLabel.isHidden = product.buyAndCollect != true
            buyAndCollect?.isHidden = product.buyAndCollect != true
        }
        
        if let ukIrelandDeliveryLabel = ukAndIrelandDeliveryLabel {
            ukIrelandDeliveryLabel.text = AppLocalization.sharedInstance.ukAndIrelandDelivery
            ukIrelandDeliveryLabel.font = AppTheme.sharedInstance.bagDeliveryInfoLabelFont
            ukIrelandDeliveryLabel.isHidden = product.homeDelivery != true
            ukAndIrelandDelivery?.isHidden = product.homeDelivery != true
        }
        
        if let interDeliveryLabel = internationalDeliveryLabel {
            interDeliveryLabel.text = AppLocalization.sharedInstance.internationalDelivery
            interDeliveryLabel.font = AppTheme.sharedInstance.bagDeliveryInfoLabelFont
            interDeliveryLabel.isHidden = product.internationalDelivery != true
            internationalDelivery?.isHidden = product.internationalDelivery != true
        }
        
        let price = bagItem.product?.specialPrice ?? bagItem.product?.price
        if let price = price, let quantity = bagItem.quantity {
            let total = price * Double(quantity)
            subTotalLabel?.attributedText = LabelStyleHelper.initSubTotalLabel(total)
        }
        
        updateEditingState(isEditing)
        
        unavailableText = product.isOutOfStock() ? AppLocalization.sharedInstance.bagOutOfStockMessage : unavailableText
        
        // Check if the product id is minus, that means the product is not in our system. so we need to show a message where the product info is not available.
        if let productId = product.id, productId < 0, unavailableText.isNullOrEmpty() {
            unavailableText = AppLocalization.sharedInstance.bagProductInfoNotAvailableMessage

            // Disable interactions only for Products with negative IDs
            // That are NOT marked as isExternal
            // ----
            // Products isExternal are eligible for update/delete
            let isExternal = bagItem.isExternal ?? false
            isUserInteractionEnabled = isExternal
        }
        
        unavailableLabel?.text = unavailableText
    }
    
    open func updateEditingState(_ editing: Bool) {
        // Enable them all first
        if editing {
            plusButton?.isHidden = !editing
            minusButton?.isHidden = !editing
            
            // Extra checking for minus button if qty = 1
            enableDisableMinusButton()
            
            closeButton?.isHidden = !editing
        }
        
        let price = bagItem?.product?.specialPrice ?? bagItem?.product?.price
        if editing {
            quantityLabel?.text = String(format: "%d", bagItem?.quantity ?? 0)
            quantityLabel?.textAlignment = NSTextAlignment.center
        }

        // Then have fade in and fade out animation
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.plusButton?.alpha = editing ? 1.0 : 0.0
            self.minusButton?.alpha = editing ? 1.0 : 0.0
            self.closeButton?.alpha = editing ? 1.0 : 0.0
            
            }, completion: { _ in
                if let price = price, let quantity = self.bagItem?.quantity, !editing {
                    self.quantityLabel?.textAlignment = NSTextAlignment.left
                    self.quantityLabel?.text = LabelStyleHelper.initQuantityLabel(quantity: quantity, priceOfItem: price)
                }
        })
    }
    
    @IBAction open func plusButtonClicked() {
        quantity += 1
        self.bagItem?.quantity = quantity
        self.quantityLabel?.text = String(quantity)
        
        updateSubtotalLabelText()
        enableDisableMinusButton()
        delegate?.updateTotals()
    }
    
    @IBAction open func minusButtonClicked() {
        if quantity == 1 {
            return
        }
        
        quantity -= 1
        self.bagItem?.quantity = quantity
        self.quantityLabel?.text = String(quantity)
        
        updateSubtotalLabelText()
        enableDisableMinusButton()
        delegate?.updateTotals()
    }
    
    @IBAction open func closeButtonClicked(_ sender: Any?) {
        guard let bagItem = bagItem else {
            return
        }
        
        delegate?.removeBagItem(bagItem)
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        
        productImage?.prepareForReuse()
    }
    
    open func enableDisableMinusButton() {
        // Extra checking for minus button if qty = 1
        minusButton?.isEnabled = self.bagItem?.quantity != 1
    }
    
    open func updateSubtotalLabelText() {
        let price = self.bagItem?.product?.specialPrice ?? self.bagItem?.product?.price
        if let price = price, let quantity = self.bagItem?.quantity {
            let total: Double =  price * Double(quantity)
            self.subTotalLabel?.attributedText = LabelStyleHelper.initSubTotalLabel(total)
        }
    }
}

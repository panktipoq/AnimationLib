//
//  CartItemTableViewCell.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import Cartography
import PoqPlatform
import PoqUtilities

/**
 
  This class is a UITableViewCell subclass that can present a Cart Item
 
  Subclass this cell and override the initBagItemView method to provide your custom UIView that conforms to CartItemViewPresentable to present a different representation of a Cart item
 */
class CartItemTableViewCell: UITableViewCell, ViewEditable {
    
    public static let accessibilityIdentifierPrefix = "BagItemTableViewCell_"
    public static let productInfoViewAccessibilityIdentifierPrefix = "CartItemProductInfoView_"
    public static let priceLabelAccessibilityIdentifierPrefix = "CartItemPriceLabel_"
    public static let quantityInfoViewAccessibilityIdentifierPrefix = "CartItemQuantityInfoView_"
    public static let stockMessageLabelAccessibilityIdentifierPrefix = "CartItemStockMessageLabel_"
    
    var productImageView: PoqAsyncImageView?
    var productInfoView: (UIView & ProductInfoViewPresentable)?
    var stockMessageLabel: UILabel?
    var priceLabel: UILabel?
    var quantityView: (UIView & QuantityViewPresentable)?
    
    var cartItem: CartItemViewDataRepresentable?
    weak var presenterDelegate: CartCellPresenter?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: .value2, reuseIdentifier: reuseIdentifier)

        translatesAutoresizingMaskIntoConstraints = false

        initSubviews()
        
        addSubviews()

        setupStyles()
        
        layoutBagItemView()
        
        setupSubviewActions()
    }
    
    /// This method initialises all the subviews of the CartItemTableViewCell
    /// Override this method to setup you custom subviews
    open func initSubviews() {
        
        // This CGRect for PoqAsyncImageView needs to be a non-zero value as the Haneke Cache library method to fetch image uses the view frame to size the image.
        productImageView = PoqAsyncImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        productImageView?.contentMode = .scaleAspectFit
        
        productInfoView = ProductInfoView(frame: CGRect.zero)
        quantityView = QuantityView(frame: CGRect.zero)
        priceLabel = UILabel(frame: CGRect.zero)
        stockMessageLabel = UILabel(frame: CGRect.zero)
    }
    
    /// This method adds the subviews of the CartItemTableViewCell
    /// Override this method to add your custom subviews
    open func addSubviews() {
        
        guard let productInfoView = productInfoView, let productImageView = productImageView, let priceLabel = priceLabel, let quantityView = quantityView, let stockMessageLabel = stockMessageLabel else {
            assertionFailure("Subviews not initialised")
            return
        }
        
        contentView.addSubview(productImageView)
        contentView.addSubview(productInfoView)
        contentView.addSubview(quantityView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(stockMessageLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupSubviewActions() {
        
        quantityView?.editQuantityAction = { [weak self] updatedQuantity in
            
            guard let cartItemId = self?.cartItem?.id else {
                Log.error("Unable to fetch cart item Id. Cannot delete cell")
                return
            }
            
            self?.presenterDelegate?.updateQuantity(of: cartItemId, to: updatedQuantity)
        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        cartItem = nil
    }
    
    /// This method toggles the edit mode on CartItemTableViewCell and it's subviews
    ///
    /// - Parameters:
    ///   - editing: A boolean indicating whether the Cart screen is in edit mode
    ///   - animate: A boolean indicating whether the transition to edit mode is to be animated
    open func setEditMode(to editing: Bool, animate: Bool) {

        quantityView?.setEditMode(to: editing, animate: animate)
        
        priceLabel?.textColor = editing ? UIColor.hexColor("#D6D6D6") : UIColor.black
        
        if animate {
            
            UIView.animate(withDuration: 0.5) { self.layoutIfNeeded() }
            
        } else {
            
            layoutIfNeeded()
        }
    }
    
    /// This method is used to set the CartItemTableViewCell up with content and a delegate
    ///
    /// - Parameters:
    ///   - contentItem: The content item that is to presented by the cell
    ///   - delegate: The presenter delegate to be used by the cell
    open func setup(with contentItem: CartItemViewDataRepresentable, delegate: CartCellPresenter?) {
        
        cartItem = contentItem
        presenterDelegate = delegate
        
        accessibilityIdentifier = CartItemTableViewCell.accessibilityIdentifierPrefix + contentItem.id
        productInfoView?.accessibilityIdentifier = CartItemTableViewCell.productInfoViewAccessibilityIdentifierPrefix + contentItem.id
        quantityView?.accessibilityIdentifier = CartItemTableViewCell.quantityInfoViewAccessibilityIdentifierPrefix + contentItem.id
        priceLabel?.accessibilityIdentifier = CartItemTableViewCell.priceLabelAccessibilityIdentifierPrefix + contentItem.id
        stockMessageLabel?.accessibilityIdentifier = CartItemTableViewCell.stockMessageLabelAccessibilityIdentifierPrefix + contentItem.id
            
        if let imageUrl = contentItem.productImageUrl, let url = URL(string: imageUrl) {
            
            productImageView?.fetchImage(from: url, shouldDisplaySkeleton: true, isAnimated: true, showLoading: false)
        }
        
        let productTitleInfo = ProductTitleInfo(productTitle: contentItem.productTitle, brand: contentItem.brandName, color: contentItem.color, size: contentItem.size)
        productInfoView?.setup(with: productTitleInfo)
        
        priceLabel?.text = contentItem.total
        
        stockMessageLabel?.text = contentItem.isInStock ? nil : "OUT_OF_STOCK_MESSAGE".localizedPoqString
        
        quantityView?.setup(with: contentItem.quantity, price: contentItem.nowPrice)
        
    }
    
    open func setupStyles() {
        
        stockMessageLabel?.textColor = UIColor.hexColor("#F93037")
        stockMessageLabel?.font = UIFont(name: "HelveticaNeue", size: 12.0)
    }

    /// This method lays out the contraints of the cell
    open func layoutBagItemView() {

        guard let productImageView = productImageView, let productInfoView = productInfoView, let priceLabel = priceLabel, let quantityView = quantityView, let stockMessageLabel = stockMessageLabel else {
            fatalError("Views not initialised")
        }
        
        stockMessageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        constrain( contentView, productImageView, productInfoView as UIView, priceLabel, quantityView as UIView, stockMessageLabel) { contentView, productImageView, productInfoView, priceLabel, quantityView, stockMessageLabel in

            // ProductTitleView Constraints
            productInfoView.trailing == contentView.trailing ~ .required
            productInfoView.top == contentView.top + 20
            productInfoView.leading == productImageView.trailing + 10
            productInfoView.leading == contentView.leading + 149

            stockMessageLabel.top == productInfoView.bottom + 40 ~ .required
            stockMessageLabel.bottom == quantityView.top - 20 ~ .required
            stockMessageLabel.trailing == contentView.trailing ~ .required
            
            quantityView.bottom == contentView.bottom - 20 ~ .required

            // PriceLabel Constraints
            align(leading: productInfoView, stockMessageLabel, quantityView)

            // QuantityView Constraints
            priceLabel.leading >= quantityView.trailing + 4 ~ .required
            align(top: quantityView, priceLabel)
            priceLabel.trailing == contentView.trailing - 10 ~ .required
            priceLabel.height == quantityView.height ~ .required
            priceLabel.bottom == contentView.bottom - 20 ~ .required

            // ImageView Constraints
            productImageView.top == contentView.top + 20
            productImageView.leading == contentView.leading + 10
            productImageView.height == productImageView.width * 1.2
            productImageView.bottom <= contentView.bottom - 20
        }
    }
}

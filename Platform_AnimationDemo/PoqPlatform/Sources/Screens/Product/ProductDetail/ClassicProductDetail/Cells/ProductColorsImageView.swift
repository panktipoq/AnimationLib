//
//  ProductColorsImageView.swift
//  Poq.iOS
//
//  Created by GabrielMassana on 19/12/2016.
//
//

import PoqNetworking
import UIKit

protocol ProductColorsImageViewDelegate: AnyObject {
        
    func willUpdateProductDetailSelectedColor(_ selectedColor: String, productId: Int, externalId: String)
}

class ProductColorsImageView: UIView {
    
    // MARK: - Properties
    
    let poqProductColors: [PoqProductColor]
    let product: PoqProduct
    
    /// Delegate object
    weak var delegate: ProductColorsImageViewDelegate?
    
    /// Index match the button tag value.
    var selectedColorIndex: Int = 0
    
    /// Array with all the buttons allocated in the view.
    var buttons: [UIButton] = []
    
    // AppSettings and AppTheme
    let pdpProductColorImageSize = AppSettings.sharedInstance.pdpProductColorImageSize
    let pdpProductColorImagePaddingBetween = AppSettings.sharedInstance.pdpProductColorImagePaddingBetween
    let pdpProductColorsViewHeight: CGFloat = AppSettings.sharedInstance.pdpProductColorsViewHeight
    
    // Set scroll x value
    var colorElementX: CGFloat = AppSettings.sharedInstance.pdpProductColorImagePaddingBetween
    
    lazy var swatchButtonImageSize: CGFloat = {
        
        return self.pdpProductColorImageSize + (self.pdpProductColorImagePaddingBetween * 2)
    }()
    
    lazy var swatchButtonImageCornerRadius: CGFloat = {
        
        return self.swatchButtonImageSize / 2
    }()
    
    // MARK: - Init
    
    init(frame: CGRect, poqProductColors: [PoqProductColor], product: PoqProduct) {
        
        self.poqProductColors = poqProductColors
        self.product = product
        
        super.init(frame: frame)

        setUpView(poqProductColors,
                  product: product)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetUpView
    
    func setUpView(_ poqProductColors: [PoqProductColor], product: PoqProduct) {
        
        // Add available image colors
        for index in 0 ..< poqProductColors.count {
            
            let validProductColor: PoqProductColor = poqProductColors[index]
            guard let validProductID = validProductColor.productID else {
                    return
            }
            
            let swatchImageViewFrame = CGRect(x: colorElementX + pdpProductColorImagePaddingBetween,
                                                  y: pdpProductColorImagePaddingBetween,
                                                  width: pdpProductColorImageSize,
                                                  height: pdpProductColorImageSize)
            
            let swatchImageView = PoqAsyncImageView(frame: swatchImageViewFrame)
            
            swatchImageView.clipsToBounds = true
            swatchImageView.layer.cornerRadius = AppSettings.sharedInstance.pdpProductColorImageCornerRadius
            swatchImageView.layer.borderWidth = AppSettings.sharedInstance.pdpProductColorImageBorderWidth
            swatchImageView.layer.borderColor = AppTheme.sharedInstance.colorSwatchImageBorder.cgColor
            
            let swatchButtonFrame = CGRect(x: colorElementX,
                                               y: 0.0,
                                               width: swatchButtonImageSize,
                                               height: swatchButtonImageSize)
            
            let swatchButton = UIButton(frame: swatchButtonFrame)
            swatchButton.layer.cornerRadius = swatchButtonImageCornerRadius
            swatchButton.clipsToBounds = true
            swatchButton.layer.borderColor = AppTheme.sharedInstance.colorSwatchSelectorBorder.cgColor
            swatchButton.addTarget(self, action: #selector(swatchButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            
            // Check matching product id.
            if product.id == validProductID {
                self.selectedColorIndex = index
                swatchButton.layer.borderWidth = CGFloat(AppTheme.sharedInstance.colorSwatchSelectorBorderWidth)
            }
            
            swatchButton.tag = index
            
            guard let validImageURL = validProductColor.imageUrl,
                let url = URL(string: validImageURL) else {
                    return
            }
            
            swatchImageView.getImageFromURL(url, isAnimated: true)
            
            self.buttons.append(swatchButton)
            
            addSubview(swatchImageView)
            addSubview(swatchButton)
            
            colorElementX = colorElementX + swatchButtonImageSize + pdpProductColorImagePaddingBetween
        }
        
        // Update view frame
        frame = CGRect(x: 0.0, y: 0.0, width: colorElementX, height: pdpProductColorsViewHeight)
    }
    
    // MARK: - ButtonActions
    
    @objc func swatchButtonPressed(_ sender: UIButton) {
        
        // Unselect old button
        let oldButton: UIButton = self.buttons[selectedColorIndex]
        oldButton.layer.borderWidth = 0
        
        // Select tapped button
        sender.layer.borderWidth = CGFloat(AppTheme.sharedInstance.colorSwatchSelectorBorderWidth)
        
        selectedColorIndex = sender.tag
        
        let currentProduct: PoqProduct = product
        guard let productColors: [PoqProductColor] = currentProduct.productColors, productColors.count > selectedColorIndex else {
                return
        }
        
        let selectedColor: PoqProductColor = productColors[selectedColorIndex]
        
        guard let title = selectedColor.title,
            let externalId = selectedColor.externalID,
            let productId = selectedColor.productID else {
                return
        }
        
        // Callback to update selected button
        delegate?.willUpdateProductDetailSelectedColor(title,
                                                       productId: productId,
                                                       externalId: externalId)
    }
}

//
//  ProductColorsTitleView.swift
//  Poq.iOS
//
//  Created by GabrielMassana on 19/12/2016.
//
//

import PoqNetworking
import UIKit

protocol ProductColorsTitleViewDelegate: AnyObject {
    
    /**
     Callback to update the selected Product Color.
     
     - Parameter selectedColor: color title attribute.
     - Parameter productId: productID.
     - Parameter externalId: externalId.
     */
    func willUpdateProductDetailSelectedColor(_ selectedColor: String, productId: Int, externalId: String)
}

class ProductColorsTitleView: UIView {

    // MARK: - Properties
    
    let poqProductColors: [PoqProductColor]
    let product: PoqProduct
    
    /// Delegate object
    weak var delegate: ProductColorsTitleViewDelegate?
    
    /// Index match the button tag value.
    var selectedColorIndex: Int = 0

    /// Array with all the buttons allocated in the view.
    var buttons: [UIButton] = []

    // AppSettings and AppTheme
    let pdpProductColorTitleColor = AppTheme.sharedInstance.pdpProductColorTitleColor
    let pdpProductColorTitleFont = AppTheme.sharedInstance.pdpProductColorTitleFont
    let pdpProductColorTitleHorizontalPadding = AppSettings.sharedInstance.pdpProductColorTitleHorizontalPadding
    let pdpProductColorTitleMinimumHorizontalSize = AppSettings.sharedInstance.pdpProductColorTitleMinimumHorizontalSize
    let pdpProductColorTitleVerticalSize = AppSettings.sharedInstance.pdpProductColorTitleVerticalSize
    let pdpProductColorTitlePaddingBetween = AppSettings.sharedInstance.pdpProductColorTitlePaddingBetween
    let pdpProductColorsViewHeight: CGFloat = AppSettings.sharedInstance.pdpProductColorsViewHeight

    // Set scroll x value
    var colorElementX: CGFloat = AppSettings.sharedInstance.pdpProductColorTitlePaddingBetween
    
    lazy var swatchButtonFrameTitleY: CGFloat = {
        
        return (self.pdpProductColorsViewHeight - self.pdpProductColorTitleVerticalSize) / 2
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
        
        // Add available title colors
        for index in 0 ..< poqProductColors.count {
            
            let validProductColor: PoqProductColor = poqProductColors[index]
            guard let validProductID = validProductColor.productID else {
                    
                    return
            }
            
            guard let validShortTitle = validProductColor.shortTitle else {
                return
            }
            
            let size = validShortTitle.sizeForText(font: pdpProductColorTitleFont,
                                                   boundingRectSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            
            var swatchButtonWidth = size.width + (pdpProductColorTitleHorizontalPadding * 2)
            
            if swatchButtonWidth < pdpProductColorTitleMinimumHorizontalSize {
                
                swatchButtonWidth = pdpProductColorTitleMinimumHorizontalSize
            }
            
            let swatchButtonFrame = CGRect(x: colorElementX,
                                               y: swatchButtonFrameTitleY,
                                               width: swatchButtonWidth,
                                               height: pdpProductColorTitleVerticalSize)
            
            let swatchButton = UIButton(frame: swatchButtonFrame)
            swatchButton.layer.cornerRadius = AppSettings.sharedInstance.pdpProductColorTitleCornerRadius
            swatchButton.layer.borderWidth = AppSettings.sharedInstance.pdpProductColorTitleBorderWidth
            swatchButton.clipsToBounds = true
            swatchButton.titleLabel?.font = pdpProductColorTitleFont
            swatchButton.layer.borderColor = AppTheme.sharedInstance.pdpProductColorTitleBorderColor.cgColor
            swatchButton.addTarget(self,
                                   action: #selector(swatchButtonPressed(_:)),
                                   for: UIControlEvents.touchUpInside)
            
            swatchButton.setTitle(validShortTitle,
                                  for: UIControlState())
            
            swatchButton.setTitleColor(pdpProductColorTitleColor,
                                       for: UIControlState())
            
            swatchButton.setTitleColor(UIColor.white,
                                       for: .selected)
            
            // Check matching product id.
            if product.id == validProductID {
                self.selectedColorIndex = index
                swatchButton.isSelected = true
                swatchButton.backgroundColor = pdpProductColorTitleColor
            }
            
            swatchButton.tag = index
            
            buttons.append(swatchButton)
            
            addSubview(swatchButton)
            
            colorElementX += swatchButtonWidth + pdpProductColorTitlePaddingBetween
        }
        
        // Update view frame
        frame = CGRect(x: 0.0, y: 0.0, width: colorElementX, height: pdpProductColorsViewHeight)
    }
    
    // MARK: - ButtonActions
    
    @objc func swatchButtonPressed(_ sender: UIButton) {
        
        // unselect old button
        let oldButton: UIButton = self.buttons[selectedColorIndex]
        oldButton.isSelected = false
        oldButton.backgroundColor = UIColor.clear
        
        // select tapped button
        sender.isSelected = true
        sender.backgroundColor = AppTheme.sharedInstance.pdpProductColorTitleColor
        
        selectedColorIndex = sender.tag

        guard let productColors: [PoqProductColor] = product.productColors, productColors.count > selectedColorIndex else {
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

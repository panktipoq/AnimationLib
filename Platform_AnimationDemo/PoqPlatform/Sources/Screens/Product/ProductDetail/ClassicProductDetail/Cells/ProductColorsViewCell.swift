//
//  ProductColorsViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

open class ProductColorsViewCell: UITableViewCell {
    
    //MARK - Properties

    static let XibName:String = "ProductColorsViewCell"
    
    @IBOutlet weak var colorScrollView: UIScrollView! {
        
        didSet {
            
            colorScrollView.frame = CGRect(x: colorScrollView.frame.origin.x,
                                           y: colorScrollView.frame.origin.y,
                                           width: ScreenSize.SCREEN_WIDTH,
                                           height: colorScrollView.frame.height)
        }
    }
    
    var buttons:[UIButton] = []
    var selectedColorIndex:Int = 0
    var product:PoqProduct?
    weak var productDetailDelegate: ProductColorsDelegate?
    
    var productColorsView: UIView?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Setup
    
    func setup(using product: PoqProduct) {
        
        self.product = product
        
        guard let validProductColors = product.productColors else {
        
            return
        }
        
        // Remove previous views to support reloading the current view
        for view in self.colorScrollView!.subviews {
            view.removeFromSuperview()
        }
        
        let pdpProductColor = ProductColorsViewCell.productColor(AppSettings.sharedInstance.pdpProductColor)
        
        let pdpProductColorImagePaddingBetween = AppSettings.sharedInstance.pdpProductColorImagePaddingBetween
        let pdpProductColorsViewHeight: CGFloat = AppSettings.sharedInstance.pdpProductColorsViewHeight
        let pdpProductColorTitleMinimumHorizontalSize = AppSettings.sharedInstance.pdpProductColorTitleMinimumHorizontalSize
        let pdpProductColorTitlePaddingBetween = AppSettings.sharedInstance.pdpProductColorTitlePaddingBetween

        switch pdpProductColor {
            
        case .image:
            
            let width = (CGFloat(validProductColors.count) * (pdpProductColorsViewHeight + pdpProductColorImagePaddingBetween)) + pdpProductColorImagePaddingBetween
            let frame = CGRect(x: 0.0, y: 0.0, width: width, height: pdpProductColorsViewHeight)
            
            let productColorsImageView = ProductColorsImageView(frame: frame,
                                                                poqProductColors: validProductColors,
                                                                product: product)
            
            productColorsImageView.delegate = self
            productColorsView = productColorsImageView
            colorScrollView?.addSubview(productColorsImageView)
            
        case .title:
            
            let width = (CGFloat(validProductColors.count) * (pdpProductColorTitleMinimumHorizontalSize + pdpProductColorTitlePaddingBetween)) + pdpProductColorTitlePaddingBetween
            let frame = CGRect(x: 0.0, y: 0.0, width: width, height: pdpProductColorsViewHeight)
            
            let productColorsTitleView = ProductColorsTitleView(frame: frame,
                                                                poqProductColors: validProductColors,
                                                                product: product)
            
            productColorsTitleView.delegate = self
            productColorsView = productColorsTitleView
            colorScrollView?.addSubview(productColorsTitleView)
        }
        
        if let productColorsView = productColorsView {
            
            updateScrollViewWithCGSize(productColorsView.frame.size)
        }
    }
    
    //MARK: - PDPProductColor
    
    /// Cast server value into PDPProductColor enum
    static func productColor(_ productColorSettings: Double) -> PDPProductColor {
        
        if let productColor = PDPProductColor(rawValue: productColorSettings) {
            
            return productColor
        }
        else {
            
            return PDPProductColor.image
        }
    }
    
    //MARK: - ScrollView
    
    /// Updates and center ScrollView contentSize
    func updateScrollViewWithCGSize(_ size: CGSize) {
        
        colorScrollView?.contentSize = size
        
        if size.width < frame.width {
            
            alignScrollViewCenter()
        }
    }
    
    func alignScrollViewCenter(){
        // Center align
        let offsetX = (self.colorScrollView.contentSize.width / 2) - (self.bounds.size.width / 2)
        //self.colorScrollView?.contentOffset.x = offsetX
        self.colorScrollView?.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        //self.colorScrollView?.setNeedsDisplay()
    }
}

extension ProductColorsViewCell: ProductColorsTitleViewDelegate, ProductColorsImageViewDelegate {
    
    func willUpdateProductDetailSelectedColor(_ selectedColor: String, productId: Int, externalId: String) {
        
        productDetailDelegate?.colorSelected(selectedColor,
                                             productId: productId,
                                             externalId: externalId, selectedColorProductId: nil)
    }
}

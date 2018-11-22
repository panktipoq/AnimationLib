//
//  ColorSwatchButtonView.swift
//  ColorSwatchView
//
//  Created by Balaji Reddy on 17/12/2016.
//  Copyright © 2016 Balaji Reddy. All rights reserved.
//

import Foundation
import PoqUtilities
import UIKit

/// The color swatch button control
open class ColorSwatchButtonView: UIControl {
    
    /// The image view in which the color swatch is rendered
    @IBOutlet var colorSwatchImageView: PoqAsyncImageView?
    
    /// The button that matches the color swatch TODO: I think we can render the image inside the button in the future
    @IBOutlet var colorSwatchButton: UIButton?
    
    /// Wether or not the swatch is selected
    fileprivate(set) var isSwatchSelected: Bool = false
    
    /// Initializes the control with a given frame
    ///
    /// - Parameter frame: The frame for the control
    override public init(frame: CGRect) {
        super.init(frame: frame)
        prepareForUse()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        prepareForUse()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    /// Prepares the view for reuse
    open func prepareForUse() {
        
        colorSwatchButton?.addTarget(self, action: #selector(swatchButtonClicked(_:)), for: .touchUpInside)
        isHidden = true
    }
    
    /// Sets up the button and the image view
    open func setupView() {
        
        setupColorSwatchButtonView()
        setupColorSwatchImageView()

    }
    
    /// Sets the swatch as selected renders accordingly
    ///
    /// - Parameter isSwatchSelected: Wether or not the swatch is selected
    open func setSwatchSelected(_ isSwatchSelected: Bool) {
        
        colorSwatchButton?.layer.borderColor = isSwatchSelected ? AppTheme.sharedInstance.colorSwatchSelectorBorder.cgColor : UIColor.clear.cgColor
        colorSwatchButton?.isEnabled = isSwatchSelected ? false : true
        self.isSwatchSelected = isSwatchSelected
        
    }
    
    
    /// Sets up the color swatch visuals. Loads the image
    ///
    /// - Parameter urlString: The url of the color swatch image that is to be loaded
    open func setup(imageWithUrl urlString: String) {
        guard let url = URL(string: urlString) else {
            Log.warning("Incorrect swatch image URL received: \(urlString)")
            return
        }
        
        colorSwatchImageView?.layer.borderColor = AppTheme.sharedInstance.colorSwatchImageBorder.cgColor
        colorSwatchImageView?.layer.borderWidth = 0.5
        colorSwatchImageView?.fetchImage(from: url, showLoading: false)
        isHidden = false
    }
    
    /// Triggered when the swatch button has been clicked
    ///
    /// - Parameter sender: The object that dispatched the action
    @objc fileprivate func swatchButtonClicked(_ sender: AnyObject?) {
      
        setSwatchSelected(true)
        
        sendActions(for: .touchUpInside)
    }
    
    /// Sets up the round corner radius of the imageview TODO: Rename this to something more clear
    open func setupColorSwatchImageView() {
        colorSwatchImageView?.layer.cornerRadius = (colorSwatchImageView?.bounds.width ?? 2)/2
    }
    
    /// Sets up the round corner radius of the button TODO: Rename this to something more clear
    open func setupColorSwatchButtonView() {
        colorSwatchButton?.layer.cornerRadius = (colorSwatchButton?.bounds.width ?? 2)/2

    }
    
    /// Prepares the cell for reuse
    open func prepareForReuse() {
        isHidden = true
        setSwatchSelected(false)
        colorSwatchImageView?.prepareForReuse()
        
    }
    
    
    
    
}

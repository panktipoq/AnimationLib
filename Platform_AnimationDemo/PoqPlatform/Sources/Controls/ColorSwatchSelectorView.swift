//
//  ColorSwatchSelectorView.swift
//  ColorSwatchSelectorView
//
//  Created by Balaji Reddy on 17/12/2016.
//  Copyright © 2016 Balaji Reddy. All rights reserved.
//

import Foundation
import PoqUtilities
import UIKit

/// The control that handles the color swatch selection
open class ColorSwatchSelectorView: UIControl {
    
    /// The views for the color swatch selection
    fileprivate var swatchButtonViews: [ColorSwatchButtonView]?
    
    /// Spacing between the swatch buttons
    let spacing: CGFloat = 5.0
    
    /// The tag of the selected swatch
    open fileprivate(set) var selectedSwatchTag: Int?
    
    /// Sets a given swatch as selected
    ///
    /// - Parameter tag: The tag of the swatch that is going to be selected
    open func setSelectedSwatch(_ tag: Int) {
        
        guard tag != selectedSwatchTag else {
            return
        }
        
        guard let swatchButtonViews = swatchButtonViews else {
            Log.error("Attempt to set selected swatch without initialising swatch buttons.")
            return
        }
        
        getButtonViewWithTag(tag)?.setSwatchSelected(true)
        
        for swatchButton in swatchButtonViews {
            if tag != swatchButton.tag {
                swatchButton.setSwatchSelected(false)
            }
        }
        
        selectedSwatchTag = tag
    }
    
    /// The max number of swatch buttons
    open var maxButtons = Int(AppSettings.sharedInstance.plpMaxSwatchesToDisplay)
    
    /// Sets up the view 
    open func setupView() {
        
        swatchButtonViews = [ColorSwatchButtonView]()
        
        for _ in 0..<maxButtons {
            
            if let swatchButton = createSwatchButtonView() {
                swatchButtonViews?.append(swatchButton)
                addSubview(swatchButton)
            }
        }
        if preferredButtonWidth !=  nil {
            setButtonFramesForPreferredButtonWidth()
        }
    }
    
    /// Triggered when the subviews need to realign the layout
    override open func layoutSubviews() {
        super.layoutSubviews()
        if preferredButtonWidth ==  nil {
            setColorSwatchButtonFrames()
        }
    }
    
    /// Returns an instance of a color swatch button view, from the xib. Sets up the action
    ///
    /// - Returns: A instance of the color swatch button
    func createSwatchButtonView() -> ColorSwatchButtonView? {
        let colorSwatchButtonView = loadColorSwatchButtonViewFromNib()
        colorSwatchButtonView?.addTarget(self, action: #selector(swatchSelected), for: .touchUpInside)
        colorSwatchButtonView?.setSwatchSelected(false)
        return colorSwatchButtonView
    }
    
    /// Loads a color swatch button view from the xib
    ///
    /// - Returns: The color swatch button view
    func loadColorSwatchButtonViewFromNib() -> ColorSwatchButtonView? {
       
        let colorSwatchNibName = String(describing: ColorSwatchButtonView.self)
        
        guard let bundleOfColorSwatchButtonNib  = NibInjectionResolver.findBundle(nibName: colorSwatchNibName) else {
            Log.error("No nib found for ColorSwatchButtonView. Color swatches cannot be displayed.")
            return nil
        }

        guard let nibObjects = bundleOfColorSwatchButtonNib.loadNibNamed(colorSwatchNibName, owner: nil, options: nil) else {
            Log.error("No nib found for ColorSwatchButtonView. Color swatches cannot be displayed.")
            return nil
        }
        
        guard let indexOfColorSwatchButton =  nibObjects.index(where: { $0 is ColorSwatchButtonView }) else {
            Log.error("ColorSwatchButtonView could not be loaded from nib. Color swatches cannot be displayed.")
            return nil
        }
        
        return nibObjects[indexOfColorSwatchButton] as? ColorSwatchButtonView
    }
    
    /// Updates the swatch tags and images accordingly
    ///
    /// - Parameter swatchButtonTagsToImages: An array of tags and their respective images
    open func updateSwatchTagsAndImages(_ swatchButtonTagsToImages: [(tag: Int, swatchImageUrl: String)]) {
       
        guard swatchButtonTagsToImages.count > 0 && swatchButtonTagsToImages.count <= maxButtons else {
            Log.warning("Incorrect number of swatchButtonTagsToImages provided.")
            return
        }
        
        swatchButtonTagsToImages.enumerated().forEach() { index, swatchButtonTagToImage  in
            swatchButtonViews?[index].tag = swatchButtonTagToImage.tag
            swatchButtonViews?[index].setup(imageWithUrl: swatchButtonTagToImage.swatchImageUrl)
        }
        
        if let swatchButtonViews = swatchButtonViews {
            setSelectedSwatch(swatchButtonViews[0].tag)
        }
        
    }
    
    /// Prepares the view for reuse
    open func prepareForReuse() {
        selectedSwatchTag = nil
        swatchButtonViews?.forEach({ $0.prepareForReuse() })
    }
  
    /// The totals space requried to render the buttons spacing included
    var totalSpace: CGFloat {
        return (CGFloat(maxButtons) + 1) * spacing
    }
    
    /// The preffered button width
    open var preferredButtonWidth: CGFloat?
    
    /// Sets the frames of the color button swatches
    fileprivate func setColorSwatchButtonFrames() {
        // |spacing - buttonView - spacing - buttonView - spacing| :: totalSpace = ( maxButtons + 1 ) * spacing
        let widthLeftAfterSpacing = (bounds.width - totalSpace)
        let buttonWidth = min(widthLeftAfterSpacing / CGFloat(maxButtons), bounds.height)
        let yPos = (bounds.height - buttonWidth) / 2
        var xPos = spacing
    
        guard let swatchButtonViews = swatchButtonViews else {
            Log.warning("Attempt set swatch button frames without initial ing swatch button views")
            return
        }
        
        for swatchButtonView in swatchButtonViews {
            swatchButtonView.frame = CGRect(x: xPos, y: yPos, width: buttonWidth, height: buttonWidth)
            xPos += spacing + buttonWidth
        }
    }
    
    /// Sets the button frames with the preffered button width
    fileprivate func setButtonFramesForPreferredButtonWidth() {
        
        guard let preferredButtonWidth = preferredButtonWidth else {
            Log.error("Preferred button width not set. Cannot set button frames")
            return
        }
    
        let buttonWidth = preferredButtonWidth
        let yPos: CGFloat = 0.0
        var xPos = spacing
        
        guard let swatchButtonViews = swatchButtonViews else {
            Log.warning("Attempt set swatch button frames without initial ing swatch button views")
            return
        }
        
        for swatchButtonView in swatchButtonViews {
            swatchButtonView.frame = CGRect(x: xPos, y: yPos, width: buttonWidth, height: buttonWidth)
            xPos += spacing + buttonWidth
        }
    }
    
    /// Triggered when a swatch is selected
    ///
    /// - Parameter colorSwatchView: The swatch that was selected
    @objc fileprivate func swatchSelected(_ colorSwatchView: ColorSwatchButtonView) {
  
        setSelectedSwatch(colorSwatchView.tag)
        sendActions(for: .valueChanged)
    }
    
    /// Returns the size of all the buttons rendered in a horizontal line. Includes spacing
    ///
    /// - Returns: The size of all buttons
    open func sizeThatFits() -> CGSize {
        
        guard let preferredButtonWidth = preferredButtonWidth else {
            Log.error("Preferred button width not set. Cannot Size")
            return CGSize.zero
        }
        
        return CGSize(width: CGFloat(maxButtons) * preferredButtonWidth + spacing * (CGFloat(maxButtons) + 1),
                      height: preferredButtonWidth)
    }
    
    /// Returns the button view with with a given tag
    ///
    /// - Parameter tag: The tag of the view that needs to be retrieved
    /// - Returns: The color swatch button view if it exists
    open func getButtonViewWithTag(_ tag: Int) -> ColorSwatchButtonView? {
     
        if let index = swatchButtonViews?.index(where: { $0.tag == tag }) {
            return swatchButtonViews?[index]
        }
        
        return nil
    }
    
}

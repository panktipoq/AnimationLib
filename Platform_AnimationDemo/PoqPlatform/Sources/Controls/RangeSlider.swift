//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

open class RangeSliderTrackLayer: CALayer {
    
    weak open var rangeSlider: RangeSlider?
    
    override open func draw(in ctx: CGContext) {
        drawRange(ctx: ctx)
        drawSelectedRange(ctx: ctx)
    }
    
    private func drawRange(ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        let cornerRadius = bounds.height * slider.curvaceousness / 2.0
        var lineRect = bounds
        lineRect.size.height = slider.trackStroke
        let path = UIBezierPath(roundedRect: lineRect, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)
        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }
    
    private func drawSelectedRange(ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
        let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
        let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: slider.trackStroke)
        ctx.fill(rect)
    }
}

open class RangeSliderThumbLayer: CALayer {
    
    open var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak open var rangeSlider: RangeSlider?
    
    override open func draw(in context: CGContext) {
        if let slider = rangeSlider {
            if AppSettings.sharedInstance.customisedRangeSlider {
                let thumbFrame = bounds.insetBy(dx: 0, dy: 0)
                UIGraphicsPushContext(context)
                ResourceProvider.sharedInstance.homePageStyle?.drawPriceToggle(frame: thumbFrame, pressed: highlighted)
                UIGraphicsPopContext()
            } else {
                // thumb
                let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
                let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
                let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
                context.setFillColor(slider.thumbTintColor.cgColor)
                context.addPath(thumbPath.cgPath)
                context.fillPath()

                if let color = slider.innerThumbColor {
                    // Inner thumb. this creates the illusion of a hollow circle as thick as "slider.lineHeight"
                    let thumbFrame = bounds.insetBy(dx: 2.0 + slider.trackStroke, dy: 2.0 + slider.trackStroke)
                    let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
                    let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
                    context.setFillColor(color.cgColor)
                    context.addPath(thumbPath.cgPath)
                    context.fillPath()
                }
                
                // Gray outline on the circle
                let outlineColor = UIColor.gray
                context.setStrokeColor(outlineColor.cgColor)
                context.setLineWidth(0.5)
                context.addPath(UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius).cgPath)
                context.strokePath()
                
                if highlighted {
                    // Darkens the knob when pressed
                    context.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                    context.addPath(thumbPath.cgPath)
                    context.fillPath()
                }
            }
        }
    }
}

open class RangeSlider: UIControl {

    open var innerThumbColor: UIColor? {
        didSet {
            updateLayerFrames()
        }
    }
    
    public var trackStroke = CGFloat(10.0) {
        willSet(newValue) {
            assert(newValue >= 0, "RangeSlider: trackStroke should be equal or greater than zero")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    public var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    public var maximumValue: Double = 1.0 {
        willSet(newValue) {
            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    public var lowerValue: Double = 0.2 {
        didSet(newValue) {
            if newValue < minimumValue {
                lowerValue = minimumValue
            }
            updateLayerFrames()
        }
    }
    
    public var upperValue: Double = 0.8 {
        didSet(newValue) {
            if newValue > maximumValue {
                upperValue = maximumValue
            }
            updateLayerFrames()
        }
    }
    
    public var gapBetweenThumbs: Double {
        return Double(thumbWidth)*(maximumValue - minimumValue) / Double(bounds.width)
    }
    
    open var trackTintColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    open var trackHighlightTintColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    open var thumbTintColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    public var curvaceousness: CGFloat = 1.0 {
        didSet(newValue) {
            if newValue < 0.0 {
                curvaceousness = 0.0
            }
            
            if newValue > 1.0 {
                curvaceousness = 1.0
            }
            
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    public var previouslocation = CGPoint()
    
    public let trackLayer = RangeSliderTrackLayer()
    public let lowerThumbLayer = RangeSliderThumbLayer()
    public let upperThumbLayer = RangeSliderThumbLayer()
    
    open var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    open var sliderTrackHeight: CGFloat = 10.0

    override open var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    func commonInit() {
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
        
        updateLayerFrames()
        
        isAccessibilityElement = true
        accessibilityLabel = AccessibilityLabels.rangeSlider
        accessibilityTraits = UIAccessibilityTraitAdjustable
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    open func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let frameInset: CGFloat = 0.5 * (bounds.height - sliderTrackHeight)
        trackLayer.frame.size.height = trackStroke
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: frameInset + (frameInset - trackStroke) / 2)
        
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    open func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    open func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }

    // MARK: - Touches
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previouslocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previouslocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}

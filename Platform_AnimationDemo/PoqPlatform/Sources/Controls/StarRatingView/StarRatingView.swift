//
//  StarRatingView.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 07/03/2018.
//

import Foundation

/// A view that represents a given rating using stars. Uses custom drawing to allow their appearance at any size. The view also allows for editing, using either tapping, panning, or both.
/// - Note: View based initially on Objective-C project: https://github.com/danwilliams64/DJWStarRatingView
/// - Note: Translated from our fork with our changes: https://github.com/poqcommerce/DJWStarRatingView
@IBDesignable open class StarRatingView: UIView {
    
    // MARK: -
    
    /// The individual size for each star.
    @IBInspectable open var starSize = CGSize(width: 12.0, height: 12.0) {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The total number of stars to show. Defaults to `5`.
    @IBInspectable open var numberOfStars = 5 {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The rating for the view to display. E.g. `2.9` or `4.5`.
    @IBInspectable open var rating: Float = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The fill color of the stars.
    @IBInspectable open var fillColor = ResourceProvider.sharedInstance.clientStyle?.pdpRatingStarsFilledColor ?? .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The unfilled color of the stars.
    @IBInspectable open var unfilledColor = ResourceProvider.sharedInstance.clientStyle?.pdpRatingStarsUnfilledColor ?? .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The color of the star's stroke.
    @IBInspectable open var strokeColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The width of the stroke around the stars. Defaults to `1.0`.
    @IBInspectable open var lineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The space between each star. Defaults to 5 percent of the width alocated to each star.
    open var padding: CGFloat? {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Init
    
    public init(starSize: CGSize,
         numberOfStars: Int,
         rating: Float,
         fillColor: UIColor,
         unfilledColor: UIColor,
         strokeColor: UIColor) {
        
        super.init(frame: CGRect.zero)
        
        self.starSize = starSize
        self.numberOfStars = numberOfStars
        self.rating = rating
        self.fillColor = fillColor
        self.unfilledColor = unfilledColor
        self.strokeColor = strokeColor
        
        backgroundColor = UIColor.clear
        frame = CGRect(origin: CGPoint.zero, size: intrinsicContentSize)
        
        setNeedsDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clear
    }
    
    // MARK: - UIView
    
    override open func draw(_ rect: CGRect) {
        
        var drawPoint = CGPoint.zero
        
        for index in 0..<numberOfStars {
            
            let starRect = CGRect(origin: drawPoint, size: starSize)
            drawStar(atPoint: drawPoint, atFrame: starRect, forStarNumber: index)
            let newXPoint = drawPoint.x + starSize.width + (padding ?? starSize.width / 5.0)
            drawPoint.x = newXPoint
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        
        let starSize = CGSize(width: self.starSize.width + 1.0, height: self.starSize.width + 1.0)
        let floatStars = CGFloat(numberOfStars)
        let width: CGFloat = (starSize.width * floatStars) + ((padding ?? starSize.width / 5.0) * floatStars)
        
        return CGSize(width: width, height: starSize.height)
    }
    
    // MARK: - Draw
    
    fileprivate func drawStar(atPoint point: CGPoint, atFrame frame: CGRect, forStarNumber starNumber: Int) {
        
        // Star Drawing
        let context = UIGraphicsGetCurrentContext()
        let starPath = UIBezierPath()
        
        starPath.move(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.60940 * frame.width, y: frame.minY + 0.34942 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.97553 * frame.width, y: frame.minY + 0.34549 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.67702 * frame.width, y: frame.minY + 0.55752 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.79389 * frame.width, y: frame.minY + 0.90451 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.68613 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.20611 * frame.width, y: frame.minY + 0.90451 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.32298 * frame.width, y: frame.minY + 0.55752 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.02447 * frame.width, y: frame.minY + 0.34549 * frame.height))
        starPath.addLine(to: CGPoint(x: frame.minX + 0.39060 * frame.width, y: frame.minY + 0.34942 * frame.height))
        
        starPath.close()
        context?.saveGState()
        starPath.addClip()
        
        gradientFill(forStarRect: starPath.cgPath.boundingBox, forStarNumber: starNumber)
        context?.restoreGState()
        
        strokeColor.setStroke()
        starPath.lineWidth = lineWidth
        starPath.stroke()
    }
    
    fileprivate func gradientFill(forStarRect starBounds: CGRect, forStarNumber starNumber: Int) {
        
        let fill = fillPercentage(forStarNumber: starNumber)
        let startColor = fillColor
        let endColor = unfilledColor
        
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colors = [startColor, endColor, endColor]
        let cgColors: [CGColor] = colors.map({ $0.cgColor })
        let gradientLocations = [fill, fill, fill]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: gradientLocations) else {
            return
        }
        
        context?.drawLinearGradient(gradient,
                                    start: CGPoint(x: starBounds.minX, y: starBounds.midY),
                                    end: CGPoint(x: starBounds.maxX, y: starBounds.midY),
                                    options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
    
    fileprivate func fillPercentage(forStarNumber starNumber: Int) -> CGFloat {
        
        return CGFloat(fmaxf(fminf(rating - Float(starNumber) * 1.0, 1.0), 0.0))
    }
}

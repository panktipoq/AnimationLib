//
//  RingSpinnerView.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 13/04/2018.
//

import Foundation

/// Layer animation key.
let ringSpinnerAnimationKey = "ringspinnerview.rotation"

/// A view that displays a spinner to show progress.
/// - Note: View based initially on Objective-C project: https://github.com/lipka/LLARingSpinnerView
public class RingSpinnerView: UIView {
    
    /// The width of the spinner line.
    public var lineWidth: CGFloat {
        get {
            return progressLayer.lineWidth
        } set {
            progressLayer.lineWidth = newValue
            updatePath()
        }
    }
    
    /// Stores if the spinner should be hidden when the animation stops.
    public var hidesWhenStopped: Bool? {
        didSet {
            isHidden = isAnimating == false && hidesWhenStopped == true
        }
    }
    
    /// Timing for the animation.
    public var timingFunction: CAMediaTimingFunction?
    
    /// Stores the animation status of the spinner.
    public var isAnimating: Bool {
        return progressLayer.animation(forKey: ringSpinnerAnimationKey) != nil
    }
    
    /// The Layer with the spinner shape.
    private(set) public var progressLayer = CAShapeLayer() {
        didSet {
            progressLayer.strokeColor = tintColor.cgColor
            progressLayer.fillColor = nil
            progressLayer.lineWidth = 1.5
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /// Code to init the spinner.
    func initialize() {
        timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.addSublayer(progressLayer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.width,
            height: bounds.height)
        
        progressLayer.fillColor = nil
        progressLayer.strokeColor = tintColor.cgColor

        updatePath()
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        progressLayer.strokeColor = tintColor.cgColor
    }
    
    /// Operations to animate the spinner.
    public func startAnimating() {
        
        if isAnimating == true {
            return
        }
        
        let animation = CABasicAnimation()
        
        animation.keyPath = "transform.rotation"
        animation.duration = 1.0
        animation.fromValue = 0.0
        animation.toValue = 2 * Double.pi
        animation.repeatCount = Float.infinity
        animation.timingFunction = timingFunction
        
        progressLayer.add(animation, forKey: ringSpinnerAnimationKey)
        
        if hidesWhenStopped == true {
            isHidden = false
        }
    }
    
    /// Operations to stop the spinner animation.
    public func stopAnimating() {
        
        if isAnimating == false {
            return
        }
        
        progressLayer.removeAnimation(forKey: ringSpinnerAnimationKey)

        if hidesWhenStopped == true {
            isHidden = true
        }
    }
    
    /// Operation to draw the spinner bezier path.
    private func updatePath() {
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = min(bounds.width / 2.0, bounds.height / 2.0) - (progressLayer.lineWidth / 2.0)
        let startAngle = CGFloat(-Double.pi / 4.0)
        let endAngle = CGFloat(3 * (Double.pi / 2.0))
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressLayer.path = path.cgPath
    }
}

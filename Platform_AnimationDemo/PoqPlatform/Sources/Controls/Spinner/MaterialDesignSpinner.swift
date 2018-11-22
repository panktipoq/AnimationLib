//
//  MaterialDesignSpinner.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 17/04/2018.
//

import Foundation

/// Layer animation keys.
let ringStrokeAnimationKey = "materialdesignspinner.stroke"
let ringRotationAnimationKey = "materialdesignspinner.rotation"

/// A view that displays a spinner to show progress.
/// - Note: View based initially on Objective-C project: https://github.com/misterwell/MMMaterialDesignSpinner
public class MaterialDesignSpinner: UIView {

    /// The width of the spinner line.
    public var lineWidth: CGFloat {
        get {
            return progressLayer.lineWidth
        } set {
            progressLayer.lineWidth = newValue
            updatePath()
        }
    }
    /// The cap style used when stroking the path
    public var lineCap: String {
        get {
            return progressLayer.lineCap
        } set {
            progressLayer.lineCap = newValue
            updatePath()
        }
    }
    
    /// Stores if the spinner should be hidden when the animation stops.
    public var hidesWhenStopped: Bool? {
        didSet {
            isHidden = isAnimating == false && hidesWhenStopped == true
        }
    }
    
    /// Percent Completed
    private(set) var percentCompleted: CGFloat = 0.0 {
        didSet {
            if isAnimating == true {
                return
            }
            
            progressLayer.strokeStart = 0.9
            progressLayer.strokeEnd = percentCompleted
        }
    }
    
    /// The Layer with the spinner shape.
    private(set) public var progressLayer = CAShapeLayer() {
        didSet {
            progressLayer.strokeColor = tintColor.cgColor
            progressLayer.fillColor = nil
            progressLayer.lineWidth = 1.5
        }
    }
    
    /// Stores the animation status of the spinner.
    public var isAnimating: Bool?
    
    /// Timing for the animation.
    public var timingFunction: CAMediaTimingFunction?
    
    /// Duration for one spin.
    public var duration: TimeInterval = 1.5
    
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
        invalidateIntrinsicContentSize()

        // See comment in resetAnimations on why this notification is used.
        setupNotifications()
    }
    
    /// Set up the notifications for the spinner.
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetAnimations), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.width,
            height: bounds.height)
        
        invalidateIntrinsicContentSize()
        
        progressLayer.fillColor = nil
        progressLayer.strokeColor = tintColor.cgColor
        
        updatePath()
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        progressLayer.strokeColor = tintColor.cgColor
    }
    
    /// Reset the animation if it was stoped but it is still in isAnimating.
    @objc public func resetAnimations() {
        // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
        if isAnimating == true {
            stopAnimating()
            startAnimating()
        }
    }
    
    /// Operations to animate the spinner.
    public func startAnimating() {
        
        if self.isAnimating == true {
            return
        }
        
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation"
        animation.duration = duration / 0.375
        animation.fromValue = 0.0
        animation.toValue = 2 * Double.pi
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: ringRotationAnimationKey)
        
        let headAnimation = CABasicAnimation()
        headAnimation.keyPath = "strokeStart"
        headAnimation.duration = duration / 1.5
        headAnimation.fromValue = 0.0
        headAnimation.toValue = 0.25
        headAnimation.timingFunction = timingFunction
        
        let tailAnimation = CABasicAnimation()
        tailAnimation.keyPath = "strokeEnd"
        tailAnimation.duration = duration / 1.5
        tailAnimation.fromValue = 0.0
        tailAnimation.toValue = 1.0
        tailAnimation.timingFunction = timingFunction
        
        let endHeadAnimation = CABasicAnimation()
        endHeadAnimation.keyPath = "strokeStart"
        endHeadAnimation.beginTime = duration / 1.5
        endHeadAnimation.duration = duration / 3.0
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1.0
        endHeadAnimation.timingFunction = timingFunction
        
        let endTailAnimation = CABasicAnimation()
        endTailAnimation.keyPath = "strokeEnd"
        endTailAnimation.beginTime = duration / 1.5
        endTailAnimation.duration = duration / 3.0
        endTailAnimation.fromValue = 1.0
        endTailAnimation.toValue = 1.0
        endTailAnimation.timingFunction = timingFunction
        
        let animations = CAAnimationGroup()
        animations.duration = duration
        animations.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        animations.repeatCount = Float.infinity
        animations.isRemovedOnCompletion = false
        progressLayer.add(animations, forKey: ringStrokeAnimationKey)

        isAnimating = true

        if hidesWhenStopped == true {
            isHidden = false
        }
    }
    
    /// Operations to stop the spinner animation.
    public func stopAnimating() {
        
        if isAnimating == false {
            return
        }
        
        progressLayer.removeAnimation(forKey: ringRotationAnimationKey)
        progressLayer.removeAnimation(forKey: ringStrokeAnimationKey)

        isAnimating = false
        
        if hidesWhenStopped == true {
            isHidden = true
        }
    }
    
    /// Operation to draw the spinner bezier path.
    private func updatePath() {
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = min(bounds.width / 2.0, bounds.height / 2.0) - (progressLayer.lineWidth / 2.0)

        let startAngle: CGFloat = 0
        let endAngle = CGFloat(Double.pi * 2)
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        progressLayer.path = path.cgPath
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = percentCompleted
    }
}

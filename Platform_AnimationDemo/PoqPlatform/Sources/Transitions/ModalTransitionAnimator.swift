//
//  ModalTransitionAnimator.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 12/03/2018.
//

import Foundation

/// Enum with the allowed directions to present a view controller.
public enum ModalTransitonDirection: UInt {
    
    case bottom
    case left
    case right
}

/// Custom dragable transition used to show Size picker when user add to bag
/// - Note: View based initially on Objective-C project: https://github.com/zoonooz/ZFDragableModalTransition
open class ModalTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Accessors

    /// Allow to drag out the presented view controller.
    open var isDragable: Bool = false {
        didSet {
            updateDragable()
        }
    }
    
    /// Allow to add a gesture to cancel the drag action.
    open var gestureRecognizerToFailPan: UIGestureRecognizer?
    
    /// The direction of the presented view controller.
    open var direction: ModalTransitonDirection = .bottom {
        didSet {
            if direction != .bottom {
                gesture?.scrollView = nil
            }
        }
    }
    
    /// The scale the already presented view controller will be reduced.
    open var behindViewScale: CGFloat = 0.9
    
    /// Alpha for the already presented view controller will be reduced.
    open var behindViewAlpha: CGFloat = 1.0
    
    /// Total time for the transition.
    open var transitionDuration: TimeInterval = 0.8
    
    fileprivate var gesture: DetectScrollViewEndGestureRecognizer?
    fileprivate var modalViewController: UIViewController?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var panLocationStart: CGFloat = 0.0
    fileprivate var isDismiss: Bool?
    fileprivate var isInteractive: Bool?
    fileprivate var tempTransform: CATransform3D?
    
    // MARK: - Init

    public init(withModalViewController modalViewController: UIViewController) {
        
        super.init()
        
        self.modalViewController = modalViewController
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    // MARK: - ScrollView

    /// Update the scrollview of the transition.
    /// - scrollView: The scroll view to be shown from the .bottom.
    open func setContentScrollView(_ scrollView: UIScrollView?) {
        
        // Always enable drag if scrollview is set
        if isDragable == false {
            isDragable = true
        }
        
        // Scrollview will work only for bottom mode
        direction = .bottom
        gesture?.scrollView = scrollView
    }
    
    // MARK: - Private

    fileprivate func updateDragable() {
        
        removeGestureRecognizerFromModalController()
        
        if isDragable == true {
            gesture = DetectScrollViewEndGestureRecognizer(target: self, action: #selector(handlePan))
            if let gesture = gesture {
                gesture.delegate = self
                modalViewController?.view.addGestureRecognizer(gesture)
            }
        }
    }
    

    @objc fileprivate func orientationChanged(notification: NSNotification) {
    
        guard let backViewController = modalViewController?.presentingViewController else {
            return
        }
        backViewController.view.transform = CGAffineTransform.identity
        backViewController.view.frame = modalViewController?.view.bounds ?? CGRect.zero
        backViewController.view.transform = backViewController.view.transform.scaledBy(x: behindViewScale, y: behindViewScale)
    }
    
    fileprivate func removeGestureRecognizerFromModalController() {
        
        if let gesture = gesture,
            modalViewController?.view.gestureRecognizers?.contains(gesture) == true {
            
            modalViewController?.view.removeGestureRecognizer(gesture)
            self.gesture = nil
        }
    }
    
    @objc fileprivate func handlePan(recognizer: UIPanGestureRecognizer) {
        
        guard let view = recognizer.view else {
            return
        }
        
        // Location reference
        var location = recognizer.location(in: modalViewController?.view.window)
        location = location.applying(view.transform.inverted())

        // Velocity reference
        var velocity = recognizer.velocity(in: modalViewController?.view.window)
        velocity = velocity.applying(view.transform.inverted())
        
        if recognizer.state == .began {
            
            isInteractive = true
            if direction == .bottom {
                panLocationStart = location.y
            } else {
                panLocationStart = location.x
            }
            
            modalViewController?.dismiss(animated: true, completion: nil)
            
        } else if recognizer.state == .changed {
        
            var animationRatio: CGFloat = 0.0
            
            if self.direction == .bottom {
                animationRatio = (location.y - panLocationStart) / view.bounds.height
            } else if self.direction == .left {
                animationRatio = (panLocationStart - location.x) / view.bounds.width
            } else if self.direction == .right {
                animationRatio = (location.x - panLocationStart) / view.bounds.width
            }

            update(animationRatio)
            
        } else if recognizer.state == .ended {

            var velocityForSelectedDirection: CGFloat = 0.0
            
            if self.direction == .bottom {
                velocityForSelectedDirection = velocity.y
            } else {
                velocityForSelectedDirection = velocity.x
            }
            
            if velocityForSelectedDirection > 100 &&
                (direction == .right || direction == .bottom) {
                finish()
            } else if velocityForSelectedDirection < -100
                && direction == .left {
                finish()
            } else {
                cancel()
            }
            
            isInteractive = false
        }
    }
    
    // MARK: - UIPercentDrivenInteractiveTransition
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        
        // Grab the from and to view controllers from the context
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        if SYSTEM_VERSION_LESS_THAN("8.0") {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, behindViewScale, behindViewScale, 1.0)
        }
        
        tempTransform = toViewController.view.layer.transform
        
        toViewController.view.alpha = behindViewAlpha
        
        if fromViewController.modalPresentationStyle == .fullScreen {
            
            transitionContext.containerView.addSubview(toViewController.view)
        }
        
        transitionContext.containerView.bringSubview(toFront: fromViewController.view)
    }
    
    open override func update(_ percentComplete: CGFloat) {
        
        var percentCompleted = percentComplete
        if percentCompleted < 0.0 {
            percentCompleted = 0.0
        }

        guard let transitionContext = self.transitionContext else {
            return
        }
        
        // Grab the from and to view controllers from the context
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        guard let tempTransform = tempTransform else {
            return
        }
        
        let transform = CATransform3DMakeScale(
            1 + (((1 / self.behindViewScale) - 1) * percentCompleted),
            1 + (((1 / self.behindViewScale) - 1) * percentCompleted),
            1.0)
        
        toViewController.view.layer.transform = CATransform3DConcat(tempTransform, transform)
        toViewController.view.alpha = behindViewAlpha + ((1 - behindViewAlpha) * percentCompleted)
        
        var updateRect = CGRect.zero
        
        if self.direction == .bottom {
            
            updateRect = CGRect(x: 0.0,
                                y: fromViewController.view.bounds.height * percentCompleted,
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height)
            
        } else if self.direction == .left {
            
            updateRect = CGRect(x: -(fromViewController.view.bounds.width * percentCompleted),
                                y: 0.0,
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height)
            
        } else if self.direction == .right {
            
            updateRect = CGRect(x: fromViewController.view.bounds.width * percentCompleted,
                                y: 0.0,
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height)
        }
        
        // reset to zero if x and y has unexpected value to prevent crash
        if (updateRect.origin.x.isNaN || updateRect.origin.x.isInfinite) {
            updateRect.origin.x = 0
        }
        
        if (updateRect.origin.y.isNaN || updateRect.origin.y.isInfinite) {
            updateRect.origin.y = 0
        }
        
        let transformedPoint = updateRect.origin.applying(fromViewController.view.transform)
        updateRect = CGRect(origin: transformedPoint,
                            size: updateRect.size)
        
        fromViewController.view.frame = updateRect
    }
    
    open override func finish() {
        
        guard let transitionContext = self.transitionContext else {
            return
        }
        
        // Grab the from and to view controllers from the context
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        var endRect = CGRect.zero
        
        if direction == .bottom {
            
            endRect = CGRect(x: 0.0,
                             y: fromViewController.view.bounds.height,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height)
        } else if direction == .left {
            
            endRect = CGRect(x: -fromViewController.view.bounds.width,
                             y: 0.0,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height)
        } else if direction == .right {
            
            endRect = CGRect(x: fromViewController.view.bounds.width,
                             y: 0.0,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height)
        }
        
        let transformedPoint = endRect.origin.applying(fromViewController.view.transform)
        endRect = CGRect(origin: transformedPoint,
                         size: endRect.size)
        
        if (fromViewController.modalPresentationStyle == .custom) {
            toViewController.beginAppearanceTransition(true, animated: true)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        
                        let scaleBack = 1.0 / self.behindViewScale
                        toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1)
                        toViewController.view.alpha = 1.0
                        fromViewController.view.frame = endRect
        },
                       completion: { (finished) in
                        
                        toViewController.view.layer.transform = CATransform3DIdentity
                        if (fromViewController.modalPresentationStyle == .custom) {
                            toViewController.endAppearanceTransition()
                        }
                        transitionContext.completeTransition(true)
        })

    }
    
    open override func cancel() {
        
        guard let transitionContext = self.transitionContext else {
            return
        }
        
        // Grab the from and to view controllers from the context
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        guard let tempTransform = tempTransform else {
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        
                        toViewController.view.layer.transform = tempTransform
                        toViewController.view.alpha = self.behindViewAlpha
                        
                        fromViewController.view.frame = CGRect(origin: CGPoint.zero,
                                                               size: fromViewController.view.frame.size)
                        
        },
                       completion: { (finished) in
                        
                        transitionContext.completeTransition(false)
                        if (fromViewController.modalPresentationStyle == .fullScreen) {
                            toViewController.view.removeFromSuperview()
                        }
        })
    }
}

extension ModalTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerAnimatedTransitioning

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isInteractive == true {
            return
        }
        
        // Grab the from and to view controllers from the context
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        if isDismiss == false {
            
            var startRect = CGRect.zero
            
            containerView.addSubview(toViewController.view)
            toViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if direction == .bottom {
                
                startRect = CGRect(x: 0.0,
                                   y: containerView.frame.height,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height)
                
            } else if direction == .left {
                
                startRect = CGRect(x: -containerView.frame.width,
                                   y: 0.0,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height)
            } else if direction == .right {
                startRect = CGRect(x: containerView.frame.width,
                                   y: 0.0,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height)
            }
            
            let transformedPoint = startRect.origin.applying(toViewController.view.transform)
            toViewController.view.frame = CGRect(origin: transformedPoint,
                                                 size: startRect.size)
            
            if (toViewController.modalPresentationStyle == .custom) {
                fromViewController.beginAppearanceTransition(false, animated: true)
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseOut,
                           animations: {
                            
                            fromViewController.view.transform = fromViewController.view.transform.scaledBy(x: self.behindViewScale,
                                                                                                           y: self.behindViewScale)
                            fromViewController.view.alpha = self.behindViewAlpha
                            
                            toViewController.view.frame = CGRect(origin: CGPoint.zero,
                                                                 size: toViewController.view.frame.size)
            },
                           completion: { (finished) in
                            
                            if (toViewController.modalPresentationStyle == .custom) {
                                fromViewController.endAppearanceTransition()
                            }
                            let didComplete = !transitionContext.transitionWasCancelled
                            transitionContext.completeTransition(didComplete)
            })
        } else {
            
            if fromViewController.modalPresentationStyle == .fullScreen {
                containerView.addSubview(toViewController.view)
            }
            
            containerView.bringSubview(toFront: fromViewController.view)
            
            if SYSTEM_VERSION_LESS_THAN("8.0") {
                
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, behindViewScale, behindViewScale, 1.0)
            }
            
            toViewController.view.alpha = behindViewAlpha
            
            var endRect = CGRect.zero
            
            if direction == .bottom {
                
                endRect = CGRect(x: 0.0,
                                 y: fromViewController.view.bounds.height,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height)
            } else if direction == .left {
                
                endRect = CGRect(x: -fromViewController.view.bounds.width,
                                 y: 0.0,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height)
            } else if direction == .right {
                
                endRect = CGRect(x: fromViewController.view.bounds.width,
                                 y: 0.0,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height)
            }
            
            let transformedPoint = endRect.origin.applying(fromViewController.view.transform)
            endRect = CGRect(origin: transformedPoint,
                             size: endRect.size)
            
            if (fromViewController.modalPresentationStyle == .custom) {
                toViewController.beginAppearanceTransition(true, animated: true)
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseOut,
                           animations: {
                
                            let scaleBack = 1.0 / self.behindViewScale
                            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1)
                            toViewController.view.alpha = 1.0
                            fromViewController.view.frame = endRect
            },
                           completion: { (finished) in
                            
                            toViewController.view.layer.transform = CATransform3DIdentity
                            if (fromViewController.modalPresentationStyle == .custom) {
                                toViewController.endAppearanceTransition()
                            }
                            let didComplete = !transitionContext.transitionWasCancelled
                            
                            transitionContext.completeTransition(didComplete)
            })
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
        // Reset to our default state
        isInteractive = false
        transitionContext = nil
    }
}

extension ModalTransitionAnimator: UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isDismiss = false
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isDismiss = true
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        // Return nil if we are not interactive
        if isInteractive == true && isDragable == true {
            isDismiss = true
            return self
        }
        
        return nil
    }
}

extension ModalTransitionAnimator: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (direction == .bottom) {
            return true
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizerToFailPan = gestureRecognizerToFailPan,
            gestureRecognizerToFailPan == otherGestureRecognizer {
            
            return true
        }
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.direction == .bottom) {
            return true
        }
        return false
    }
}

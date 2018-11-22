//
//  AppStoryCardCountOverlayView.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/25/17.
//
//

import Foundation
import QuartzCore
import UIKit

/**
 Provide overlay for card and animatable boxes.
 If card passed: box is white, if not - box is grey
 Current card progress box filling can be animated
 */
public final class AppStoryCardCountOverlayView: UIView {

    /// Changing this number will stop any animation and drop currentIndex to 0
    public var numberOfCards: Int = 0 {
        didSet {
            reloadCardProgressViews()
        }
    }

    /// Changing this value will stop any animation and update passed progres boxes 
    public var currentIndex: Int = 0 {
        didSet {
            updateProgressViewStates()
        }
    }
    
    /// Animate from current state
    public func animateAutoplay(with duration: TimeInterval) {
        let currentProgress = progressViews[currentIndex]
        currentProgress.changeProgress(to: 1, animationDuration: duration)
    }
    
    /// Pause all animations and stop on `currentProgress`. Update only progress for current card
    // - parameter currentProgress: in [0, 1]
    public func updateCurrentProgress(to currentProgress: CGFloat) {
        let currentProgressView = progressViews[currentIndex]
        currentProgressView.changeProgress(to: currentProgress, animationDuration: 0)
    }
    
    // MARK: Private
    fileprivate var progressViews = [AppStoryCardProgressView]()

    fileprivate func reloadCardProgressViews() {
        
        progressViews.forEach({ 
            (view: UIView) in
            view.removeFromSuperview()
        })
        progressViews.removeAll()
        
        guard numberOfCards > 0 else {
            return
        }
        
        let horizontalIndent: CGFloat = 8
        
        var prevView: UIView?
        
        for i in 0..<numberOfCards {
            let dashView = AppStoryCardProgressView()
            addSubview(dashView)
            
            dashView.translatesAutoresizingMaskIntoConstraints = false
            
            dashView.heightAnchor.constraint(equalToConstant: 2).isActive = true
            
            dashView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            if let prevViewUnwrapped = prevView {
                dashView.leadingAnchor.constraint(equalTo: prevViewUnwrapped.trailingAnchor, constant: horizontalIndent).isActive = true
                dashView.widthAnchor.constraint(equalTo: prevViewUnwrapped.widthAnchor).isActive = true
            } else {
                dashView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalIndent).isActive = true
            }
            
            prevView = dashView
            
            progressViews.append(dashView)
            
            dashView.tag = i 
        }
        
        prevView?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalIndent).isActive = true
        
        UIView.performWithoutAnimation {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    fileprivate func updateProgressViewStates() {
        
        for i in 0..<progressViews.count {
            let view = progressViews[i]
            view.isPassedCard = i < currentIndex
        }
    }
}


public class AppStoryCardProgressView: UIView {
    
    /// True if progress should show that card is passed (white)
    var isPassedCard: Bool = false {
        didSet {
            let progress: CGFloat = isPassedCard ? 1 : 0 
            changeProgress(to: progress)
        }
    }
    
    public override init(frame: CGRect) {
        
        progressView = UIView()
        
        super.init(frame: frame)
        
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        progressWidthConstraint = progressView.trailingAnchor.constraint(equalTo: leadingAnchor)
        progressWidthConstraint?.isActive = true

        layer.masksToBounds = true
        layer.cornerRadius = 1
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 1

        backgroundColor = UIColor.gray
        progressView.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard window != nil else {
            // no sence to do it, until we really o nscreen
            return
        }
        viewDidLayout = true
        
        DispatchQueue.main.async {
            [weak self] in
            self?.layoutWaitingAction?()
            self?.layoutWaitingAction = nil
        }
    }
    
    // MARK: API
    
    /// Change progress. `to` in [0...1]
    /// NOTE: remove all animations
    public func changeProgress(to: CGFloat, animationDuration: TimeInterval = 0) {
        
        let animated = animationDuration > 0
        
        if animated && !viewDidLayout {
            setNeedsLayout()
            // we have to postpone animation, until view appears in view hierarchy
            layoutWaitingAction = {
                [weak self] in
                self?.changeProgress(to: to, animationDuration: animationDuration)
            }
            return
        }

        progressView.layer.removeAllAnimations()
        progressWidthConstraint?.isActive = false
         
        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: to)
        progressWidthConstraint?.isActive = true

        if animated {
            
            UIView.animate(withDuration: animationDuration, 
                           delay: 0, 
                           options: UIViewAnimationOptions.curveLinear, 
                           animations: {
                            self.layoutIfNeeded()
            })
        } else {
            layoutIfNeeded()
        }
    }
    
    // MARK: Private
    
    // white view which show progress of autoplay.
    fileprivate let progressView: UIView
    
    fileprivate var progressWidthConstraint: NSLayoutConstraint?
    
    // To make a proper animation we need apply it AFTER subviews layout
    fileprivate var layoutWaitingAction: (() -> Void)?
    fileprivate var viewDidLayout = false
    
}




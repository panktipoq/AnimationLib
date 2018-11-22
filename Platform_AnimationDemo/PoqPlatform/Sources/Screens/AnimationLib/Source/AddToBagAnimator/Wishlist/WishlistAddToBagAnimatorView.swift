//
//  WishlistAddToBagAnimatorView.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 21/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit



public struct WishlistAddToBagAnimatorViewSettings {
    
    public var productImageFrame: CGRect
    public var productImage: UIImage
    public var bagTabbarItemView: UIView
    public var allowUserInteraction: Bool
    
    init(productImageFrame: CGRect,
         productImage: UIImage,
         bagTabbarItemView: UIView,
         allowUserInteraction: Bool = false) {
        self.productImageFrame = productImageFrame
        self.productImage = productImage
        self.bagTabbarItemView = bagTabbarItemView
        self.allowUserInteraction = allowUserInteraction
    }
}

class WishlistAddToBagAnimatorView: UIView {
    
    var completion: AnimClosure?
    
    var animSettings: WishlistAddToBagAnimatorViewSettings? {
        didSet {
            
            self.backgroundView.frame = CGRect(x: 0, y: animSettings?.productImageFrame.origin.y ?? 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.productImage.frame = CGRect(x: animSettings?.productImageFrame.origin.x ?? 0, y: 20, width: animSettings?.productImageFrame.size.width ?? 0, height: animSettings?.productImageFrame.size.height ?? 0)
            self.productImage.image = animSettings?.productImage
            if animSettings?.allowUserInteraction == false {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
    }
    
    lazy var backgroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        return bgView
        
    }()
    
    lazy var productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode =  .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 1
        return imageView
    }()
    
    lazy var overlayLayer: CAShapeLayer = {
        let overlay = CAShapeLayer()
        let path = UIBezierPath(rect: self.bounds)
        overlay.path = path.cgPath
        overlay.fillColor = UIColor.black.cgColor
        overlay.opacity = 0
        return overlay
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = .clear
        self.layer.addSublayer(overlayLayer)
        self.addSubview(backgroundView)
        backgroundView.addSubview(productImage)
    }
    func startAnimation(with settings: WishlistAddToBagAnimatorViewSettings,
                        completion:@escaping AnimClosure) {
        
        self.animSettings = settings
        self.completion = completion
        
        weak var weakself = self
        
        //View, image Tranform and scale animations
        weakself?.viewScaleAnimation()
            .overlayScaleAnimation()
            .imageScaleAnimation {
                
                //View, image fall and scale animations
                weakself?.viewTransformAnimation()
                    .overlayTransformAnimation(completion: {
                        
                        //badge view, tabbar view scale animations
                        weakself?.tabViewAnimation(completion: {
                            weakself?.perform(#selector(weakself?.dismissView), with: nil, afterDelay: 0.1)
                        })
                    })
        }
    }
    
    @objc func dismissView() {
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        if let completion = self.completion {
            completion()
        }
        self.removeFromSuperview()
    }
    
    static func stopAnimation() {
        UIApplication.shared.endIgnoringInteractionEvents()
        PoqAnimator().stopAnimation()
    }
    deinit {
        UIApplication.shared.endIgnoringInteractionEvents()
        PoqAnimator().stopAnimation()
    }
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Start Scale Animations
    
    func viewScaleAnimation() -> Self {
        PoqAnimator()
            .addBasicAnimation(keyPath: .positionY,
                               from:backgroundView.center.y,
                               to: self.center.y-52,
                               duration: 0.35)
            .addBasicAnimation(keyPath: .scale,
                               from:1,
                               to: 0.5 ,
                               duration: 0.35)
            .startAnimation(for: backgroundView.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        return self
    }
    func overlayScaleAnimation() -> Self {
        PoqAnimator()
            .addBasicAnimation(keyPath: .opacity,
                               from:0,
                               to: 0.24,
                               duration: 0.35)
            .startAnimation(for: self.overlayLayer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        return self
        
    }
    func imageScaleAnimation(completion: AnimClosure?) {
        PoqAnimator()
            .addBasicAnimation(keyPath: .radius,
                               from:1,
                               to: 15 ,
                               duration: 0.35,
                               delay: 0,
                               timingFunction: .easeInfast)
            .startAnimation(for: self.productImage.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false,
                            completion: completion)
        
    }
    
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Start transform Animations
    
    func viewTransformAnimation() -> Self {
        
        PoqAnimator()
            .addBasicAnimation(keyPath: .position,
                               from:CGPoint(x: self.center.x, y: self.center.y-52),
                               to: CGPoint(x: animSettings?.bagTabbarItemView.center.x ?? 0, y: animSettings?.bagTabbarItemView.superview?.center.y ?? 0 ) ,
                               duration: 0.35,
                               delay: 0,
                               timingFunction: .easeInfast)
            .addBasicAnimation(keyPath: .scale,
                               from:0.5,
                               to: 0 ,
                               duration: 0.35)
            .startAnimation(for: backgroundView.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        return self
    }
    func overlayTransformAnimation(completion: AnimClosure?) {
        PoqAnimator()
            .addBasicAnimation(keyPath: .opacity,
                               from:0.24,
                               to: 0 ,
                               duration: 0.35,
                               delay: 0,
                               timingFunction: .easeOut)
            .startAnimation(for: self.overlayLayer,
                            type: .parallel,
                            isRemovedOnCompletion: false,
                            completion: completion)
        
    }
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Tab bar bag Animations
    
    func tabViewAnimation(completion: @escaping AnimClosure) {
        
        TabBarAnimator().startAnimation(using: Int(AppSettings.sharedInstance.shoppingBagTabIndex), completion: completion)
    }
    
}

//
//  PDPAddToBagAnimatorView.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit


/*
 
 Wishlist Add to bag animation settings
 Parameters:
 
 wishlistCellImage : Screenshot of the wishlist cell
 wishlistCellFrame : Frame of the wishlist cell
 endFrame          : Frame of the tabbar
 
 */

public struct WishlistAddToBagAnimatorViewSettings {
    
    
    public var wishlistCellImage: UIImage
    public var wishlistCellFrame: CGRect
    public var endOrigin: CGPoint
    
    init(wishlistCellImage: UIImage,
         wishlistCellFrame: CGRect,
         endOrigin: CGPoint) {
        self.wishlistCellFrame = wishlistCellFrame
        self.wishlistCellImage = wishlistCellImage
        self.endOrigin = endOrigin
    }
}

class WishlistAddToBagAnimatorView: UIView {
    
    // MARK: - Initialisation
    var completion: AnimClosure? //Completion of the animation
    var animSettings: WishlistAddToBagAnimatorViewSettings? {
        didSet {
            
            let imageLayerFrame = animSettings?.wishlistCellFrame ?? CGRect.zero
            self.backgroundView.frame = imageLayerFrame
            self.productImage.frame = CGRect(x: 0, y: 0, width: imageLayerFrame.size.width, height: imageLayerFrame.size.height)
            self.productImage.image = animSettings?.wishlistCellImage
        }
    }
    
    /*
     Background view of the size view
     it will contain imageview
     This view is created to provide seperate animation to imageBG and overlay view
     */
    lazy var backgroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.clipsToBounds = true
        return bgView
        
    }()
    
    /*
     ImageView with the image provided in settings
     */
    lazy var productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode =  .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 1
        return imageView
    }()
    
    /*
     Overlay view with black background
     */
    lazy var overlayLayer: CAShapeLayer = {
        let overlay = CAShapeLayer()
        let path = UIBezierPath(rect: self.bounds)
        overlay.path = path.cgPath
        overlay.fillColor = UIColor.black.cgColor
        overlay.opacity = 0
        return overlay
        
    }()
    
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        UIApplication.shared.endIgnoringInteractionEvents()
        PoqAnimator().stopAnimation()
    }
    
    
    //MARK: UI Setup
    func setup() {
        self.backgroundColor = .clear
        self.layer.addSublayer(overlayLayer)
        self.addSubview(backgroundView)
        backgroundView.addSubview(productImage)
    }
    
    //MARK: - Animation Actions
    func startAnimation(with settings: WishlistAddToBagAnimatorViewSettings,
                        completion:@escaping AnimClosure) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.animSettings = settings
        self.completion = completion
        
        weak var weakself = self
        
        //View, image Tranform and scale animations
        weakself?.scaleAnimation {
            //View, image fall and scale animations
            weakself?.transformAnimation(completion: {
                //badge view, tabbar view scale animations
                weakself?.tabViewAnimation(completion: {
                    weakself?.perform(#selector(weakself?.dismissView), with: nil, afterDelay: 0.1)
                })
            })
        }
    }
    
    @objc func dismissView() {
        
        PDPAddToBagAnimatorView.stopAnimation()
        if let completion = self.completion {
            completion()
        }
        self.removeFromSuperview()
        
    }
    
    static func stopAnimation() {
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        PoqAnimator().stopAnimation()
    }
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Start Scale Animations
    
    func scaleAnimation(completion: AnimClosure?){
        self.viewScaleAnimation()
        .imageScaleAnimation()
        .overlayScaleAnimation(completion: completion)
    }
    
    func viewScaleAnimation() -> Self {
        PoqAnimator()
            .addBasicAnimation(keyPath: .position,
                               from: self.backgroundView.center,
                               to: CGPoint(x: self.center.x, y: self.backgroundView.center.y),
                               duration: 0.3)
            .addBasicAnimation(keyPath: .scale,
                               from: 1,
                               to: 1.2,
                               duration: 0.3)
            .addBasicAnimation(keyPath: .boundsSizeWidth,
                               from: animSettings?.wishlistCellFrame.size.width ?? 0,
                               to: 120,
                               duration: 0.3)
            .addBasicAnimation(keyPath: .boundsSizeHeight,
                               from: animSettings?.wishlistCellFrame.size.height ?? 0,
                               to: animSettings?.wishlistCellFrame.size.height ?? 0 - 30,
                               duration: 0.3)
            .addBasicAnimation(keyPath: .radius,
                               from:1,
                               to: 8 ,
                               duration: 0.3,
                               delay: 0,
                               timingFunction: .easeInfast)
            .startAnimation(for: self.backgroundView.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        return self
        
    }
    
    func imageScaleAnimation() -> Self {
        PoqAnimator()
            .addBasicAnimation(keyPath: .scale,
                               from: 1,
                               to: 1.1,
                               duration: 0.1)
            .addBasicAnimation(keyPath: .position,
                               from: self.productImage.center,
                               to: CGPoint(x: self.productImage.center.x - 10,
                                           y: self.productImage.center.y - 5 ),
                               duration: 0.3)
            .startAnimation(for: self.productImage.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        return self
        
    }
    
    func overlayScaleAnimation(completion: AnimClosure?){
        PoqAnimator()
            .addBasicAnimation(keyPath: .opacity,
                               from:0,
                               to: 0.3,
                               duration: 0.4)
            .startAnimation(for: self.overlayLayer,
                            type: .parallel,
                            isRemovedOnCompletion: false,
                            completion: completion)
    }
   
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Start transform Animations
    
    func transformAnimation(completion: AnimClosure?){
        self.viewTransformAnimation()
        .overlayTransformAnimation(completion: completion)
    }
    
    
    func viewTransformAnimation() -> Self {
        
        PoqAnimator()
            .addBasicAnimation(keyPath: .position,
                               from:backgroundView.center,
                               to: CGPoint(x: animSettings?.endOrigin.x ?? 0,
                                           y: animSettings?.endOrigin.y ?? 0 ),
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

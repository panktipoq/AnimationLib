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
    
    public var imageFrame: CGRect
    public var wishlistCellImage: UIImage
    public var wishlistCellFrame: CGRect
    public var endOrigin: CGPoint
    
    init(imageFrame:CGRect,
        wishlistCellImage: UIImage,
        wishlistCellFrame: CGRect,
        endOrigin: CGPoint) {
        self.imageFrame = imageFrame
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
        imageView.contentMode =  .scaleToFill
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
        
        if let completion = self.completion {
            completion()
        }
        self.removeFromSuperview()
        
    }
    
    static func stopAnimation() {
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
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
        
        let positionAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .position,
                                                                           fromValue:self.backgroundView.center,
                                                                           toValue: CGPoint(x: self.center.x, y: self.backgroundView.center.y),
                                                                           duration: 0.3))

        let bounceAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .boundsSize,
                                                                           fromValue: animSettings?.wishlistCellFrame.size ?? CGSize.zero,
                                                                           toValue: animSettings?.imageFrame.size ?? CGSize.zero,
                                                                           duration: 0.3))
        self.backgroundView.layer.runAnimations(for: .parallel,
                                                animations: [positionAnimation,
                                                             CAAnimation.WishlistCellStartScaleAnimation(),
                                                             bounceAnimation,
                                                             CAAnimation.WishlistCellRadiusAnimation()],
                                                completion: nil)
        
        return self
        
    }
    
    func imageScaleAnimation() -> Self {

        let positionAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .position,
                                                                           fromValue:self.productImage.center,
                                                                           toValue: CGPoint(x:(self.productImage.center.x - (animSettings?.imageFrame.origin.x ?? 0)),y: self.productImage.center.y - (animSettings?.imageFrame.origin.y ?? 0) ),
                                                                           duration: 0.2))
        self.productImage.layer.runAnimation(positionAnimation, completion: nil)
        return self
        
    }
    
    func overlayScaleAnimation(completion: AnimClosure?){
        overlayLayer.runAnimation(CAAnimation.OverlayStartOpacityAnimation(),
                                  completion: nil)
    }
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Start transform Animations
    
    func transformAnimation(completion: AnimClosure?){
        self.viewTransformAnimation()
        .overlayTransformAnimation(completion: completion)
    }
    
    
    func viewTransformAnimation() -> Self {

        let positionAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .position,
                                                                           fromValue:backgroundView.center,
                                                                           toValue: CGPoint(x: animSettings?.endOrigin.x ?? 0,y: animSettings?.endOrigin.y ?? 0 ),
                                                                           duration: 0.35,
                                                                           delay: 0,
                                                                           timingFunction: .easeInfast))
        
        backgroundView.layer.runAnimations(for: .parallel,
                                           animations: [positionAnimation, CAAnimation.WishlistCellEndScaleAnimation()],
                                           completion: nil)
        return self
    }
    func overlayTransformAnimation(completion: AnimClosure?) {
        overlayLayer.runAnimation(CAAnimation.OverlayEndOpacityAnimation(),
                                  completion: nil)
    }
}

extension WishlistAddToBagAnimatorView {
    
    // MARK: - Tab bar bag Animations
    
    func tabViewAnimation(completion: @escaping AnimClosure) {
        
        TabBarAnimator().startAnimation(using: Int(AppSettings.sharedInstance.shoppingBagTabIndex), completion: completion)
    }
    
}

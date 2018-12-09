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
 
 PDP Add to bag animation settings
 Parameters:
 
    productImage : Image of the pdp from selected page
    startFrame   : Frame of the pdp imageview
    endFrame     : Frame of the tabbar
 
 */

public struct PDPAddToBagAnimatorViewSettings {
    
    
    public var productImage: UIImage
    public var startFrame: CGRect
    public var endOrigin: CGPoint
    
    init(productImage: UIImage,
         startFrame: CGRect,
         endOrigin: CGPoint) {
        self.startFrame = startFrame
        self.productImage = productImage
        self.endOrigin = endOrigin
    }
}

class PDPAddToBagAnimatorView: UIView {
    
    // MARK: - Initialisation
    var completion: AnimClosure? //Completion of the animation
    var animSettings: PDPAddToBagAnimatorViewSettings? {
        didSet {
            
            let imageLayerFrame = animSettings?.startFrame ?? CGRect.zero
            self.backgroundView.frame = CGRect(x: 0,
                                               y: imageLayerFrame.origin.y,
                                               width: UIScreen.main.bounds.width,
                                               height: UIScreen.main.bounds.height)
            self.productImage.frame = CGRect(x: imageLayerFrame.origin.x,
                                             y: 20,
                                             width: imageLayerFrame.size.width,
                                             height: imageLayerFrame.size.height)
            self.productImage.image = animSettings?.productImage
        }
    }
    
    /*
     Background view of the size view
     it will contain imageview
     This view is created to provide seperate animation to imageBG and overlay view
     */
    lazy var backgroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .clear
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
    }
    
    
    //MARK: UI Setup
    func setup() {
        self.backgroundColor = .clear
        self.layer.addSublayer(overlayLayer)
        self.addSubview(backgroundView)
        backgroundView.addSubview(productImage)
    }
    
    //MARK: - Animation Actions
    func startAnimation(with settings: PDPAddToBagAnimatorViewSettings,
                        completion:@escaping (AnimClosure)) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.animSettings = settings
        self.completion = completion
        
        weak var weakself = self
        
        //View, image Tranform and scale animations
        weakself?.scaleAnimation(completion:{
            //View, image fall and scale animations
            weakself?.transformAnimation(completion: {
                //badge view, tabbar view scale animations
                weakself?.tabViewAnimation(completion: {
                    weakself?.perform(#selector(weakself?.dismissView), with: nil, afterDelay: 0.1)
                })
            })
        })
    }
    
    @objc func dismissView() {
        
        if let completion = self.completion {
            completion()
        }
        self.removeFromSuperview()
        
    }
}

extension PDPAddToBagAnimatorView {
    
    // MARK: - Start Scale Animations
    
    func scaleAnimation(completion: AnimClosure?){
        self.viewScaleAnimation()
            .overlayScaleAnimation()
           .imageScaleAnimation(completion: completion)
    }
    
    func viewScaleAnimation() -> Self {
        let positionAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .positionY,
                                                                         fromValue: backgroundView.center.y,
                                                                         toValue: self.center.y-52,
                                                                         duration: 0.3,
                                                                         delay:0,
                                                                         timingFunction: .easeInfast))
        
        backgroundView.layer.runAnimations(for: .parallel,
                                           animations: [positionAnimation, CAAnimation.PDPStartScaleAnimation()],
                                           completion: nil)
        return self
    }
    func overlayScaleAnimation() -> Self {
        overlayLayer.runAnimation(CAAnimation.OverlayStartOpacityAnimation(),
                                  completion: nil)

        return self
        
    }
    func imageScaleAnimation(completion: AnimClosure?) {
        self.productImage.layer.runAnimation(CAAnimation.PDPImageRadiusAnimation(),
                                             completion: completion)
    }
    
}

extension PDPAddToBagAnimatorView {
    
    // MARK: - Start transform Animations
    func transformAnimation(completion: AnimClosure?){
        self.viewTransformAnimation()
            .overlayTransformAnimation(completion:completion)
    }
    func viewTransformAnimation() -> Self {

        let positionAnimation = CAAnimation.basicAnimation(for: AnimConfig(keyPath: .position,
                                                                           fromValue: CGPoint(x: self.center.x, y: self.center.y-52),
                                                                           toValue: CGPoint(x: animSettings?.endOrigin.x ?? 0, y: animSettings?.endOrigin.y ?? 0 ),
                                                                           duration: 0.35,
                                                                           delay:0,
                                                                           timingFunction: .easeInfast))

        backgroundView.layer.runAnimations(for: .parallel,
                                           animations: [positionAnimation, CAAnimation.PDPEndScaleAnimation()],
                                           completion: nil)
        return self
    }
    func overlayTransformAnimation(completion: AnimClosure?) {
        overlayLayer.runAnimation(CAAnimation.OverlayEndOpacityAnimation(),
                                  completion: nil)
    }
}

extension PDPAddToBagAnimatorView {
    
    // MARK: - Tab bar bag Animations
    
    func tabViewAnimation(completion: @escaping AnimClosure) {
        
        TabBarAnimator().startAnimation(using: Int(AppSettings.sharedInstance.shoppingBagTabIndex), completion: completion)
    }
    
}


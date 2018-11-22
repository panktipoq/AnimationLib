//
//  PoqAsyncImageView.swift
//  Haneke
//
//  Created by Jun Seki on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Haneke
import PoqUtilities
import UIKit

/// The image view that renders the images in the PoqPlatform
open class PoqAsyncImageView: UIImageView {
    
    /// The spinner view that is shown while the image is loading
    var spinnerView: PoqSpinner?
    
    /// The image ratio used to keep the aspect ratio of the image via constraints
    var imageRatio: NSLayoutConstraint?

    /// Specific object that retrieves the image from the URL
    var fetcher: NetworkFetcher<UIImage>?
    
    // MARK: - Animations for skeletons
    
    public static var skeletonColor = UIColor.hexColor("#EFEFF4")
    
    var loadingFrameGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.withAlphaComponent(1).cgColor, UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.2, 0.5, 0.7]
        return gradientLayer
    }()
    
    var loadingFrameAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 2.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        return animation
    }()
    
    var animatedView: UIView?
    
    private func removeSkeleton() {
        CATransaction.begin()
        layer.removeAllAnimations()
        layer.mask = nil
        animatedView?.isHidden = true
        CATransaction.commit()
    }
    
    open func setupSkeletonView() {
        let view = UIView()
        
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.backgroundColor = PoqAsyncImageView.skeletonColor
        
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        animatedView = view
    }
    
    open func addSkeleton() {
        if animatedView == nil {
            setupSkeletonView()
        }
        
        animatedView?.isHidden = false
        addLoadingFrameAnimation()
    }
    
    open func addLoadingFrameAnimation() {
        loadingFrameGradientLayer.frame = bounds
        loadingFrameGradientLayer.locations = [-0.3, -0.2, 0.0]        
        layer.mask = loadingFrameGradientLayer
        loadingFrameGradientLayer.add(loadingFrameAnimation, forKey: "locationsChange")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
    }
    
    /// Sets up the progress view
    open func setupProgressView() {
        
        guard self.spinnerView == nil else {
            return
        }
        
        // For small images spinner view should be half imageview size
        // For bigger images spinner should use default spinner size
        
        var spinnerViewFrame: CGRect
        let minFrameEdge = min(frame.width, frame.height)
        
        if minFrameEdge < CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension) {
            spinnerViewFrame = CGRect(x: 0, y: 0, width: minFrameEdge/2, height: minFrameEdge/2)
        } else {
            spinnerViewFrame = CGRect.zero
        }
        
        let spinnerView = PoqSpinner(frame: spinnerViewFrame)
        self.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = spinnerView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.5)
        // We need width constraint higher proiority than compressing
        widthConstraint.priority = UILayoutPriority.defaultHigh + 1
        
        let heightConstraint = spinnerView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5)
        // We need height constaint higher proiority than compressing
        heightConstraint.priority = UILayoutPriority.defaultHigh + 1
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        spinnerView.applyCenterPositionConstraints()
        
        spinnerView.lineWidth = 1.5
        // Set the tint color of the spinner
        spinnerView.tintColor = AppTheme.sharedInstance.mainColor
        
        self.spinnerView = spinnerView
    }
    
    /**
     DON'T USE THIS METHOD ANYMORE. USE: fetchImageFromURL(URL, placeholder:, isAnimated:, showLoadingIndicator:, completion:)
     SINCE THIS ONE DOESN'T ALLOW TO CANCEL LOADING
     */
    
    /// Returns the image from the URL 
    ///
    /// - Parameters:
    ///   - URL: The URL of the image
    ///   - isAnimated: Wether the appearance of the image is animated or not
    ///   - showLoadingIndicator: Shows the loading indicator
    ///   - resetConstraints: Wether or not to reset the constraints after the image is loaded
    ///   - completion: Triggered when the load process is completed
    open func getImageFromURL(_ URL: URL, isAnimated: Bool, showLoadingIndicator: Bool = true, resetConstraints: Bool = false, completion: ((UIImage?) -> Void)? = nil) {
        
        if showLoadingIndicator {
            spinnerView?.startAnimating()
        }
        
        let cache = Shared.imageCache
        fetcher = NetworkFetcher<UIImage>(URL: URL)
        
        // 50 MB
        let iconFormat = Format<UIImage>(name: HanekeGlobals.Cache.OriginalFormatName, diskCapacity: 50 * 1024 * 1024) { image in
            return image
        }
        
        cache.addFormat(iconFormat)
        cache.fetch(URL: URL, formatName: HanekeGlobals.Cache.OriginalFormatName).onFailure({ (_: Error?) in
            self.spinnerView?.stopAnimating()
        }).onSuccess { image in
            if showLoadingIndicator {
                self.spinnerView?.stopAnimating()
            }
            
            // If reset contraints, so it won't be restricted by the image view on the nib file.
            if resetConstraints && image.size.width != 0 {
                if let existingRatio = self.imageRatio {
                    self.removeConstraint(existingRatio)
                }
                
                self.imageRatio = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: image.size.width/image.size.height, constant: 0)
                if let ratio = self.imageRatio {
                    self.addConstraint(ratio)
                }
            }
            
            if isAnimated {
                self.alpha = 0
                UIView.animate(withDuration: 0.3, delay: 0, options: .showHideTransitionViews, animations: {
                    self.image = image
                    self.alpha = 1
                })
                
            } else {
                // Disable the fade in animation for UICollection view cell which caused the flicking/swapping images
                self.image = image
            }
            
            if let existedCompletion = completion {
                existedCompletion(image)
            }
        }
    }

    /// Fetch an image from its URL and present it in this PoqAsyncImageView at its original size.
    ///
    /// - Parameters:
    ///   - url: Source image URL.
    ///   - placeholder: Placeholder image to be shown while we are loading.
    ///   - isAnimated: If true, image will be transitioned in after it has been loaded (default is false).
    ///   - showLoading: Show or hide the loading indicator (default is true).
    ///   - completion: Called after image loading completes with loaded image or nil on failure. This can be used for
    open func fetchOriginalImage(from url: URL, placeholder: UIImage? = nil, isAnimated: Bool = false, showLoading: Bool = false, completion: ((UIImage?) -> Void)? = nil) {
        let format = Format<UIImage>(name: HanekeGlobals.Cache.OriginalFormatName, diskCapacity: 50 * 1024 * 1024)
        fetchImage(from: url, placeholder: placeholder, format: format, isAnimated: isAnimated, showLoading: showLoading, completion: completion)
    }
    
    /// Fetch an image from its URL and present it in this PoqAsyncImageView.
    ///
    /// - Parameters:
    ///   - url: Source image URL.
    ///   - placeholder: Placeholder image to be shown while we are loading.
    ///   - format: An optional format for use with Haneke, if this is left nil Haneke uses the imageView's frame size.
    ///   - isAnimated: If true, image will be transitioned in after it has been loaded (default is false).
    ///   - showLoading: Show or hide the loading indicator (default is true).
    ///   - completion: Called after image loading completes with loaded image or nil on failure. This can be used for postprocessing.
    open func fetchImage(from url: URL, shouldDisplaySkeleton: Bool = false, placeholder: UIImage? = nil, format: Format<UIImage>? = nil, isAnimated: Bool = false, showLoading: Bool = true, completion: ((UIImage?) -> Void)? = nil) {

        if shouldDisplaySkeleton {
            addSkeleton()
        }
        
        if showLoading {
            spinnerView?.startAnimating()
        }
        
        func onSuccess(_ image: UIImage) {
            
            if showLoading {
                spinnerView?.stopAnimating()
            }
            
            removeSkeleton()

            if isAnimated {
                
                // Setting the image to nil in prepaeForReuse does not remove the image until the next run loop.
                // This causes a weird ghosting effect. Which is why we dispatch the animation on the main queue so that it runs
                // on the run-loop after the image is cleared. Check: https://poqcommerce.atlassian.net/browse/PROD-2206
                DispatchQueue.main.async {
                
                    UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
                        self.image = image
                    })
                }
            } else {
                self.image = image
            }

            completion?(image)
        }
        
        func onFailure(_ error: Error?) {
            
            removeSkeleton()
            
            if showLoading {
                spinnerView?.stopAnimating()
            }
            
            Log.warning("Failed to fetch image \(url.absoluteString): \(String(describing: error?.localizedDescription))")
            image = placeholder
            
            completion?(nil)
        }
        hnk_setImageFromURL(url, placeholder: placeholder, format: format, failure: onFailure, success: onSuccess)
    }
    
    private func removeAnimations() {
        
        CATransaction.begin()
        layer.removeAllAnimations()
        layer.mask = nil
        CATransaction.commit()
    }
    
    /// Prepares the image view for reuse
    open func prepareForReuse() {
        
        hnk_cancelSetImage()
        fetcher?.cancelFetch()
        
        removeSkeleton()
        
        spinnerView?.stopAnimating()
        self.image = nil
    }
}

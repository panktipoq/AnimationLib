//
//  PoqGifImageView.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 11/24/16.
//
//

import Foundation
import ImageIO
import PoqNetworking
import PoqUtilities
import QuartzCore

private let AnimationKeyPath = "contents"

public class PoqGif: NSObject, DataPresentable {
    
    public static var memoryCacheItemsCountLimit: Int {
        return Int(AppSettings.sharedInstance.inMemeoryCacheGifsNumber)
    }
    
    /// lets keep this info and will be ready to start animation at any moment
    /// images.count  MUST BE EQUAL to delays.count, at the same time both can be 0 
    fileprivate let images: [CGImage]
    fileprivate let delays: [Double]
    fileprivate let totalDuration: Double /// we can't get this info from 'delay', problem in last delay
    
    /// Url, from which gif was downloaded
    let url: URL
    
    public required init(data: Data, url: URL) {
        self.url = url
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            Log.error("We didn't get image source from data, looks like data is invalid")
            self.images = [CGImage]()
            self.delays = [Double]()
            self.totalDuration = 0
            
            super.init()
            return
        }
        
        var images = [CGImage]()
        var delays = [Double]()
        
        var totalDuration: Double = 0
        
        let count = CGImageSourceGetCount(imageSource)
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(imageSource, i, nil), let renderedImage = image.render() {
                images.append(renderedImage)
            }
            
            // At it's delay in seconds, since we need switch each frame after delay defined in gif
            let delaySeconds = PoqGifImageView.delayForImageAtIndex(i, source: imageSource)
            delays.append(totalDuration)
            
            totalDuration += delaySeconds
        }
        
        self.images = images
        self.delays = delays
        self.totalDuration = totalDuration

        super.init()
    }
    
    fileprivate func createAnimation() -> CAPropertyAnimation? {

        let animation = CAKeyframeAnimation(keyPath: AnimationKeyPath)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = totalDuration
        
        var keyTimes = delays.map({ return $0/totalDuration })
        var values = images
        if let firstImage = values.first {
            keyTimes.append(1)
            values.append(firstImage)
        }
        
        
        // Here is a problem: switching between images happens with crossfade(alpha animation)
        // Avoid it, by setting small switch time
        // On switch we will put 2 close keyframe with current and next value, on distance 1e-3
        /**
         So
         |0----1-----2---3-------------------4---|
         Become
         |0---0'1----1'2---2'3------------------3'4--4'|
         Where i' is i image with keytime = keyTimes[i+1] - 1e-3
         In this case we have alpha animation for 1e-3 seconds which - is less than frame
         */
        if values.count > 2 {
            
            var adjustedValues: [CGImage] = [images[0]]
            var adjustedKeyTimes: [Double] = [0.0]
            
            let epsilon = 1e-3

            for i in 1..<images.count {
                var prevTime = keyTimes[i] - epsilon
                
                if prevTime < 0 {
                    prevTime = 0
                }
                
                adjustedValues.append(images[i-1])
                adjustedKeyTimes.append(prevTime)
                
                adjustedValues.append(images[i])
                adjustedKeyTimes.append(keyTimes[i])
            }
            
            keyTimes = adjustedKeyTimes
            values = adjustedValues
        }
        
        
        animation.keyTimes = keyTimes as [NSNumber]?
        animation.values = values
        animation.repeatCount = Float.infinity
        
        return animation
    }
}

/// UIImageView subclass for animating gifs
public class PoqGifImageView: UIImageView {
    
    fileprivate var url: URL?
    fileprivate var gif: PoqGif?

    override public func willMove(toWindow newWindow: UIWindow?) {
        
        super.willMove(toWindow: newWindow)
        
        if let gifUnwrapped = gif,
            layer.animation(forKey: AnimationKeyPath) == nil,
            newWindow != nil {
            
            if let animation = gifUnwrapped.createAnimation() {
                layer.add(animation, forKey: AnimationKeyPath)
            }
        }
    }

    
    fileprivate var cancelationToken: FetchCancelationToken?
    fileprivate var spinnerView: PoqSpinner?
    

    /// Load gif from url and animate it
    /// - parameter url: url of gif
    /// - parameter completion: Will be called when gif load from web finished
    /// NOTE: shouldbe called from main thread only
    public func animateGif(_ url: URL, completion: (() -> Void)? = nil) {
        
        assert(Thread.isMainThread, "To sync access to some variables, should be called only on main thread")
        
        if let gifUnwrapped = gif, url == gifUnwrapped.url {
            // we already loaded this gif
            if let animation = gifUnwrapped.createAnimation() {
                layer.add(animation, forKey: AnimationKeyPath)
            }
            completion?()
            return
        }
        
        if let gifUnwrapped = gif, url == gifUnwrapped.url {
            // we already loaded this gif
            if let animation = gifUnwrapped.createAnimation() {
                layer.add(animation, forKey: AnimationKeyPath)
            }
            return
        }
        
        self.url = url
        gif = nil
        
        cancelationToken?.isCancelled = true
        layer.removeAnimation(forKey: AnimationKeyPath)
        startLoadingAnimation()
        backgroundColor = UIColor.white
        
        cancelationToken = DataFetcher<PoqGif>.fetchData(url) {
            [weak self]
            (result: PoqGif?, error: Error?) in
            
            self?.gif = result
            
            self?.stopLoadingAnimation()
            if let animation = result?.createAnimation() {
                self?.layer.add(animation, forKey: AnimationKeyPath)
            }
            completion?()
        }
    }

    /// Stop loading process and animation. Should be called in 'prepareForReuse', for example
    func stopFetchingAndAnimation() {
        cancelationToken?.isCancelled = true
        layer.removeAnimation(forKey: AnimationKeyPath)
        stopLoadingAnimation()
    }

}

// MARK: Private
extension PoqGifImageView {

    fileprivate static func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> Double {
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        guard let existedCfProperties = cfProperties else {
            Log.error("can't get properties from source for index \(index)")
            return 0
        }
        
        let dictionary: NSDictionary = existedCfProperties as NSDictionary
        
        let gifPropertiesObject: NSDictionary? = dictionary[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        
        guard let existedGifProperties = gifPropertiesObject else {
            Log.error("can't get properties from source for index \(index)")
            return 0
        }
        
        let delayNumber: NSNumber? = existedGifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber
        guard let existedNumber = delayNumber else {
            Log.error("we got gif property for index \(index), but there is no delay..")
            return 0
        }
        
        return existedNumber.doubleValue
    }
    
    fileprivate final func startLoadingAnimation() {
        
        if spinnerView == nil {

            let newSpinner = PoqSpinner(frame: CGRect.zero)
            addSubview(newSpinner)
            
            newSpinner.translatesAutoresizingMaskIntoConstraints = false

            newSpinner.applyCenterPositionConstraints()
            
            newSpinner.backgroundColor = UIColor.clear
            
            spinnerView = newSpinner
        }

        spinnerView?.startAnimating()

    }
    
    fileprivate final func stopLoadingAnimation() {
        spinnerView?.stopAnimating()
    }
}



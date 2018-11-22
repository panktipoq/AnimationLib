//
//  VisualSearchCropView.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/05/2018.
//

import Foundation
import AVFoundation
import PoqUtilities
import UIKit
/**
 VisualSearchCropView is the main view which host the actual image to be cropped/resized. This view has multiple components:
 - image: It is the actual image that is passed
 - scrollView: This is the scroll that will contain the image so the view is zoomable
 - cropRectView: this is the grid view that can be resized from its corners. It will be displayed on top of the scrollview
 
 And its public functions are:
 - `croppedImage()`: This function will return the result cropped image.
 */
open class VisualSearchCropView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, VisualSearchCropRectViewDelegate {
    
    public static let visualSearchCropScrollViewAccessibilityId = "visualSearchCroppingViewAccessibilityId"
    
    fileprivate var image: UIImage
    fileprivate var imageView: UIView?
    fileprivate var imageSize = CGSize(width: 1.0, height: 1.0)
    fileprivate var scrollView: UIScrollView!
    fileprivate var zoomingView = UIView()
    fileprivate let cropRectView = VisualSearchCropRectView()
    fileprivate var insetRect = CGRect.zero
    fileprivate var editingRect = CGRect.zero
    fileprivate var resizing = false
    fileprivate let marginTop: CGFloat = 37.0
    fileprivate let marginLeft: CGFloat = 20.0
    
    // MARK: - Init and Setup
    
    public init(frame: CGRect, image: UIImage) {
        self.image = image
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initialize() {
        imageSize = image.size
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor.clear
        
        setupScrollView()
        setupCropRectView()
        setupZoomingView()
        setupImageView()
    }
    
    fileprivate func setupCropRectView() {
        cropRectView.delegate = self
        addSubview(cropRectView)
    }
    
    fileprivate func setupScrollView() {
        let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect)
        scrollView = UIScrollView(frame: cropRect)
        scrollView.isAccessibilityElement = true
        scrollView.accessibilityIdentifier = VisualSearchCropView.visualSearchCropScrollViewAccessibilityId
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        scrollView.backgroundColor = UIColor.clear
        scrollView.maximumZoomScale = 20.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        scrollView.clipsToBounds = false
        scrollView.contentSize = cropRect.size
        addSubview(scrollView)
    }
    
    fileprivate func setupZoomingView() {
        zoomingView.frame = scrollView.bounds
        zoomingView.backgroundColor = .clear
        scrollView.addSubview(zoomingView)
    }
    
    fileprivate func setupImageView() {
        let imageView = UIImageView(frame: zoomingView.bounds)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        zoomingView.addSubview(imageView)
        self.imageView = imageView
    }
    
    // MARK: - Layout subviews
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        editingRect = bounds.insetBy(dx: marginLeft, dy: marginTop)
        
        if insetRect == CGRect.zero {
            insetRect = bounds.insetBy(dx: marginLeft, dy: marginTop)
            layoutScrollView()
            layoutZoomingView()
            layoutImageView()
        }
        
        if !resizing {
             cropRectView.frame = scrollView.frame
        }
    }
    
    fileprivate func layoutScrollView() {
        let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect)
        scrollView.frame = cropRect
        scrollView.contentSize = cropRect.size
    }
    
    fileprivate func layoutZoomingView() {
        zoomingView.frame = scrollView.bounds
    }
    
    fileprivate func layoutImageView() {
        imageView?.frame = zoomingView.bounds
    }
    
    // MARK: - HitTest
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else {
            Log.error("User interaction is not enabled")
            return nil
        }
        
        if let hitView = cropRectView.hitTest(convert(point, to: cropRectView), with: event) {
            return hitView
        }
        let locationInImageView = convert(point, to: zoomingView)
        let zoomedPoint = CGPoint(x: locationInImageView.x * scrollView.zoomScale, y: locationInImageView.y * scrollView.zoomScale)
        if zoomingView.frame.contains(zoomedPoint) {
            return scrollView
        }
        return super.hitTest(point, with: event)
    }
    
    /// The function will adjust the scrollview for a given rect
    ///
    /// - Parameter toRect: The given rect to use
    fileprivate func zoomToCropRect(forCropRect toRect: CGRect) {
        if scrollView.frame.equalTo(toRect) {
            return
        }
        
        let width = toRect.width
        let height = toRect.height
        let scale = min(editingRect.width / width, editingRect.height / height)
        
        let scaledWidth = width * scale
        let scaledHeight = height * scale
        let cropRect = CGRect(x: (bounds.width - scaledWidth) / 2.0, y: (bounds.height - scaledHeight) / 2.0, width: scaledWidth, height: scaledHeight)
        
        var zoomRect = convert(toRect, to: zoomingView)
        zoomRect.size.width = cropRect.width / (scrollView.zoomScale * scale)
        zoomRect.size.height = cropRect.height / (scrollView.zoomScale * scale)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: { [unowned self] in
            self.scrollView.bounds = cropRect
            self.scrollView.zoom(to: zoomRect, animated: false)
            self.cropRectView.frame = cropRect
            }, completion: nil)
    }
    
    fileprivate func zoomedCropRect() -> CGRect {
        let cropRect = convert(scrollView.frame, to: zoomingView)
        let ratio = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect).width / imageSize.width
        let zoomedCropRect = CGRect(x: cropRect.origin.x / ratio,
                                    y: cropRect.origin.y / ratio,
                                    width: cropRect.size.width / ratio,
                                    height: cropRect.size.height / ratio)
        
        return zoomedCropRect
    }
    
    /// This function will return the rect that is to be cropped from a given view
    ///
    /// - Parameter cropRectView: The view that determines what to crop
    /// - Returns: The result rect
    fileprivate func cappedCropRectInImageRect(forCropRect cropRectView: VisualSearchCropRectView) -> CGRect {
        var cropRect = cropRectView.frame
        
        let rect = convert(cropRect, to: scrollView)
        if rect.minX < zoomingView.frame.minX {
            cropRect.origin.x = scrollView.convert(zoomingView.frame, to: self).minX
            let cappedWidth = rect.maxX
            let height = cropRect.size.height
            cropRect.size = CGSize(width: cappedWidth, height: height)
        }
        
        if rect.minY < zoomingView.frame.minY {
            cropRect.origin.y = scrollView.convert(zoomingView.frame, to: self).minY
            let cappedHeight = rect.maxY
            let width = cropRect.size.width
            cropRect.size = CGSize(width: width, height: cappedHeight)
        }
        
        if rect.maxX > zoomingView.frame.maxX {
            let cappedWidth = scrollView.convert(zoomingView.frame, to: self).maxX - cropRect.minX
            let height = cropRect.size.height
            cropRect.size = CGSize(width: cappedWidth, height: height)
        }
        
        if rect.maxY > zoomingView.frame.maxY {
            let cappedHeight = scrollView.convert(zoomingView.frame, to: self).maxY - cropRect.minY
            let width = cropRect.size.width
            cropRect.size = CGSize(width: width, height: cappedHeight)
        }
        
        return cropRect
    }
    
    /// Checks whether the user is dragging the view out of the screen so it will start to zoom out
    ///
    /// - Parameter cropRect: The rect to be checked against the editing rect
    fileprivate func automaticZoomIfEdgeTouched(forCropRect cropRect: CGRect) {
        if cropRect.minX < editingRect.minX - 5.0 ||
            cropRect.maxX > editingRect.maxX + 5.0 ||
            cropRect.minY < editingRect.minY - 5.0 ||
            cropRect.maxY > editingRect.maxY + 5.0 {
            self.zoomToCropRect(forCropRect: self.cropRectView.frame)
        }
    }
    
    /// Checks whether the zoomed out image is smaller then the previous crop rect size and adjusts the crop view and scroll view size if it is
    fileprivate func automaticCropViewAdjustmentOnZoom() {
        if scrollView.contentSize.height <= scrollView.frame.size.height || scrollView.contentSize.width < scrollView.frame.size.width {
            let cropRect = cappedCropRectInImageRect(forCropRect: cropRectView)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: { [unowned self] in
                self.scrollView.bounds = cropRect
                self.cropRectView.frame = cropRect
                }, completion: nil)
        }
    }
    
    // MARK: - Accessible Cropped image
    
    open func croppedImage() -> UIImage? {
        guard let imageWithFixedUpOrientation = image.fixedUpOrientation() else {
            Log.error("Couldn't get the right orientation for the image")
            return nil
        }
        
        guard let croppedImage = imageWithFixedUpOrientation.cgImage?.cropping(to: zoomedCropRect()) else {
            Log.error("Can't crop image")
            return nil
        }
        
        return UIImage(cgImage: croppedImage, scale: imageWithFixedUpOrientation.scale, orientation: imageWithFixedUpOrientation.imageOrientation)
    }
    
    // MARK: - VisualSearchCropRectViewDelegate delegate methods
    
    func cropRectViewDidBeginEditing(_ view: VisualSearchCropRectView) {
        resizing = true
    }
    
    func cropRectViewDidChange(_ view: VisualSearchCropRectView) {
        let cropRect = cappedCropRectInImageRect(forCropRect: view)
        cropRectView.frame = cropRect
        automaticZoomIfEdgeTouched(forCropRect: cropRect)
    }
    
    func cropRectViewDidEndEditing(_ view: VisualSearchCropRectView) {
        resizing = false
        zoomToCropRect(forCropRect: cropRectView.frame)
    }
    
    // MARK: - ScrollView delegate methods
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffset = scrollView.contentOffset
        targetContentOffset.pointee = contentOffset
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        automaticCropViewAdjustmentOnZoom()
    }
    
    // MARK: - Gesture Recognizer delegate methods
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

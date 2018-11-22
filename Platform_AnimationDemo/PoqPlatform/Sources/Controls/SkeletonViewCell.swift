//
//  UICollectionViewSkeletonCell.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 12/09/2018.
//

import Foundation
import PoqUtilities
import UIKit

let SkeletonViewCellAccessibilityId = "SkeletonViewCellAccessibilityId"

/// This protocol extends functionality to any cell that wants a skeleton.
public protocol SkeletonViewCell {
    
    var imageView: PoqAsyncImageView? { get }
    var topConstraint: NSLayoutConstraint? { get set }
    var bottomConstraint: NSLayoutConstraint? { get set }
    var rightConstraint: NSLayoutConstraint? { get set }
    var leftConstraint: NSLayoutConstraint? { get set }
    
    /// This function should be called in order to display a skeleton in the cell
    ///
    /// - Parameters:
    ///   - image: The image to display
    ///   - padding: Any needed padding
    ///   - contentMode: What content mode should the image adopt
    ///   - cornerRadius: This will be the radius of the skeleton, if it is 0 it will not have rounded corner
    func setupSkeleton(image: UIImage, padding: UIEdgeInsets, contentMode: UIViewContentMode, cornerRadius: CGFloat)
    
    /// Disable the skeleton if it was previously setup
    ///
    /// - Parameters:
    ///   - padding: The original padding that the cell should have
    ///   - contentMode: The content mode that the image should have
    ///   - cornerRadius: Whether the cell should have a corner radius
    func disableSkeleton(padding: UIEdgeInsets, contentMode: UIViewContentMode, cornerRadius: CGFloat)

    /// This function sets up the skeleton padding
    ///
    /// - Parameter padding: The desired padding to adopt
    func setupPadding(_ padding: UIEdgeInsets)
}

extension SkeletonViewCell where Self: UICollectionViewCell {
    // Set default nil values to all of them so they become optionals when conforming the protocol
    public var imageView: PoqAsyncImageView? { get { return nil } }
    public var topConstraint: NSLayoutConstraint? { get { return nil } set {} }
    public var bottomConstraint: NSLayoutConstraint? { get { return nil } set {} }
    public var rightConstraint: NSLayoutConstraint? { get { return nil } set {} }
    public var leftConstraint: NSLayoutConstraint? { get { return nil } set {} }
    
    public func setupSkeleton(image: UIImage, padding: UIEdgeInsets = UIEdgeInsets.zero, contentMode: UIViewContentMode = .scaleToFill, cornerRadius: CGFloat = 0) {
        accessibilityIdentifier = SkeletonViewCellAccessibilityId
        isUserInteractionEnabled = false
        imageView?.image = image
        imageView?.contentMode = contentMode
        // Only change the corner radius if anything is supplied
        if cornerRadius != 0 {
            imageView?.layer.masksToBounds = true
            imageView?.layer.cornerRadius = cornerRadius
        }
        imageView?.addLoadingFrameAnimation()
        setupPadding(padding)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func setupPadding(_ padding: UIEdgeInsets) {
        topConstraint?.constant = padding.top
        leftConstraint?.constant = padding.left
        rightConstraint?.constant = -padding.right
        bottomConstraint?.constant = -padding.bottom
    }
    
    public func disableSkeleton(padding: UIEdgeInsets = UIEdgeInsets.zero, contentMode: UIViewContentMode = .scaleAspectFit, cornerRadius: CGFloat = 0) {
        isUserInteractionEnabled = true
        imageView?.contentMode = contentMode
        imageView?.layer.masksToBounds = cornerRadius == 0 ? false : true
        imageView?.layer.cornerRadius = cornerRadius
    }
}

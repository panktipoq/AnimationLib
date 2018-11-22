//
//  BrandedHeaderView.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 20/06/2016.
//
//

import Foundation
import PoqNetworking

/// A view containing the branded header of a branded PLP screen
public final class BrandedHeaderView: UIView {
    
    /// The image that is going to be loaded in the header
    weak var logoImageView: PoqAsyncImageView?
    
    // if headerBlock not nill and valid - correct size will be returned, otherwise CGSizeZero
    
    /// Calculates the size of the header block
    ///
    /// - Parameter headerBlock: The block for which the size needs to be calculated.
    /// - Returns: The size of the header block. The width is the width of the screen. The height is the one fed to the headerHeight property of the block. TODO: This is not a calculation in the real sense and might be useful to add it to the poq block object
    public static func calculateSize(_ headerBlock: PoqBlock?) -> CGSize {
        guard let headerHeight: Int = headerBlock?.headerHeight else {
            return CGSize.zero
        }
        
        let width: CGFloat = UIScreen.main.bounds.size.width
        let height: CGFloat = CGFloat(headerHeight)
        return CGSize(width: width, height: height)
    }
    
    /// Initializes the header view with a block
    ///
    /// - Parameter headerBlock: The header block
    public init(headerBlock: PoqBlock?) {

        let size: CGSize = BrandedHeaderView.calculateSize(headerBlock)
        let bounds: CGRect = CGRect(origin: CGPoint.zero, size: size)
        super.init(frame: bounds)
        
        let imageView: PoqAsyncImageView = PoqAsyncImageView(frame: bounds)
        self.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        logoImageView = imageView

        if let urlString: String = headerBlock?.pictureURL, let pictureUrl: URL = URL(string: urlString) {
            imageView.getImageFromURL(pictureUrl, isAnimated: false, showLoadingIndicator: true, resetConstraints: false) {
                [weak imageView]
                (image: UIImage?) in
                
                // we need scale it
                if let cgImage: CGImage = image?.cgImage {
                    // here we assume logo is 2 scaled
                    let scaledImage = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.up)
                    imageView?.image = scaledImage
                }
            }
        }
        
        backgroundColor = headerBlock?.backgroundColor ?? UIColor.clear
        
        accessibilityIdentifier = AccessibilityLabels.brandedLogoHeader
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/// The reuse identifier of the branded header view
public let BrandedHeaderReuseIdentifier: String = "BrandedCollectionHeaderView"

/// The branded header reusable view
public final class BrandedCollectionHeaderView: UICollectionReusableView {

    /// The header block that provides information to this cell
    public var headerBlock: PoqBlock? {
        willSet {
            brandedView?.removeFromSuperview()
            brandedView = nil
        }
        didSet {
            if brandedView == nil {
                let view: BrandedHeaderView = BrandedHeaderView(headerBlock: headerBlock)
                view.translatesAutoresizingMaskIntoConstraints = true
                self.addSubview(view)
                brandedView = view
                
                let constraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsForView(view, withInsetsInContainer: UIEdgeInsets.zero)
                self.addConstraints(constraints)
            }
        }
    }
    
    /// The componenet that renders the branded view
    fileprivate weak var brandedView: BrandedHeaderView?
    

    /// The reuse identifier of the header view
    public override final var reuseIdentifier: String? {
        return BrandedHeaderReuseIdentifier
    }

}


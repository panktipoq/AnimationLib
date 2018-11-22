//
//  FullWidthAutoresizedCollectionCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/11/17.
//
//

import Foundation
import UIKit

/// Create cell with autocalculated height, which occupy whole screen width
/// Should be used as base class for all cells, which needs such behaviour
open class FullWidthAutoresizedCollectionCell: UICollectionViewCell, StaticSizableCell {
    
    // MARK: StaticSizableCell
    var isSizingCell = false
    
    // MARK: UICollectionView overrides
    
    /// Triggered when the view is (re)created from the xib. Sets up the width constraint for the cell for the full width layout
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width)
        widthConstraint.priority = UILayoutPriority(rawValue: 999.0)
        widthConstraint.isActive = true
    }
    
    /// Allow us to keep calcualted size, to avide to many calculations, as well as miss some needed recalcualtion
    // avoid crash on some iOS 9 versions
    
    /// The calculated size of the cell
    var calculatedSize: CGSize?
    
    /// Prepares the cell for reuse. Nils the calculated size
    override open func prepareForReuse() {
        super.prepareForReuse()

        calculatedSize = nil
    }
    
    /// Returns the uicollection view layout attributes with a calculated size. The calculation of the size is the result of contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    ///
    /// - Parameter layoutAttributes: the collection view's layout attributes
    /// - Returns: The preffered layout attributes
    override open func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let size: CGSize
        if let existedCalulatedSize = calculatedSize {
            size = existedCalulatedSize 
        } else {

            // _NSLayoutConstraintNumberExceedsLimit exception will be raised in large constraint situations values
            // Set to magic number 1000 for maximum value instead of larget magnitude

            var newSize = contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)            
            newSize.width = UIScreen.main.bounds.width
            
            calculatedSize = newSize
            size = newSize
        }

        attributes.size = size
        
        var newFrame = layoutAttributes.frame
        newFrame.size = size
        attributes.frame = newFrame
        return attributes
    }

}

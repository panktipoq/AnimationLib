//
//  FullWidthAutoresizedCellFlowLayout.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 7/14/17.
//
//

import PoqModuling
import PoqUtilities
import UIKit

/// Describe cells, which use auto size calculations
/// There is special cases, when cell should not do extra actions, if it is just for sizing
/// Adopt cell to this protocol to reduce amount work for cell, which will be never presented to user
/// Example 1 - Prodduct Info cell: do we really need start images loading and set collection view size?
/// Example 2 - Recently viewed: we have only one data source and its coupled with presented cell.
///             To avoid incorrect coupling we need indicator that this is sizing cell
protocol StaticSizableCell: AnyObject {
    
    /// True if cell never will be presented to users and used only for size calculation
    var isSizingCell: Bool { get set }
}

@objc public protocol FullWidthAutoresizedCellFlowLayoutDelegate {

    /// Will be called to configure sizing cell. Configuration might be simplified, since cells will never appears on screen
    /// All values, which effect sizes must be applied
    func setup(cell: UICollectionViewCell, at indexPath: IndexPath)
    
    func cellClass(at indexPath: IndexPath) -> UICollectionViewCell.Type?
    
    @objc optional func supplementaryViewClass(at indexPath: IndexPath) -> UICollectionViewCell.Type?
}

/// Good alternative to flow layout: will create 1 column layout
/// All sizes calculated in 'prepare', so when we will display cell - all sizes will be known
/// For proper work require collectionView.delegate to de confirmed to FullWidthAutoresizedCellFlowLayoutDelegate
/// NOTE: For smoother work will check does cells adopt StaticSizableCell
class FullWidthAutoresizedCellFlowLayout: UICollectionViewLayout {

    /// Flow layout delegate for the input flow layout
    fileprivate var delegate: FullWidthAutoresizedCellFlowLayoutDelegate? {
        return collectionView?.delegate as? FullWidthAutoresizedCellFlowLayoutDelegate 
    }

    /// Calculated attributes of the flow layout
    fileprivate var calculatedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    /// Calculated attributes of supplementary view
    fileprivate var calculatedSupplementaryViewAttributes: UICollectionViewLayoutAttributes?
    
    /// Prepares the cell for usage. TODO: This can be removed as it does nothing
    override func prepare() {
        super.prepare()
    }
    
    /// Generates the array of layout attributes for the given element
    ///
    /// - Parameter rect: The rectangle in which the elements will be generated
    /// - Returns: The array of layout attributes resulted
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let numberOfRows = collectionView?.numberOfItems(inSection: 0), numberOfRows > 0 else {
            return []
        }

        var res = [UICollectionViewLayoutAttributes]()
        
        var currentY: CGFloat = 0
        for index in 0..<numberOfRows {

            let indexPath = IndexPath(row: index, section: 0)

            let cellOrigin = CGPoint(x: 0, y: currentY)
            let attributes = calculatedAttributes[indexPath]

            var frame = attributes?.bounds ?? CGRect.zero
            frame.origin = cellOrigin

            guard attributes == nil || rect.intersects(frame) else {
                currentY += attributes?.bounds.size.height ?? 0
                continue
            }

            let updatedAttributes = calculateAttributes(for: indexPath, origin: cellOrigin)

            currentY += updatedAttributes.bounds.size.height 

            res.append(updatedAttributes)

            calculatedAttributes[indexPath] = updatedAttributes
        }
        
        let supplementaryViewIndexPath = IndexPath(row: res.count, section: 0)
        
        if delegate?.supplementaryViewClass?(at: supplementaryViewIndexPath) != nil {
            if let calculatedSupplementaryViewAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: supplementaryViewIndexPath) {
                self.calculatedSupplementaryViewAttributes = calculatedSupplementaryViewAttributes
                res.append(calculatedSupplementaryViewAttributes)
            }
        }

        return res
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // TODO: make attributes for UICollectionElementKindSectionHeader
        
        if elementKind == UICollectionElementKindSectionFooter {
            return calculateSupplementaryAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: indexPath, origin: CGPoint(x: 0, y: contentSize.height))
        } else {
            assert(false, "Any of supplementary views are not supported except UICollectionElementKindSectionFooter")
            return nil
        }
    }
    
    /// Generates the layout attributes for a given item at a indexpath
    ///
    /// - Parameter indexPath: The indexpath of the item who's layout attributes need to be generated
    /// - Returns: The layout attribute of the item
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        /// For now this method was called only while we invalidating layout
        /// So we already calculated proper size, lets avoid extra operations
        return calculatedAttributes[indexPath]
    }
    
    /// The content size of the collection view
    override var collectionViewContentSize: CGSize {
        var size = contentSize
        
        if let validcalculatedSupplementaryViewAttributes = calculatedSupplementaryViewAttributes {
            size.height += validcalculatedSupplementaryViewAttributes.bounds.size.height
        }
        
        return size
    }
    
    /// The content size of the collection view without supplementary views
    fileprivate var contentSize: CGSize {
        var size = CGSize(width: collectionView?.bounds.width ?? 0, height: 0)
        for (_, attributes) in calculatedAttributes {
            size.height += attributes.bounds.size.height
        }
        return size
    }
    
    /// Invalidates the latout of the collection view
    ///
    /// - Parameter context: The invalidation context of the view layout
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard !context.invalidateEverything else {
            super.invalidateLayout(with: context)
            calculatedAttributes = [:]
            return
        }
        
        let currentSize = collectionViewContentSize

        // Find set for sizes recalculation
        var invalidatedItemIndexSet = IndexSet()
        context.invalidatedItemIndexPaths?.forEach({ invalidatedItemIndexSet.insert($0.row) })
        updateAttributes(for: invalidatedItemIndexSet)
        
        let newContentSize = collectionViewContentSize
        context.contentSizeAdjustment = CGSize(width: 0, height: newContentSize.height - currentSize.height)
        
        // Just in case: if we changes any size: we have to invalidate position of every cell after
        if let minIndex = invalidatedItemIndexSet.min(), let numberOfRows = collectionView?.numberOfItems(inSection: 0), numberOfRows > 0 {
            let additionalPaths = Array<Int>(minIndex..<numberOfRows).map {
                IndexPath(row: $0, section: 0)
            }
            context.invalidateItems(at: additionalPaths)
        }

        super.invalidateLayout(with: context)
    }
    
    /// Sizing cells used for calculating the size of the actual cells
    fileprivate static var sizingCells = [String: UICollectionViewCell]() 

    /// Finds a given sizing cell based on the class type
    ///
    /// - Parameter cellClass: The class type for which the sizing cell is required
    /// - Returns: The sizing collection view cell
    fileprivate static func findSizingCell(for cellClass: UICollectionViewCell.Type) -> UICollectionViewCell? {

        let className = String(describing: cellClass)
        if let existedCell = sizingCells[className] {
            return existedCell
        }

        guard let nib = cellClass.poqNib else {
            Log.error("We can't find nib for cell - \(cellClass))")
            return nil
        }
        
        let item = nib.instantiate(withOwner: nil, options: nil).first(where: { $0 is UICollectionViewCell })
        
        let cellOrNil = item as? UICollectionViewCell
        if let staticSizableCell = cellOrNil as? StaticSizableCell {
            staticSizableCell.isSizingCell = true
        }
        sizingCells[className] = cellOrNil

        return cellOrNil
    }

    /// Update attributes. For attributes from `range` sizes will be recalcualted
    /// For rest of attributes only origins will be updated
    /// After return `calculatedAttributes` will be updated
    
    /// Updates the attributes for a number of cells by using indexpath
    ///
    /// - Parameter cellsAtIndexPaths: The indexpaths that need to be updated
    fileprivate func updateAttributes(for cellsAtIndexPaths: IndexSet) {
        
        guard let numberOfRows = collectionView?.numberOfItems(inSection: 0), numberOfRows > 0 else {
            calculatedAttributes = [:]
            return
        }
        
        var currentY: CGFloat = 0
        
        for index in 0..<numberOfRows {
            let indexPath = IndexPath(row: index, section: 0)
            let cellOrigin = CGPoint(x: 0, y: currentY)
            let resAttributes: UICollectionViewLayoutAttributes
            if let existedAttribues = calculatedAttributes[indexPath], !cellsAtIndexPaths.contains(index) {
                resAttributes = existedAttribues
                resAttributes.frame.origin = cellOrigin
            } else {
               resAttributes = calculateAttributes(for: indexPath, origin: cellOrigin)
            }
            currentY += resAttributes.bounds.size.height
            calculatedAttributes[indexPath] = resAttributes
        }
    }
    
    /// Calculate attributes for cell at indexPath
    ///
    /// - Parameters:
    ///   - indexPath: index path of cell
    ///   - origin: origin of cell frame
    /// - Returns: The layout attributes of the collection view. Makes the calculations based on the sizing cells.
    fileprivate func calculateAttributes(for indexPath: IndexPath, origin: CGPoint) -> UICollectionViewLayoutAttributes {
        let fittingAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        fittingAttributes.bounds = .zero
        fittingAttributes.frame = CGRect(origin: origin, size: .zero)

        guard let delegateUnwrapped = delegate else {
            Log.error("collectionView delegate must confirm to FullWidthAutoresizedCellFlowLayoutDelegate") 
            return fittingAttributes
        }
        
        guard let cellClass = delegateUnwrapped.cellClass(at: indexPath) else {
            Log.error("Unable to find cell class at index path '\(String(describing: indexPath))'")
            return fittingAttributes
        }
        
        guard let cell = FullWidthAutoresizedCellFlowLayout.findSizingCell(for: cellClass) else {
            Log.error("Unable to find PoqProductDetailCell in provided nib for '\(cellClass)'")
            return fittingAttributes
        }
        
        let fittingSize = CGSize(width: collectionView?.bounds.size.width ?? 0, height: UIScreen.main.bounds.size.height)
        let fittingBounds = CGRect(origin: CGPoint.zero, size: fittingSize)
        fittingAttributes.bounds = fittingBounds
        
        cell.prepareForReuse()
        delegateUnwrapped.setup(cell: cell, at: indexPath)
        
        // To make sure that layout updated
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        fittingAttributes.frame = CGRect(origin: origin, size: fittingAttributes.bounds.size)
        let resAttributes = cell.preferredLayoutAttributesFitting(fittingAttributes)
        resAttributes.frame.origin = origin
        
        return resAttributes
    }
    
    /// Calculate attributes for footer
    ///
    /// - Parameters:
    ///   - forSupplementaryViewOfKind: kind of supplementary view
    ///   - indexPath: index path of supplementary view
    ///   - origin: origin of supplementary view frame
    /// - Returns: The layout attributes of the supplementary view. Makes the calculations based on the sizing supplementary view.
    fileprivate func calculateSupplementaryAttributes(forSupplementaryViewOfKind: String, with indexPath: IndexPath, origin: CGPoint) -> UICollectionViewLayoutAttributes {
        let fittingAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: forSupplementaryViewOfKind, with: indexPath)
        fittingAttributes.bounds = .zero
        fittingAttributes.frame = CGRect(origin: origin, size: .zero)
        
        guard let supplementaryClass = delegate?.supplementaryViewClass?(at: indexPath) else {
            Log.error("Unable to find supplementary view class")
            return fittingAttributes
        }
        
        guard let cell = FullWidthAutoresizedCellFlowLayout.findSizingCell(for: supplementaryClass) else {
            Log.error("Unable to find supplementary view cell in provided nib for '\(supplementaryClass)'")
            return fittingAttributes
        }
        
        let fittingSize = CGSize(width: collectionView?.bounds.size.width ?? 0, height: UIScreen.main.bounds.size.height)
        let fittingBounds = CGRect(origin: CGPoint.zero, size: fittingSize)
        fittingAttributes.bounds = fittingBounds
        
        // To make sure that layout updated
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        fittingAttributes.frame = CGRect(origin: origin, size: fittingAttributes.bounds.size)
        let resAttributes = cell.preferredLayoutAttributesFitting(fittingAttributes)
        resAttributes.frame.origin = origin
        
        return resAttributes
    }
}

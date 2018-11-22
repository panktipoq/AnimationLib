//
//  UITableViewCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/4/16.
//
//

import Foundation
import UIKit

/**
     This protocol declares convenience methods that provide the nib name and the reuseIdentifier for a view.
 */

public protocol PoqReusableView: AnyObject {
    /// By default Nib will be searched in correponded bundles, name - class name
    static var poqNib: UINib? { get }
    
    /// Default value is class name
    static var poqReuseIdentifier: String { get }
}

extension PoqReusableView {

    /**
         This default implementation of this computed variable uses the `NibInjectionResolver` static method `findNib` to find a nib with the same name as the class that it is called on and returns one if it does find it or returns nil if it does not.
     */
    @nonobjc
    public static var poqNib: UINib? {
        let nibFileName = String(describing: self)
        return NibInjectionResolver.findNib(nibFileName)
    }
}

extension UITableViewCell: PoqReusableView {

    /**
         This implementation of this computed variable for `UITableViewCell` returns the name of the class it is called for.
     */
    @nonobjc
    open class var poqReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    /**
         Convenience API for batch registration of cell classes.
         - paramenter cellClasses: array of `UITabLeViewCell` subclasses. Also every class must be confirmed to
     */
    @nonobjc
    public func registerPoqCells(cellClasses classes: [UITableViewCell.Type]) {
        for cellClass in classes {
            register(cellClass.poqNib, forCellReuseIdentifier: cellClass.poqReuseIdentifier)
        }
        
        // Failover scenario:
        register(NotFoundContentTableViewCell.poqNib, forCellReuseIdentifier: NotFoundContentTableViewCell.poqReuseIdentifier)
    }
    
    /**
         Convinience API to deque cell classes. This method tries to cast the `UITableViewCell` to the given type and returns a nil if it cannot.
         - paramenter cellClasses: array of UITabLeViewCell subclasses. Also every class must be confirmed to
     */
    @nonobjc
    public func dequeueReusablePoqCell<V: PoqReusableView>() -> V? {
        return dequeueReusableCell(withIdentifier: V.poqReuseIdentifier) as? V
    }
    
    /**
         Convinience API to deque `NotFoundContentTableViewCell`.
     */
    public func dequeueContentNotFoundCell() -> NotFoundContentTableViewCell {
        return dequeueReusablePoqCell()!
    }
    
    /**
         Convenience method to to deque cells. This method tries to cast the `UITableViewCell` to the given type that conforms to `PoqReusableView`.
     
         **WARNING:** This method assumes that the cell was registered using `PoqReusableView.poqReuseIdentifier`. If the cell cannot be casted to the provided type it will throw an exception.
         - parameter forIndexPath: The indexPath of the cell.
     */
    @nonobjc
    public func dequeueReusablePoqCell<V: PoqReusableView>(forIndexPath indexPath: IndexPath) -> V {
        // We use here '!'. But with this identifier can be registered only this cell. No other options
        return dequeueReusableCell(withIdentifier: V.poqReuseIdentifier, for: indexPath) as! V
    }
}

extension UICollectionViewCell: PoqReusableView {
    /**
         This implementation of this computed variable for `UICollectionViewCell` returns the name of the class it is called for.
     */
    @nonobjc
    open class var poqReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    /**
         Convenience API for batch registration of cell classes.
         - paramenter cellClasses: array of `UICollectionViewCell` subclasses. Also every class must be confirmed to
     */
    @nonobjc
    public func registerPoqCells(cellClasses classes: [UICollectionViewCell.Type]) {
        for cellClass in classes {
            register(cellClass.poqNib, forCellWithReuseIdentifier: cellClass.poqReuseIdentifier)
        }
        
        // Failover scenario:
        register(NotFoundContentCollectionViewCell.poqNib, forCellWithReuseIdentifier: NotFoundContentCollectionViewCell.poqReuseIdentifier)
    }
    
    /**
         Convenience API to deque cell classes. This method tries to cast the `UICollectionViewCell` to the given type and returns a nil if it cannot.
         - paramenter cellClasses: array of `UICollectionViewCell` subclasses. Also every class must be confirmed to
     */
    @nonobjc
    public func registerPoqCell(_ cellClass: UICollectionViewCell.Type, forSupplementaryViewOfKind kind: String) {
        register(cellClass.poqNib, forSupplementaryViewOfKind: kind, withReuseIdentifier: cellClass.poqReuseIdentifier)
    }
    
    /**
         Convenience method to to deque cells. This method tries to cast the `UICollectionViewCell` to the given type that conforms to `PoqReusableView`.
     
         **WARNING:** This method assumes that the cell was registered using `PoqReusableView.poqReuseIdentifier`. If the cell cannot be casted to the provided type it will throw an exception.
         - parameter forIndexPath: The indexPath of the cell.
     */
    @nonobjc
    public func dequeueReusablePoqCell<V: PoqReusableView>(forIndexPath indexPath: IndexPath) -> V {
        return dequeueReusableCell(withReuseIdentifier: V.poqReuseIdentifier, for: indexPath) as! V
    }
    
    /**
         Convinience API to deque `NotFoundContentCollectionViewCell`.
     */
    @nonobjc
    public func dequeueContentNotFoundCell(forIndexPath indexPath: IndexPath) -> NotFoundContentCollectionViewCell {
        return dequeueReusablePoqCell(forIndexPath: indexPath)
    }
    
    /**
     Convenience method to to deque supplementary cells. This method tries to cast the `UICollectionViewCell` to the given type that conforms to `PoqReusableView`.
     
     **WARNING:** This method assumes that the cell was registered using `PoqReusableView.poqReuseIdentifier`. If the cell cannot be casted to the provided type it will throw an exception.
     - parameter forIndexPath: The indexPath of the cell.
     */
    @nonobjc
    public func dequeueReusablePoqSupplementaryViewOfKind<V: PoqReusableView>(_ kind: String, forIndexPath indexPath: IndexPath) -> V {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: V.poqReuseIdentifier, for: indexPath) as! V
    }
}

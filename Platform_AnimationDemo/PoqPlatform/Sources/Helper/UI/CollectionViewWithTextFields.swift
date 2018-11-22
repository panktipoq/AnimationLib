//
//  CollectionViewWithTextFields.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 04/03/2017.
//
//

import Foundation

public protocol CollectionViewWithTextFields {
    
    var collectionView: UICollectionView? { get }
    
    func resizeCollectionViewForKeyboardWillShow(_ notification: Notification, top: CGFloat?)
    
    func resizeCollectionViewForKeyboardWillHide(_ notification: Notification)
}

extension CollectionViewWithTextFields {
    
    
    // MARK: Keyboard will be shown and collectionview will be pushed up.
    public func resizeCollectionViewForKeyboardWillShow(_ notification: Notification, top: CGFloat? = nil) {
        
        guard let userInfo = notification.userInfo, let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let editingIndexPath = indexPathOfFirstResponderCell()
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let keyboardOffset = frameValue.cgRectValue.size.height
        
        let topInset = top ?? (collectionView?.contentInset.top ?? 0)
        let insets = UIEdgeInsets(top: topInset, left: 0, bottom: keyboardOffset, right: 0)
        
        UIView.animate(withDuration: animationDuration) {
            self.collectionView?.contentInset = insets
            self.collectionView?.scrollIndicatorInsets = insets
        }
        
        if let indexPath = editingIndexPath {
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
        
    }
    
    // MARK: Keyboard will be hidden and collection view will be reset
    public func resizeCollectionViewForKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: animationDuration, animations: {
            () -> Void in
            //for handling navigation bar
            self.collectionView?.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0)
            self.collectionView?.scrollIndicatorInsets = UIEdgeInsets.zero
        })
    }
    
    /**
     Return cell with text field on it, which is first responder now
     */
    fileprivate func indexPathOfFirstResponderCell() -> IndexPath? {
        
        guard let indexPaths: [IndexPath] = collectionView?.indexPathsForVisibleItems else {
            return nil
        }
        
        for indexPath in indexPaths {
            
            let boolOrNil = collectionView?.cellForItem(at: indexPath)?.containtFirstResponderTextField()
            
            if boolOrNil == true {
                return indexPath
            }
        }
        
        
        return nil
    }
}

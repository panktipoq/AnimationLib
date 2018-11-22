//
//  WishListGridCellView.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 12/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

class WishListGridCellView: UICollectionViewCell {
    
    // IB Outlets
    @IBOutlet weak var imageView: PoqAsyncImageView?
    @IBOutlet weak var wishListCloseButton: WishListCloseButton?

    // Editing mode 
    var isInEditingMode = false
    
    // Delegate for deleting the current cell
    var delegate: WishlistCellDelegate?
    var wishListItem: PoqProduct?
    var index: Int?
    
    // Called when the cell is on Screen
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Product detail click event
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(WishListGridCellView.imageClicked(_:)))
        imageView?.addGestureRecognizer(imageTapGesture)

    }
    
    // Update image for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.prepareForReuse()
    }
    
    func updateView() {
        
        wishListCloseButton?.isHidden = !isInEditingMode
        imageView?.alpha = isInEditingMode ? 0.8 : 1
    }
      
    @objc func imageClicked(_ gesture: UITapGestureRecognizer) {
        
        if !isInEditingMode {
            
            Log.verbose("Open product for wishlist item \(String(describing: wishListItem?.title)) - \(String(describing: index))")
            
            if let selectedProductId = wishListItem?.id {
                
                if let selectedExternalId = wishListItem?.externalID {
                    
                    NavigationHelper.sharedInstance.loadProduct(selectedProductId, externalId: selectedExternalId, isModal: false, isViewAnimated: true, source: ViewProductSource.wishlistGrid.rawValue, productTitle: wishListItem?.title)
                }
            }
        }
        
    }
    
    @IBAction func wishListCloseButtonClicked(_ sender: Any?) {
        
        if let deleteDelegate = delegate, let listItem = wishListItem, let listItemIndex = index {
            
            Log.verbose("Remove product for wishlist item \(String(describing: listItem.title)) - \(listItemIndex)")
            deleteDelegate.remove(listItem, index: listItemIndex)
        }

    }

}

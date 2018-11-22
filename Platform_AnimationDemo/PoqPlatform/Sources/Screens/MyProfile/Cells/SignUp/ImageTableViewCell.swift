//
//  ImageTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Table view cell containing a imageview. TODO: Make this cell a generic image view rendering cell
class ImageTableViewCell: UITableViewCell {

    /// The image view that renders the card 
    @IBOutlet weak var cardImageView: PoqAsyncImageView?
    
    /// Sets up the image of the card
    ///
    /// - Parameter urlString: The url of the card image
    func setUpImage(_ urlString: String?) {
        guard let urlString = urlString, let url =  URL(string: urlString) else {
            return
        }
        
        self.cardImageView?.getImageFromURL(url, isAnimated: true, resetConstraints: true)
    }
    
    /// Prepares the cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cardImageView?.prepareForReuse()
    }
}

// MARK: - MyProfileCell implements
extension ImageTableViewCell: MyProfileCell {

    /// Updates the UI of the cell
    ///
    /// - Parameters:
    ///   - item: The content item used to populate the cell
    ///   - delegate: The delegate used to make the calls resulted from the cell actions
    func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        setUpImage(item.firstInputItem.value)
    }
}

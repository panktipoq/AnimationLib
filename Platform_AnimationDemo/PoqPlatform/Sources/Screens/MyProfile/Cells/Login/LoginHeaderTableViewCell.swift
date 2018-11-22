//
//  LoginHeaderTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 26/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Protocol for login header actions
public protocol LoginHeaderTableViewCellDelegate: AnyObject {
    
     /// Triggered when the header in the login table is tapped
     func imageTapped()
}

/// Cell rendering the header of the login screen
class LoginHeaderTableViewCell: UITableViewCell {

    /// The imageview that renders the header
    @IBOutlet weak var headerImageView: PoqAsyncImageView?
    
    /// The title of the header
    @IBOutlet weak var titleLabel: UILabel?
    
    /// The delegate on which actions will be sent to
    weak var delegate: LoginHeaderTableViewCellDelegate?
    
    /// Triggered when the view is generated from a xib. Sets up the header image view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let imageView = self.headerImageView {
            let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginHeaderTableViewCell.imageTapped(_:)))
            imageView.addGestureRecognizer(imageTapGesture)
            
            imageView.clipsToBounds = true
        }
    }
    
    /// Prepares the cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        headerImageView?.prepareForReuse()
        titleLabel?.attributedText = nil
    }
    
    /// Triggered when the image has been tapped
    ///
    /// - Parameter sender: The object that triggered the action
    @objc func imageTapped(_ sender: UIGestureRecognizer) {
        delegate?.imageTapped()
    }
    
}

// MARK: - LoginHeaderTableViewCell implementation of MyProfileCell
extension LoginHeaderTableViewCell: MyProfileCell {
    
    /// Updates the UI for a given cell
    ///
    /// - Parameters:
    ///   - item: The content item that is used as the backbone for this cell
    ///   - delegate: The delegate that receives the cell actions
    func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        
        if let title = item.firstInputItem.title, AppSettings.sharedInstance.shouldLoginHeaderBeShown {
            self.titleLabel?.attributedText = LabelStyleHelper.initLoginHeaderPlatformLabel(title: title)
        }
        
        if let urlString = item.firstInputItem.value, let imageURL = URL(string: urlString) {
            self.headerImageView?.getImageFromURL(imageURL, isAnimated: true)
        }
    }
}

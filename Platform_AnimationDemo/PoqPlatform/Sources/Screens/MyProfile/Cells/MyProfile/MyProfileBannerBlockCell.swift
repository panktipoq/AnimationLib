//
//  MyProfileBannerBlockCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 5/4/16.
//
//

import PoqNetworking
import UIKit

/// Content block handling the my profile banner in the my profile section
open class MyProfileBannerBlockCell: FullWidthAutoresizedCollectionCell, PoqLinkBlock, PoqMyProfileListReusableView {
    
    /// The presenter for the banner cell
    weak public var presenter: PoqMyProfileListPresenter?
    
    /// The height constraint for the cell
    weak var heightCellConstraint: NSLayoutConstraint?
    
    /// The banner image for the cell
    @IBOutlet open weak var bannerImage: PoqAsyncImageView?
    
    /// The title label of the cell
    @IBOutlet open weak var titleLabel: UILabel?
    
    /// The subtitle label of the cell
    @IBOutlet open weak var subtitleLabel: UILabel?
    
    /// Gesture recognizer that listens to tap gestures on the header
    var tapRecognizer: UITapGestureRecognizer?
    
    /// The deep link that this header accesses when tapped
    open var deepLinkURL: String?
    
    /// Triggered when the cell is created from the xib
    override open func awakeFromNib() {
        super.awakeFromNib()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileBannerBlockCell.didSelect(_:)))
        addGestureRecognizer(tapRecognizer)
        self.tapRecognizer = tapRecognizer
        
    }
    
    /// Sets the image url for for the banner block
    ///
    /// - Parameter imageURL: The url to the image that the banner will display
    open func setLinkImage(_ imageURL: String?) {
        guard let image = imageURL, let imageView = bannerImage, !image.isNullOrEmpty() else {
            return
        }
        setImage(imageURL, imageView: imageView)
    }
    
    /// Triggered when the banner has been selected
    ///
    /// - Parameter gesture: The gesture type that triggered the action
    @objc func didSelect(_ gesture: UIGestureRecognizer) {
        openLink(deepLinkURL)
    }
    
    /// Updates the size of the of the cell accordingly to the block object
    ///
    /// - Parameter block: The block object used as a backbone for the cell
    open func updateSize(using block: PoqBlock) {
        let cellHeight = ImageResizerHelper().resizeMyProfileImage(CGFloat(block.pictureWidth), pictureOriginalHeight: CGFloat(block.pictureHeight)).height
        
        if let validHeightCellConstraint = heightCellConstraint {
            validHeightCellConstraint.isActive = false
            validHeightCellConstraint.constant = cellHeight
            validHeightCellConstraint.isActive = true
        } else {
            heightCellConstraint = contentView.heightAnchor.constraint(equalToConstant: cellHeight)
            heightCellConstraint?.priority = UILayoutPriority(rawValue: 999.0)
            heightCellConstraint?.isActive = true
        }
        
    }
    
    /// Sets up the visuals of the cell
    ///
    /// - Parameters:
    ///   - content: The content item that holds the information for this cell
    ///   - presenter: The presenter that will be used as a delegate for this cell's actions
    open func setup(using content: PoqMyProfileListContentItem, cellPresenter presenter: PoqMyProfileListPresenter) {
        guard let block = content.block, let pictureURL = block.pictureURL else {
            return
        }
        
        updateSize(using: block)
        setLinkImage(pictureURL)
        deepLinkURL = block.link
        
        if LoginHelper.isLoggedIn() {
            
            guard let account: PoqAccount = LoginHelper.getAccounDetails() else {
                return
            }
            titleLabel?.text = "WELCOME".localizedPoqString
            
            var fullName = ""
            
            if let firstName = account.firstName {
                fullName.append(firstName)
            }
            
            if let lastName = account.lastName {
                if fullName.count > 0 { // have appended firstName
                    fullName.append(" ")
                }
                fullName.append(lastName)
            }
            
            subtitleLabel?.text = fullName
            
        } else {
            
            titleLabel?.text = ""
            subtitleLabel?.text = ""
            
        }
    }
}

//
//  MyProfileLinkViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

/// A profile content block containing a imageview and a title label. Used specifically to open a given deeplink
open class MyProfileLinkViewCell: FullWidthAutoresizedCollectionCell, PoqLinkBlock, PoqCollectionCellHighlighter, PoqMyProfileListReusableView {
    
    /// The presenter on which the my profile actions will be called
    weak public var presenter: PoqMyProfileListPresenter?

    /// The height of the my profile cell
    static let Height: CGFloat = CGFloat(AppSettings.sharedInstance.myProfileLinkViewCellHeight)
    
    /// The deepLink url that will be called upon tapping
    open var deepLinkURL: String?
    
    /// The constraint of the width of the icon imageview
    @IBOutlet weak var iconWidth: NSLayoutConstraint?
    
    /// The left constraint of the title label
    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint?
    
    /// The left constraint of the icon imageview
    @IBOutlet weak var iconLeft: NSLayoutConstraint?
    
    /// The icon imageview
    @IBOutlet weak var icon: PoqAsyncImageView?
    
    /// The cell's title label
    @IBOutlet weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.font = AppTheme.sharedInstance.profileLinkTitleFont
            titleLabel?.textColor = AppTheme.sharedInstance.profileLinkTitleLabelTextColor
        }
    }

    /// Triggered when the view is created from the xib
    override open func awakeFromNib() {
        super.awakeFromNib()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileLinkViewCell.didSelect(_:)))
        addGestureRecognizer(tapRecognizer)
        
        contentView.heightAnchor.constraint(equalToConstant: MyProfileLinkViewCell.Height).isActive = true
    }
    
    /// Triggered when the icon's image is set
    ///
    /// - Parameter imageURL: The icon's image url
    func setLinkImage(_ imageURL: String?) {
        
        guard let image = imageURL, !image.isNullOrEmpty() else {
            
            hideIcon()
            return
        }

        showIcon()
        setImage(imageURL, imageView: icon)
    }
    
    /// Hides the icon of the cell 
    func hideIcon() {

        iconLeft?.constant = 0.0
        iconWidth?.constant = 0.0
        titleLabelLeft?.constant = AppSettings.sharedInstance.profileLinkCellLeftAlignment
    }
    
    /// Shows the icon of the cell
    func showIcon() {
        
        iconLeft?.constant = AppSettings.sharedInstance.profileLinkCellLeftAlignment
        iconWidth?.constant = 44.0
        titleLabelLeft?.constant = 10.0
    }
    
    /// Triggered when the cell has been selected. Opens the deep link
    ///
    /// - Parameter gesture: The gesture that triggered this action
    @objc open func didSelect(_ gesture: UIGestureRecognizer) {
        
        openLink(deepLinkURL)
        highlightDidTap(self, duration: 0.1, color: UIColor.groupTableViewBackground)
    }
    
    /// Sets up the visuals for the cell
    ///
    /// - Parameters:
    ///   - content: The content item that is used to populate the block
    ///   - presenter: The presenter on which the my profile actions will be called
    public func setup(using content: PoqMyProfileListContentItem, cellPresenter presenter: PoqMyProfileListPresenter) {
        
        guard let block = content.block else {
            return
        }
        setLinkImage(block.pictureURL)
        setTitle(block.title, titleLabel: titleLabel)
        deepLinkURL = block.link
        
    }
}

//
//  MyProfileSeperatorViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

/// Cell with no content used to separate areas
class MyProfileSeperatorViewCell: FullWidthAutoresizedCollectionCell, PoqMyProfileListReusableView {

    /// The presenter on which this cell is rendered
    weak public var presenter: PoqMyProfileListPresenter?

    /// The height of the cell
    static let Height: CGFloat = CGFloat(MyProfileSettings.myProfileSeperatorHeight)
    
    /// Triggered when the cell is created from xib
    override func awakeFromNib() {
        super.awakeFromNib()
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: MyProfileSeperatorViewCell.Height)
        heightConstraint.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint.isActive = true
    }
    
    /// Sets up the cell content. Implementation is a stub
    ///
    /// - Parameters:
    ///   - content: The content item used to populate the cell
    ///   - cellPresenter: The cell presenter on which the cell is rendered
    func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter) {
        // nothing to do here
    }
}
